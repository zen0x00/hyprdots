import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: workspaces

    property var colors
    property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0
    property int refreshKey: 0

    spacing: 6

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            workspaces.refreshKey++;
        }
    }

    Repeater {
        model: [1, 2, 3, 4, 5]

        MouseArea {
            id: workspaceButton

            readonly property int workspaceId: modelData
            readonly property var workspace: workspaces.workspaceFor(workspaceId, workspaces.refreshKey)
            readonly property bool active: workspaces.focusedId === workspaceId
            readonly property bool occupied: workspace !== null
            readonly property bool urgent: workspace !== null && workspace.urgent

            Layout.preferredWidth: active ? 38 : 28
            Layout.preferredHeight: 28
            cursorShape: Qt.PointingHandCursor
            onClicked: Hyprland.dispatch("workspace " + workspaceId)

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: workspaceButton.active ? workspaces.colors.accent
                    : workspaceButton.containsMouse ? workspaces.colors.panelAlt
                    : "transparent"
                border.width: 1
                border.color: workspaceButton.urgent ? workspaces.colors.danger
                    : workspaceButton.active ? workspaces.colors.accent
                    : "transparent"

                Text {
                    anchors.centerIn: parent
                    color: workspaceButton.active ? "#071015"
                        : workspaceButton.occupied ? workspaces.colors.fg
                        : workspaces.colors.muted
                    font.pixelSize: 12
                    font.weight: workspaceButton.active || workspaceButton.occupied ? Font.Bold : Font.Medium
                    text: workspaceButton.workspaceId
                }
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
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
