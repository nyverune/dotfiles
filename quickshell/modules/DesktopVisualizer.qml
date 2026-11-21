import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."

PanelWindow {
    id: root

    // Spans the full width of the screen at the very bottom
    anchors {
        left: true
        right: true
        bottom: true
    }

    margins {
        left: 0
        right: 0
        bottom: 0
    }

    implicitHeight: 140
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Bottom

    property var barValues: []
    property bool isAudioActive: false

    Component.onCompleted: {
        let initial = [];
        for (let i = 0; i < 64; i++) {
            initial.push(0);
        }
        root.barValues = initial;
    }

    // Process to run cava with 64 bars stdout raw output
    Process {
        id: cavaProc
        command: ["cava", "-p", "/home/nyverune/.config/cava/visualizer.conf"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(';');
                if (parts.length >= 64) {
                    let vals = [];
                    let sum = 0;
                    for (let i = 0; i < 64; i++) {
                        let v = parseInt(parts[i], 10);
                        if (isNaN(v) || v < 0) v = 0;
                        vals.push(v);
                        sum += v;
                    }
                    root.barValues = vals;
                    root.isAudioActive = sum > 0;
                }
            }
        }
        onExited: restartTimer.start()
    }

    Timer {
        id: restartTimer
        interval: 2000
        repeat: false
        onTriggered: cavaProc.running = true
    }

    // Full-width bars row
    RowLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        Repeater {
            model: 64

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.max(2, parent.width)
                    radius: 3
                    height: {
                        let v = (root.barValues && root.barValues[index] !== undefined) ? root.barValues[index] : 0;
                        return Math.max(3, Math.min(parent.height - 4, (v / 100.0) * (parent.height - 4)));
                    }

                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: root.isAudioActive ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.70)
                                                      : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
                        }
                        GradientStop {
                            position: 1.0
                            color: root.isAudioActive ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.35)
                                                      : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
                        }
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 55
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }
}
