"""Human-readable names for result videos and the files downloaded from them.

Display names
-------------
A result's name is generated from its job's masking config when the worker
uploads the result video:

    fresh run:  "Blurring + OpenPose BODY_25 · SAM2 small"
    per person: "P1 Blurring / P2 Solid fill + RTMPose M · SAM2 small"
    refine:     "<source result name> · v2"   (v3, v4 ... for later refines)

Names are unique per source video; a clash gets a " (2)" style suffix. Users
can rename a result afterwards, and refines of a renamed result build on the
new name.

Results created before this naming existed are stored as "Result" (the column
default). They are not rewritten in the database; `resolve_result_names` gives
them a generated name whenever names are read, so the UI, downloads and zips
all agree.

File names
----------
Every downloaded file starts with the same stem:

    <video name>_<result name>          e.g. interview01_blurring-openpose-body-25-sam2-small

followed by a suffix per file type (`_qa.json`, `_kinematics-body.csv`, ...).
Result names are unique per video, so stems are too.
"""

import re
import unicodedata

LEGACY_DEFAULT_NAME = "Result"

HIDING_LABELS = {
    "none": "No hiding",
    "solid_fill": "Solid fill",
    "transparent_fill": "Transparent fill",
    "blurring": "Blurring",
    "pixelation": "Pixelation",
    "contours": "Contours",
}

OVERLAY_LABELS = {
    "none": None,
    "rtmpose_s": "RTMPose S",
    "rtmpose_m": "RTMPose M",
    "rtmpose_l": "RTMPose L",
    "rtmpose_ap10k": "RTMPose AP-10K",
    "rtmpose_ap10k_w48": "RTMPose AP-10K W48",
    "rtmpose_ap10k_rtm": "RTMPose AP-10K RTM",
    "rtmpose_animalpose": "RTMPose AnimalPose",
    "rtmpose_ak_mammal": "RTMPose Animal Kingdom",
    "mp_pose": "MediaPipe Pose",
    "mp_face": "MediaPipe Face",
    "mp_hand": "MediaPipe Hands",
    "openpose": "OpenPose BODY_25",
    "openpose_body25b": "OpenPose BODY_25B",
    "openpose_face": "OpenPose BODY_25 + Face",
    "openpose_body_135": "OpenPose BODY_135",
}

SAM_MODEL_LABELS = {
    "sam2.1_hiera_tiny": "SAM2 tiny",
    "sam2.1_hiera_small": "SAM2 small",
    "sam2.1_hiera_base_plus": "SAM2 base+",
    "sam2.1_hiera_large": "SAM2 large",
}

# Per-person names get unreadable beyond this; fall back to a count.
MAX_PEOPLE_LISTED = 3

# Separator between the main description and the model / version parts.
SEP = " · "

_VERSION_SUFFIX = re.compile(r"^(?P<root>.*)" + re.escape(SEP) + r"v(?P<n>\d+)$")
_COUNTER_SUFFIX = re.compile(r"^(?P<root>.*) \((?P<n>\d+)\)$")


def _label(labels: dict, key, fallback_prefix: str = "") -> str | None:
    if key in labels:
        return labels[key]
    if not key:
        return None
    return f"{fallback_prefix}{key}"


def _person_part(hiding: str | None, overlay: str | None) -> str:
    hiding_label = _label(HIDING_LABELS, hiding or "none")
    overlay_label = _label(OVERLAY_LABELS, overlay or "none")

    if overlay_label is None:
        return hiding_label
    if hiding in (None, "", "none"):
        return f"{overlay_label} only"
    return f"{hiding_label} + {overlay_label}"


def strategy_name(job_type: str, job_data: dict | None) -> str:
    """Describe a job's masking config in a short, readable name."""
    video_masking = (job_data or {}).get("videoMasking") or {}

    if job_type == "sam2_masking":
        hiding = list(video_masking.get("hidingStrategies") or [])
        overlay = list(video_masking.get("overlayStrategies") or [])
        people = max(len(hiding), len(overlay))
        hiding += [None] * (people - len(hiding))
        overlay += [None] * (people - len(overlay))
        parts = [_person_part(h, o) for h, o in zip(hiding, overlay)]

        if not parts:
            main = "No masking"
        elif len(set(parts)) == 1:
            main = parts[0]
        elif len(parts) <= MAX_PEOPLE_LISTED:
            main = " / ".join(f"P{i} {part}" for i, part in enumerate(parts, start=1))
        else:
            main = f"Mixed strategies ({len(parts)} people)"

        if main == "No hiding":
            main = "No masking"

        extras = [_label(SAM_MODEL_LABELS, video_masking.get("samModel") or "sam2.1_hiera_small")]
        if video_masking.get("motionTraces"):
            extras.append("traces")
        return SEP.join([main] + [e for e in extras if e])

    if job_type == "basic_masking":
        strategy = video_masking.get("strategy")
        if strategy:
            return f"Basic {str(strategy).replace('_', ' ')}"
        return "Basic masking"

    return LEGACY_DEFAULT_NAME


def _root_and_version(name: str) -> tuple[str, int]:
    match = _VERSION_SUFFIX.match(name)
    if match:
        return match.group("root"), int(match.group("n"))
    return name, 1


def refined_name(source_name: str, existing_names) -> str:
    """Name for a refine of `source_name`: same root, next free version."""
    root, _ = _root_and_version(source_name)
    highest = 1
    for name in existing_names:
        other_root, version = _root_and_version(name)
        if other_root == root:
            highest = max(highest, version)
    return f"{root}{SEP}v{highest + 1}"


def unique_name(name: str, existing_names) -> str:
    """Return `name`, or `name (2)`, `name (3)` ... if it is already taken."""
    existing = set(existing_names)
    if name not in existing:
        return name
    match = _COUNTER_SUFFIX.match(name)
    root = match.group("root") if match else name
    counter = 2
    while f"{root} ({counter})" in existing:
        counter += 1
    return f"{root} ({counter})"


def new_result_name(job_type: str, job_data: dict | None, existing_names: dict) -> str:
    """Pick the name for a newly finished result.

    `existing_names` maps result id -> current (resolved) name for the other
    results of the same video. A refine of a result that still exists builds
    on that result's name; anything else is named from its strategies.
    """
    refined_from = (job_data or {}).get("refinedFrom")
    if refined_from and refined_from in existing_names:
        name = refined_name(existing_names[refined_from], existing_names.values())
    else:
        name = strategy_name(job_type, job_data)
    return unique_name(name, existing_names.values())


def resolve_result_names(results, jobs_by_id: dict) -> dict:
    """Map result id -> display name for all results of one video.

    Stored names are used as they are. Legacy rows still named "Result" get a
    generated name, assigned oldest first so suffixes are stable.
    """
    names = {}
    legacy = []
    for result in results:
        if result.name == LEGACY_DEFAULT_NAME and result.job_id in jobs_by_id:
            legacy.append(result)
        else:
            names[result.id] = result.name

    for result in sorted(legacy, key=lambda r: str(r.created_at)):
        job = jobs_by_id[result.job_id]
        names[result.id] = new_result_name(job.type, job.data, names)

    return names


def resolve_names_for_video(video_id: str, result_video_manager, job_manager) -> dict:
    """`resolve_result_names` for one video, loading its results and jobs."""
    results = result_video_manager.fetch_result_videos(video_id)
    jobs_by_id = job_manager.fetch_jobs_by_ids([str(r.job_id) for r in results])
    return resolve_result_names(
        [_with_str_ids(r) for r in results], jobs_by_id
    )


def _with_str_ids(result):
    result.id = str(result.id)
    result.job_id = str(result.job_id)
    return result


def slugify(text: str, max_length: int = 60) -> str:
    """ASCII, lowercase, hyphen-separated; safe in file names and headers."""
    text = unicodedata.normalize("NFKD", str(text)).encode("ascii", "ignore").decode("ascii")
    text = text.replace("+", " ")
    slug = re.sub(r"[^A-Za-z0-9]+", "-", text).strip("-").lower()
    slug = slug[:max_length].rstrip("-")
    return slug or "untitled"


def strip_video_extension(video_name: str) -> str:
    return re.sub(r"\.(mp4|mov|avi|mkv|webm|m4v)$", "", video_name, flags=re.IGNORECASE)


def video_stem(video_name: str) -> str:
    return slugify(strip_video_extension(video_name), max_length=40)


def result_stem(video_name: str, result_name: str) -> str:
    return f"{video_stem(video_name)}_{slugify(result_name)}"


EXTRA_FILE_SUFFIXES = {
    "qa": ("qa", "json"),
    "poses": ("poses", "json"),
    "sam2_masks": ("sam2-masks", "npz"),
}


def extra_file_name(stem: str, extra_type: str) -> str:
    suffix, extension = EXTRA_FILE_SUFFIXES.get(extra_type, (slugify(extra_type), "bin"))
    return f"{stem}_{suffix}.{extension}"


def content_disposition(file_name: str) -> str:
    return f'attachment; filename="{file_name}"'
