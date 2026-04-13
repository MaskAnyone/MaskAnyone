# MaskPrimate

**MaskPrimate** extends [MaskAnyone](https://github.com/MaskAnyone/MaskAnyone) to support animal and primate subjects. Where MaskAnyone targets human de-identification in video, MaskPrimate targets non-human primates and other animals — enabling pose extraction, segmentation, and masking of animal subjects without any human pipeline dependency.

---

## Motivation

Research video in primatology, comparative psychology, and animal behaviour increasingly requires:

- **Pose extraction** — automated keypoint estimation for kinematic analysis and behavioural coding, replacing labour-intensive manual annotation
- **Subject segmentation** — pixel-accurate isolation of animals from background for tracking and region-of-interest analysis
- **Data anonymisation** — protecting individual animal identity in shared datasets, particularly where re-identification is a concern

Existing human de-identification tools do not transfer to animal subjects: pose models trained on COCO-17 human topology produce no meaningful output on primates, and segmentation models trained predominantly on human-centric data degrade on animal fur, occlusion patterns, and field-recording conditions.

MaskPrimate addresses this by substituting animal-domain models throughout the pipeline while preserving the MaskAnyone infrastructure (SAM2 segmentation, Docker stack, job queue, web UI).

---

## What is implemented

| Component | Status | Notes |
|---|---|---|
| RTMPose AP-10K | ✅ Done | 17-keypoint animal skeleton, 54 species incl. chimpanzees |
| OpenPose | ⛔ Disabled | Human-only, not relevant |
| MediaPipe | ⛔ Disabled (UI only) | Human-only |
| SAM2 segmentation | ✅ Available | Works; quality degrades on field footage |
| Model weight caching | ✅ Done | Volume-mounted at `./data/rtmpose_model_cache` |

---

## AP-10K keypoint topology

AP-10K uses 17 keypoints with animal-specific anatomy:

```
0: left_eye       1: right_eye      2: nose
3: neck           4: root_of_tail
5: left_shoulder  6: left_elbow     7: left_front_paw
8: right_shoulder 9: right_elbow    10: right_front_paw
11: left_hip      12: left_knee     13: left_back_paw
14: right_hip     15: right_knee    16: right_back_paw
```

Skeleton connections follow quadruped anatomy: head → neck → spine → tail root, with four limbs branching from neck (forelimbs) and tail root (hindlimbs).

---

## Getting started

### Prerequisites

- Docker with NVIDIA GPU support
- GPU declared in `app.env` (`MASKANYONE_GPU_ID`, default `0`)
- SAM2 and RTMPose are the only GPU/CPU services required (OpenPose disabled)

### Start the stack

```bash
docker compose up -d
```

### Run a primate job

1. Open the UI at [https://localhost](https://localhost)
2. Upload an animal/primate video
3. Right-click the first frame to place a point prompt on the subject
4. Set **Overlay strategy** → `RTMPose AP-10K (Animals, CPU)`
5. Set **Hiding strategy** as required (e.g. `Blurring`, `Solid Fill`, or `No Hiding` for pose-only)
6. Click **Mask**

### Monitor the worker

```bash
docker logs -f maskanyone-worker-basic_masking-1
```

The first AP-10K job downloads model weights (~200 MB) into `./data/rtmpose_model_cache/`. Subsequent jobs are fast.

---

## Architecture

MaskPrimate uses the same pipeline as MaskAnyone:

```
Video → SAM2 (segmentation) → sub-video crops → RTMPose AP-10K (pose) → render
```

Key files modified from the MaskAnyone baseline:

| File | Change |
|---|---|
| `worker/masking/sam2_pose_masker.py` | Added `rtmpose_ap10k` model entry |
| `worker/masking/pose_renderer.py` | Added `AP10K_PAIRS`, `_render_ap10k_overlay()` |
| `frontend/src/pages/VideosMaskingEditorPage.tsx` | Added AP-10K menu item |
| `docker-compose.yml` | Disabled OpenPose; added RTMPose model cache volume |

The `PosePostprocessor` requires no changes — it already handles any strategy beginning with `rtmpose`.

---

## References

- AP-10K dataset: Hang et al. (2021) — [arXiv:2108.12617](https://arxiv.org/abs/2108.12617) — 54 animal species, 10,015 images
- RTMPose: Jiang et al. (2023) — [arXiv:2303.07399](https://arxiv.org/abs/2303.07399)
- MMPose AP-10K model zoo: [mmpose.readthedocs.io](https://mmpose.readthedocs.io/en/latest/model_zoo/animal_2d_keypoint.html)
- SAM2: Ravi et al. (2024) — [arXiv:2408.00714](https://arxiv.org/abs/2408.00714)
- SA-FARI dataset (for SAM2 fine-tuning): [huggingface.co/datasets/facebook/SA-FARI](https://huggingface.co/datasets/facebook/SA-FARI)
- MacaquePose: Labuguen et al. (2021) — [Frontiers in Neuroscience](https://www.frontiersin.org/articles/10.3389/fnins.2020.581154/full)
