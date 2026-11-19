import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Io
import ".."
import "../components"

Pill {
    id: root
    implicitWidth: wsRow.implicitWidth + 16
    implicitHeight: 28

    property int activeWorkspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    property var occupiedMap: ({})

    Process {
        id: dispatchProc
    }

    // Monitor active workspace in real time
    Process {
        id: activeWsChecker
        command: ["hyprctl", "-j", "activeworkspace"]
        stdout: StdioCollector {
            onTextChanged: {
                try {
                    let obj = JSON.parse(text)
                    if (obj && obj.id) {
                        root.activeWorkspaceId = obj.id
                    }
                } catch (e) {}
            }
        }
    }

    // Monitor occupied workspaces list in real time
    Process {
        id: wsListChecker
        command: ["hyprctl", "-j", "workspaces"]
        stdout: StdioCollector {
            onTextChanged: {
                try {
                    let list = JSON.parse(text)
                    let map = {}
                    if (Array.isArray(list)) {
                        for (let i = 0; i < list.length; i++) {
                            let item = list[i]
                            if (item && item.id && item.windows > 0) {
                                map[item.id] = true
                            }
                        }
                    }
                    root.occupiedMap = map
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            if (!activeWsChecker.running) activeWsChecker.running = true
            if (!wsListChecker.running) wsListChecker.running = true
        }
        Component.onCompleted: {
            activeWsChecker.running = true
            wsListChecker.running = true
        }
    }

    function switchWorkspace(wsId) {
        root.activeWorkspaceId = wsId
        // Dispatch using Lua focus format required by hyprland.lua
        dispatchProc.command = ["hyprctl", "dispatch", "hl.dsp.focus({ workspace = " + wsId + " })"]
        dispatchProc.running = true
        try {
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + " })")
        } catch (e) {}
    }

    // Return list of workspace IDs to display (minimum 5)
    readonly property var workspaceList: {
        let maxId = 5
        if (root.occupiedMap) {
            for (let k in root.occupiedMap) {
                let idNum = parseInt(k)
                if (idNum > maxId && idNum < 20) {
                    maxId = idNum
                }
            }
        }
        if (Hyprland.workspaces && Hyprland.workspaces.values) {
            for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                let ws = Hyprland.workspaces.values[i]
                if (ws && ws.id > maxId && ws.id < 20) {
                    maxId = ws.id
                }
            }
        }
        let list = []
        for (let j = 1; j <= maxId; j++) {
            list.push(j)
        }
        return list
    }

    function isOccupied(wsId) {
        if (root.occupiedMap && root.occupiedMap[wsId]) return true
        if (!Hyprland.workspaces || !Hyprland.workspaces.values) return false
        for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
            let ws = Hyprland.workspaces.values[i]
            if (ws && ws.id === wsId) {
                return true
            }
        }
        return false
    }

    RowLayout {
        id: wsRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: root.workspaceList

            Item {
                id: wsItem
                required property int modelData

                readonly property bool isActive: (modelData === root.activeWorkspaceId)
                readonly property bool occupied: root.isOccupied(modelData)
                readonly property bool isHovered: wsMouse.containsMouse

                implicitWidth: 24
                implicitHeight: 24

                // Rotated diamond badge for active and occupied workspaces
                Rectangle {
                    anchors.centerIn: parent
                    visible: wsItem.isActive || wsItem.occupied
                    width: 17
                    height: 17
                    rotation: 45
                    radius: 3.5

                    color: wsItem.isActive ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.22) : (wsItem.isHovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent")
                    border.color: {
                        if (wsItem.isActive) return Theme.primary
                        if (wsItem.isHovered) return Theme.accent
                        return Theme.border
                    }
                    border.width: wsItem.isActive ? 1.5 : 1

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                }

                // Text: Displays the workspace number inside the diamond when occupied/active;
                // displays the clean brand diamond ◇ when unoccupied.
                Text {
                    anchors.centerIn: parent
                    text: (wsItem.isActive || wsItem.occupied) ? String(wsItem.modelData) : "◇"
                    font.family: Theme.fontFamily
                    font.pixelSize: (wsItem.isActive || wsItem.occupied) ? 10.5 : 12
                    font.bold: wsItem.isActive
                    color: {
                        if (wsItem.isActive) return Theme.primary
                        if (wsItem.isHovered) return Theme.accent
                        if (wsItem.occupied) return Theme.foreground
                        return Theme.border
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.switchWorkspace(wsItem.modelData)
                    }
                }
            }
        }
    }
}
