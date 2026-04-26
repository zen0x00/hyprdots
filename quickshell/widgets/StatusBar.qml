import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import "../components"

PanelWindow {
    id: bar

    property date clockDate
    property string cpuText: "CPU --"
    property string memText: "RAM --"
    property string batteryText: "BAT --"
    property string networkText: "NET --"
    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool powerMenuOpen: false
    property bool themeMenuOpen: false
    property var colors

    signal launcherRequested()
    signal controlCenterRequested()
    signal powerMenuRequested()
    signal themeMenuRequested()

    color: "transparent"
    implicitHeight: colors.barHeight
    exclusiveZone: colors.barHeight
    anchors {
        top: true
        left: true
        right: true
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            id: barSurface
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 4
            anchors.bottomMargin: 4
            radius: 8
            color: colors.bg
            border.width: 1
            border.color: colors.panelAlt
        }

        Item {
            anchors.fill: barSurface
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                MouseArea {
                    id: launcherArea
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bar.launcherRequested()

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: bar.launcherOpen ? colors.accent : launcherArea.containsMouse ? colors.panelAlt : "transparent"
                        border.width: 1
                        border.color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            color: bar.launcherOpen ? "#071015" : colors.accent
                            font.family: "Symbols Nerd Font Mono"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            text: ""
                        }
                    }
                }

                HyprWorkspaces {
                    colors: bar.colors
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 230
                height: 28
                radius: 8
                color: colors.panel
                border.width: 1
                border.color: "transparent"

                Text {
                    anchors.centerIn: parent
                    color: colors.fg
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    text: Qt.formatDateTime(bar.clockDate, "ddd, MMM d  h:mm AP")
                }
            }

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                StatusIcon { icon: "󰻠"; text: bar.cpuText; prefix: "CPU "; colors: bar.colors }
                StatusIcon { icon: "󰍛"; text: bar.memText; prefix: "RAM "; colors: bar.colors }
                StatusIcon { icon: "󰖩"; text: bar.networkText; prefix: "NET "; colors: bar.colors }
                StatusIcon {
                    icon: "󰁹"
                    text: bar.batteryText
                    prefix: "BAT "
                    colors: bar.colors
                    visible: text.length > 0 && value !== "--"
                }

                IconButton {
                    icon: "󰏘"
                    active: bar.themeMenuOpen
                    colors: bar.colors
                    onActivated: bar.themeMenuRequested()
                }

                IconButton {
                    icon: "⚙"
                    active: bar.controlCenterOpen
                    colors: bar.colors
                    onActivated: bar.controlCenterRequested()
                }

                IconButton {
                    icon: "⏻"
                    active: bar.powerMenuOpen
                    colors: bar.colors
                    onActivated: bar.powerMenuRequested()
                }

                TrayExpander {
                    colors: bar.colors
                }
            }
        }
    }

    component TrayExpander: Rectangle {
        id: tray

        property bool expanded: false
        property var colors
        readonly property int itemCount: SystemTray.items.values.length

        Layout.preferredHeight: 28
        Layout.preferredWidth: expanded ? Math.max(42, 32 + (itemCount * 28)) : 42
        radius: 8
        color: expanded ? colors.panelAlt : trayMouse.containsMouse ? colors.panelAlt : "transparent"
        border.width: 1
        border.color: "transparent"
        clip: true

        Behavior on Layout.preferredWidth {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 6

            MouseArea {
                id: trayMouse
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                cursorShape: Qt.PointingHandCursor
                onClicked: tray.expanded = !tray.expanded

                Text {
                    anchors.centerIn: parent
                    color: tray.expanded ? colors.accent : colors.fg
                    font.family: "Symbols Nerd Font Mono"
                    font.pixelSize: 14
                    text: tray.expanded ? "󰍡" : "󰀻"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: tray.expanded
                spacing: 4

                Repeater {
                    model: SystemTray.items

                    MouseArea {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: mouse => {
                            if (mouse.button == Qt.RightButton && modelData.hasMenu)
                                modelData.secondaryActivate();
                            else
                                modelData.activate();
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: parent.containsMouse ? colors.bg : "transparent"
                        }

                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 16
                            width: 16
                            height: 16
                            source: modelData.icon
                        }
                    }
                }
            }
        }
    }

    component IconButton: MouseArea {
        id: button

        property string icon: ""
        property bool active: false
        property var colors

        signal activated()

        Layout.preferredWidth: 30
        Layout.preferredHeight: 28
        cursorShape: Qt.PointingHandCursor
        onClicked: activated()

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: button.active ? button.colors.accent : button.containsMouse ? button.colors.panelAlt : "transparent"
            border.width: 1
            border.color: "transparent"

            Text {
                id: label
                anchors.centerIn: parent
                color: button.active ? "#071015" : button.colors.fg
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                text: button.icon
            }
        }
    }

    component StatusIcon: Rectangle {
        id: status

        property string icon: ""
        property string text: ""
        property string prefix: ""
        property var colors
        readonly property string value: text.replace(prefix, "")

        Layout.preferredHeight: 28
        Layout.preferredWidth: valueLabel.implicitWidth + 34
        radius: 8
        color: "transparent"
        border.width: 1
        border.color: "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 6

            Text {
                color: colors.accent
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: 13
                text: status.icon
            }

            Text {
                id: valueLabel
                color: colors.fg
                font.pixelSize: 12
                font.weight: Font.DemiBold
                text: status.value
            }
        }
    }
}
