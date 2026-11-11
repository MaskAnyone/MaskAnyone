# Troubleshooting

## First step: run the doctor

Most problems can be diagnosed with:

```bash
bash setup.sh doctor
```

It checks Docker, images, containers, the backend, GPU arch compatibility, and per-service health — and prints the exact command to run for each issue found. Try this before digging in by hand.

---

## Known issues

### 1. `AxiosError: Request failed with status code 500` when running SAM2 on a new GPU

**Symptom:** The frontend shows a 500 error when you click "Segment" in the masking editor. `docker logs maskanyone-sam2-1` contains:

```
CUDA error: no kernel image is available for execution on the device
```

**Root cause:** SAM2's `Dockerfile` uses a PyTorch version that was compiled without kernels for your GPU's compute capability. This bites any GPU newer than what the image was built for — most commonly NVIDIA Blackwell (RTX 5090, compute capability `sm_120`), since PyTorch only added `sm_120` in version 2.8 with CUDA 12.8.

**Fix:** The current `Dockerfile` is already on PyTorch 2.8 + CUDA 12.8 and `setup.sh` auto-detects your GPU's compute capability and passes it as `TORCH_CUDA_ARCH_LIST` to the build. If you still hit it on an older clone:

```bash
bash setup.sh --clean
bash setup.sh
```

**To confirm the fix worked:**

```bash
docker run --rm --gpus all maskanyone-sam2 python -c \
  "import torch; print(torch.cuda.get_arch_list()); print(torch.cuda.get_device_name(0))"
```

You should see your GPU's `sm_XX` in the arch list.

### 2. OpenPose crashes at runtime on newer GPUs

**Symptom:** Pose estimation via OpenPose fails with a CUDA kernel error:

```
F0421 ... im2col.cu:61] Check failed: error == cudaSuccess (209 vs. 0)
no kernel image is available for execution on the device
```

**Root cause:** [`docker/openpose/Dockerfile`](docker/openpose/Dockerfile) compiles OpenPose with `cmake -DCUDA_ARCH_BIN="75"` against CUDA 11.7, which targets Turing (sm_75) only. It will not produce working kernels for Ampere (sm_80+), Ada (sm_89), or Blackwell (sm_120).

**Workaround (recommended):** Pick **MediaPipe** or **RTMPose** as the pose overlay strategy in the masking editor. Both give good results on any hardware. RTMPose in particular matches or exceeds OpenPose on standard benchmarks.

**Why it's not fixed yet:** Upgrading to CUDA 12+ fails during the Caffe build with `nvcc fatal: Unsupported gpu architecture 'compute_35'`. OpenPose's bundled Caffe fork hardcodes Kepler (compute_35) in its "known archs" list via `Caffe_known_gpu_archs`, and CUDA 12 dropped compute_35. Setting `-DCUDA_ARCH_NAME=Manual` on OpenPose's top-level cmake doesn't help — OpenPose pulls Caffe via `ExternalProject_Add` so the flag isn't forwarded. A real fix needs one of:
- Adding a `PATCH_COMMAND` to OpenPose's Caffe ExternalProject that strips obsolete arches from `cmake/Cuda.cmake` before build
- Pre-cloning a patched Caffe fork and pointing OpenPose at it via `BUILD_CAFFE=OFF` + `Caffe_INCLUDE_DIRS`/`Caffe_LIBS`
- Forking OpenPose's Caffe to modernize arch support

Estimated effort: 2–4 hours, risky. Not prioritized because the workaround above covers the same use cases.

### 3. `setup.sh --clean` does nothing / `--skip-build` rebuilds everything

**Symptom:** `--clean` claims success but `docker images` still shows the MaskAnyone images; `--skip-build` rebuilds every image on every run.

**Root cause:** Old versions of `setup.sh` assumed the docker-compose project name was `src`, so they looked for images named `maskanyone-src-*`. The actual project name (driven by the directory name `MaskAnyone`) is `maskanyone`, so the images are `maskanyone-*`.

**Fix:** Pull the latest `setup.sh` — this is fixed.

### 4. Scout reports "GPU: unknown" / services as "Offline" even when everything works

**Symptom:** `setup.sh` completes but the final summary shows `GPU: unknown`, `RAM: ?`, `Disk: ?`, and warns that SAM2 / RTMPose / OpenPose are offline — even though the app works fine at https://localhost.

**Root cause:** The scout parses the `/api/platform/resources` JSON with `python3`, which on Windows often resolves to the Microsoft Store launcher stub instead of a real Python. The stub exits non-zero, the parse fails silently, and everything shows as unknown.

**Fix:** Latest `setup.sh` auto-detects a working Python (`python3` → `python` → `py`) and falls back to pure-bash checks for simple booleans. If the problem persists, install a real Python (Anaconda, or `python.org`) and make sure `python -c 'print(1)'` actually runs in your terminal.

### 5. `setup.sh` exits mid-run with `syntax error near unexpected token '('`

**Root cause:** The script was edited (usually by git pull, or by you) while it was already running. Bash re-reads the script file as it executes, so any mid-run edit shifts line offsets and corrupts the parse.

**Fix:** Don't edit `setup.sh` while it's running. The images that were built before the crash are still valid — just re-run `bash setup.sh --skip-build` to finish starting services.

### 6. Browser warns about an invalid certificate at https://localhost

**This is expected.** MaskAnyone's nginx uses a self-signed cert. Click "Advanced" → "Proceed to localhost (unsafe)" — the connection is still encrypted, it's just not signed by a public CA.

---

## Environment requirements

- **Docker Desktop** running (Windows/Mac) or Docker daemon active (Linux)
- **NVIDIA Container Toolkit** installed if you want GPU acceleration. `docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi` should print your GPU.
- **≥ 30 GB free disk** (for images and model checkpoints, ~10 GB base + 4 GB SAM2 checkpoints + overhead)
- **≥ 16 GB RAM** recommended, 8 GB absolute minimum with small chunk sizes

---

## Collecting logs for a bug report

Every run of `setup.sh` writes a timestamped log to `logs/setup-<timestamp>.log`. When filing an issue, please attach the most recent one plus the output of:

```bash
bash setup.sh doctor
docker ps -a
docker logs --tail 200 maskanyone-python-1
docker logs --tail 200 maskanyone-sam2-1
```
