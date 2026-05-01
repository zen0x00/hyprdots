#!/usr/bin/env bash
# gaming-optimize.sh — auto-detects hardware, applies gaming optimizations
# Supports: AMD/Intel CPU | AMD/NVIDIA GPU | Desktop/Laptop
# Games tuned: Marvel Rivals, GTA V Enhanced, Black Myth: Wukong

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
log()  { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✗]${NC} $*"; }
info() { echo -e "${BLUE}[i]${NC} $*"; }
hdr()  { echo -e "\n${BOLD}── $* ──${NC}"; }

# Globals set by detect_hardware()
CPU_CHOICE=""   # amd | intel
GPU_CHOICE=""   # amd | nvidia
IS_LAPTOP=false
NVME_DEVS=""
SATA_SSD_DEVS=""
HDD_DEVS=""
AMD_DRM_CARD=""

# ── Root ──────────────────────────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && { err "Run as root: sudo $0"; exit 1; }

# ── Hardware Detection ────────────────────────────────────────────────────────
detect_hardware() {
    hdr "Hardware Detection"

    # CPU
    local cpu_vendor cpu_model
    cpu_vendor=$(grep -m1 "vendor_id" /proc/cpuinfo | awk '{print $3}')
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
    case "$cpu_vendor" in
        AuthenticAMD) CPU_CHOICE="amd" ;;
        GenuineIntel) CPU_CHOICE="intel" ;;
        *) err "Unknown CPU vendor: $cpu_vendor"; exit 1 ;;
    esac

    # GPU — use loaded driver module as ground truth, lspci for model name only
    local gpu_model
    if lsmod | grep -q "^nvidia "; then
        GPU_CHOICE="nvidia"
        gpu_model=$(lspci 2>/dev/null | grep -iE "VGA|3D|Display" | grep -i "nvidia" | sed 's/.*: //' | head -1)
        [[ -z "$gpu_model" ]] && gpu_model="NVIDIA GPU"
    elif lsmod | grep -q "^amdgpu "; then
        GPU_CHOICE="amd"
        gpu_model=$(lspci 2>/dev/null | grep -iE "VGA|3D|Display" | grep -iE "AMD|ATI|Radeon" | sed 's/.*: //' | head -1)
        [[ -z "$gpu_model" ]] && gpu_model="AMD GPU"
    else
        err "No amdgpu or nvidia kernel module loaded — is the driver installed?"
        exit 1
    fi

    # Laptop: BAT0/BAT1 only — excludes wireless device batteries (hidpp etc.)
    if ls /sys/class/power_supply/ 2>/dev/null | grep -qE "^BAT[0-9]"; then
        IS_LAPTOP=true
    else
        IS_LAPTOP=false
    fi

    # Storage
    NVME_DEVS=$(ls /sys/block/ 2>/dev/null | grep "nvme" || true)
    for dev in $(ls /sys/block/ 2>/dev/null | grep -E "^sd" || true); do
        rot=$(cat "/sys/block/$dev/queue/rotational" 2>/dev/null || echo "1")
        if [[ "$rot" == "0" ]]; then
            SATA_SSD_DEVS="$SATA_SSD_DEVS $dev"
        else
            HDD_DEVS="$HDD_DEVS $dev"
        fi
    done

    AMD_DRM_CARD=$(ls /sys/class/drm/ 2>/dev/null | grep -E "^card[0-9]+$" | head -1 || echo "")

    info "CPU      : $cpu_model ($CPU_CHOICE)"
    info "GPU      : $gpu_model ($GPU_CHOICE)"
    info "Type     : $(${IS_LAPTOP} && echo Laptop || echo Desktop)"
    [[ -n "$NVME_DEVS" ]]     && info "NVMe     : $NVME_DEVS"
    [[ -n "$SATA_SSD_DEVS" ]] && info "SATA SSD :$SATA_SSD_DEVS"
    [[ -n "$HDD_DEVS" ]]      && info "HDD      :$HDD_DEVS"
}

# ── CPU ───────────────────────────────────────────────────────────────────────
optimize_cpu() {
    hdr "CPU ($CPU_CHOICE)"

    local gov="performance"
    local epp="performance"

    # Intel laptop: avoid thermal throttle with balance_performance EPP
    if [[ "$IS_LAPTOP" == "true" && "$CPU_CHOICE" == "intel" ]]; then
        epp="balance_performance"
        warn "Laptop Intel: EPP → balance_performance (avoids thermal throttle)"
    fi

    local changed=0
    for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$gov" > "$f" 2>/dev/null && changed=1
    done
    [[ $changed -eq 1 ]] && log "Governor → $gov" || warn "Could not set governor (pstate driver active?)"

    changed=0
    for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        echo "$epp" > "$f" 2>/dev/null && changed=1
    done
    [[ $changed -eq 1 ]] && log "EPP → $epp" || warn "EPP not available"

    if [[ "$IS_LAPTOP" == "true" ]]; then
        warn "Laptop: C-state disable skipped (would kill battery)"
    fi
}

# ── GPU ───────────────────────────────────────────────────────────────────────
optimize_gpu_amd() {
    hdr "GPU (AMD)"

    if [[ -z "$AMD_DRM_CARD" ]]; then
        warn "No AMD DRM card found — check amdgpu driver is loaded"
        return
    fi

    local card="/sys/class/drm/${AMD_DRM_CARD}/device"

    echo "high" > "${card}/power_dpm_force_performance_level" 2>/dev/null && \
        log "Power level → high" || warn "Could not set power level"

    echo "1" > "${card}/pp_power_profile_mode" 2>/dev/null && \
        log "Power profile → 3D_FULL_SCREEN (profile 1)" || warn "Could not set power profile"
}

optimize_gpu_nvidia() {
    hdr "GPU (NVIDIA)"

    if ! command -v nvidia-smi &>/dev/null; then
        warn "nvidia-smi not found — install nvidia-utils"
        return
    fi

    nvidia-smi -pm 1 &>/dev/null      && log "Persistence mode → enabled"   || warn "Persistence mode failed"
    nvidia-smi --auto-boost-default=0 &>/dev/null && log "Auto-boost → disabled" || true

    local max_power
    max_power=$(nvidia-smi --query-gpu=power.max_limit --format=csv,noheader,nounits 2>/dev/null | tr -d ' ' | head -1 || echo "")
    if [[ -n "$max_power" && "$max_power" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        nvidia-smi -pl "$max_power" &>/dev/null && log "Power limit → max (${max_power}W)" || warn "Could not set power limit"
    fi

    if command -v nvidia-settings &>/dev/null && [[ -n "${DISPLAY:-}" ]]; then
        nvidia-settings -a GPUPowerMizerMode=1 &>/dev/null && \
            log "PowerMizer → prefer max performance" || warn "nvidia-settings failed"
    else
        warn "DISPLAY not set — run after login: nvidia-settings -a GPUPowerMizerMode=1"
    fi
}

# ── IO Schedulers ─────────────────────────────────────────────────────────────
optimize_io() {
    hdr "IO Schedulers"

    for dev in $NVME_DEVS; do
        echo none > "/sys/block/$dev/queue/scheduler" 2>/dev/null && \
            log "$dev (NVMe) → none" || warn "$dev: could not set scheduler"
    done

    for dev in $SATA_SSD_DEVS; do
        echo mq-deadline > "/sys/block/$dev/queue/scheduler" 2>/dev/null && \
            log "$dev (SATA SSD) → mq-deadline" || warn "$dev: could not set scheduler"
    done

    for dev in $HDD_DEVS; do
        echo bfq > "/sys/block/$dev/queue/scheduler" 2>/dev/null && \
            log "$dev (HDD) → bfq" || warn "$dev: could not set scheduler"
    done
}

# ── Gamemode ──────────────────────────────────────────────────────────────────
setup_gamemode() {
    hdr "Gamemode"

    if ! command -v gamemoded &>/dev/null; then
        warn "gamemode not installed — skipping (pacman -S gamemode)"
        return
    fi

    local gpu_section=""
    case "$GPU_CHOICE" in
        amd)
            gpu_section="[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=1
amd_performance_level=high"
            ;;
        nvidia)
            gpu_section="[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=0
nv_powermizer_mode=1"
            ;;
    esac

    cat > /etc/gamemode.ini <<EOF
[general]
reaper_freq=100
defaultgov=performance
softrealtime=on
renice=-19

$gpu_section
EOF
    log "/etc/gamemode.ini written"
    systemctl enable --now gamemoded 2>/dev/null && log "gamemoded enabled + started" || \
        warn "gamemoded service unavailable (relogin may be needed)"
}

# ── udev Rules ────────────────────────────────────────────────────────────────
setup_udev() {
    hdr "udev Rules (persistent)"

    cat > /etc/udev/rules.d/50-gaming-perf.rules <<'UDEV'
# CPU governor + EPP
ACTION=="add", SUBSYSTEM=="cpu", ATTR{cpufreq/scaling_governor}="performance"
ACTION=="add", SUBSYSTEM=="cpu", ATTR{cpufreq/energy_performance_preference}="performance"

# NVMe — bypass scheduler
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"

# SATA SSD — deadline
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"

# HDD — bfq
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
UDEV

    if [[ "$GPU_CHOICE" == "amd" ]]; then
        cat >> /etc/udev/rules.d/50-gaming-perf.rules <<'UDEV'

# AMD GPU — high performance + 3D_FULL_SCREEN profile
ACTION=="add", KERNEL=="card[0-9]", SUBSYSTEM=="drm", ATTR{device/power_dpm_force_performance_level}="high"
ACTION=="add", KERNEL=="card[0-9]", SUBSYSTEM=="drm", ATTR{device/pp_power_profile_mode}="1"
UDEV
    fi

    udevadm control --reload-rules && log "udev rules written + reloaded"
}

# ── sysctl ────────────────────────────────────────────────────────────────────
setup_sysctl() {
    hdr "sysctl"

    cat > /etc/sysctl.d/99-gaming.conf <<EOF
# BORE scheduler — lower burst penalty for game responsiveness
kernel.sched_burst_penalty_scale = 1280

# No background memory compaction jitter during gaming
vm.compaction_proactiveness = 0
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
EOF

    if [[ "$IS_LAPTOP" == "false" ]]; then
        cat >> /etc/sysctl.d/99-gaming.conf <<EOF

# Desktop: explicit dirty thresholds (fast NVMe handles this)
vm.dirty_bytes = 268435456
vm.dirty_background_bytes = 67108864
EOF
    fi

    sysctl --system &>/dev/null && log "sysctl applied"
}

# ── IRQ Pinning (AMD GPU, desktop only) ───────────────────────────────────────
setup_irq_pinning() {
    [[ "$GPU_CHOICE" != "amd" || "$IS_LAPTOP" == "true" ]] && return

    hdr "IRQ Pinning (AMD Desktop)"

    cat > /usr/local/bin/pin-gaming-irqs <<'SCRIPT'
#!/usr/bin/env bash
# Pin amdgpu IRQ to core 5, NVMe IRQs to cores 4-5
# Keeps GPU/storage interrupts away from game process cores 0-3

AMDGPU_IRQ=$(awk -F: '/amdgpu/{gsub(/ /,"",$1); print $1; exit}' /proc/interrupts)
if [[ -n "$AMDGPU_IRQ" ]]; then
    echo 20 > "/proc/irq/${AMDGPU_IRQ}/smp_affinity"  # 0x20 = CPU5
    echo "[+] amdgpu IRQ ${AMDGPU_IRQ} → CPU5"
fi

while IFS= read -r irq; do
    echo 30 > "/proc/irq/${irq}/smp_affinity" 2>/dev/null  # 0x30 = CPU4+5
done < <(awk -F: '/nvme/{gsub(/ /,"",$1); print $1}' /proc/interrupts)
echo "[+] NVMe IRQs → CPUs 4-5"
SCRIPT
    chmod +x /usr/local/bin/pin-gaming-irqs

    cat > /etc/systemd/system/gaming-irq-pin.service <<'SVC'
[Unit]
Description=Pin GPU/NVMe IRQs for low-latency gaming
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/pin-gaming-irqs
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SVC

    systemctl daemon-reload
    systemctl enable --now gaming-irq-pin.service
    log "IRQ pinning service installed + started"
}

# ── MangoHud ──────────────────────────────────────────────────────────────────
setup_mangohud() {
    hdr "MangoHud"

    local config_dir="/home/${SUDO_USER:-$USER}/.config/MangoHud"
    mkdir -p "$config_dir"

    cat > "$config_dir/MangoHud.conf" <<'EOF'
fps
frametime
frame_timing
cpu_load
gpu_load
gpu_temp
cpu_temp
gpu_core_clock
gpu_mem_clock
vram
ram
EOF

    chown -R "${SUDO_USER:-$USER}:${SUDO_USER:-$USER}" "$config_dir" 2>/dev/null || true
    log "~/.config/MangoHud/MangoHud.conf written"
    info "Enable per game: prepend MANGOHUD=1 to Steam launch options"
}

# ── Kernel Cmdline ────────────────────────────────────────────────────────────
suggest_kernel_cmdline() {
    hdr "Kernel Cmdline (manual step required)"
    echo ""
    warn "Edit /etc/kernel/cmdline, then run: sudo reinstall-kernels && reboot"
    echo ""

    local common="nowatchdog split_lock_detect=off"
    local cpu_param=""

    case "$CPU_CHOICE" in
        amd)   cpu_param="amd_pstate=active amd_pstate_epp=performance" ;;
        intel) cpu_param="intel_pstate=active" ;;
    esac

    if [[ "$IS_LAPTOP" == "false" ]]; then
        echo "  ADD: $common processor.max_cstate=1 idle=nomwait threadirqs mitigations=off $cpu_param"
    else
        local laptop_epp=""
        [[ "$CPU_CHOICE" == "amd" ]] && laptop_epp="amd_pstate=active amd_pstate_epp=balance_performance" || laptop_epp="intel_pstate=active"
        echo "  ADD: $common $laptop_epp"
        warn "Laptop: processor.max_cstate=1 + mitigations=off intentionally omitted"
    fi
    echo ""
}

# ── Steam Launch Options ──────────────────────────────────────────────────────
print_steam_options() {
    hdr "Steam Launch Options"
    echo ""

    case "$GPU_CHOICE" in
        amd)
            local base="RADV_PERFTEST=gpl,nggc VKD3D_CONFIG=nodxr,pipeline_library_app_cache PROTON_LOG=0 gamemoderun"
            echo "Marvel Rivals:"
            echo "  $base %command% -dx12 -NoVerifyGC"
            echo ""
            echo "GTA V Enhanced:"
            echo "  $base %command%"
            echo ""
            echo "Black Myth: Wukong:"
            echo "  RADV_PERFTEST=gpl,nggc,afmf2 VKD3D_CONFIG=nodxr,pipeline_library_app_cache PROTON_LOG=0 gamemoderun %command% -dx12"
            ;;
        nvidia)
            local base="__GL_THREADED_OPTIMIZATIONS=1 PROTON_ENABLE_NVAPI=1 DXVK_ENABLE_NVAPI=1 VKD3D_CONFIG=nodxr,pipeline_library_app_cache PROTON_LOG=0 gamemoderun"
            echo "Marvel Rivals:"
            echo "  $base %command% -dx12 -NoVerifyGC"
            echo ""
            echo "GTA V Enhanced:"
            echo "  $base %command%"
            echo ""
            echo "Black Myth: Wukong:"
            echo "  $base %command% -dx12"

            if [[ "$IS_LAPTOP" == "true" ]]; then
                echo ""
                info "Laptop PRIME — prepend if game runs on iGPU instead of dGPU:"
                echo "  __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia"
                echo ""
                info "Full example (Marvel Rivals forced to dGPU):"
                echo "  __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia $base %command% -dx12 -NoVerifyGC"
            fi
            ;;
    esac

    echo ""
    info "Use GE-Proton (latest) for all three games — install via ProtonUp-Qt"
    echo ""
}

# ── BIOS Tips ─────────────────────────────────────────────────────────────────
print_bios_tips() {
    hdr "BIOS Recommendations (manual)"
    echo ""
    case "$CPU_CHOICE" in
        amd)
            echo "  • EXPO/XMP              → Enable"
            echo "  • Precision Boost Overdrive (PBO) → Enable / Advanced"
            echo "  • Curve Optimizer       → All-core -10, push to -20/-30 if stable"
            echo "  • FCLK                  → RAM speed ÷ 2  (DDR5-6000 → 2000MHz)"
            echo "  • CPU power limits      → Remove / set max"
            ;;
        intel)
            echo "  • XMP/DOCP              → Enable"
            echo "  • PL1 / PL2 power limits → Set to max or remove"
            echo "  • Intel Turbo Boost     → Enable"
            if [[ "$IS_LAPTOP" == "true" ]]; then
                echo "  • Check thermal paste — repaste if >2 years old"
            fi
            ;;
    esac
    echo ""
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    echo -e "\n${BOLD}════════════════════════════════════════${NC}"
    echo -e "${BOLD}  Gaming Performance Optimizer${NC}"
    echo -e "${BOLD}════════════════════════════════════════${NC}"

    detect_hardware

    optimize_cpu

    case "$GPU_CHOICE" in
        amd)    optimize_gpu_amd ;;
        nvidia) optimize_gpu_nvidia ;;
    esac

    optimize_io
    setup_gamemode
    setup_udev
    setup_sysctl
    setup_irq_pinning
    setup_mangohud
    suggest_kernel_cmdline
    print_bios_tips
    print_steam_options

    hdr "Done"
    log "Immediate optimizations applied."
    log "Kernel cmdline: edit manually → sudo reinstall-kernels → reboot"
    echo ""
}

main "$@"
