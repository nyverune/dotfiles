import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../components"

Pill {
    id: root
    implicitWidth: contentRow.implicitWidth + 16
    implicitHeight: 28

    property bool isConnected: false
    property string networkName: "Disconnected"

    Process {
        id: netChecker
        command: ["sh", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | head -n1 | cut -d: -f2-"]
        stdout: StdioCollector {
            onTextChanged: {
                let ssid = text.trim()
                if (ssid.length > 0) {
                    root.isConnected = true
                    root.networkName = ssid
                } else {
                    // Check if wired/default route is active
                    wiredChecker.running = true
                }
            }
        }
    }

    Process {
        id: wiredChecker
        command: ["sh", "-c", "ip route get 1.1.1.1 2>/dev/null && echo 'CONNECTED' || echo 'OFFLINE'"]
        stdout: StdioCollector {
            onTextChanged: {
                let status = text.trim()
                if (status === "CONNECTED") {
                    root.isConnected = true
                    root.networkName = "Ethernet"
                } else {
                    root.isConnected = false
                    root.networkName = "Disconnected"
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (!netChecker.running) {
                netChecker.running = true
            }
        }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.isConnected ? "󰖩" : "󰖪"
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: root.isConnected ? Theme.success : Theme.error
        }

        Text {
            text: root.networkName
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: root.isConnected ? Theme.foreground : Theme.muted
            elide: Text.ElideRight
            Layout.maximumWidth: 120
        }
    }
}
