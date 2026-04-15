#!/usr/bin/env bash
# MaskAnyone setup script
# Usage: bash setup.sh [--skip-build] [--with-auth]
#   --skip-build   skip docker compose build (use existing images)
#   --with-auth    enable Keycloak authentication (default: local/no-login mode)
set -euo pipefail

SKIP_BUILD=false
WITH_AUTH=false
for arg in "$@"; do
    [[ "$arg" == "--skip-build" ]] && SKIP_BUILD=true
    [[ "$arg" == "--with-auth"  ]] && WITH_AUTH=true
done

# Cross-platform helpers
# sed -i behaves differently on macOS (BSD) vs Linux/Git Bash
if [[ "$(uname)" == "Darwin" ]]; then
    sedi() { sed -i '' "$@"; }
    disk_free_gb() { df -g . | awk 'NR==2{print $4}' 2>/dev/null || echo "0"; }
else
    sedi() { sed -i "$@"; }
    disk_free_gb() { df -BG . | awk 'NR==2{gsub("G","",$4); print $4}' 2>/dev/null || echo "0"; }
fi

# Detect GPU early — used to choose compose files and in the service scout.
# COMPOSE_GPU_OVERRIDE is appended to every docker compose invocation.
HAS_GPU=false
if command -v nvidia-smi &>/dev/null && nvidia-smi --query-gpu=name --format=csv,noheader &>/dev/null 2>&1; then
    HAS_GPU=true
fi
if [[ "$HAS_GPU" == "true" ]]; then
    COMPOSE_BASE="-f docker-compose.yml"
else
    COMPOSE_BASE="-f docker-compose.yml -f docker-compose-cpu.yml"
fi

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
if [[ "$HAS_GPU" == "true" ]]; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 || echo "")
    GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null | head -1 | tr -d ' ' || echo "")
    if [[ -n "$GPU_NAME" ]]; then
        check_ok "GPU: $GPU_NAME ($GPU_MEM) — running in GPU mode"
    else
        check_warn "nvidia-smi found but no GPU detected — falling back to CPU mode"
    fi
else
    check_warn "No NVIDIA GPU detected — running in CPU mode (SAM2 will be slow for long videos)"
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
DISK_FREE_GB=$(disk_free_gb)
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

# ── auth mode ──────────────────────────────────────────────────────────────────
COMPOSE_PROFILES=""
if [[ "$WITH_AUTH" == "true" ]]; then
    info "Auth mode: Keycloak enabled (--with-auth)"
    sedi 's/^MASK_ANYONE_PLATFORM_MODE=.*/MASK_ANYONE_PLATFORM_MODE=server/' app.env
    COMPOSE_PROFILES="--profile auth"
else
    info "Auth mode: local (no login required) — pass --with-auth to enable Keycloak"
    sedi 's/^MASK_ANYONE_PLATFORM_MODE=.*/MASK_ANYONE_PLATFORM_MODE=local/' app.env
fi

if [[ "$SKIP_BUILD" == "true" ]]; then
    info "Skipping build (--skip-build)"
else
    info "Building Docker images (this takes 20–60 min on first run)..."
    info "SAM2 will download ~4 GB of model checkpoints. RTMPose will download ~1 GB."
    echo ""

    BUILD_SVCS=(nginx postgres pgadmin yarn python worker sam2 rtmpose openpose)
    [[ "$WITH_AUTH" == "true" ]] && BUILD_SVCS+=(keycloak)
    BUILD_TOTAL=${#BUILD_SVCS[@]}
    BUILD_IDX=0
    BUILD_ERRORS=0

    for SVC in "${BUILD_SVCS[@]}"; do
        BUILD_IDX=$((BUILD_IDX + 1))
        echo -e "  ${CYAN}→${RESET}  [${BUILD_IDX}/${BUILD_TOTAL}] Building ${BOLD}${SVC}${RESET}..."
        BUILD_START=$SECONDS
        if docker compose $COMPOSE_BASE build "$SVC" 2>&1; then
            BUILD_ELAPSED=$((SECONDS - BUILD_START))
            ok "[${BUILD_IDX}/${BUILD_TOTAL}] ${SVC} built (${BUILD_ELAPSED}s)"
        else
            fail "[${BUILD_IDX}/${BUILD_TOTAL}] ${SVC} build FAILED"
            BUILD_ERRORS=$((BUILD_ERRORS + 1))
        fi
        echo ""
    done

    if [[ "$BUILD_ERRORS" -gt 0 ]]; then
        fail "$BUILD_ERRORS image(s) failed to build — see output above."
        exit 1
    fi
    check_ok "All images built"
fi

# ── ensure no critical images are missing (even with --skip-build) ─────────────
CORE_SVCS=(python worker sam2 yarn nginx postgres pgadmin rtmpose openpose)
[[ "$WITH_AUTH" == "true" ]] && CORE_SVCS+=(keycloak)
NEED_BUILD=()
for SVC in "${CORE_SVCS[@]}"; do
    IMG="maskanyone-src-${SVC}:latest"
    if ! docker image inspect "$IMG" &>/dev/null 2>&1; then
        NEED_BUILD+=("$SVC")
    fi
done
if [[ ${#NEED_BUILD[@]} -gt 0 ]]; then
    warn "Missing images: ${NEED_BUILD[*]} — building them now..."
    NB_TOTAL=${#NEED_BUILD[@]}
    NB_IDX=0
    for SVC in "${NEED_BUILD[@]}"; do
        NB_IDX=$((NB_IDX + 1))
        echo -e "  ${CYAN}→${RESET}  [${NB_IDX}/${NB_TOTAL}] Building ${BOLD}${SVC}${RESET}..."
        BUILD_START=$SECONDS
        docker compose $COMPOSE_BASE build "$SVC" 2>&1
        ok "[${NB_IDX}/${NB_TOTAL}] ${SVC} built ($((SECONDS - BUILD_START))s)"
        echo ""
    done
    check_ok "Missing images built"
fi

# ═══════════════════════════════════════════════════════════════════════════════
section "3 / 4  Start services"
# ═══════════════════════════════════════════════════════════════════════════════

info "Installing frontend dependencies..."
docker compose $COMPOSE_BASE run --rm yarn yarn install --silent 2>&1 | grep -v "^warning" || true
check_ok "Frontend dependencies installed"

info "Starting database..."
docker compose $COMPOSE_BASE up -d postgres
info "Waiting for PostgreSQL to be ready..."
for i in $(seq 1 30); do
    if docker compose $COMPOSE_BASE exec -T postgres pg_isready -U dev &>/dev/null 2>&1; then
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
UP_OUT=$(docker compose $COMPOSE_BASE $COMPOSE_PROFILES up -d --no-build 2>&1) || true
if echo "$UP_OUT" | grep -qi "error\|failed"; then
    warn "Some services had issues starting:"
    echo "$UP_OUT" | grep -i "error\|failed" | while read -r line; do warn "  $line"; done
    WARNINGS=$((WARNINGS+1))
else
    check_ok "All services started"
fi

# Restart python and worker after postgres is confirmed ready.
# On a cold start they race postgres and crash; restart ensures a clean connect.
info "Restarting backend and worker against live database..."
docker compose $COMPOSE_BASE restart python worker &>/dev/null || true
check_ok "Backend and worker restarted"

# ═══════════════════════════════════════════════════════════════════════════════
section "4 / 4  Service scout"
# ═══════════════════════════════════════════════════════════════════════════════

info "Waiting for backend to be ready (up to 5 min)..."
BACKEND_UP=false
for i in $(seq 1 60); do
    STATUS=$(curl -4sk --max-time 5 -o /dev/null -w "%{http_code}" https://localhost/api/platform/mode 2>/dev/null || echo "000")
    if [[ "$STATUS" == "200" ]]; then
        check_ok "Backend reachable"
        BACKEND_UP=true
        break
    fi
    echo -ne "  ${CYAN}→${RESET}  Still starting... (${i}/60)\r"
    sleep 5
done
echo ""
if [[ "$BACKEND_UP" == "false" ]]; then
    check_warn "Backend not reachable yet — try opening https://localhost in a minute"
fi

# Query /platform/resources
RESOURCES=$(curl -4sk --max-time 10 https://localhost/api/platform/resources 2>/dev/null || echo "{}")

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
echo -e "  ${YELLOW}Note: your browser will warn about a self-signed certificate — click 'Advanced' and proceed.${RESET}"
if [[ "$WARNINGS" -gt 0 && "$GPU" == "Not detected" ]]; then
    echo -e "  ${YELLOW}Tip: No GPU detected. Use 30–60 s chunk sizes for videos longer than 2 min.${RESET}"
fi
echo ""
