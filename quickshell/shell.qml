import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "services"
import "widgets"

ShellRoot {
    id: root

    property bool launcherVisible: false
    property bool controlCenterVisible: false
    property bool powerMenuVisible: false
    property bool osdVisible: false
    property string osdIcon: ""
    property string osdLabel: ""
    property real osdValue: 0
    property string osdDetailText: ""
    property string lastCapsLockState: ""
    property string lastNumLockState: ""

    Component.onCompleted: Qt.application.font.family = "JetBrainsMono Nerd Font Propo"

    readonly property color bg:       Colors.bg
    readonly property color panel:    Colors.panel
    readonly property color panelAlt: Colors.panelAlt
    readonly property color fg:       Colors.fg
    readonly property color muted:    Colors.muted
    readonly property color accent:   Colors.accent
    readonly property color danger:   Colors.danger
    readonly property int barHeight: 58

    function toggleLauncher() {
        controlCenterVisible = false;
        powerMenuVisible = false;
        launcherVisible = !launcherVisible;
    }

    function closeLauncher() {
        launcherVisible = false;
    }

    function toggleControlCenter() {
        launcherVisible = false;
        powerMenuVisible = false;
        controlCenterVisible = !controlCenterVisible;
    }

    function togglePowerMenu() {
        launcherVisible = false;
        controlCenterVisible = false;
        powerMenuVisible = !powerMenuVisible;
    }

    function closeOverlays() {
        launcherVisible = false;
        controlCenterVisible = false;
        powerMenuVisible = false;
    }

    function showOsd(icon, label, value, detailText) {
        osdIcon = icon;
        osdLabel = label;
        osdValue = Math.max(0, Math.min(1, Number(value)));
        osdDetailText = detailText ? String(detailText) : "";
        osdVisible = true;
        osdHideTimer.restart();
    }

    function normalizeLockState(stateText) {
        const state = String(stateText || "").trim().toLowerCase();
        return state === "yes" || state === "on" || state === "1" ? "on" : "off";
    }

    function updateCapsLockState(stateText) {
        const state = normalizeLockState(stateText);
        if (lastCapsLockState.length > 0 && lastCapsLockState !== state)
            showOsd("⇪", "Caps Lock", state === "on" ? 1 : 0, state === "on" ? "On" : "Off");
        lastCapsLockState = state;
    }

    function updateNumLockState(stateText) {
        const state = normalizeLockState(stateText);
        if (lastNumLockState.length > 0 && lastNumLockState !== state)
            showOsd("󰎠", "Num Lock", state === "on" ? 1 : 0, state === "on" ? "On" : "Off");
        lastNumLockState = state;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Timer {
        id: osdHideTimer
        interval: 1200
        repeat: false
        onTriggered: root.osdVisible = false
    }

    IpcHandler {
        target: "shell"

        function toggleLauncher() {
            root.toggleLauncher();
        }

        function openLauncher() {
            root.closeOverlays();
            root.launcherVisible = true;
        }

        function closeLauncher() {
            root.launcherVisible = false;
        }

        function toggleControlCenter() {
            root.toggleControlCenter();
        }

        function openControlCenter() {
            root.closeOverlays();
            root.controlCenterVisible = true;
        }

        function closeControlCenter() {
            root.controlCenterVisible = false;
        }

        function togglePowerMenu() {
            root.togglePowerMenu();
        }

        function openPowerMenu() {
            root.closeOverlays();
            root.powerMenuVisible = true;
        }

        function closePowerMenu() {
            root.powerMenuVisible = false;
        }

        function closeAll() {
            root.closeOverlays();
        }

        function showOsd(icon: string, label: string, value: real, detailText: string) {
            root.showOsd(icon, label, value, detailText);
        }

        function volume(value: real) {
            root.showOsd(value <= 0 ? "󰝟" : "󰕾", "Volume", value);
        }

        function refreshAudio() {
            audioProbe.refresh();
        }

        function capsLock(state: string) {
            const enabled = state.toLowerCase() === "yes" || state.toLowerCase() === "on" || state === "1";
            root.showOsd("⇪", "Caps Lock", enabled ? 1 : 0, enabled ? "On" : "Off");
        }

        function numLock(state: string) {
            const enabled = state.toLowerCase() === "yes" || state.toLowerCase() === "on" || state === "1";
            root.showOsd("󰎠", "Num Lock", enabled ? 1 : 0, enabled ? "On" : "Off");
        }

        function brightness(value: real) {
            root.showOsd("󰃠", "Brightness", value);
        }

        function mic(value: real) {
            root.showOsd("󰍬", "Microphone", value);
        }
    }

    PollingCommand {
        id: cpuProbe
        interval: 5000
        fallback: "CPU --"
        command: ["sh", "-c", "top -bn1 | awk '/Cpu/ {printf \"CPU %.0f%%\", 100 - $8; exit}'"]
    }

    PollingCommand {
        id: memProbe
        interval: 8000
        fallback: "RAM --"
        command: ["sh", "-c", "free -m | awk '/Mem:/ {printf \"RAM %.0f%%\", ($3 / $2) * 100}'"]
    }

    PollingCommand {
        id: batteryProbe
        interval: 30000
        fallback: ""
        command: ["sh", "-c", "if command -v upower >/dev/null 2>&1; then dev=$(upower -e | grep -m1 BAT); [ -n \"$dev\" ] && upower -i \"$dev\" | awk '/percentage:/ {print \"BAT \" $2; exit}'; else cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 | awk '{print \"BAT \" $1 \"%\"}'; fi"]
    }

    PollingCommand {
        id: networkProbe
        interval: 10000
        fallback: "NET --"
        command: ["sh", "-c", "ip route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i == \"dev\") {print \"NET \" $(i+1); exit}}'"]
    }

    PollingCommand {
        id: titleProbe
        interval: 1200
        fallback: "Desktop"
        command: ["sh", "-c", "hyprctl activewindow 2>/dev/null | awk '/^[[:space:]]*title:/ {sub(/^[[:space:]]*title:[[:space:]]*/, \"\"); print; found=1; exit} END {if (!found) print \"Desktop\"}'"]
    }

    PollingCommand {
        id: audioProbe
        interval: 2000
        fallback: "VOL --"
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{if ($3 == \"[MUTED]\") {print \"VOL muted\"; exit} if ($2 != \"\") printf \"VOL %.0f%%\", $2 * 100; else print \"VOL --\"}'"]
    }

    PollingCommand {
        id: gpuProbe
        interval: 3000
        fallback: ""
        command: ["sh", "-c", "if command -v nvidia-smi >/dev/null 2>&1; then util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | awk 'NR==1{print int($1)}'); [ -n \"$util\" ] && [ \"$util\" -gt 0 ] && printf \"GPU %s%%\" \"$util\"; elif ls /sys/class/drm/card*/device/gpu_busy_percent >/dev/null 2>&1; then util=$(cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | awk '$1>max{max=$1} END{print int(max)}'); [ -n \"$util\" ] && [ \"$util\" -gt 0 ] && printf \"GPU %s%%\" \"$util\"; fi"]
    }

    PollingCommand {
        id: diskProbe
        interval: 30000
        fallback: "DISK --"
        command: ["sh", "-c", "df -h / 2>/dev/null | awk 'NR==2 {print \"DISK \" $5; exit}'"]
    }

    PollingCommand {
        id: capsLockProbe
        interval: 250
        fallback: "off"
        command: ["sh", "-c", "hyprctl devices 2>/dev/null | awk '/capsLock:/{caps=$2} /main: yes/{print caps; exit}'"]
        onTextChanged: root.updateCapsLockState(text)
    }

    PollingCommand {
        id: numLockProbe
        interval: 250
        fallback: "off"
        command: ["sh", "-c", "hyprctl devices 2>/dev/null | awk '/numLock:/{num=$2} /main: yes/{print num; exit}'"]
        onTextChanged: root.updateNumLockState(text)
    }

    PollingCommand {
        id: mediaTitleProbe
        interval: 2000
        fallback: ""
        command: ["sh", "-c", "playerctl metadata title 2>/dev/null"]
    }

    PollingCommand {
        id: mediaArtistProbe
        interval: 2000
        fallback: ""
        command: ["sh", "-c", "playerctl metadata artist 2>/dev/null"]
    }

    PollingCommand {
        id: mediaStatusProbe
        interval: 2000
        fallback: ""
        command: ["sh", "-c", "playerctl status 2>/dev/null"]
    }

    Variants {
        model: Quickshell.screens

        StatusBar {
            required property var modelData

            screen: modelData
            clockDate: clock.date
            windowTitle: titleProbe.text
            audioText: audioProbe.text
            cpuText: cpuProbe.text
            batteryText: batteryProbe.text
            networkText: networkProbe.text
            gpuText: gpuProbe.text
            onVolumeFeedbackRequested: (icon, value) => root.showOsd(icon, "Volume", value)
            onControlCenterRequested: root.toggleControlCenter()

            colors: QtObject {
                readonly property color bg: root.bg
                readonly property color panel: root.panel
                readonly property color panelAlt: root.panelAlt
                readonly property color fg: root.fg
                readonly property color muted: root.muted
                readonly property color accent: root.accent
                readonly property color danger: root.danger
                readonly property int barHeight: root.barHeight
            }
        }
    }

    Variants {
        model: Quickshell.screens

        AppLauncher {
            required property var modelData

            screen: modelData
            visible: root.launcherVisible
            topOffset: root.barHeight + 2
            onDismissed: root.closeLauncher()

            colors: QtObject {
                readonly property color bg: root.bg
                readonly property color panel: root.panel
                readonly property color panelAlt: root.panelAlt
                readonly property color fg: root.fg
                readonly property color muted: root.muted
                readonly property color accent: root.accent
            }
        }
    }

    Variants {
        model: Quickshell.screens

        ControlCenter {
            required property var modelData

            screen: modelData
            visible: root.controlCenterVisible
            topOffset: root.barHeight
            clockDate: clock.date
            cpuText: cpuProbe.text
            gpuText: gpuProbe.text
            memText: memProbe.text
            batteryText: batteryProbe.text
            diskText: diskProbe.text
            networkText: networkProbe.text
            mediaTitle: mediaTitleProbe.text
            mediaArtist: mediaArtistProbe.text
            mediaStatus: mediaStatusProbe.text
            onDismissed: root.closeOverlays()

            colors: QtObject {
                readonly property color bg: root.bg
                readonly property color panel: root.panel
                readonly property color panelAlt: root.panelAlt
                readonly property color fg: root.fg
                readonly property color muted: root.muted
                readonly property color accent: root.accent
                readonly property color danger: root.danger
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PowerMenu {
            required property var modelData

            screen: modelData
            visible: root.powerMenuVisible
            onDismissed: root.closeOverlays()

            colors: QtObject {
                readonly property color bg: root.bg
                readonly property color panel: root.panel
                readonly property color panelAlt: root.panelAlt
                readonly property color fg: root.fg
                readonly property color muted: root.muted
                readonly property color accent: root.accent
                readonly property color danger: root.danger
            }
        }
    }

    Variants {
        model: Quickshell.screens

        Osd {
            required property var modelData

            screen: modelData
            visible: root.osdVisible
            icon: root.osdIcon
            label: root.osdLabel
            value: root.osdValue
            detailText: root.osdDetailText

            colors: QtObject {
                readonly property color bg: root.bg
                readonly property color panel: root.panel
                readonly property color panelAlt: root.panelAlt
                readonly property color fg: root.fg
                readonly property color muted: root.muted
                readonly property color accent: root.accent
            }
        }
    }
}
