import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: menu

    property int topOffset: 46
    property var colors
    property string activeThemeSlug: "catppuccin"
    readonly property int menuWidth: 420
    readonly property int menuHeight: 500
    readonly property var themes: [
        { "name": "Abyssal", "slug": "abyssal", "swatches": ["#061115", "#448fff", "#8bd5ca"] },
        { "name": "Black", "slug": "black", "swatches": ["#0d0d0d", "#ffffff", "#8d8d8d"] },
        { "name": "Catppuccin", "slug": "catppuccin", "swatches": ["#1e1e2e", "#89b4fa", "#f5c2e7"] },
        { "name": "Dracula", "slug": "dracula", "swatches": ["#282a36", "#bd93f9", "#ff79c6"] },
        { "name": "E-Ink", "slug": "e-ink", "swatches": ["#ffffff", "#000000", "#6e6e6e"] },
        { "name": "Everforest", "slug": "everforest", "swatches": ["#2b3339", "#7fbbb3", "#a7c080"] },
        { "name": "Gruvbox", "slug": "gruvbox", "swatches": ["#282828", "#fabd2f", "#83a598"] },
        { "name": "Latte", "slug": "catppuccin-latte", "swatches": ["#f5f6fa", "#1e66f5", "#d20f39"] },
        { "name": "Nord", "slug": "nord", "swatches": ["#2e3440", "#88c0d0", "#a3be8c"] },
        { "name": "Tokyo Night", "slug": "tokyonight", "swatches": ["#1a1b26", "#7aa2f7", "#bb9af7"] }
    ]

    signal dismissed()

    color: "transparent"
    focusable: true
    aboveWindows: true
    exclusiveZone: 0
    implicitWidth: menuWidth
    implicitHeight: menuHeight
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins {
        left: Math.max(16, Math.round((menu.screen.width - menu.menuWidth) / 2))
        right: Math.max(16, Math.round((menu.screen.width - menu.menuWidth) / 2))
        top: Math.max(16, Math.round((menu.screen.height - menu.menuHeight) / 2))
        bottom: Math.max(16, Math.round((menu.screen.height - menu.menuHeight) / 2))
    }

    onVisibleChanged: {
        if (visible) {
            themeList.currentIndex = activeThemeIndex();
            keyboardScope.forceActiveFocus();
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: menu.dismissed()
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 8
        color: colors.bg
        border.width: 1
        border.color: colors.panelAlt

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
        }

        FocusScope {
            id: keyboardScope
            anchors.fill: parent
            focus: menu.visible

            Keys.onEscapePressed: event => {
                menu.dismissed();
                event.accepted = true;
            }
            Keys.onUpPressed: event => {
                menu.selectRelative(-1);
                event.accepted = true;
            }
            Keys.onDownPressed: event => {
                menu.selectRelative(1);
                event.accepted = true;
            }
            Keys.onReturnPressed: event => {
                menu.activateCurrentTheme();
                event.accepted = true;
            }
            Keys.onEnterPressed: event => {
                menu.activateCurrentTheme();
                event.accepted = true;
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: 8
                    color: colors.panel

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        verticalAlignment: Text.AlignVCenter
                        color: colors.fg
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        text: "Themes"
                    }
                }

                ListView {
                    id: themeList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: menu.themes
                    currentIndex: menu.activeThemeIndex()
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: true

                    delegate: ThemeRow {
                        required property var modelData

                        width: themeList.width
                        itemData: modelData
                        selected: modelData.slug === menu.activeThemeSlug
                        active: ListView.isCurrentItem
                        colors: menu.colors
                        onEntered: themeList.currentIndex = index
                        onPicked: {
                            menu.activeThemeSlug = modelData.slug;
                            themeList.currentIndex = index;
                            menu.applyTheme(modelData.slug);
                        }
                    }
                }
            }
        }
    }

    Process {
        id: themeRunner
    }

    function activeThemeIndex() {
        for (let i = 0; i < themes.length; i++) {
            if (themes[i].slug === activeThemeSlug)
                return i;
        }

        return 0;
    }

    function activateCurrentTheme() {
        if (themeList.currentItem)
            themeList.currentItem.pick();
    }

    function selectRelative(step) {
        if (themes.length === 0) {
            themeList.currentIndex = -1;
            return;
        }

        if (themeList.currentIndex < 0)
            themeList.currentIndex = activeThemeIndex();

        themeList.currentIndex = (themeList.currentIndex + step + themes.length) % themes.length;
        themeList.positionViewAtIndex(themeList.currentIndex, ListView.Contain);
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
        property bool active: false
        property var colors

        signal picked()

        width: parent ? parent.width : 0
        height: 58
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: pick()

        function pick() {
            picked();
        }

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: row.active ? Qt.alpha(colors.accent, 0.28) : row.containsMouse ? Qt.alpha(colors.accent, 0.16) : "transparent"
            border.width: row.active || row.containsMouse ? 1 : 0
            border.color: row.active ? Qt.alpha(colors.accent, 0.6) : Qt.alpha(colors.accent, 0.35)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    color: row.active ? colors.accent : colors.fg
                    elide: Text.ElideRight
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    text: row.itemData.name
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.preferredWidth: 20
                    horizontalAlignment: Text.AlignRight
                    color: row.selected ? colors.accent : colors.muted
                    font.family: "Symbols Nerd Font Mono"
                    font.pixelSize: 15
                    text: row.selected ? "󰄬" : "󰅂"
                }
            }
        }
    }
}
