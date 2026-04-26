import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Rectangle {
    id: tray

    property var tokens
    property bool expanded: false

    readonly property int buttonSize: tokens ? tokens.moduleHeight : 24
    readonly property int itemSpacing: tokens ? tokens.rightInlineGap : 3
    readonly property int collapsedWidth: buttonSize
    readonly property int expandedWidth: collapsedWidth + (trayIcons.width > 0 ? itemSpacing + trayIcons.width : 0)

    signal clicked()

    width: expanded ? expandedWidth : collapsedWidth
    height: tokens ? tokens.moduleHeight : 24
    radius: tokens ? tokens.moduleRadius : (height / 2)
    color: expanded || trayToggle.containsMouse ? tokens.moduleHoverFill : tokens.clear
    border.width: 0
    border.color: tokens ? tokens.clear : "transparent"
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: tokens ? tokens.animationDuration : 150
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: tokens ? tokens.animationDuration : 150
        }
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: tray.buttonSize
        spacing: tray.itemSpacing

        Item {
            width: tray.buttonSize
            height: tray.buttonSize
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -2.5
                color: tray.expanded ? tokens.textPrimary : tokens.textSecondary
                font.family: tokens.iconFont
                font.pixelSize: Math.round(tokens.rightIconFontSize * 2.5)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: tray.expanded ? "›" : "‹"
            }

            MouseArea {
                id: trayToggle
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: tray.clicked()
            }
        }

        Item {
            width: trayIcons.width
            height: tray.buttonSize
            anchors.verticalCenter: parent.verticalCenter
            opacity: tray.expanded ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: tokens ? tokens.animationDuration : 150
                    easing.type: Easing.OutCubic
                }
            }

            Row {
                id: trayIcons
                anchors.verticalCenter: parent.verticalCenter
                spacing: tray.itemSpacing

                Repeater {
                    model: SystemTray.items

                    Item {
                        width: tray.buttonSize
                        height: tray.buttonSize

                        MouseArea {
                            anchors.fill: parent
                            enabled: tray.expanded
                            hoverEnabled: tray.expanded
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onPressed: mouse => {
                                if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                                    modelData.secondaryActivate();
                                    mouse.accepted = true;
                                }
                            }
                            onClicked: mouse => {
                                if (mouse.button !== Qt.RightButton)
                                    modelData.activate();
                            }
                        }

                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: tokens.trayIconSize
                            width: tokens.trayIconSize
                            height: tokens.trayIconSize
                            source: modelData.icon
                        }
                    }
                }
            }
        }
    }
}
