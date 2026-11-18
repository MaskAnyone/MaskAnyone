"""
Conftest: mock out native C-extension modules that aren't installed in the
Windows dev environment so unit tests can import worker code without a Docker
container.
"""
import sys
from unittest.mock import MagicMock

# cv2 (OpenCV) — installed in the worker Docker image but not on the dev machine
if 'cv2' not in sys.modules:
    sys.modules['cv2'] = MagicMock()

# mediapipe — same situation; mock the full submodule tree it imports
for _mp_mod in [
    'mediapipe',
    'mediapipe.tasks',
    'mediapipe.tasks.python',
    'mediapipe.tasks.python.vision',
    'mediapipe.framework',
    'mediapipe.framework.formats',
    'mediapipe.framework.formats.landmark_pb2',
    'mediapipe.solutions',
    'mediapipe.solutions.drawing_utils',
    'mediapipe.solutions.pose',
    'mediapipe.solutions.face_mesh',
    'mediapipe.solutions.hands',
]:
    if _mp_mod not in sys.modules:
        sys.modules[_mp_mod] = MagicMock()
