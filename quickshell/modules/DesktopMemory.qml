import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."

PanelWindow {
    id: root

    // Positioned immediately to the left of DesktopStats with matching dimensions
    anchors {
        bottom: true
        right: true
    }

    margins {
        bottom: 24
        right: 330 // 28 (right margin) + 290 (DesktopStats width) + 12 (gap)
    }

    implicitWidth: 290
    implicitHeight: 200
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Bottom

    // General Combined Memory
    property int totalMemUsage: 0
    property string totalMemUsedStr: "0.0"
    property string totalMemTotalStr: "0.0"

    // 1. Physical RAM
    property int ramUsage: 0
    property string ramUsedStr: "0.0"
    property string ramTotalStr: "0.0"

    // 2. ZRAM (Compressed RAM Swap)
    property int zramUsage: 0
    property string zramUsedStr: "0.0"
    property string zramTotalStr: "0.0"

    // 3. Disk Swap (/swapfile on NVMe)
    property int diskSwapUsage: 0
    property string diskSwapUsedStr: "0.0"
    property string diskSwapTotalStr: "0.0"

    Process {
        id: memQueryProc
        command: [
            "sh", "-c",
            "grep -E '^(MemTotal|MemAvailable):' /proc/meminfo; " +
            "echo '---'; " +
            "cat /proc/swaps"
        ]
        running: true
        stdout: StdioCollector {
            id: memOut
            onTextChanged: root.parseMemory(text)
        }
        onExited: root.parseMemory(memOut.text)
    }

    Timer {
        id: pollTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!memQueryProc.running) {
                memQueryProc.running = true
            }
        }
    }

    function parseMemory(raw) {
        if (!raw || raw.length === 0) return
        let sections = raw.split("---")
        if (sections.length < 2) return

        // 1. Physical RAM
        let memSection = sections[0]
        let totalMatch = memSection.match(/MemTotal:\s+(\d+)/)
        let availMatch = memSection.match(/MemAvailable:\s+(\d+)/)
        let ramTotKb = totalMatch ? parseInt(totalMatch[1]) : 0
        let ramAvailKb = availMatch ? parseInt(availMatch[1]) : 0
        let ramUsedKb = Math.max(0, ramTotKb - ramAvailKb)

        root.ramUsage = ramTotKb > 0 ? Math.min(100, Math.max(0, Math.round((ramUsedKb / ramTotKb) * 100))) : 0
        root.ramUsedStr = (ramUsedKb / 1048576).toFixed(1)
        root.ramTotalStr = (ramTotKb / 1048576).toFixed(1)

        // 2. Swaps: ZRAM & Disk Swap
        let swapsSection = sections[1].trim()
        let swapLines = swapsSection.split("\n")
        let zramTotKb = 0
        let zramUsedKb = 0
        let diskSwapTotKb = 0
        let diskSwapUsedKb = 0

        for (let s = 1; s < swapLines.length; s++) {
            let sline = swapLines[s].trim()
            if (!sline) continue
            let parts = sline.split(/\s+/)
            if (parts.length >= 4) {
                let fn = parts[0]
                let sz = parseInt(parts[2]) || 0
                let us = parseInt(parts[3]) || 0
                if (fn.indexOf("zram") !== -1) {
                    zramTotKb += sz
                    zramUsedKb += us
                } else {
                    diskSwapTotKb += sz
                    diskSwapUsedKb += us
                }
            }
        }

        root.zramUsage = zramTotKb > 0 ? Math.min(100, Math.max(0, Math.round((zramUsedKb / zramTotKb) * 100))) : 0
        root.zramUsedStr = (zramUsedKb / 1048576).toFixed(1)
        root.zramTotalStr = (zramTotKb / 1048576).toFixed(1)

        root.diskSwapUsage = diskSwapTotKb > 0 ? Math.min(100, Math.max(0, Math.round((diskSwapUsedKb / diskSwapTotKb) * 100))) : 0
        root.diskSwapUsedStr = (diskSwapUsedKb / 1048576).toFixed(1)
        root.diskSwapTotalStr = (diskSwapTotKb / 1048576).toFixed(1)

        // 3. Métrica General Combinada
        let totalCombinedKb = ramTotKb + zramTotKb + diskSwapTotKb
        let usedCombinedKb = ramUsedKb + zramUsedKb + diskSwapUsedKb
        root.totalMemUsage = totalCombinedKb > 0 ? Math.min(100, Math.max(0, Math.round((usedCombinedKb / totalCombinedKb) * 100))) : 0
        root.totalMemUsedStr = (usedCombinedKb / 1048576).toFixed(1)
        root.totalMemTotalStr = (totalCombinedKb / 1048576).toFixed(1)
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 14
        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.72)
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 6

            // Header: Icon + Title + Status
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "󰍛"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                    color: Theme.accent
                }

                Text {
                    text: "Memory Hub"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.foreground
                    Layout.fillWidth: true
                }

                Text {
                    text: root.totalMemUsage + "% Active"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    color: root.totalMemUsage > 85 ? Theme.error : Theme.secondary
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
            }

            // 1. Métrica General Combinada
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Total Combined"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.foreground
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.totalMemUsedStr + " / " + root.totalMemTotalStr + " GB"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: root.totalMemUsage > 85 ? Theme.error : Theme.secondary
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 6
                    radius: 3
                    color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.35)

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: Math.max(0, Math.min(parent.width, parent.width * (root.totalMemUsage / 100.0)))
                        radius: 3
                        color: root.totalMemUsage > 85 ? Theme.error : (root.totalMemUsage > 70 ? Theme.warning : Theme.secondary)

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }

            // 2. Tres Métricas Independientes (RAM, ZRAM, Disk Swap)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                // A. Physical RAM
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "• Physical RAM"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.foreground
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.ramUsedStr + " / " + root.ramTotalStr + " GB (" + root.ramUsage + "%)"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.muted
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 4
                        radius: 2
                        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.35)

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: Math.max(0, Math.min(parent.width, parent.width * (root.ramUsage / 100.0)))
                            radius: 2
                            color: root.ramUsage > 85 ? Theme.error : Theme.primary

                            Behavior on width {
                                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }

                // B. ZRAM (Compressed Swap in RAM)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "• ZRAM (Compressed)"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.foreground
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.zramUsedStr + " / " + root.zramTotalStr + " GB (" + root.zramUsage + "%)"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.muted
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 4
                        radius: 2
                        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.35)

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: Math.max(0, Math.min(parent.width, parent.width * (root.zramUsage / 100.0)))
                            radius: 2
                            color: root.zramUsage > 80 ? Theme.warning : Theme.accent

                            Behavior on width {
                                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }

                // C. Disk Swap (NVMe /swapfile)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "• NVMe Swapfile"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.foreground
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.diskSwapUsedStr + " / " + root.diskSwapTotalStr + " GB (" + root.diskSwapUsage + "%)"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.muted
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 4
                        radius: 2
                        color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.35)

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: Math.max(0, Math.min(parent.width, parent.width * (root.diskSwapUsage / 100.0)))
                            radius: 2
                            color: root.diskSwapUsage > 80 ? Theme.error : Theme.accent

                            Behavior on width {
                                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }
            }
        }
    }
}
