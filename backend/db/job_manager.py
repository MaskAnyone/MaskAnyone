import json
import logging
import uuid

from fastapi import HTTPException

from db.db_connection import DBConnection
from db.model.job import Job

logger = logging.getLogger(__name__)


class JobManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def fetch_jobs(self, user_id: str) -> list[Job]:
        job_data_list = self.__db_connection.select_all(
            "SELECT * FROM jobs WHERE user_id=%(user_id)s ORDER BY created_at DESC",
            {"user_id": user_id},
        )

        return [Job(*job_data) for job_data in job_data_list]

    def create_new_jobs(
        self,
        id: str,
        video_ids: list[str],
        result_video_id: str,
        data: dict,
        job_type: str,
        user_id: str,
    ) -> None:
        for idx, video_id in enumerate(video_ids):
            job_id = id if idx == 0 else str(uuid.uuid4())
            self.__db_connection.execute(
                "INSERT INTO jobs (id, video_id, result_video_id, type, status, data, created_at, user_id) VALUES (%(id)s, %(video_id)s, %(result_video_id)s, %(type)s, %(status)s, %(data)s, current_timestamp, %(user_id)s)",
                {
                    "id": job_id,
                    "video_id": video_id,
                    "result_video_id": result_video_id,
                    "type": job_type,
                    "status": "open",
                    "data": json.dumps(data),
                    "user_id": user_id,
                },
            )

    def reclaim_orphaned_jobs(self) -> int:
        """Reset jobs stuck in 'running' because their worker died or restarted.

        A job is orphaned when:
          - status='running', AND
          - started_at is older than 10s (grace for the tiny race between marking
            the job running and the worker writing its job_id), AND
          - no active worker (pinged within 3 min) holds a reference to it.

        Resets the row so any worker (including a freshly-restarted one) can
        pick it up again. Also clears `job_id` on stale workers so the /workers
        UI doesn't show them hung on ghost assignments.

        Returns the number of jobs reclaimed. Called from fetch_next_job, so
        every poll self-heals — no dedicated cron needed.
        """
        cursor = self.__db_connection.get_cursor()
        try:
            cursor.execute("BEGIN")
            cursor.execute(
                """
                UPDATE jobs
                   SET status='open', started_at=NULL, progress=0, phase=NULL
                 WHERE status='running'
                   AND started_at < NOW() - INTERVAL '10 SECONDS'
                   AND NOT EXISTS (
                       SELECT 1 FROM workers w
                        WHERE w.job_id = jobs.id
                          AND w.last_activity > NOW() - INTERVAL '3 MINUTES'
                   )
                RETURNING id
                """
            )
            reclaimed_rows = cursor.fetchall()
            cursor.execute(
                """
                UPDATE workers
                   SET job_id=NULL
                 WHERE last_activity <= NOW() - INTERVAL '3 MINUTES'
                   AND job_id IS NOT NULL
                """
            )
            cursor.execute("COMMIT")

            if reclaimed_rows:
                reclaimed_ids = [row[0] for row in reclaimed_rows]
                logger.warning(
                    "Reclaimed %d orphaned job(s) back to 'open': %s",
                    len(reclaimed_ids),
                    reclaimed_ids,
                )
            return len(reclaimed_rows)
        except Exception:
            cursor.execute("ROLLBACK")
            logger.exception("Error reclaiming orphaned jobs")
            raise
        finally:
            cursor.close()

    def fetch_next_job(self) -> Job | None:
        # Self-heal: before claiming a new job, reset any orphaned 'running' rows.
        # Cheap (indexed query, usually a no-op), runs on every worker poll.
        try:
            self.reclaim_orphaned_jobs()
        except Exception:
            # Never block job fetching on a sweep failure — log and continue.
            logger.exception("reclaim_orphaned_jobs failed, continuing to fetch anyway")

        cursor = self.__db_connection.get_cursor()
        jobs = []

        try:
            cursor.execute("BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ")
            cursor.execute(
                "SELECT * FROM jobs WHERE status=%(status)s LIMIT 1",
                {"status": "open"},
            )
            jobs = cursor.fetchall()

            if len(jobs) > 0:
                cursor.execute(
                    "UPDATE jobs SET status=%(status)s, started_at=current_timestamp WHERE id=%(id)s",
                    {"status": "running", "id": jobs[0][0]},
                )

            cursor.execute("COMMIT")
        except Exception:
            cursor.execute("ROLLBACK")
            logger.exception("Error fetching next job")
            raise
        finally:
            cursor.close()

        return None if len(jobs) < 1 else Job(*jobs[0])

    def fetch_job_by_result_video_id(self, result_video_id: str) -> Job:
        job_data_list = self.__db_connection.select_all(
            "SELECT * FROM jobs WHERE result_video_id=%(result_video_id)s",
            {"result_video_id": result_video_id},
        )

        if len(job_data_list) < 1:
            raise HTTPException(
                status_code=404,
                detail=f"No job found for result video {result_video_id}",
            )

        return Job(*job_data_list[0])

    def update_job_progress(self, job_id: str, progress: int, phase: str | None = None) -> None:
        # Keep phase column untouched when caller doesn't supply one — prevents blanking
        # the phase on mid-phase progress ticks.
        if phase is None:
            self.__db_connection.execute(
                "UPDATE jobs SET progress=%(progress)s WHERE id=%(id)s",
                {"progress": progress, "id": job_id},
            )
        else:
            self.__db_connection.execute(
                "UPDATE jobs SET progress=%(progress)s, phase=%(phase)s WHERE id=%(id)s",
                {"progress": progress, "phase": phase, "id": job_id},
            )

    def mark_job_as_finished(self, job_id: str) -> None:
        # Don't flip a cancelled job to finished — the cancel wins even if the worker
        # happens to complete the in-flight phase before noticing.
        self.__db_connection.execute(
            "UPDATE jobs SET status=%(status)s, finished_at=current_timestamp, progress=100 "
            "WHERE id=%(id)s AND status <> 'cancelled'",
            {"status": "finished", "id": job_id},
        )

    def mark_job_as_failed(self, job_id: str) -> None:
        # Guard: don't clobber a cancelled job with 'failed' if a worker exits via
        # JobCancelled → worker_process's exception handler.
        self.__db_connection.execute(
            "UPDATE jobs SET status=%(status)s, finished_at=current_timestamp, progress=100 "
            "WHERE id=%(id)s AND status <> 'cancelled'",
            {"status": "failed", "id": job_id},
        )

    def mark_job_as_cancelled(self, job_id: str) -> None:
        self.__db_connection.execute(
            "UPDATE jobs SET status=%(status)s, finished_at=current_timestamp WHERE id=%(id)s",
            {"status": "cancelled", "id": job_id},
        )

    def get_job_status(self, job_id: str) -> str:
        return self.get_job(job_id).status

    def get_job(self, job_id: str) -> Job:
        job_data_list = self.__db_connection.select_all(
            "SELECT * FROM jobs WHERE id=%(id)s",
            {"id": job_id},
        )

        if len(job_data_list) < 1:
            raise HTTPException(
                status_code=404,
                detail=f"Job {job_id} not found",
            )

        return Job(*job_data_list[0])

    def delete_job(self, job_id: str) -> None:
        self.__db_connection.execute(
            "DELETE FROM jobs WHERE id=%(id)s",
            {"id": job_id},
        )

    def get_result_video_id(self, job_id: str) -> str:
        return self.get_job(job_id).result_video_id

    def get_video_id(self, job_id: str) -> str:
        return self.get_job(job_id).video_id
