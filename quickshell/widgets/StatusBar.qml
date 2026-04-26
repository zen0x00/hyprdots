import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Widgets

PanelWindow {
    id: bar

    property date clockDate
    property string windowTitle: "Desktop"
    property string audioText: "VOL --"
    property string cpuText: "CPU --"
    property string batteryText: ""
    property string networkText: "NET --"
    property string gpuText: ""
    property string displayedAudioText: audioText
    property bool calendarVisible: false
    property var colors

    signal volumeFeedbackRequested(icon: string, value: real)
    signal controlCenterRequested()

    readonly property QtObject ui: QtObject {
        readonly property string clear: "transparent"
        readonly property string iconFont: "Symbols Nerd Font Mono"

        readonly property int shellInsetX: 12
        readonly property int shellInsetY: 8
        readonly property int shellPaddingX: 10
        readonly property int shellPaddingY: 5
        readonly property int sectionGap: 8
        readonly property int moduleGap: 3
        readonly property int contentGap: 4
        readonly property int rightItemGap: 6
        readonly property int rightInlineGap: 3
        readonly property int rightClusterGap: 6
        readonly property int rightEdgePadding: 4
        readonly property int separatorWidth: 1
        readonly property int separatorHeight: 14
        readonly property int moduleHeight: 24
        readonly property int modulePaddingX: 4
        readonly property int moduleRadius: 12
        readonly property int titleIdealWidth: 280
        readonly property int titleRevealWidth: 88
        readonly property int titleMinWidth: 0
        readonly property int clockWidth: 100
        readonly property int clockFontSize: 12
        readonly property int titleFontSize: 11
        readonly property int textFontSize: 10
        readonly property int iconFontSize: 12
        readonly property int rightTextFontSize: 9
        readonly property int rightIconFontSize: 11
        readonly property int trayTouchSize: moduleHeight
        readonly property int trayIconSize: 15
        readonly property int borderWidth: 1
        readonly property int animationDuration: 150
        readonly property real hoverScale: 1.03
        readonly property real activeScale: 1.06
        readonly property real pressedScale: 0.98
        readonly property int calendarWidth: 220
        readonly property int calendarPadding: 12
        readonly property int calendarHeaderFontSize: 12
        readonly property int calendarWeekdayFontSize: 10
        readonly property int calendarDayFontSize: 11
        readonly property int calendarCellSize: 24
        readonly property int calendarGridSpacing: 4
        readonly property int calendarSectionGap: 8
        readonly property int calendarTopMargin: 8
        readonly property int calendarHeight: (calendarPadding * 2) + calendarHeaderFontSize + calendarSectionGap + calendarWeekdayFontSize + calendarSectionGap + (calendarCellSize * 6) + (calendarGridSpacing * 5)
        readonly property color shellFill: Qt.alpha(colors.panelAlt, 0.95)
        readonly property color shellBorder: Qt.alpha(colors.accent, 0.1)
        readonly property color separator: Qt.alpha(colors.muted, 0.22)
        readonly property color moduleHoverFill: Qt.alpha(colors.panel, 0.54)
        readonly property color moduleHoverBorder: Qt.alpha(colors.accent, 0.0)
        readonly property color groupFill: ui.clear
        readonly property color groupBorder: ui.clear
        readonly property color textPrimary: colors.fg
        readonly property color textSecondary: Qt.alpha(colors.fg, 0.84)
        readonly property color textMuted: colors.muted
        readonly property color textAccent: colors.accent
        readonly property color textAlert: colors.danger
        readonly property color workspaceActiveFill: Qt.alpha(colors.accent, 0.92)
        readonly property color workspaceHoverFill: Qt.alpha(colors.panel, 0.8)
        readonly property color workspaceActiveText: colors.bg
        readonly property color workspaceUrgent: colors.danger
        readonly property color workspaceIdleText: colors.muted
        readonly property color workspaceBusyText: colors.fg
        readonly property color stateAlertFill: Qt.alpha(colors.danger, 0.12)
        readonly property color stateAlertBorder: Qt.alpha(colors.danger, 0.26)
    }

    readonly property string resolvedTitle: displayTitle(windowTitle)
    readonly property int rightSectionReserveWidth: Math.ceil(clockLabel.implicitWidth) + trayPill.collapsedWidth + bellButton.width + (ui.rightInlineGap * 2) + ui.rightEdgePadding
    readonly property int sideReserveWidth: Math.max(leftSection.width, rightSectionReserveWidth)
    readonly property int titleLaneInset: sideReserveWidth + (ui.sectionGap * 2)
    readonly property int titleWidthBudget: Math.max(
        ui.titleMinWidth,
        Math.floor(shellContent.width - (titleLaneInset * 2))
    )
    readonly property bool showTitle: titleWidthBudget >= ui.titleRevealWidth

    color: ui.clear
    implicitHeight: colors.barHeight + (calendarVisible ? ui.calendarHeight + ui.calendarTopMargin : 0)
    exclusiveZone: colors.barHeight
    anchors {
        top: true
        left: true
        right: true
    }

    Process {
        id: volumeRunner

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const output = text.trim();
                if (output.length > 0)
                    bar.applyAudioState(output, true);
            }
        }
    }

    function stripPrefix(source, prefix) {
        const value = String(source || "");
        return value.indexOf(prefix) === 0 ? value.slice(prefix.length) : value;
    }

    function numericValue(source, prefix) {
        const numeric = Number(stripPrefix(source, prefix).replace(/[^0-9.]/g, ""));
        return isNaN(numeric) ? -1 : numeric;
    }

    function displayTitle(source) {
        const value = String(source || "").trim();
        return value.length > 0 ? value : "Desktop";
    }

    function calendarMonthTitle() {
        return Qt.formatDateTime(clockDate, "MMMM yyyy");
    }

    function calendarWeekdayLabel(index) {
        return ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"][index];
    }

    function calendarMonthStart() {
        return new Date(clockDate.getFullYear(), clockDate.getMonth(), 1);
    }

    function calendarMonthDayCount() {
        return new Date(clockDate.getFullYear(), clockDate.getMonth() + 1, 0).getDate();
    }

    function calendarStartOffset() {
        return (calendarMonthStart().getDay() + 6) % 7;
    }

    function calendarDayNumber(index) {
        return index - calendarStartOffset() + 1;
    }

    function calendarCellVisible(index) {
        const day = calendarDayNumber(index);
        return day >= 1 && day <= calendarMonthDayCount();
    }

    function calendarCellToday(index) {
        return calendarCellVisible(index)
            && calendarDayNumber(index) === clockDate.getDate();
    }

    function audioDisplay() {
        const value = stripPrefix(displayedAudioText, "VOL ");
        return value.length > 0 ? value : "--";
    }

    function isMuted() {
        return audioDisplay().toLowerCase().indexOf("muted") !== -1;
    }

    function audioIcon() {
        const value = audioDisplay().toLowerCase();
        if (value.indexOf("muted") !== -1)
            return "󰝟";

        const level = numericValue(displayedAudioText, "VOL ");
        if (level < 0 || level < 34)
            return "󰕿";
        if (level < 68)
            return "󰖀";

        return "󰕾";
    }

    function networkIcon() {
        const value = stripPrefix(networkText, "NET ").toLowerCase();
        if (value === "--" || value.length === 0)
            return "󰖪";
        if (value.indexOf("wl") === 0)
            return "󰖩";
        if (value.indexOf("en") === 0 || value.indexOf("eth") === 0)
            return "󰈀";

        return "󰖩";
    }

    function batteryIcon() {
        const level = numericValue(batteryText, "BAT ");
        if (level < 0)
            return "󰂑";
        if (level < 15)
            return "󰁺";
        if (level < 35)
            return "󰁼";
        if (level < 60)
            return "󰁿";
        if (level < 85)
            return "󰂀";

        return "󰁹";
    }

    function batteryLevelValue() {
        return numericValue(batteryText, "BAT ");
    }

    function isBatteryLow() {
        const level = batteryLevelValue();
        return level >= 0 && level < 25;
    }

    function isBatteryCritical() {
        const level = batteryLevelValue();
        return level >= 0 && level < 12;
    }

    function networkDisplay() {
        const value = stripPrefix(networkText, "NET ");
        return value === "--" || value.length === 0 ? "Offline" : value;
    }

    function isNetworkOffline() {
        return networkDisplay() === "Offline";
    }

    function segmentScale(mouseArea, emphasized) {
        if (mouseArea && mouseArea.pressed)
            return ui.pressedScale;
        if (mouseArea && mouseArea.containsMouse)
            return emphasized ? ui.activeScale : ui.hoverScale;
        return 1;
    }

    function segmentFill(hovered, alert) {
        if (alert)
            return ui.stateAlertFill;
        if (hovered)
            return ui.moduleHoverFill;
        return ui.clear;
    }

    function segmentBorder(hovered, alert) {
        return ui.clear;
    }

    function audioAccentColor() {
        return isMuted() ? ui.textAlert : ui.textAccent;
    }

    function audioTextColor() {
        return isMuted() ? ui.textSecondary : ui.textPrimary;
    }

    function statsIconColor() {
        return Qt.alpha(ui.textMuted, 0.82);
    }

    function statsTextColor() {
        return Qt.alpha(ui.textPrimary, 0.56);
    }

    function networkAccentColor() {
        return isNetworkOffline() ? ui.textAlert : Qt.alpha(ui.textAccent, 0.9);
    }

    function networkTextColor() {
        return isNetworkOffline() ? ui.textSecondary : Qt.alpha(ui.textPrimary, 0.82);
    }

    function batteryAccentColor() {
        return isBatteryLow() ? ui.textAlert : ui.textAccent;
    }

    function batteryTextColor() {
        return isBatteryLow() ? ui.textSecondary : ui.textPrimary;
    }

    function adjustVolume(delta) {
        if (delta > 0) {
            volumeRunner.exec(["sh", "-c", "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ >/dev/null 2>&1; wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{if ($3 == \"[MUTED]\") {print \"VOL muted\"; exit} if ($2 != \"\") printf \"VOL %.0f%%\", $2 * 100; else print \"VOL --\"}'"]);
            return;
        }

        if (delta < 0)
            volumeRunner.exec(["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- >/dev/null 2>&1; wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{if ($3 == \"[MUTED]\") {print \"VOL muted\"; exit} if ($2 != \"\") printf \"VOL %.0f%%\", $2 * 100; else print \"VOL --\"}'"]);
    }

    function toggleMute() {
        volumeRunner.exec(["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null 2>&1; wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{if ($3 == \"[MUTED]\") {print \"VOL muted\"; exit} if ($2 != \"\") printf \"VOL %.0f%%\", $2 * 100; else print \"VOL --\"}'"]);
    }

    function audioLevel() {
        const value = audioDisplay().toLowerCase();
        if (value.indexOf("muted") !== -1)
            return 0;

        const level = numericValue(displayedAudioText, "VOL ");
        return level < 0 ? 0 : Math.max(0, Math.min(1, level / 100));
    }

    function applyAudioState(sourceText, showOsd) {
        displayedAudioText = sourceText;
        if (showOsd)
            volumeFeedbackRequested(audioIcon(), audioLevel());
    }

    onAudioTextChanged: applyAudioState(audioText, false)

    Rectangle {
        id: shellSurface
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: ui.shellInsetX
        anchors.rightMargin: ui.shellInsetX
        anchors.topMargin: ui.shellInsetY
        height: colors.barHeight - (ui.shellInsetY * 2)
        radius: (height / 2)
        color: ui.shellFill
        border.width: ui.borderWidth
        border.color: ui.shellBorder

        Item {
            id: shellContent
            anchors.fill: parent
            anchors.leftMargin: ui.shellPaddingX
            anchors.rightMargin: ui.shellPaddingX
            anchors.topMargin: ui.shellPaddingY
            anchors.bottomMargin: ui.shellPaddingY

            Item {
                id: leftSection
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: leftRow.width
                height: ui.moduleHeight

                Row {
                    id: leftRow
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: ui.sectionGap

                    HyprWorkspaces {
                        id: workspaceStrip
                        anchors.verticalCenter: parent.verticalCenter
                        tokens: bar.ui
                    }
                }
            }

            Item {
                id: centerSection
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: bar.titleLaneInset
                anchors.rightMargin: bar.titleLaneInset
                anchors.verticalCenter: parent.verticalCenter
                height: ui.moduleHeight
                visible: bar.showTitle
                scale: bar.segmentScale(titleMouse, false)

                Behavior on scale {
                    NumberAnimation {
                        duration: ui.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: ui.textPrimary
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: ui.titleFontSize
                    font.weight: Font.Bold
                    text: bar.resolvedTitle
                }

                MouseArea {
                    id: titleMouse
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.ArrowCursor
                    hoverEnabled: false
                }
            }

            Item {
                id: rightSection
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: rightRow.width + ui.rightEdgePadding
                height: ui.moduleHeight

                Row {
                    id: rightRow
                    anchors.right: parent.right
                    anchors.rightMargin: ui.rightEdgePadding
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: ui.rightInlineGap

                    CollapsibleTray {
                        id: trayPill
                        anchors.verticalCenter: parent.verticalCenter
                        tokens: bar.ui
                        onClicked: expanded = !expanded
                    }

                    Item {
                        id: clockButton
                        width: Math.ceil(clockLabel.implicitWidth)
                        height: ui.moduleHeight
                        anchors.verticalCenter: parent.verticalCenter
                        scale: bar.segmentScale(clockMouse, true)

                        Behavior on scale {
                            NumberAnimation {
                                duration: ui.animationDuration
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            id: clockLabel
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            color: ui.textPrimary
                            font.pixelSize: ui.clockFontSize
                            font.weight: Font.DemiBold
                            text: Qt.formatDateTime(bar.clockDate, "hh:mm AP")
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            id: clockMouse
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: bar.calendarVisible = !bar.calendarVisible
                        }
                    }

                    Item {
                        id: bellButton
                        width: ui.moduleHeight
                        height: ui.moduleHeight
                        anchors.verticalCenter: parent.verticalCenter
                        scale: bar.segmentScale(bellMouse, false)

                        Behavior on scale {
                            NumberAnimation {
                                duration: ui.animationDuration
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            color: ui.textSecondary
                            font.family: ui.iconFont
                            font.pixelSize: ui.rightIconFontSize + 2
                            text: "󰂚"
                        }

                        MouseArea {
                            id: bellMouse
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                bar.calendarVisible = false;
                                bar.controlCenterRequested();
                            }
                        }
                    }
                }

                Rectangle {
                    id: calendarPopup
                    visible: bar.calendarVisible
                    width: ui.calendarWidth
                    height: ui.calendarHeight
                    x: ui.shellPaddingX + rightSection.width - width
                    y: rightRow.y + rightRow.height + ui.calendarTopMargin
                    radius: ui.moduleRadius
                    color: colors.panel
                    border.width: ui.borderWidth
                    border.color: ui.shellBorder

                    Column {
                        anchors.fill: parent
                        anchors.margins: ui.calendarPadding
                        spacing: ui.calendarSectionGap

                        Text {
                            width: parent.width
                            color: ui.textPrimary
                            font.pixelSize: ui.calendarHeaderFontSize
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            text: bar.calendarMonthTitle()
                        }

                        Row {
                            spacing: ui.calendarGridSpacing

                            Repeater {
                                model: 7

                                Text {
                                    width: ui.calendarCellSize
                                    color: ui.textMuted
                                    font.pixelSize: ui.calendarWeekdayFontSize
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                    text: bar.calendarWeekdayLabel(index)
                                }
                            }
                        }

                        Grid {
                            columns: 7
                            rowSpacing: ui.calendarGridSpacing
                            columnSpacing: ui.calendarGridSpacing

                            Repeater {
                                model: 42

                                Rectangle {
                                    width: ui.calendarCellSize
                                    height: ui.calendarCellSize
                                    radius: ui.calendarCellSize / 2
                                    color: bar.calendarCellToday(index) ? ui.workspaceActiveFill : ui.clear

                                    Text {
                                        anchors.centerIn: parent
                                        visible: bar.calendarCellVisible(index)
                                        color: bar.calendarCellToday(index) ? ui.workspaceActiveText : ui.textPrimary
                                        font.pixelSize: ui.calendarDayFontSize
                                        font.weight: bar.calendarCellToday(index) ? Font.Bold : Font.Medium
                                        text: String(bar.calendarDayNumber(index))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
