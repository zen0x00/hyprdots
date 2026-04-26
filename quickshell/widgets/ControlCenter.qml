import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: center

    property int topOffset: 46
    property date clockDate
    property string cpuText: "CPU --"
    property string gpuText: ""
    property string memText: "RAM --"
    property string batteryText: ""
    property string diskText: "DISK --"
    property string networkText: "NET --"
    property var colors

    signal dismissed()

    color: "transparent"
    focusable: true
    aboveWindows: true
    exclusiveZone: 0
    implicitWidth: 390
    anchors {
        top: true
        bottom: true
        right: true
    }
    margins {
        top: 0
        bottom: 8
        right: 8
    }

    onVisibleChanged: {
        if (visible)
            center.forceActiveFocus();
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            center.dismissed();
            event.accepted = true;
        }
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
            spacing: 8

            Rectangle {
                id: headerSection
                Layout.fillWidth: true
                Layout.preferredHeight: 88
                radius: 8
                color: colors.panel

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            color: colors.fg
                            font.pixelSize: 34
                            font.weight: Font.Bold
                            text: Qt.formatDateTime(center.clockDate, "h:mm")
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 8

                            Text {
                                color: colors.accent
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                text: Qt.formatDateTime(center.clockDate, "AP")
                            }

                            Text {
                                color: colors.muted
                                font.pixelSize: 13
                                text: Qt.formatDateTime(center.clockDate, "dddd, MMM d")
                            }
                        }
                    }

                }
            }

            Rectangle {
                id: controlsSection
                Layout.fillWidth: true
                Layout.preferredHeight: 184
                radius: 8
                color: colors.panel

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        color: colors.fg
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        text: "Controls"
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 2
                        columnSpacing: 8
                        rowSpacing: 8

                        ActionTile {
                            icon: "󰖩"
                            title: "Network"
                            subtitle: center.networkText.replace("NET ", "")
                            colors: center.colors
                            command: ["sh", "-c", "command -v nm-connection-editor >/dev/null && nm-connection-editor || command -v nmtui >/dev/null && foot -e nmtui"]
                        }

                        ActionTile {
                            icon: "󰂯"
                            title: "Bluetooth"
                            subtitle: "Devices"
                            colors: center.colors
                            command: ["sh", "-c", "command -v blueman-manager >/dev/null && blueman-manager || command -v bluetoothctl >/dev/null && foot -e bluetoothctl"]
                        }

                        ActionTile {
                            icon: "󰕾"
                            title: "Audio"
                            subtitle: "Toggle mute"
                            colors: center.colors
                            command: ["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]
                        }

                        ActionTile {
                            icon: "󰃠"
                            title: "Brightness"
                            subtitle: "Increase"
                            colors: center.colors
                            command: ["sh", "-c", "brightnessctl set +10%"]
                        }
                    }
                }
            }

            Rectangle {
                id: statsSection
                Layout.fillWidth: true
                Layout.preferredHeight: 118
                radius: 8
                color: colors.panel

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        color: colors.fg
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        text: "Stats"
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: center.batteryText.length > 0 ? 5 : 4
                        columnSpacing: 8
                        rowSpacing: 8

                        StatCard {
                            icon: "󰻠"
                            label: "CPU"
                            value: center.cpuText.replace("CPU ", "")
                            colors: center.colors
                        }

                        StatCard {
                            icon: "󰢮"
                            label: "GPU"
                            value: center.gpuText.length > 0 ? center.gpuText.replace("GPU ", "") : "--"
                            colors: center.colors
                        }

                        StatCard {
                            icon: "󰍛"
                            label: "RAM"
                            value: center.memText.replace("RAM ", "")
                            colors: center.colors
                        }

                        StatCard {
                            icon: "󰁹"
                            label: "BAT"
                            value: center.batteryText.length > 0 ? center.batteryText.replace("BAT ", "") : "--"
                            colors: center.colors
                            visible: center.batteryText.length > 0
                        }

                        StatCard {
                            icon: "󰋊"
                            label: "DISK"
                            value: center.diskText.replace("DISK ", "")
                            colors: center.colors
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    component ActionTile: MouseArea {
        id: tile

        property string icon: ""
        property string title: ""
        property string subtitle: ""
        property var command: []
        property var colors

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: 0
        Layout.preferredHeight: 76
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: runner.exec(command)

        Process {
            id: runner
        }

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: tile.containsMouse ? tile.colors.panelAlt : tile.colors.bg
            border.width: 1
            border.color: tile.containsMouse ? tile.colors.accent : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    radius: 8
                    color: tile.colors.panel

                    Text {
                        anchors.centerIn: parent
                        color: colors.accent
                        font.family: "Symbols Nerd Font Mono"
                        font.pixelSize: 16
                        text: tile.icon
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        color: tile.colors.fg
                        elide: Text.ElideRight
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        text: tile.title
                    }

                    Text {
                        Layout.fillWidth: true
                        color: tile.colors.muted
                        elide: Text.ElideRight
                        font.pixelSize: 11
                        text: tile.subtitle
                    }
                }
            }
        }
    }

    component StatCard: Rectangle {
        id: stat

        property string icon: ""
        property string label: ""
        property string value: ""
        property var colors

        Layout.fillWidth: true
        Layout.preferredHeight: 74
        radius: 8
        color: colors.bg
        border.width: 1
        border.color: "transparent"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4

            Text {
                Layout.alignment: Qt.AlignHCenter
                color: stat.colors.accent
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: 15
                text: stat.icon
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                color: stat.colors.muted
                font.pixelSize: 10
                font.weight: Font.DemiBold
                text: stat.label
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                color: stat.colors.fg
                font.pixelSize: 12
                font.weight: Font.Bold
                text: stat.value
            }
        }
    }

}
