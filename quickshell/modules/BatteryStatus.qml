import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."
import "../components"

Pill {
    id: root
    implicitWidth: contentRow.implicitWidth + 16
    implicitHeight: 28

    property int capacity: 100
    property string status: "Full"
    property int acOnline: 0
    property bool isLow: capacity <= 20
    property bool isCharging: status === "Charging" || (acOnline === 1 && status !== "Discharging")
    property bool notifiedLow: false

    color: isLow && !isCharging ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.18) : Theme.surface
    border.color: isLow && !isCharging ? Theme.warning : Theme.border

    Process {
        id: notifyProc
        command: [
            "notify-send",
            "-u", "critical",
            "-i", "battery-caution",
            "Low Battery (Nyverune)",
            "Current level: " + root.capacity + "%. Please connect your device to power."
        ]
    }

    function parseOutput(raw) {
        if (!raw || raw.length === 0) return
        let lines = raw.trim().split("\n")
        if (lines.length >= 1 && lines[0].length > 0) {
            let cap = parseInt(lines[0])
            if (!isNaN(cap)) root.capacity = cap
        }
        if (lines.length >= 2 && lines[1].length > 0) {
            root.status = lines[1].trim()
        }
        if (lines.length >= 3 && lines[2].length > 0) {
            let ac = parseInt(lines[2])
            if (!isNaN(ac)) root.acOnline = ac
        }

        // Trigger low battery notification once when dropping to 20% or below while discharging
        if (root.isLow && !root.isCharging) {
            if (!root.notifiedLow) {
                root.notifiedLow = true
                notifyProc.running = true
            }
        } else if (root.capacity > 25 || root.isCharging) {
            root.notifiedLow = false
        }
    }

    // Direct kernel sysfs reader (bypasses inotify cache on virtual /sys files)
    Process {
        id: batProc
        command: [
            "sh", "-c",
            "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1; " +
            "cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1; " +
            "cat /sys/class/power_supply/AD*/online /sys/class/power_supply/AC*/online 2>/dev/null | head -n 1"
        ]
        running: true
        stdout: StdioCollector {
            id: batOut
            onTextChanged: root.parseOutput(text)
        }
        onExited: root.parseOutput(batOut.text)
    }

    // Ultra-responsive 1-second refresh timer
    Timer {
        id: pollTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (!batProc.running) {
                batProc.running = true
            }
        }
        Component.onCompleted: {
            if (!batProc.running) {
                batProc.running = true
            }
        }
    }

    readonly property string batteryIcon: {
        if (root.isCharging) return "󰂄"
        if (root.capacity >= 90) return "󰁹"
        if (root.capacity >= 70) return "󰂀"
        if (root.capacity >= 50) return "󰁾"
        if (root.capacity >= 30) return "󰁼"
        if (root.capacity >= 15) return "󰁻"
        return "󰁺"
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.batteryIcon
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: {
                if (root.isCharging) return Theme.success
                if (root.isLow) return Theme.warning
                return Theme.primary
            }
        }

        Text {
            text: root.capacity + "%"
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: root.isLow && !root.isCharging ? Theme.warning : Theme.foreground
        }
    }
}
