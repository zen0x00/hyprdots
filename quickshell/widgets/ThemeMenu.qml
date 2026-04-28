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
        { "name": "Abyssal", "slug": "abyssal", "bg": "#061115", "accent": "#448fff" },
        { "name": "Black", "slug": "black", "bg": "#0d0d0d", "accent": "#8d8d8d" },
        { "name": "Catppuccin", "slug": "catppuccin", "bg": "#1e1e2e", "accent": "#89b4fa" },
        { "name": "Dracula", "slug": "dracula", "bg": "#282a36", "accent": "#bd93f9" },
        { "name": "E-Ink", "slug": "e-ink", "bg": "#000000", "accent": "#6e6e6e" },
        { "name": "Everforest", "slug": "everforest", "bg": "#2b3339", "accent": "#7fbbb3" },
        { "name": "Gruvbox", "slug": "gruvbox", "bg": "#1d2021", "accent": "#83a598" },
        { "name": "Latte", "slug": "catppuccin-latte", "bg": "#f5f6fa", "accent": "#1e66f5" },
        { "name": "Nord", "slug": "nord", "bg": "#2e3440", "accent": "#88c0d0" },
        { "name": "Tokyo Night", "slug": "tokyonight", "bg": "#16161e", "accent": "#7aa2f7" }
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
            activeThemeSlug = detectedThemeSlug();
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
                        itemIndex: index
                        itemData: modelData
                        selected: modelData.slug === menu.activeThemeSlug
                        active: ListView.isCurrentItem
                        colors: menu.colors
                        onEntered: themeList.currentIndex = itemIndex
                        onPicked: {
                            menu.activeThemeSlug = modelData.slug;
                            themeList.currentIndex = itemIndex;
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

    function normalizeColor(value) {
        const color = String(value || "").trim().toLowerCase();
        if (color.length === 9 && color.indexOf("#ff") === 0)
            return "#" + color.slice(3);
        return color;
    }

    function detectedThemeSlug() {
        const currentBg = normalizeColor(colors.bg);
        const currentAccent = normalizeColor(colors.accent);

        for (let i = 0; i < themes.length; i++) {
            if (themes[i].bg === currentBg && themes[i].accent === currentAccent)
                return themes[i].slug;
        }

        return activeThemeSlug;
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
            "-lc",
            "nohup /home/aman/dotfiles/bin/zen0x-apply-theme " + slug + " >/tmp/zen0x-apply-theme.log 2>&1 </dev/null &"
        ]);
        menu.dismissed();
    }

    component ThemeRow: MouseArea {
        id: row

        property var itemData
        property int itemIndex: -1
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
