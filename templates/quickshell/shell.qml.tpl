import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland

import "services"
import "widgets"

ShellRoot {
    id: root

    property bool launcherVisible: false
    property bool controlCenterVisible: false
    property bool powerMenuVisible: false
    property bool themeMenuVisible: false
    property bool osdVisible: false
    property string osdIcon: ""
    property string osdLabel: ""
    property real osdValue: 0

    readonly property color bg: "{{ semantic.bg }}"
    readonly property color panel: "{{ semantic.panel }}"
    readonly property color panelAlt: "{{ semantic.panel_alt }}"
    readonly property color fg: "{{ semantic.fg }}"
    readonly property color muted: "{{ semantic.muted }}"
    readonly property color accent: "{{ semantic.accent }}"
    readonly property color danger: "{{ semantic.danger }}"
    readonly property int barHeight: 44

    function toggleLauncher() {
        controlCenterVisible = false;
        powerMenuVisible = false;
        themeMenuVisible = false;
        launcherVisible = !launcherVisible;
    }

    function closeLauncher() {
        launcherVisible = false;
    }

    function toggleControlCenter() {
        launcherVisible = false;
        powerMenuVisible = false;
        themeMenuVisible = false;
        controlCenterVisible = !controlCenterVisible;
    }

    function togglePowerMenu() {
        launcherVisible = false;
        controlCenterVisible = false;
        themeMenuVisible = false;
        powerMenuVisible = !powerMenuVisible;
    }

    function toggleThemeMenu() {
        launcherVisible = false;
        controlCenterVisible = false;
        powerMenuVisible = false;
        themeMenuVisible = !themeMenuVisible;
    }

    function closeOverlays() {
        launcherVisible = false;
        controlCenterVisible = false;
        powerMenuVisible = false;
        themeMenuVisible = false;
    }

    function showOsd(icon, label, value) {
        osdIcon = icon;
        osdLabel = label;
        osdValue = Math.max(0, Math.min(1, Number(value)));
        osdVisible = true;
        osdHideTimer.restart();
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

    NotificationServer {
        id: notifications
        keepOnReload: false
        bodySupported: true
        actionsSupported: true
        imageSupported: true
        persistenceSupported: false
        onNotification: notification => notification.tracked = true
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

        function toggleThemeMenu() {
            root.toggleThemeMenu();
        }

        function openThemeMenu() {
            root.closeOverlays();
            root.themeMenuVisible = true;
        }

        function closeThemeMenu() {
            root.themeMenuVisible = false;
        }

        function closeAll() {
            root.closeOverlays();
        }

        function showOsd(icon: string, label: string, value: real) {
            root.showOsd(icon, label, value);
        }

        function volume(value: real) {
            root.showOsd("󰕾", "Volume", value);
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

    Variants {
        model: Quickshell.screens

        StatusBar {
            required property var modelData

            screen: modelData
            clockDate: clock.date
            cpuText: cpuProbe.text
            memText: memProbe.text
            batteryText: batteryProbe.text
            networkText: networkProbe.text
            controlCenterOpen: root.controlCenterVisible
            powerMenuOpen: root.powerMenuVisible
            themeMenuOpen: root.themeMenuVisible
            launcherOpen: root.launcherVisible
            onLauncherRequested: root.toggleLauncher()
            onControlCenterRequested: root.toggleControlCenter()
            onPowerMenuRequested: root.togglePowerMenu()
            onThemeMenuRequested: root.toggleThemeMenu()

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
            topOffset: root.barHeight + 10
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
            topOffset: root.barHeight + 10
            clockDate: clock.date
            cpuText: cpuProbe.text
            memText: memProbe.text
            batteryText: batteryProbe.text
            networkText: networkProbe.text
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

        ThemeMenu {
            required property var modelData

            screen: modelData
            visible: root.themeMenuVisible
            topOffset: root.barHeight + 10
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

        NotificationToasts {
            required property var modelData

            screen: modelData
            topOffset: root.barHeight + 12
            server: notifications

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
