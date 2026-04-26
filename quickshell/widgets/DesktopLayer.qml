import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland._WlrLayerShell

PanelWindow {
    id: desktop

    property date clockDate
    property int topOffset: 36
    property var colors

    color: "transparent"
    focusable: false
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Background
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins {
        top: desktop.topOffset
    }

    Rectangle {
        anchors.fill: parent
        color: colors.surface

        Rectangle {
            width: 300
            height: 128
            radius: 8
            color: colors.bg
            border.width: 1
            border.color: colors.panelAlt
            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 24
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 4

                Text {
                    color: colors.fg
                    font.pixelSize: 36
                    font.weight: Font.Bold
                    text: Qt.formatDateTime(desktop.clockDate, "h:mm")
                }

                Text {
                    color: colors.accent
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    text: Qt.formatDateTime(desktop.clockDate, "AP")
                }

                Text {
                    Layout.fillWidth: true
                    color: colors.muted
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    text: Qt.formatDateTime(desktop.clockDate, "dddd, MMMM d")
                }
            }
        }
    }
}
