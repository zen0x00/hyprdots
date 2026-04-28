import QtQuick
import Quickshell.Hyprland

Item {
    id: workspaces

    property var tokens
    property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0
    property int refreshKey: 0
    readonly property var persistentWorkspaceIds: [1, 2, 3, 4, 5]
    readonly property var visibleWorkspaceIds: buildVisibleWorkspaceIds(refreshKey, focusedId)
    readonly property int indicatorHeight: 3
    readonly property int indicatorWidth: Math.max(10, tokens.moduleHeight - 10)

    implicitWidth: workspaceRow.width
    implicitHeight: workspaceRow.height

    function workspaceBackground(active, hovered) {
        if (hovered)
            return tokens.workspaceHoverFill;
        return tokens.clear;
    }

    function workspaceBorder(urgent, active, hovered) {
        if (urgent)
            return tokens.workspaceUrgent;
        return tokens.clear;
    }

    function workspaceTextColor(active, occupied) {
        if (active)
            return tokens.textAccent;
        if (occupied)
            return tokens.workspaceBusyText;
        return tokens.workspaceIdleText;
    }

    function activeIndicatorX() {
        for (let i = 0; i < workspaceRepeater.count; i++) {
            const button = workspaceRepeater.itemAt(i);
            if (button && button.workspaceId === focusedId)
                return button.x + ((button.width - indicatorWidth) / 2);
        }

        return ((tokens.moduleHeight - indicatorWidth) / 2);
    }

    function buildVisibleWorkspaceIds(key, activeId) {
        const visible = persistentWorkspaceIds.slice();
        const list = Hyprland.workspaces.values;

        for (let i = 0; i < list.length; i++) {
            const id = list[i].id;
            if (id >= 6 && id <= 10 && visible.indexOf(id) === -1)
                visible.push(id);
        }

        visible.sort((a, b) => a - b);
        return visible;
    }

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            workspaces.refreshKey++;
        }
    }

    Rectangle {
        id: activeIndicator
        x: workspaces.activeIndicatorX()
        y: workspaceRow.height - height
        width: workspaces.indicatorWidth
        height: workspaces.indicatorHeight
        radius: 9999
        z: 0
        color: Qt.alpha(tokens.textAccent, 0.95)

        Behavior on x {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
    }

    Row {
        id: workspaceRow
        spacing: tokens.moduleGap
        z: 1

        Repeater {
            id: workspaceRepeater
            model: workspaces.visibleWorkspaceIds

            Rectangle {
                id: workspaceButton

                readonly property int workspaceId: modelData
                readonly property var workspace: workspaces.workspaceFor(workspaceId, workspaces.refreshKey)
                readonly property bool active: workspaces.focusedId === workspaceId
                readonly property bool occupied: workspace !== null
                readonly property bool urgent: workspace !== null && workspace.urgent

                width: tokens.moduleHeight
                height: tokens.moduleHeight
                radius: tokens.moduleRadius
                color: workspaces.workspaceBackground(active, workspaceMouse.containsMouse)
                border.width: urgent ? tokens.borderWidth : 0
                border.color: workspaces.workspaceBorder(urgent, active, workspaceMouse.containsMouse)
                scale: workspaceMouse.pressed ? tokens.pressedScale : workspaceMouse.containsMouse ? tokens.hoverScale : 1

                Text {
                    anchors.centerIn: parent
                    color: workspaces.workspaceTextColor(workspaceButton.active, workspaceButton.occupied)
                    font.pixelSize: tokens.textFontSize + (workspaceButton.active ? 3 : 1)
                    font.weight: Font.DemiBold
                    text: String(workspaceButton.workspaceId)

                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: tokens.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: tokens.animationDuration
                    }
                }
                Behavior on border.color {
                    ColorAnimation {
                        duration: tokens.animationDuration
                    }
                }

                MouseArea {
                    id: workspaceMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: Hyprland.dispatch("workspace " + workspaceButton.workspaceId)
                }
            }
        }
    }

    function workspaceFor(id, key) {
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].id === id)
                return list[i];
        }

        return null;
    }
}
