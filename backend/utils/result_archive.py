"""Zip archives of results: one result, or all results of a video.

Layout of one result folder (files that a result does not have are left out):

    <stem>/
        <stem>.mp4                      masked video
        <stem>_qa.json                  mask QA report
        <stem>_poses.json               post-processed pose keypoints
        <stem>_sam2-masks.npz           raw SAM2 masks
        <stem>_kinematics-<type>.json   MediaPipe kinematics (basic masking)
        <stem>_kinematics-<type>.csv
        <stem>_blendshapes.json
        <stem>_voice.mp3
        masking_config.json             job type, times and the full config
        README.txt                      what is in the folder, per-person strategies

The video archive puts one such folder per result under
`<video stem>_results/`. The original (unmasked) video is never included.

Archives are written to a temporary file (videos can be large) that the caller
deletes after sending.
"""

import csv
import io
import json
import os
import tempfile
import zipfile

from config import RESULT_BASE_PATH
from utils.result_naming import (
    HIDING_LABELS,
    OVERLAY_LABELS,
    SAM_MODEL_LABELS,
    extra_file_name,
    resolve_names_for_video,
    result_stem,
    video_stem,
)

# Already-compressed formats are stored as is; deflating them wastes CPU.
_STORED_EXTENSIONS = (".mp4", ".mp3", ".npz", ".png")

EXTRA_FILE_DESCRIPTIONS = {
    "qa": "mask QA report (per-frame mask coverage and suspect frames)",
    "poses": "post-processed pose keypoints per person and frame",
    "sam2_masks": "raw SAM2 segmentation masks (NumPy .npz)",
}


def mp_kinematics_csv_chunks(json_data):
    """Yield MediaPipe kinematics as CSV text, one row per timestamp."""
    entries_with_landmarks = [e for e in json_data if e['data']['landmarks']]
    entries_with_world = [e for e in json_data if e['data']['world_landmarks']]
    max_poses = max((len(e['data']['landmarks']) for e in entries_with_landmarks), default=0)
    max_landmarks_per_pose = max(
        (max(len(pose) for pose in e['data']['landmarks']) for e in entries_with_landmarks), default=0
    )
    max_world_landmarks_per_pose = max(
        (max(len(pose) for pose in e['data']['world_landmarks']) for e in entries_with_world), default=0
    )

    columns = ['timestamp']
    for pose in range(max_poses):
        for lm in range(max_landmarks_per_pose):
            columns += [f'pose_{pose}_landmark_{lm}_{f}' for f in ('x', 'y', 'z', 'visibility', 'presence')]
        for wlm in range(max_world_landmarks_per_pose):
            columns += [f'pose_{pose}_world_landmark_{wlm}_{f}' for f in ('x', 'y', 'z', 'visibility', 'presence')]

    buffer = io.StringIO()
    writer = csv.writer(buffer)

    def flush():
        text = buffer.getvalue()
        buffer.seek(0)
        buffer.truncate(0)
        return text

    writer.writerow(columns)
    yield flush()

    for entry in json_data:
        row = [entry['timestamp']]
        for pose in entry['data']['landmarks']:
            for lm in pose:
                row += [lm.get(f, '') for f in ('x', 'y', 'z', 'visibility', 'presence')]
            row += [''] * (max_landmarks_per_pose - len(pose)) * 5
        row += [''] * ((max_poses - len(entry['data']['landmarks'])) * max_landmarks_per_pose * 5)

        for pose in entry['data']['world_landmarks']:
            for wlm in pose:
                row += [wlm.get(f, '') for f in ('x', 'y', 'z', 'visibility', 'presence')]
            row += [''] * (max_world_landmarks_per_pose - len(pose)) * 5
        row += [''] * ((max_poses - len(entry['data']['world_landmarks'])) * max_world_landmarks_per_pose * 5)

        writer.writerow(row)
        yield flush()


def _json_bytes(data) -> bytes:
    if isinstance(data, (bytes, bytearray, memoryview)):
        return bytes(data)
    if isinstance(data, str):
        return data.encode("utf-8")
    return json.dumps(data, indent=2, default=str).encode("utf-8")


def _format_time(value) -> str:
    if not value:
        return "-"
    return str(value).replace("T", " ")[:16] + " UTC"


def _person_lines(job) -> list[str]:
    if job is None or job.type != "sam2_masking":
        return []
    video_masking = (job.data or {}).get("videoMasking") or {}
    hiding = list(video_masking.get("hidingStrategies") or [])
    overlay = list(video_masking.get("overlayStrategies") or [])
    people = max(len(hiding), len(overlay))
    lines = []
    for i in range(people):
        h = hiding[i] if i < len(hiding) else "none"
        o = overlay[i] if i < len(overlay) else "none"
        hiding_label = HIDING_LABELS.get(h or "none", h)
        overlay_label = OVERLAY_LABELS.get(o or "none", o) or "no overlay"
        lines.append(f"  Person {i + 1}: hiding = {hiding_label}, overlay = {overlay_label}")
    return lines


def _readme(video, result, result_name, job, refined_from_name, files) -> str:
    lines = [
        f"Result:   {result_name}",
        f"Video:    {video.name}",
        f"Created:  {_format_time(result.created_at)}",
    ]
    if job is not None:
        video_masking = (job.data or {}).get("videoMasking") or {}
        lines.append(f"Job type: {job.type}")
        if job.type == "sam2_masking":
            sam_model = video_masking.get("samModel") or "sam2.1_hiera_small"
            lines.append(f"SAM model: {SAM_MODEL_LABELS.get(sam_model, sam_model)}")
            chunk = video_masking.get("chunkSizeSeconds")
            lines.append(
                f"Chunking: {chunk} s chunks, {video_masking.get('chunkOverlapSeconds', 0)} s overlap"
                if chunk else "Chunking: single pass"
            )
            lines.append(f"Motion traces: {'on' if video_masking.get('motionTraces') else 'off'}")
        elif job.type == "basic_masking":
            lines.append(f"Strategy: {video_masking.get('strategy', '-')}")
        voice = ((job.data or {}).get("voiceMasking") or {}).get("strategy")
        if voice:
            lines.append(f"Voice:    {voice}")
    if refined_from_name:
        lines.append(f"Refined from: {refined_from_name}")

    person_lines = _person_lines(job)
    if person_lines:
        lines += ["", "Strategies per person:"] + person_lines

    lines += ["", "Files:"]
    lines += [f"  {name}  -  {description}" for name, description in files]
    lines += [
        "  masking_config.json  -  full masking config (enough to reproduce or refine this result)",
        "",
        "Times are UTC. The original, unmasked video is not included.",
        "",
    ]
    return "\n".join(lines)


def _write_result_folder(zf: zipfile.ZipFile, folder: str, video, result, names: dict, job, sources: dict) -> None:
    result_id = str(result.id)
    stem = result_stem(video.name, names[result_id])
    files = []  # (file name, description) for the README
    used = set()

    def add_bytes(file_name: str, data: bytes, description: str):
        base, ext = os.path.splitext(file_name)
        counter = 2
        while file_name in used:
            file_name = f"{base}-{counter}{ext}"
            counter += 1
        used.add(file_name)
        compress = zipfile.ZIP_STORED if file_name.endswith(_STORED_EXTENSIONS) else zipfile.ZIP_DEFLATED
        zf.writestr(f"{folder}/{file_name}", data, compress_type=compress)
        files.append((file_name, description))

    video_path = os.path.join(RESULT_BASE_PATH, str(result.video_id), f"{result_id}.mp4")
    if os.path.exists(video_path):
        file_name = f"{stem}.mp4"
        used.add(file_name)
        zf.write(video_path, f"{folder}/{file_name}", compress_type=zipfile.ZIP_STORED)
        files.append((file_name, "masked video"))

    extra_manager = sources["result_extra_files_manager"]
    for entry in extra_manager.find_entries(result_id):
        extra = extra_manager.fetch_result_extra_files_entry(str(entry["id"]))
        add_bytes(
            extra_file_name(stem, entry["type"]),
            bytes(extra.data),
            EXTRA_FILE_DESCRIPTIONS.get(entry["type"], f"additional output ({entry['type']})"),
        )

    kinematics_manager = sources["result_mp_kinematics_manager"]
    for kinematics_id, kinematics_type in kinematics_manager.find_entries(result_id):
        kinematics = kinematics_manager.fetch_result_mp_kinematics_entry(str(kinematics_id))
        add_bytes(f"{stem}_kinematics-{kinematics_type}.json", _json_bytes(kinematics.data),
                  f"MediaPipe {kinematics_type} kinematics (JSON)")
        add_bytes(f"{stem}_kinematics-{kinematics_type}.csv",
                  "".join(mp_kinematics_csv_chunks(kinematics.data)).encode("utf-8"),
                  f"MediaPipe {kinematics_type} kinematics (CSV)")

    blendshapes_manager = sources["result_blendshapes_manager"]
    for blendshapes_id in blendshapes_manager.find_entries(result_id):
        blendshapes = blendshapes_manager.fetch_result_blendshapes_entry(str(blendshapes_id))
        add_bytes(f"{stem}_blendshapes.json", _json_bytes(blendshapes.data), "face blendshapes")

    audio_manager = sources["result_audio_files_manager"]
    for audio_id in audio_manager.find_entries(result_id):
        audio = audio_manager.fetch_result_audio_files_entry(str(audio_id))
        add_bytes(f"{stem}_voice.mp3", bytes(audio.data), "masked voice")

    refined_from = (job.data or {}).get("refinedFrom") if job is not None else None
    config = {
        "result": {
            "id": result_id,
            "name": names[result_id],
            "video_id": str(result.video_id),
            "video_name": video.name,
            "created_at": str(result.created_at),
            "refined_from": refined_from,
        },
        "job": None if job is None else {
            "id": str(job.id),
            "type": job.type,
            "status": job.status,
            "created_at": str(job.created_at),
            "started_at": str(job.started_at),
            "finished_at": str(job.finished_at),
        },
        "config": None if job is None else job.data,
    }
    zf.writestr(f"{folder}/masking_config.json", _json_bytes(config), compress_type=zipfile.ZIP_DEFLATED)

    readme = _readme(video, result, names[result_id], job, names.get(refined_from) if refined_from else None, files)
    zf.writestr(f"{folder}/README.txt", readme.encode("utf-8"), compress_type=zipfile.ZIP_DEFLATED)


def _open_temp_zip():
    fd, path = tempfile.mkstemp(prefix="maskanyone_", suffix=".zip")
    os.close(fd)
    return path, zipfile.ZipFile(path, "w", allowZip64=True)


def _load(video_id: str, sources: dict):
    video = sources["video_manager"].get_video(video_id)
    results = sources["result_video_manager"].fetch_result_videos(video_id)
    names = resolve_names_for_video(video_id, sources["result_video_manager"], sources["job_manager"])
    jobs = sources["job_manager"].fetch_jobs_by_ids([str(r.job_id) for r in results])
    return video, results, names, jobs


def build_result_archive(video_id: str, result_video_id: str, sources: dict) -> tuple[str, str]:
    """Write a zip for one result. Returns (temp file path, download name)."""
    video, results, names, jobs = _load(video_id, sources)
    result = next(r for r in results if str(r.id) == result_video_id)
    stem = result_stem(video.name, names[result_video_id])

    path, zf = _open_temp_zip()
    try:
        with zf:
            _write_result_folder(zf, stem, video, result, names, jobs.get(str(result.job_id)), sources)
    except Exception:
        os.remove(path)
        raise
    return path, f"{stem}.zip"


def build_video_results_archive(video_id: str, sources: dict) -> tuple[str, str]:
    """Write a zip with every result of a video. Returns (temp file path, download name)."""
    video, results, names, jobs = _load(video_id, sources)
    root = f"{video_stem(video.name)}_results"

    path, zf = _open_temp_zip()
    try:
        with zf:
            for result in sorted(results, key=lambda r: str(r.created_at)):
                stem = result_stem(video.name, names[str(result.id)])
                _write_result_folder(zf, f"{root}/{stem}", video, result, names, jobs.get(str(result.job_id)), sources)
            if not results:
                zf.writestr(f"{root}/README.txt", b"This video has no results yet.\n")
    except Exception:
        os.remove(path)
        raise
    return path, f"{root}.zip"
