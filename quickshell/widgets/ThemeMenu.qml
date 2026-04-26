import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: menu

    property int topOffset: 46
    property var colors
    property int activeSection: 0
    property int activeTheme: 1
    property int activeFont: 0
    property int activeWallpaper: 0
    readonly property var sections: ["Themes", "Fonts", "Wallpapers"]
    readonly property var themes: [
        { "name": "Black", "slug": "black", "swatches": ["#0d0d0d", "#ffffff", "#8d8d8d"] },
        { "name": "Catppuccin", "slug": "catppuccin", "swatches": ["#1e1e2e", "#89b4fa", "#f5c2e7"] },
        { "name": "Latte", "slug": "catppuccin-latte", "swatches": ["#f5f6fa", "#1e66f5", "#d20f39"] },
        { "name": "Abyssal", "slug": "abyssal", "swatches": ["#061115", "#448fff", "#8bd5ca"] },
        { "name": "Dracula", "slug": "dracula", "swatches": ["#282a36", "#bd93f9", "#ff79c6"] },
        { "name": "E-Ink", "slug": "e-ink", "swatches": ["#ffffff", "#000000", "#6e6e6e"] },
        { "name": "Everforest", "slug": "everforest", "swatches": ["#2b3339", "#7fbbb3", "#a7c080"] },
        { "name": "Gruvbox", "slug": "gruvbox", "swatches": ["#282828", "#fabd2f", "#83a598"] },
        { "name": "Nord", "slug": "nord", "swatches": ["#2e3440", "#88c0d0", "#a3be8c"] },
        { "name": "Tokyo Night", "slug": "tokyonight", "swatches": ["#1a1b26", "#7aa2f7", "#bb9af7"] }
    ]
    readonly property var fonts: [
        { "name": "Inter", "role": "Interface" },
        { "name": "JetBrains Mono", "role": "Terminal" },
        { "name": "Symbols Nerd Font Mono", "role": "Icons" },
        { "name": "SF Pro Display", "role": "Display" }
    ]
    readonly property var wallpapers: [
        { "name": "Current", "tone": "System", "swatches": ["#14171d", "#252b35"] },
        { "name": "Dawn", "tone": "Light", "swatches": ["#f5f6fa", "#df8e1d"] },
        { "name": "Forest", "tone": "Dark", "swatches": ["#2b3339", "#a7c080"] },
        { "name": "Night", "tone": "Dark", "swatches": ["#1a1b26", "#7aa2f7"] }
    ]

    signal dismissed()

    color: "transparent"
    focusable: true
    aboveWindows: true
    exclusiveZone: 0
    implicitWidth: 390
    implicitHeight: 520
    anchors {
        top: true
        right: true
    }
    margins {
        top: menu.topOffset
        right: 12
    }

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: colors.bg
        border.width: 1
        border.color: colors.panelAlt

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: menu.sections

                    MouseArea {
                        id: tab

                        required property string modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        cursorShape: Qt.PointingHandCursor
                        onClicked: menu.activeSection = index

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: menu.activeSection === tab.index ? colors.accent : tab.containsMouse ? colors.panelAlt : colors.panel

                            Text {
                                anchors.centerIn: parent
                                color: menu.activeSection === tab.index ? "#071015" : colors.fg
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                text: tab.modelData
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 68
                radius: 8
                color: colors.panel

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        radius: 8
                        color: colors.bg

                        Text {
                            anchors.centerIn: parent
                            color: colors.accent
                            font.family: "Symbols Nerd Font Mono"
                            font.pixelSize: 20
                            text: menu.activeSection === 0 ? "󰏘" : menu.activeSection === 1 ? "󰛖" : "󰸉"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            color: colors.fg
                            elide: Text.ElideRight
                            font.pixelSize: 15
                            font.weight: Font.Bold
                            text: menu.sections[menu.activeSection]
                        }

                        Text {
                            Layout.fillWidth: true
                            color: colors.muted
                            elide: Text.ElideRight
                            font.pixelSize: 12
                            text: menu.activeSection === 0 ? menu.themes[menu.activeTheme].name : menu.activeSection === 1 ? menu.fonts[menu.activeFont].name : menu.wallpapers[menu.activeWallpaper].name
                        }
                    }
                }
            }

            ListView {
                id: contentList

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                boundsBehavior: Flickable.StopAtBounds
                model: menu.activeSection === 0 ? menu.themes : menu.activeSection === 1 ? menu.fonts : menu.wallpapers

                delegate: ThemeRow {
                    width: contentList.width
                    itemData: modelData
                    selected: menu.activeSection === 0 ? index === menu.activeTheme : menu.activeSection === 1 ? index === menu.activeFont : index === menu.activeWallpaper
                    section: menu.activeSection
                    colors: menu.colors
                    onPicked: {
                        if (menu.activeSection === 0) {
                            menu.activeTheme = index;
                            menu.applyTheme(modelData.slug);
                        } else if (menu.activeSection === 1) {
                            menu.activeFont = index;
                        } else {
                            menu.activeWallpaper = index;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: themeRunner
    }

    function applyTheme(slug) {
        themeRunner.exec([
            "sh",
            "-c",
            "(if command -v zen0x-apply-theme >/dev/null 2>&1; then zen0x-apply-theme \"$1\"; else /home/aman/dotfiles/bin/zen0x-apply-theme \"$1\"; fi) >/tmp/zen0x-apply-theme.log 2>&1 &",
            "zen0x-apply-theme",
            slug
        ]);
        menu.dismissed();
    }

    component ThemeRow: MouseArea {
        id: row

        property var itemData
        property bool selected: false
        property int section: 0
        property var colors

        signal picked()

        height: 58
        cursorShape: Qt.PointingHandCursor
        onClicked: picked()

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: row.selected ? row.colors.panelAlt : row.containsMouse ? row.colors.panelAlt : row.colors.panel
            border.width: 1
            border.color: row.selected ? row.colors.accent : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Row {
                    Layout.preferredWidth: row.section === 1 ? 38 : 58
                    Layout.preferredHeight: 28
                    spacing: -8

                    Repeater {
                        model: row.section === 1 ? [row.colors.accent] : row.itemData.swatches

                        Rectangle {
                            width: 28
                            height: 28
                            radius: 8
                            color: modelData
                            border.width: 1
                            border.color: row.colors.bg

                            Text {
                                anchors.centerIn: parent
                                visible: row.section === 1
                                color: "#071015"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                text: "Aa"
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        color: row.colors.fg
                        elide: Text.ElideRight
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        text: row.itemData.name
                    }

                    Text {
                        Layout.fillWidth: true
                        color: row.colors.muted
                        elide: Text.ElideRight
                        font.pixelSize: 11
                        text: row.section === 0 ? row.itemData.slug : row.section === 1 ? row.itemData.role : row.itemData.tone
                    }
                }

                Text {
                    Layout.preferredWidth: 20
                    horizontalAlignment: Text.AlignRight
                    color: row.selected ? row.colors.accent : row.colors.muted
                    font.family: "Symbols Nerd Font Mono"
                    font.pixelSize: 15
                    text: row.selected ? "󰄬" : "󰅂"
                }
            }
        }
    }
}
