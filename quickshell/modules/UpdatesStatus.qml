import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../components"

Pill {
    id: root
    clickable: true

    property int updateCount: 0
    visible: updateCount > 0
    implicitWidth: visible ? contentRow.implicitWidth + 16 : 0
    implicitHeight: 28

    color: Qt.rgba(Theme.info.r, Theme.info.g, Theme.info.b, 0.12)
    border.color: Theme.info

    Process {
        id: updateChecker
        command: ["sh", "-c", "pacman -Qu 2>/dev/null | wc -l"]
        stdout: StdioCollector {
            onTextChanged: {
                let count = parseInt(text.trim()) || 0
                root.updateCount = count
            }
        }
    }

    onClicked: {
        if (!updateChecker.running) {
            updateChecker.running = true
        }
    }

    // Refresh updates every 15 seconds so changes appear immediately
    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: {
            if (!updateChecker.running) {
                updateChecker.running = true
            }
        }
        Component.onCompleted: {
            updateChecker.running = true
        }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: ""
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.info
        }

        Text {
            text: root.updateCount + " upd"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: Theme.info
        }
    }
}
