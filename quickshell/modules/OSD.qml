import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."

PanelWindow {
    id: osdWindow

    // Anchored at bottom center of the screen
    anchors {
        bottom: true
    }
    margins {
        bottom: 80
    }

    implicitWidth: 280
    implicitHeight: 68
    color: "transparent"
    exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Overlay

    visible: false

    property string osdType: "volume"
    property int osdValue: 50
    property string osdIcon: ""
    property bool osdMuted: false

    function trigger(type, value, icon, muted) {
        osdType = type || "volume"
        osdValue = Math.max(0, Math.min(100, parseInt(value) || 0))
        osdIcon = icon || (osdType === "brightness" ? "󰃠" : (osdType === "mic" ? "󰍬" : ""))
        osdMuted = (muted === true || muted === "true")

        closeTimer.stop()
        hideTimer.stop()
        osdWindow.visible = true
        osdCard.opacity = 1.0
        osdCard.scale = 1.0
        hideTimer.start()
    }

    Timer {
        id: hideTimer
        interval: 1800
        repeat: false
        onTriggered: {
            osdCard.opacity = 0.0
            osdCard.scale = 0.92
            closeTimer.start()
        }
    }

    Timer {
        id: closeTimer
        interval: 220
        repeat: false
        onTriggered: {
            if (osdCard.opacity === 0.0) {
                osdWindow.visible = false
            }
        }
    }

    // Native Quickshell IPC support
    IpcHandler {
        target: "osd"
        function trigger(type: string, value: string, icon: string, muted: string) {
            osdWindow.trigger(type, value, icon, muted)
        }
    }

    // Real-time FIFO / log stream listener for instant response from scripts
    Process {
        id: osdListener
        command: ["sh", "-c", "touch /tmp/nyverune-osd && exec tail -n 0 -F /tmp/nyverune-osd"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                let line = data.trim()
                if (!line) return
                try {
                    let msg = JSON.parse(line)
                    osdWindow.trigger(msg.type, msg.value, msg.icon, msg.muted)
                } catch(e) {}
            }
        }
        Component.onCompleted: {
            osdListener.running = true
        }
    }

    Rectangle {
        id: osdCard
        anchors.fill: parent
        radius: 16
        color: Theme.surface
        border.color: osdWindow.osdMuted ? Theme.muted : Theme.primary
        border.width: 1

        opacity: 0.0
        scale: 0.92

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 220; easing.type: Easing.OutBack }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 14

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 20
                color: osdWindow.osdMuted ? Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.15)
                                          : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)

                Text {
                    anchors.centerIn: parent
                    text: osdWindow.osdIcon
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                    color: osdWindow.osdMuted ? Theme.muted : Theme.primary
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: {
                            if (osdWindow.osdType === "mic") {
                                return osdWindow.osdMuted ? "Microphone Muted" : "Microphone Active"
                            } else if (osdWindow.osdType === "brightness") {
                                return "Brightness"
                            } else {
                                return osdWindow.osdMuted ? "Audio Muted" : "Volume"
                            }
                        }
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: osdWindow.osdMuted ? Theme.muted : Theme.foreground
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        visible: osdWindow.osdType !== "mic"
                        text: osdWindow.osdMuted ? "MUTED" : osdWindow.osdValue + "%"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: osdWindow.osdMuted ? Theme.muted : Theme.primary
                    }
                }

                Rectangle {
                    visible: osdWindow.osdType !== "mic"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    radius: 3
                    color: Theme.border

                    Rectangle {
                        id: progressFill
                        height: parent.height
                        radius: 3
                        width: parent.width * (osdWindow.osdMuted ? 0 : (osdWindow.osdValue / 100.0))
                        color: osdWindow.osdMuted ? Theme.muted : Theme.primary

                        Behavior on width {
                            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }
    }
}
