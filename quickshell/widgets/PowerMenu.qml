import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: menu

    property var colors

    signal dismissed()

    color: "transparent"
    focusable: true
    aboveWindows: true
    exclusiveZone: 0
    implicitWidth: 430
    implicitHeight: 160
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins {
        left: Math.max(20, Math.round((menu.screen.width - menu.implicitWidth) / 2))
        right: Math.max(20, Math.round((menu.screen.width - menu.implicitWidth) / 2))
        top: Math.max(20, Math.round((menu.screen.height - menu.implicitHeight) / 2))
        bottom: Math.max(20, Math.round((menu.screen.height - menu.implicitHeight) / 2))
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: colors.bg
        border.width: 1
        border.color: colors.panelAlt

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                PowerAction {
                    icon: "󰌾"
                    colors: menu.colors
                    command: ["sh", "-c", "loginctl lock-session || hyprlock || swaylock"]
                    onRan: menu.dismissed()
                }

                PowerAction {
                    icon: "󰒲"
                    colors: menu.colors
                    command: ["systemctl", "suspend"]
                    onRan: menu.dismissed()
                }

                PowerAction {
                    icon: "󰍃"
                    colors: menu.colors
                    command: ["sh", "-c", "hyprctl dispatch exit || loginctl terminate-user \"$USER\""]
                    onRan: menu.dismissed()
                }

                PowerAction {
                    icon: "󰜉"
                    danger: true
                    colors: menu.colors
                    command: ["systemctl", "reboot"]
                    onRan: menu.dismissed()
                }

                PowerAction {
                    icon: "⏻"
                    danger: true
                    colors: menu.colors
                    command: ["systemctl", "poweroff"]
                    onRan: menu.dismissed()
                }
            }
        }
    }

    component PowerAction: MouseArea {
        id: action

        property string icon: ""
        property bool danger: false
        property var command: []
        property var colors

        signal ran()

        Layout.preferredWidth: 72
        Layout.fillHeight: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            runner.exec(command);
            action.ran();
        }

        Process {
            id: runner
        }

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: action.containsMouse ? action.colors.panelAlt : action.colors.panel
            border.width: 1
            border.color: action.containsMouse ? (action.danger ? action.colors.danger : action.colors.accent) : "transparent"

            Text {
                anchors.centerIn: parent
                color: action.danger ? action.colors.danger : action.colors.fg
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: 28
                font.weight: Font.DemiBold
                text: action.icon
            }
        }
    }
}
