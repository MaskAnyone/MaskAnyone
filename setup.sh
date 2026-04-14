#!/usr/bin/env bash
# MaskAnyone setup script
# Usage: bash setup.sh [--skip-build]
set -euo pipefail

SKIP_BUILD=false
for arg in "$@"; do [[ "$arg" == "--skip-build" ]] && SKIP_BUILD=true; done

# ── colours ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET}  $*"; }
warn() { echo -e "  ${YELLOW}⚠${RESET}  $*"; }
fail() { echo -e "  ${RED}✗${RESET}  $*"; }
info() { echo -e "  ${CYAN}→${RESET}  $*"; }
section() { echo -e "\n${BOLD}$*${RESET}"; }

ERRORS=0
WARNINGS=0

check_ok()   { ok "$1"; }
check_warn() { warn "$1"; WARNINGS=$((WARNINGS+1)); }
check_fail() { fail "$1"; ERRORS=$((ERRORS+1)); }

# ── header ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║       MaskAnyone  —  Setup Scout         ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
section "1 / 4  Prerequisites"
# ═══════════════════════════════════════════════════════════════════════════════

# Docker
if command -v docker &>/dev/null; then
    DOCKER_VER=$(docker --version | awk '{print $3}' | tr -d ',')
    check_ok "Docker $DOCKER_VER"
else
    check_fail "Docker not found — install from https://docs.docker.com/get-docker/"
fi

# Docker daemon running
if docker info &>/dev/null 2>&1; then
    check_ok "Docker daemon running"
else
    check_fail "Docker daemon not running — start Docker Desktop or 'sudo systemctl start docker'"
fi

# Docker Compose
if docker compose version &>/dev/null 2>&1; then
    COMPOSE_VER=$(docker compose version --short 2>/dev/null || echo "v2")
    check_ok "Docker Compose $COMPOSE_VER"
else
    check_fail "Docker Compose v2 not found — update Docker Desktop or install the compose plugin"
fi

# NVIDIA GPU
if command -v nvidia-smi &>/dev/null; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 || echo "")
    GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null | head -1 | tr -d ' ' || echo "")
    if [[ -n "$GPU_NAME" ]]; then
        check_ok "GPU: $GPU_NAME ($GPU_MEM)"
    else
        check_warn "nvidia-smi found but no GPU detected"
    fi
else
    check_warn "No NVIDIA GPU detected — SAM2 will run on CPU (very slow for long videos)"
fi

# NVIDIA Container Toolkit
if docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi &>/dev/null 2>&1; then
    check_ok "NVIDIA Container Toolkit working"
else
    if command -v nvidia-smi &>/dev/null; then
        check_warn "NVIDIA Container Toolkit not configured — GPU won't be available inside containers. See: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
    fi
fi

# Disk space (need ≥ 30 GB free)
DISK_FREE_GB=$(df -BG . | awk 'NR==2{gsub("G","",$4); print $4}' 2>/dev/null || echo "0")
if [[ "$DISK_FREE_GB" -ge 30 ]]; then
    check_ok "Disk: ${DISK_FREE_GB} GB free"
elif [[ "$DISK_FREE_GB" -ge 15 ]]; then
    check_warn "Disk: ${DISK_FREE_GB} GB free (30 GB recommended — may be tight)"
else
    check_fail "Disk: ${DISK_FREE_GB} GB free — need at least 30 GB for images and models"
fi

# RAM (need ≥ 16 GB)
RAM_GB=0
if [[ -f /proc/meminfo ]]; then
    RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    RAM_GB=$((RAM_KB / 1024 / 1024))
elif command -v sysctl &>/dev/null; then
    RAM_GB=$(( $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1024 / 1024 / 1024 ))
fi
if [[ "$RAM_GB" -ge 16 ]]; then
    check_ok "RAM: ${RAM_GB} GB"
elif [[ "$RAM_GB" -ge 8 ]]; then
    check_warn "RAM: ${RAM_GB} GB (16 GB recommended for chunked processing)"
else
    check_warn "RAM: ${RAM_GB} GB (low — use small chunk sizes)"
fi

if [[ "$ERRORS" -gt 0 ]]; then
    echo ""
    fail "Found $ERRORS critical issue(s) above. Fix them before continuing."
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════════
section "2 / 4  Build images"
# ═══════════════════════════════════════════════════════════════════════════════

if [[ "$SKIP_BUILD" == "true" ]]; then
    info "Skipping build (--skip-build)"
else
    info "Building Docker images (this takes 20–60 min on first run)..."
    info "SAM2 will download ~4 GB of model checkpoints."
    echo ""
    docker compose build
    echo ""
    check_ok "Images built"
fi

# ── ensure no critical images are missing (even with --skip-build) ─────────────
NEED_BUILD=()
for SVC in python worker sam2 yarn nginx postgres pgadmin keycloak; do
    IMG=$(docker compose config --images 2>/dev/null | grep -i "$SVC" | head -1 || true)
    # Fall back to conventional name
    [[ -z "$IMG" ]] && IMG="maskanyone-src-${SVC}:latest"
    if ! docker image inspect "$IMG" &>/dev/null 2>&1; then
        NEED_BUILD+=("$SVC")
    fi
done
if [[ ${#NEED_BUILD[@]} -gt 0 ]]; then
    warn "Missing images for: ${NEED_BUILD[*]} — building them now..."
    docker compose build "${NEED_BUILD[@]}"
    check_ok "Missing images built"
fi

# ═══════════════════════════════════════════════════════════════════════════════
section "3 / 4  Start services"
# ═══════════════════════════════════════════════════════════════════════════════

info "Installing frontend dependencies..."
docker compose run --rm yarn yarn install --silent 2>&1 | grep -v "^warning" || true
check_ok "Frontend dependencies installed"

info "Starting database..."
docker compose up -d postgres
info "Waiting for PostgreSQL to be ready..."
for i in $(seq 1 30); do
    if docker compose exec -T postgres pg_isready -U dev &>/dev/null 2>&1; then
        check_ok "PostgreSQL ready"
        break
    fi
    sleep 2
    if [[ "$i" -eq 30 ]]; then
        check_fail "PostgreSQL did not become ready in time"
        exit 1
    fi
done

info "Starting all services..."
docker compose up -d --no-build
check_ok "All services started"

# ═══════════════════════════════════════════════════════════════════════════════
section "4 / 4  Service scout"
# ═══════════════════════════════════════════════════════════════════════════════

info "Waiting for backend to be ready..."
for i in $(seq 1 30); do
    STATUS=$(curl -sk -o /dev/null -w "%{http_code}" https://localhost/api/platform/mode 2>/dev/null || echo "000")
    if [[ "$STATUS" == "200" ]]; then
        check_ok "Backend reachable"
        break
    fi
    sleep 3
    if [[ "$i" -eq 30 ]]; then
        check_warn "Backend not reachable yet — try opening https://localhost in a minute"
    fi
done

# Query /platform/resources
RESOURCES=$(curl -sk https://localhost/api/platform/resources 2>/dev/null || echo "{}")

GPU=$(echo "$RESOURCES" | python3 -c "import sys,json; d=json.load(sys.stdin); g=d.get('gpu'); print(f\"{g['name']} ({g['vram_gb']} GB VRAM)\" if g else 'Not detected')" 2>/dev/null || echo "unknown")
RAM=$(echo "$RESOURCES" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"{d.get('ram_total_gb','?')} GB\")" 2>/dev/null || echo "?")
DISK=$(echo "$RESOURCES" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"{d.get('disk_free_gb','?')} GB free\")" 2>/dev/null || echo "?")

if [[ "$GPU" == "Not detected" ]]; then
    check_warn "GPU: $GPU — chunked processing recommended for videos > 2 min"
else
    check_ok "GPU: $GPU"
fi
check_ok "RAM: $RAM"
check_ok "Disk: $DISK"

# Per-service health
for SERVICE in sam2 rtmpose openpose; do
    UP=$(echo "$RESOURCES" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('services',{}).get('$SERVICE', False))" 2>/dev/null || echo "False")
    if [[ "$UP" == "True" ]]; then
        check_ok "$SERVICE: Online"
    else
        check_warn "$SERVICE: Offline"
        WARNINGS=$((WARNINGS+1))
    fi
done

# ── summary ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────${RESET}"
if [[ "$WARNINGS" -eq 0 ]]; then
    echo -e "  ${GREEN}${BOLD}All checks passed. MaskAnyone is ready.${RESET}"
else
    echo -e "  ${YELLOW}${BOLD}Setup complete with $WARNINGS warning(s) — see above.${RESET}"
fi
echo ""
echo -e "  Open ${CYAN}https://localhost${RESET} in your browser."
if [[ "$WARNINGS" -gt 0 && "$GPU" == "Not detected" ]]; then
    echo -e "  ${YELLOW}Tip: No GPU detected. Use 30–60 s chunk sizes for videos longer than 2 min.${RESET}"
fi
echo ""
