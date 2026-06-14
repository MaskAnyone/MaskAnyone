class JobCancelled(Exception):
    """Raised by a masker when it notices the job has been cancelled.

    Caught by worker_process so we exit cleanly without marking the job as failed —
    the cancel has already flipped status to 'cancelled' in the DB.
    """
    pass
