import QtQuick
import QtQuick.Layouts

Rectangle {
    id: pill

    property string text: ""
    property bool prominent: false
    property var colors

    Layout.preferredHeight: 26
    Layout.minimumWidth: label.implicitWidth + 20
    radius: 8
    color: prominent ? colors.accent : colors.panel

    Text {
        id: label
        anchors.centerIn: parent
        color: pill.prominent ? "#071015" : colors.fg
        font.pixelSize: 12
        font.weight: pill.prominent ? Font.Bold : Font.Medium
        text: pill.text
    }
}
