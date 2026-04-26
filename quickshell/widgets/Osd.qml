import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: osd

    property string icon: ""
    property string label: ""
    property real value: 0
    property string detailText: ""
    property var colors
    readonly property bool compact: detailText.length > 0

    color: "transparent"
    focusable: false
    aboveWindows: true
    exclusiveZone: 0
    implicitWidth: compact ? contentRow.implicitWidth + 24 : 300
    implicitHeight: compact ? contentRow.implicitHeight + 24 : 78
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
        radius: compact ? 14 : 8
        color: colors.bg
        border.width: 1
        border.color: colors.panelAlt

        RowLayout {
            id: contentRow
            anchors.fill: parent
            anchors.margins: compact ? 12 : 14
            spacing: compact ? 4 : 12

            Text {
                Layout.preferredWidth: compact ? 24 : 34
                color: colors.accent
                horizontalAlignment: Text.AlignHCenter
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: compact ? 18 : 24
                text: osd.icon
            }

            ColumnLayout {
                Layout.fillWidth: !compact
                spacing: compact ? 2 : 8

                RowLayout {
                    Layout.fillWidth: !compact
                    spacing: compact ? 8 : 0

                    Text {
                        Layout.fillWidth: !compact
                        color: colors.fg
                        font.pixelSize: compact ? 12 : 13
                        font.weight: Font.DemiBold
                        text: osd.label
                    }

                    Text {
                        color: colors.muted
                        font.pixelSize: compact ? 11 : 12
                        font.weight: compact ? Font.Bold : Font.DemiBold
                        text: osd.detailText.length > 0 ? osd.detailText : Math.round(osd.value * 100) + "%"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8
                    radius: 4
                    color: colors.panel
                    visible: osd.detailText.length === 0

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
