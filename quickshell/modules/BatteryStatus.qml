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
    property bool isLow: capacity <= 20
    property bool isCharging: status === "Charging"
    property bool notifiedLow: false

    color: isLow && !isCharging ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.18) : Theme.surface
    border.color: isLow && !isCharging ? Theme.warning : Theme.border

    // Read directly from sysfs (universal and zero daemon dependency)
    FileView {
        id: capFile
        path: "/sys/class/power_supply/BAT0/capacity"
        printErrors: false
    }

    FileView {
        id: statFile
        path: "/sys/class/power_supply/BAT0/status"
        printErrors: false
    }

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

    function updateBattery() {
        let rawCap = capFile.text().trim()
        let rawStat = statFile.text().trim()
        if (rawCap.length > 0) {
            root.capacity = parseInt(rawCap) || 100
        }
        if (rawStat.length > 0) {
            root.status = rawStat
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

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.updateBattery()
        Component.onCompleted: root.updateBattery()
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
