from fastapi import APIRouter, Request, Depends
from auth.jwt_bearer import JWTBearer


router = APIRouter(
    prefix="/prompts",
)


@router.get("/{video_id}/pose")
def fetch_jobs(token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]

    return [[100, 100, 1], [200, 200, 0]]
