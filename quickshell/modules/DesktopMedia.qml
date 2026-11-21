import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."

PanelWindow {
    id: root

    // Position at top-right below the topbar
    anchors {
        top: true
        right: true
    }

    margins {
        top: 48
        right: 28
    }

    implicitWidth: 290
    implicitHeight: 60
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Bottom

    property string playerStatus: "Stopped"
    property string trackTitle: ""
    property string trackArtist: ""
    property int volumeLevel: 50
    property bool isPlaying: playerStatus === "Playing"

    Process {
        id: mediaQueryProc
        command: [
            "sh", "-c",
            "STATUS=$(playerctl status 2>/dev/null || echo 'Stopped'); " +
            "TITLE=$(playerctl metadata --format '{{title}}' 2>/dev/null || echo ''); " +
            "ARTIST=$(playerctl metadata --format '{{artist}}' 2>/dev/null || echo ''); " +
            "VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2 * 100)}'); " +
            "echo \"$STATUS\"; " +
            "echo '---'; " +
            "echo \"$TITLE\"; " +
            "echo '---'; " +
            "echo \"$ARTIST\"; " +
            "echo '---'; " +
            "echo \"$VOL\""
        ]
        running: true
        stdout: StdioCollector {
            id: mediaOut
            onTextChanged: root.parseMedia(text)
        }
        onExited: root.parseMedia(mediaOut.text)
    }

    Timer {
        id: pollTimer
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            if (!mediaQueryProc.running) {
                mediaQueryProc.running = true
            }
        }
    }

    function parseMedia(raw) {
        if (!raw || raw.length === 0) return
        let parts = raw.split("---")
        if (parts.length >= 4) {
            root.playerStatus = parts[0].trim()
            root.trackTitle = parts[1].trim()
            root.trackArtist = parts[2].trim()
            let v = parseInt(parts[3].trim())
            if (!isNaN(v) && v >= 0) root.volumeLevel = v
        }
    }

    // Media Control Processes
    Process { id: playPauseProc; command: ["playerctl", "play-pause"] }
    Process { id: prevTrackProc; command: ["playerctl", "previous"] }
    Process { id: nextTrackProc; command: ["playerctl", "next"] }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 14
        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.72)
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                text: root.isPlaying ? "󰎆" : "󰓇"
                font.family: Theme.fontFamily
                font.pixelSize: 17
                font.bold: true
                color: root.isPlaying ? Theme.accent : Theme.muted
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: root.trackTitle.length > 0 ? root.trackTitle : "No Media Playing"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    color: Theme.foreground
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: root.trackArtist.length > 0 ? root.trackArtist : ("Media Player •  " + root.volumeLevel + "%")
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.muted
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            // Playback Controls
            RowLayout {
                spacing: 4

                // Previous Track Button
                Rectangle {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: 6
                    color: prevBtnMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.35) : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.45)
                    border.color: prevBtnMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: prevBtnMouse.containsMouse ? Theme.foreground : Theme.muted
                    }

                    MouseArea {
                        id: prevBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            prevTrackProc.running = true
                            mediaQueryProc.running = true
                        }
                    }
                }

                // Play / Pause Button
                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 24
                    radius: 6
                    color: playBtnMouse.containsMouse ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28)
                    border.color: Theme.primary
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: root.isPlaying ? "󰏤" : "󰐊"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: playBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            playPauseProc.running = true
                            mediaQueryProc.running = true
                        }
                    }
                }

                // Next Track Button
                Rectangle {
                    implicitWidth: 24
                    implicitHeight: 24
                    radius: 6
                    color: nextBtnMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.35) : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.45)
                    border.color: nextBtnMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: nextBtnMouse.containsMouse ? Theme.foreground : Theme.muted
                    }

                    MouseArea {
                        id: nextBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            nextTrackProc.running = true
                            mediaQueryProc.running = true
                        }
                    }
                }
            }
        }
    }
}
