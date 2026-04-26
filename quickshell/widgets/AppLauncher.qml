import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

PanelWindow {
    id: launcher

    property int topOffset: 46
    property var colors
    property string query: search.text.toLowerCase()
    property int refreshKey: 0
    property var filteredApps: filterApps(query, refreshKey)

    signal dismissed()

    color: "transparent"
    focusable: true
    aboveWindows: true
    exclusiveZone: 0
    implicitHeight: 440
    implicitWidth: 560
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins {
        left: Math.max(16, Math.round((launcher.screen.width - launcher.implicitWidth) / 2))
        right: Math.max(16, Math.round((launcher.screen.width - launcher.implicitWidth) / 2))
        top: Math.max(16, Math.round((launcher.screen.height - launcher.implicitHeight) / 2))
        bottom: Math.max(16, Math.round((launcher.screen.height - launcher.implicitHeight) / 2))
    }

    onVisibleChanged: {
        if (visible) {
            search.text = "";
            appList.currentIndex = filteredApps.length > 0 ? 0 : -1;
            search.forceActiveFocus();
        }
    }

    onFilteredAppsChanged: appList.currentIndex = filteredApps.length > 0 ? 0 : -1

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            launcher.refreshKey++;
        }
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 8
        color: colors.bg
        border.width: 1
        border.color: colors.panelAlt

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 8
                color: colors.panel

                TextInput {
                    id: search
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: colors.fg
                    selectionColor: colors.accent
                    selectedTextColor: "#071015"
                    font.pixelSize: 15
                    clip: true

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: colors.muted
                        font.pixelSize: 15
                        visible: search.text.length === 0
                        text: "Search apps"
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            launcher.dismissed();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            selectRelative(1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            selectRelative(-1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (appList.currentItem)
                                appList.currentItem.launch();
                            event.accepted = true;
                        }
                    }
                }
            }

            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: launcher.filteredApps
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds

                delegate: MouseArea {
                    id: row

                    required property var modelData

                    property string iconSource: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""

                    width: appList.width
                    height: 54
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: launch()

                    function launch() {
                        modelData.execute();
                        launcher.dismissed();
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: row.containsMouse || ListView.isCurrentItem ? colors.panelAlt : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                radius: 7
                                color: row.iconSource.length > 0 ? "transparent" : colors.accent

                                IconImage {
                                    anchors.centerIn: parent
                                    width: 28
                                    height: 28
                                    implicitSize: 28
                                    visible: row.iconSource.length > 0
                                    source: row.iconSource
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: row.iconSource.length === 0
                                    color: "#071015"
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    text: row.modelData.name.length > 0 ? row.modelData.name[0].toUpperCase() : "?"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    color: colors.fg
                                    elide: Text.ElideRight
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    text: row.modelData.name
                                }

                                Text {
                                    Layout.fillWidth: true
                                    color: colors.muted
                                    elide: Text.ElideRight
                                    font.pixelSize: 11
                                    text: row.modelData.comment || row.modelData.genericName || row.modelData.id
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function matches(app) {
        if (query.length === 0)
            return true;

        const haystack = [
            app.name,
            app.genericName,
            app.comment,
            app.id,
            app.categories ? app.categories.join(" ") : "",
            app.keywords ? app.keywords.join(" ") : ""
        ].join(" ").toLowerCase();

        return haystack.indexOf(query) !== -1;
    }

    function selectRelative(step) {
        const apps = launcher.filteredApps;
        if (apps.length === 0) {
            appList.currentIndex = -1;
            return;
        }

        appList.currentIndex = (appList.currentIndex + step + apps.length) % apps.length;
        appList.positionViewAtIndex(appList.currentIndex, ListView.Contain);
    }

    function filterApps(queryText, key) {
        const apps = DesktopEntries.applications.values;
        const visible = [];

        for (let i = 0; i < apps.length; i++) {
            if (!apps[i].noDisplay && matches(apps[i]))
                visible.push(apps[i]);
        }

        return visible;
    }
}
