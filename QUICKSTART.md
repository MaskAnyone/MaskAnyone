# MaskAnyone — Quick Start

Everything you need to go from zero to a running tool.

---

## 1. Prerequisites

Install these before running the setup script. The script will check them and tell you if anything is missing.

| Requirement | Download |
|---|---|
| **Docker Desktop** | https://www.docker.com/products/docker-desktop |
| **Git** | https://git-scm.com/downloads |

**GPU (optional but recommended)**
If you have an NVIDIA GPU, also install:
- [NVIDIA drivers](https://www.nvidia.com/drivers) — use the latest Game Ready or Studio driver
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) — lets Docker use your GPU

Without a GPU the tool still works, but processing long videos will be slow.

**Disk space:** at least 30 GB free before you start.

---

## 2. Clone and run

Open a terminal (Git Bash on Windows, Terminal on Mac/Linux):

```bash
git clone https://github.com/MaskAnyone/MaskAnyone.git -b samhack
cd MaskAnyone
bash setup.sh
```

The script will:
1. Check your system (Docker, GPU, disk, RAM)
2. Build all Docker images — **this takes 20–60 minutes on first run**
3. Download ~4 GB of AI model checkpoints (SAM2)
4. Start all services
5. Report whether everything came online

You can walk away and come back. It will tell you when it's done.

---

## 3. Open the app

Once the script finishes, open your browser and go to:

**[https://localhost](https://localhost)**

> **Browser warning:** your browser will show a security warning about a self-signed certificate. This is expected — click **Advanced** (or **Show Details**) and then **Proceed to localhost**.

---

## 4. Subsequent starts

Once images are built, starting the tool again is fast:

```bash
bash setup.sh --skip-build
```

---

## 5. Troubleshooting

**Script fails at prerequisites**
Read the error — it will tell you exactly what's missing (Docker not running, not enough disk space, etc.).

**Browser shows "502 Bad Gateway"**
The backend is still starting up. Wait 30 seconds and refresh.

**Processing is very slow**
No GPU detected. Use short chunk sizes (30–60 s) for videos longer than 2 minutes.

**Port 443 already in use**
Something else on your machine is using port 443. Stop it or change the nginx port in `docker-compose.yml`.

---

## Options

| Flag | Effect |
|---|---|
| `bash setup.sh` | Local mode, no login required |
| `bash setup.sh --with-auth` | Enable Keycloak authentication |
| `bash setup.sh --skip-build` | Skip image build (use existing images) |
