import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."

PanelWindow {
    id: root

    // Position at bottom-right of the desktop screen
    anchors {
        bottom: true
        right: true
    }

    margins {
        bottom: 24
        right: 28
    }

    implicitWidth: 290
    implicitHeight: 200
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Bottom

    // Properties for stats
    property int cpuUsage: 0
    property int cpuTemp: 0
    property real lastTotal: 0
    property real lastIdle: 0

    property int memUsage: 0
    property string memUsedStr: "0.0"
    property string memTotalStr: "0.0"
    property int totalMemUsage: 0 // Porcentaje general de memoria (RAM + ZRAM + Swap)

    property int diskUsage: 0
    property string diskUsedStr: "0G"
    property string diskTotalStr: "0G"

    property string uptimeStr: "0m"
    property string kernelStr: ""
    property int batteryLevel: 100
    property string batteryStatus: ""

    Process {
        id: kernelProc
        command: ["uname", "-r"]
        running: true
        stdout: StdioCollector {
            onTextChanged: root.kernelStr = text.trim()
        }
    }

    Process {
        id: statsProc
        command: [
            "sh", "-c",
            "grep '^cpu ' /proc/stat; " +
            "echo '---'; " +
            "grep -E '^(MemTotal|MemAvailable):' /proc/meminfo; " +
            "echo '---'; " +
            "cat /proc/swaps; " +
            "echo '---'; " +
            "df -h / | awk 'NR==2 {print $3, $2, $5}'; " +
            "echo '---'; " +
            "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -n 1; " +
            "echo '---'; " +
            "cut -d' ' -f1 /proc/uptime; " +
            "echo '---'; " +
            "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1; " +
            "echo '---'; " +
            "cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1"
        ]
        running: true
        stdout: StdioCollector {
            id: statsOut
            onTextChanged: root.parseStats(text)
        }
        onExited: root.parseStats(statsOut.text)
    }

    Timer {
        id: pollTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!statsProc.running) {
                statsProc.running = true
            }
        }
    }

    function parseStats(raw) {
        if (!raw || raw.length === 0) return
        let sections = raw.split("---")
        if (sections.length < 6) return

        // 1. CPU
        let cpuSection = sections[0].trim()
        let cpuParts = cpuSection.split(/\s+/)
        if (cpuParts.length >= 8 && cpuParts[0] === "cpu") {
            let u = parseInt(cpuParts[1]) || 0
            let n = parseInt(cpuParts[2]) || 0
            let s = parseInt(cpuParts[3]) || 0
            let i = parseInt(cpuParts[4]) || 0
            let w = parseInt(cpuParts[5]) || 0
            let q = parseInt(cpuParts[6]) || 0
            let sq = parseInt(cpuParts[7]) || 0

            let total = u + n + s + i + w + q + sq
            let idle = i + w

            if (root.lastTotal > 0) {
                let diffTotal = total - root.lastTotal
                let diffIdle = idle - root.lastIdle
                if (diffTotal > 0) {
                    root.cpuUsage = Math.min(100, Math.max(0, Math.round((1.0 - (diffIdle / diffTotal)) * 100)))
                }
            }
            root.lastTotal = total
            root.lastIdle = idle
        }

        // 2. Physical Memory
        let memSection = sections[1]
        let totalMatch = memSection.match(/MemTotal:\s+(\d+)/)
        let availMatch = memSection.match(/MemAvailable:\s+(\d+)/)
        let totKb = 0
        let usedKb = 0
        if (totalMatch && availMatch) {
            totKb = parseInt(totalMatch[1])
            let availKb = parseInt(availMatch[1])
            usedKb = totKb - availKb
            root.memUsage = Math.min(100, Math.max(0, Math.round((usedKb / totKb) * 100)))
            root.memUsedStr = (usedKb / 1048576).toFixed(1)
            root.memTotalStr = (totKb / 1048576).toFixed(1)
        }

        // 3. Swaps & Porcentaje General
        let swapsSection = sections[2].trim()
        let swapLines = swapsSection.split("\n")
        let totalSwapKb = 0
        let usedSwapKb = 0
        for (let s = 1; s < swapLines.length; s++) {
            let sline = swapLines[s].trim()
            if (!sline) continue
            let parts = sline.split(/\s+/)
            if (parts.length >= 4) {
                totalSwapKb += parseInt(parts[2]) || 0
                usedSwapKb += parseInt(parts[3]) || 0
            }
        }
        let totalCombinedKb = totKb + totalSwapKb
        let usedCombinedKb = usedKb + usedSwapKb
        if (totalCombinedKb > 0) {
            root.totalMemUsage = Math.min(100, Math.max(0, Math.round((usedCombinedKb / totalCombinedKb) * 100)))
        }

        // 4. Disk Storage
        let diskSection = sections[3].trim()
        let diskParts = diskSection.split(/\s+/)
        if (diskParts.length >= 3) {
            root.diskUsedStr = diskParts[0]
            root.diskTotalStr = diskParts[1]
            let pStr = diskParts[2].replace("%", "")
            let p = parseInt(pStr)
            if (!isNaN(p)) root.diskUsage = p
        }

        // 5. Temp
        let tempSection = sections[4].trim()
        let tempVal = parseInt(tempSection)
        if (!isNaN(tempVal) && tempVal > 0) {
            root.cpuTemp = Math.round(tempVal > 1000 ? tempVal / 1000 : tempVal)
        }

        // 6. Uptime
        let uptimeSection = sections[5].trim()
        let sec = parseFloat(uptimeSection)
        if (!isNaN(sec)) {
            let h = Math.floor(sec / 3600)
            let m = Math.floor((sec % 3600) / 60)
            root.uptimeStr = h > 0 ? (h + "h " + m + "m") : (m + "m")
        }

        // 7. Battery
        if (sections.length >= 7) {
            let bVal = parseInt(sections[6].trim())
            if (!isNaN(bVal)) root.batteryLevel = bVal
        }
        if (sections.length >= 8) {
            root.batteryStatus = sections[7].trim()
        }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 14
        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.72)
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
        border.width: 1

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 14
            spacing: 9

            // Header: Arch icon + "Arch Linux" + Uptime
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: ""
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                    color: Theme.accent
                }

                Text {
                    text: "Arch Linux"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    color: Theme.foreground
                    Layout.fillWidth: true
                }

                Text {
                    text: "󱎫 " + root.uptimeStr
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.muted
                }
            }

            // Subtle divider
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
            }

            // CPU Row
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: " CPU"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.foreground
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: (root.cpuTemp > 0 ? (root.cpuTemp + "°C  ") : "") + root.cpuUsage + "%"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: root.cpuUsage > 85 ? Theme.error : (root.cpuUsage > 65 ? Theme.warning : Theme.primary)
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
                        width: Math.max(0, Math.min(parent.width, parent.width * (root.cpuUsage / 100.0)))
                        radius: 3
                        color: root.cpuUsage > 85 ? Theme.error : (root.cpuUsage > 65 ? Theme.warning : Theme.primary)

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }

            // Memory Row (Shows RAM amount + Porcentaje General)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "󰍛 RAM"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.foreground
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.memUsedStr + " / " + root.memTotalStr + " GB (" + root.totalMemUsage + "% general)"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: root.totalMemUsage > 85 ? Theme.error : (root.totalMemUsage > 70 ? Theme.warning : Theme.secondary)
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

            // Disk Row
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "󰋊 Disk (/)"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.foreground
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.diskUsedStr + " / " + root.diskTotalStr + " (" + root.diskUsage + "%)"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: root.diskUsage > 90 ? Theme.error : Theme.accent
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
                        width: Math.max(0, Math.min(parent.width, parent.width * (root.diskUsage / 100.0)))
                        radius: 3
                        color: root.diskUsage > 90 ? Theme.error : Theme.accent

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }

            // Footer Row: Kernel + Battery
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 2
                spacing: 6

                Text {
                    text: "󰌽 " + (root.kernelStr.length > 0 ? root.kernelStr : "Linux")
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.muted
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    visible: root.batteryLevel > 0
                    text: (root.batteryStatus === "Charging" ? "󰂄 " : "󰁹 ") + root.batteryLevel + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: root.batteryLevel <= 20 && root.batteryStatus !== "Charging" ? Theme.error : Theme.muted
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                launchHtopProc.running = true
            }
        }
    }

    Process {
        id: launchHtopProc
        command: ["kitty", "-e", "htop"]
    }
}
