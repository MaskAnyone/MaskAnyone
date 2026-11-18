import re
from pathlib import PurePosixPath

from fastapi import HTTPException


# UUID v4 pattern for validating resource IDs
_UUID_PATTERN = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
    re.IGNORECASE,
)


def validate_resource_id(resource_id: str) -> str:
    """Validate that a resource ID is a safe UUID and cannot be used for path traversal.

    Args:
        resource_id: The ID string to validate.

    Returns:
        The validated resource ID.

    Raises:
        HTTPException: If the ID contains path traversal characters or is not a valid UUID.
    """
    if not resource_id or not _UUID_PATTERN.match(resource_id):
        raise HTTPException(
            status_code=400,
            detail=f"Invalid resource ID: {resource_id}",
        )
    return resource_id


def safe_join(base_path: str, *parts: str) -> str:
    """Safely join path components, preventing path traversal.

    Args:
        base_path: The base directory path.
        *parts: Additional path components to join.

    Returns:
        The joined path string.

    Raises:
        HTTPException: If the resulting path escapes the base directory.
    """
    base = PurePosixPath(base_path).resolve() if hasattr(PurePosixPath, 'resolve') else PurePosixPath(base_path)
    joined = PurePosixPath(base_path, *parts)

    # Ensure no component contains path traversal
    for part in parts:
        if ".." in part or part.startswith("/"):
            raise HTTPException(
                status_code=400,
                detail="Invalid path component",
            )

    return str(joined)
