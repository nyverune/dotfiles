import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../components"

Pill {
    id: root
    clickable: true
    implicitWidth: contentRow.implicitWidth + 16
    implicitHeight: 28

    property int volumePercent: 80
    property bool isMuted: false

    Process {
        id: volChecker
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onTextChanged: {
                let out = text.trim()
                root.isMuted = (out.indexOf("[MUTED]") !== -1)
                let match = out.match(/([0-9]+\.[0-9]+|[0-9]+)/)
                if (match) {
                    let v = parseFloat(match[1])
                    root.volumePercent = Math.round(v * 100)
                }
            }
        }
    }

    // Real-time audio event listener for instant hardware keyboard shortcut reaction
    Process {
        id: eventSubscriber
        command: ["pactl", "subscribe"]
        stdout: SplitParser {
            onRead: data => {
                if (data.indexOf("sink") !== -1 || data.indexOf("server") !== -1) {
                    if (!volChecker.running) {
                        volChecker.running = true
                    }
                }
            }
        }
        Component.onCompleted: {
            eventSubscriber.running = true
        }
    }

    Process {
        id: volAction
        onExited: {
            volChecker.running = true
        }
    }

    function changeVolume(deltaStr, deltaInt) {
        // Optimistic UI update for 0ms lag
        if (deltaInt > 0) {
            root.volumePercent = Math.min(100, root.volumePercent + deltaInt)
            root.isMuted = false
        } else {
            root.volumePercent = Math.max(0, root.volumePercent + deltaInt)
        }
        volAction.command = ["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", deltaStr]
        volAction.running = true
    }

    function toggleMute() {
        // Optimistic UI update
        root.isMuted = !root.isMuted
        volAction.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        volAction.running = true
    }

    // Regular sync timer
    Timer {
        interval: 300
        running: true
        repeat: true
        onTriggered: {
            if (!volChecker.running) {
                volChecker.running = true
            }
        }
        Component.onCompleted: {
            volChecker.running = true
        }
    }

    readonly property string volumeIcon: {
        if (isMuted || volumePercent === 0) return "󰝟"
        if (volumePercent < 33) return ""
        if (volumePercent < 66) return ""
        return ""
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.volumeIcon
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: root.isMuted ? Theme.muted : Theme.primary
        }

        Text {
            text: root.isMuted ? "MUTE" : root.volumePercent + "%"
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: root.isMuted ? Theme.muted : Theme.foreground
        }
    }

    onClicked: root.toggleMute()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: root.clicked()

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                root.changeVolume("5%+", 5)
            } else {
                root.changeVolume("5%-", -5)
            }
        }
    }
}
