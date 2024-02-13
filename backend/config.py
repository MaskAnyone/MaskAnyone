import os

RESULT_BASE_PATH = "data/results"
VIDEOS_BASE_PATH = "data/videos"
PRESETS_BASE_PATH = "data/presets"

AUTH_TOKEN_ISSUER = "https://localhost/auth/realms/maskanyone"
AUTH_TOKEN_AUDIENCE = "account"
AUTH_ALGORITHM = "RS256"
AUTH_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----\n" + os.environ['BACKEND_AUTH_PUBLIC_KEY'] + "\n-----END PUBLIC KEY-----"
