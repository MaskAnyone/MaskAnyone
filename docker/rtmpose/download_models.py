"""Pre-download all RTMPose model checkpoints at image build time."""
import numpy as np
from mmpose.apis import MMPoseInferencer

MODELS = [
    'rtmpose-s_8xb256-420e_coco-256x192',
    'rtmpose-m_8xb256-420e_coco-256x192',
    'rtmpose-l_8xb256-420e_coco-256x192',
    'td-hm_hrnet-w32_8xb64-210e_ap10k-256x256',
    'td-hm_hrnet-w32_8xb64-210e_apt36k-256x256',
    'td-hm_hrnet-w48_8xb64-210e_apt36k-256x256',
]

dummy = np.zeros((64, 64, 3), dtype=np.uint8)

for model in MODELS:
    print(f'Downloading {model}...', flush=True)
    inferencer = MMPoseInferencer(model, device='cpu')
    # consume the generator to trigger the actual forward pass
    list(inferencer([dummy], return_vis=False))
    print(f'  done.', flush=True)

print('All RTMPose models downloaded.')
