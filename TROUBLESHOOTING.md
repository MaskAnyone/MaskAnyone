# Troubleshooting

## First step: run the doctor

Most problems can be diagnosed with:

```bash
bash setup.sh doctor
```

It checks Docker, the images, the containers, the backend, your GPU and each service, and prints the command to run for each problem it finds. It changes nothing on its own.

---

## Common problems

### 1. Browser warns about an invalid certificate at https://localhost

**This is expected.** MaskAnyone uses a self-signed certificate. Click "Advanced" → "Proceed to localhost". The connection is still encrypted; the certificate is just not signed by a public authority.

### 2. Browser shows "502 Bad Gateway"

The backend is still starting up, which can take a minute after `setup.sh` finishes or after a restart. Wait about 30 seconds and refresh. If it persists, run `bash setup.sh doctor`.

### 3. Port 443 already in use

Something else on your machine (another web server, or another Docker container) is using port 443, so MaskAnyone cannot start. The simplest fix is to stop that program while you use MaskAnyone.

If you cannot stop it, you can move MaskAnyone to another port: change the port mapping `"443:443"` of the `nginx` service in `docker-compose.yml`, for example to `"8443:443"`. The app is then served at `https://localhost:8443` instead of `https://localhost`.

### 4. Advanced masking does not work without an NVIDIA GPU

**This is expected.** Without an NVIDIA GPU (including all Macs), MaskAnyone installs in CPU mode: SAM2 and OpenPose are not installed, so **Advanced Masking** cannot run. Use **Basic Masking** (MediaPipe), which works on any machine.

If you do have an NVIDIA GPU but `setup.sh` reports CPU mode, check that `nvidia-smi` works in your terminal (on Linux, also install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)), then run `bash setup.sh` again.

### 5. OpenPose fails on RTX 50-series GPUs

OpenPose works on NVIDIA RTX 20-, 30- and 40-series GPUs, but not on RTX 50-series (Blackwell). Pose estimation with OpenPose then fails with an error like `no kernel image is available for execution on the device`.

**What to do:** choose **MediaPipe** as the pose overlay in the Advanced masking editor. SAM2 masking itself works normally on these GPUs.

### 6. Advanced masking fails with a 500 error on a new GPU

**Symptom:** **Test Prompt** in the Advanced masking editor shows a 500 error, or Advanced masking runs fail, and `docker logs maskanyone-sam2-1` contains `no kernel image is available for execution on the device`.

**Cause:** the SAM2 image was built for a different GPU, usually because it was built before you changed GPUs or with an older version of MaskAnyone.

**What to do:** rebuild the images. Your videos and results are kept.

```bash
bash setup.sh --clean
bash setup.sh
```

### 7. `setup.sh` fails with `$'\r': command not found` (Windows)

The script has Windows line endings, which bash cannot read. This can happen with older clones or when the file was saved by an editor that uses Windows line endings. In Git Bash, inside the `MaskAnyone` folder, check the file out again:

```bash
rm setup.sh
git checkout setup.sh
```

### 8. `setup.sh` stops with `syntax error near unexpected token '('`

The script was changed while it was running, for example by a `git pull` in another terminal. Do not update or edit `setup.sh` while it runs. The images built so far are kept; finish with:

```bash
bash setup.sh --skip-build
```

### 9. Summary shows "GPU: unknown", "RAM: ?" or services as "Offline" although the app works

`setup.sh` needs a working Python to read the system information. On Windows, `python3` is often only a placeholder that opens the Microsoft Store. Install Python (from [python.org](https://www.python.org/downloads/) or Anaconda) and check that `python -c "print(1)"` prints `1` in your terminal. The app itself is not affected.

---

## Requirements

- **Docker Desktop** running (Windows, macOS) or the Docker service running (Linux)
- For GPU support: an NVIDIA GPU with an up-to-date driver; on Linux also the NVIDIA Container Toolkit. `docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi` should print your GPU.
- **At least 30 GB free disk space**
- **16 GB RAM** recommended; 8 GB works with smaller chunk sizes

---

## Report a new problem

If your problem is not listed here, please [open an issue on GitHub](https://github.com/MaskAnyone/MaskAnyone/issues) and describe what you did and what happened. It helps a lot to attach:

- the most recent log from the `logs/` folder (`setup.sh` writes one per run, `logs/setup-<timestamp>.log`)
- the output of these commands:

```bash
bash setup.sh doctor
docker ps -a
docker logs --tail 200 maskanyone-python-1
docker logs --tail 200 maskanyone-worker-1
docker logs --tail 200 maskanyone-sam2-1     # GPU installs only
```

Please check the logs for anything private (file names, paths) before posting them.
