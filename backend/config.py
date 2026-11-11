import os

RESULT_BASE_PATH = "/var/lib/maskanyone/data/results"
VIDEOS_BASE_PATH = "/var/lib/maskanyone/data/videos"
PRESETS_BASE_PATH = "/var/lib/maskanyone/data/presets"

for _path in (RESULT_BASE_PATH, VIDEOS_BASE_PATH, PRESETS_BASE_PATH):
    os.makedirs(_path, exist_ok=True)

AUTH_TOKEN_ISSUER = os.getenv("BACKEND_AUTH_ISSUER", "https://localhost/auth/realms/maskanyone")
AUTH_TOKEN_AUDIENCE = "account"
AUTH_ALGORITHM = "RS256"
AUTH_PUBLIC_KEY = "-----BEGIN PUBLIC KEY-----\n" + os.environ['BACKEND_AUTH_PUBLIC_KEY'] + "\n-----END PUBLIC KEY-----"

MASK_ANYONE_PLATFORM_MODE = os.environ["MASK_ANYONE_PLATFORM_MODE"]
