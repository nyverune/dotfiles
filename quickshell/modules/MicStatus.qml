import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../components"

Pill {
    id: root

    property bool micInUse: false
    visible: micInUse
    implicitWidth: visible ? contentRow.implicitWidth + 16 : 0
    implicitHeight: 28

    color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.15)
    border.color: Theme.error

    Process {
        id: micChecker
        command: [
            "sh", "-c",
            "pactl list source-outputs 2>/dev/null | awk '/Source Output/ { in_block=1; is_cava=0; is_monitor=0 } /application.name = \"cava\"/ || /application.process.binary = \"cava\"/ { is_cava=1 } /stream.capture.sink = \"true\"/ { is_monitor=1 } /^$/ { if (in_block && !is_cava && !is_monitor) real++; in_block=0 } END { if (in_block && !is_cava && !is_monitor) real++; print (real > 0 ? \"IN_USE\" : \"IDLE\") }'"
        ]
        stdout: StdioCollector {
            onTextChanged: {
                let status = text.trim()
                root.micInUse = (status === "IN_USE")
            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            if (!micChecker.running) {
                micChecker.running = true
            }
        }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            implicitWidth: 8
            implicitHeight: 8
            radius: 4
            color: Theme.error

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.micInUse
                NumberAnimation { from: 1.0; to: 0.2; duration: 600; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.2; to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            text: ""
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.error
        }

        Text {
            text: "Mic In Use"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: Theme.error
        }
    }
}
