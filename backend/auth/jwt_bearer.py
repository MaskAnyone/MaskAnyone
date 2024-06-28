from fastapi import Request, HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt

from config import AUTH_TOKEN_ISSUER, AUTH_TOKEN_AUDIENCE, AUTH_ALGORITHM, AUTH_PUBLIC_KEY, MASK_ANYONE_PLATFORM_MODE


class JWTBearer(HTTPBearer):
    def __init__(self, auto_error: bool = True):
        super(JWTBearer, self).__init__(auto_error=auto_error)

    async def __call__(self, request: Request):
        # In local mode there is no login and authentication, so we just fake a logged-in user
        if MASK_ANYONE_PLATFORM_MODE == "local":
            return {"sub": "00000000-0000-0000-0000-000000000000"}

        authorization: str = request.headers.get("Authorization")
        token = None

        if authorization:
            try:
                scheme, credentials = authorization.split()
                if scheme.lower() != "bearer":
                    raise HTTPException(status_code=403, detail="Invalid authentication scheme.")
                token = credentials
            except ValueError:
                raise HTTPException(status_code=403, detail="Invalid authorization header.")
        else:
            # Try getting the token from query params if not found in header
            # @todo this is a minor security risk and should be fixed in the future
            token = request.query_params.get("token")

        if not token:
            raise HTTPException(status_code=403, detail="Not authenticated")

        return self.verify_jwt(token)

    def verify_jwt(self, jwtoken: str):
        try:
            payload = jwt.decode(
                jwtoken,
                AUTH_PUBLIC_KEY,
                algorithms=[AUTH_ALGORITHM],
                issuer=AUTH_TOKEN_ISSUER,
                audience=AUTH_TOKEN_AUDIENCE
            )
            return payload
        except jwt.JWTError as ex:
            print(ex)
            raise HTTPException(status_code=403, detail="Invalid token or expired token.")
