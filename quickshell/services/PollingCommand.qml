import QtQuick
import Quickshell.Io

Item {
    id: poller

    property var command: []
    property int interval: 10000
    property string fallback: "--"
    property string text: fallback

    visible: false

    Process {
        id: process
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const output = text.trim();
                poller.text = output.length > 0 ? output : poller.fallback;
            }
        }
    }

    Timer {
        interval: poller.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: poller.refresh()
    }

    function refresh() {
        process.exec(poller.command);
    }
}
