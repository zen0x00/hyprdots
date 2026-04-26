import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: osd

    property string icon: ""
    property string label: ""
    property real value: 0
    property var colors

    color: "transparent"
    focusable: false
    aboveWindows: true
    exclusiveZone: 0
    implicitWidth: 300
    implicitHeight: 78
    anchors {
        bottom: true
        left: true
        right: true
    }
    margins {
        left: Math.max(20, Math.round((osd.screen.width - osd.implicitWidth) / 2))
        right: Math.max(20, Math.round((osd.screen.width - osd.implicitWidth) / 2))
        bottom: 84
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: colors.bg
        border.width: 1
        border.color: colors.panelAlt

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Text {
                Layout.preferredWidth: 34
                color: colors.accent
                horizontalAlignment: Text.AlignHCenter
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: 24
                text: osd.icon
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        color: colors.fg
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        text: osd.label
                    }

                    Text {
                        color: colors.muted
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        text: Math.round(osd.value * 100) + "%"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8
                    radius: 4
                    color: colors.panel

                    Rectangle {
                        width: parent.width * osd.value
                        height: parent.height
                        radius: 4
                        color: colors.accent

                        Behavior on width {
                            NumberAnimation {
                                duration: 110
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}
