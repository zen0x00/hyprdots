import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

PanelWindow {
    id: toasts

    property int topOffset: 48
    property var colors
    property var server

    color: "transparent"
    focusable: false
    aboveWindows: true
    exclusiveZone: 0
    implicitWidth: 360
    implicitHeight: Math.min(560, toastColumn.implicitHeight)
    visible: toastColumn.implicitHeight > 0
    anchors {
        top: true
        right: true
    }
    margins {
        top: toasts.topOffset
        right: 12
    }

    ColumnLayout {
        id: toastColumn

        anchors.fill: parent
        spacing: 8

        Repeater {
            model: toasts.server ? toasts.server.trackedNotifications : null

            MouseArea {
                id: toast

                required property var modelData

                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                readonly property string iconSource: modelData.appIcon ? Quickshell.iconPath(modelData.appIcon, true) : ""

                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(92, content.implicitHeight + 24)
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.dismiss()

                Timer {
                    interval: toast.critical || toast.modelData.resident ? 12000
                        : toast.modelData.expireTimeout > 0 ? toast.modelData.expireTimeout
                        : 5200
                    running: true
                    repeat: false
                    onTriggered: toast.modelData.dismiss()
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: colors.bg
                    border.width: 1
                    border.color: toast.critical ? colors.danger : colors.panelAlt

                    Rectangle {
                        width: 3
                        radius: 2
                        color: toast.critical ? colors.danger : colors.accent
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                            margins: 8
                        }
                    }

                    ColumnLayout {
                        id: content
                        anchors.fill: parent
                        anchors.margins: 12
                        anchors.leftMargin: 18
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: 8
                                color: colors.panel

                                IconImage {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    implicitSize: 24
                                    visible: toast.iconSource.length > 0
                                    source: toast.iconSource
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: toast.iconSource.length === 0
                                    color: colors.accent
                                    font.family: "Symbols Nerd Font Mono"
                                    font.pixelSize: 16
                                    text: "󰂚"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    color: colors.fg
                                    elide: Text.ElideRight
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    text: toast.modelData.summary || toast.modelData.appName || "Notification"
                                }

                                Text {
                                    Layout.fillWidth: true
                                    color: colors.muted
                                    elide: Text.ElideRight
                                    font.pixelSize: 11
                                    text: toast.modelData.appName
                                }
                            }

                            MouseArea {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    toast.modelData.dismiss();
                                    mouse.accepted = true;
                                }

                                Text {
                                    anchors.centerIn: parent
                                    color: colors.muted
                                    font.pixelSize: 15
                                    text: "×"
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: toast.modelData.body.length > 0
                            color: colors.fg
                            maximumLineCount: 3
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            font.pixelSize: 12
                            text: toast.modelData.body.replace(/<[^>]*>/g, "")
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: toast.modelData.actions.length > 0
                            spacing: 6

                            Repeater {
                                model: toast.modelData.actions

                                MouseArea {
                                    required property var modelData

                                    Layout.preferredHeight: 26
                                    Layout.preferredWidth: actionLabel.implicitWidth + 20
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        modelData.invoke();
                                        toast.modelData.dismiss();
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 8
                                        color: parent.containsMouse ? colors.panelAlt : colors.panel
                                    }

                                    Text {
                                        id: actionLabel
                                        anchors.centerIn: parent
                                        color: colors.fg
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        text: modelData.text
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
