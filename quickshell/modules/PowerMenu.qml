import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."

PanelWindow {
    id: powerWindow

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: powerWindow.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    visible: false

    property int selectedIndex: 0 // Default to 0 ("Shutdown")

    readonly property var actions: [
        {
            id: "shutdown",
            name: "Shutdown",
            desc: "Power off",
            icon: "⏻",
            color: Theme.error
        },
        {
            id: "reboot",
            name: "Reboot",
            desc: "Restart",
            icon: "󰑓",
            color: Theme.warning
        },
        {
            id: "lock",
            name: "Lock",
            desc: "Lock screen",
            icon: "󰌾",
            color: Theme.primary
        },
        {
            id: "logout",
            name: "Logout",
            desc: "Exit Hyprland",
            icon: "󰍃",
            color: Theme.accent
        },
        {
            id: "suspend",
            name: "Suspend",
            desc: "Sleep",
            icon: "󰒲",
            color: Theme.info
        }
    ]

    function open() {
        selectedIndex = 0 // Default always on "Shutdown"
        closeTimer.stop()
        powerWindow.visible = true
        focusScope.opacity = 1.0
        focusScope.forceActiveFocus()
    }

    function close() {
        focusScope.opacity = 0.0
        closeTimer.start()
    }

    function next() {
        selectedIndex = (selectedIndex + 1) % actions.length
    }

    function prev() {
        selectedIndex = (selectedIndex - 1 + actions.length) % actions.length
    }

    function execute(idx) {
        let targetIndex = (idx !== undefined) ? idx : selectedIndex
        let act = actions[targetIndex].id
        close()

        if (act === "shutdown") {
            execProc.command = ["systemctl", "poweroff"]
        } else if (act === "reboot") {
            execProc.command = ["systemctl", "reboot"]
        } else if (act === "lock") {
            execProc.command = ["hyprlock"]
        } else if (act === "logout") {
            execProc.command = ["hyprctl", "dispatch", "exit"]
        } else if (act === "suspend") {
            execProc.command = ["systemctl", "suspend"]
        }
        execProc.running = true
    }

    Timer {
        id: closeTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (focusScope.opacity <= 0.01) {
                powerWindow.visible = false
            }
        }
    }

    Process {
        id: execProc
    }

    IpcHandler {
        target: "powermenu"
        function toggle() {
            if (powerWindow.visible) {
                powerWindow.close()
            } else {
                powerWindow.open()
            }
        }
        function open() {
            powerWindow.open()
        }
        function close() {
            powerWindow.close()
        }
    }

    // Keyboard & focus grab
    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: true
        opacity: 0.0

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                powerWindow.close()
                event.accepted = true
            } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier)) || event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                powerWindow.prev()
                event.accepted = true
            } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                powerWindow.next()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                powerWindow.execute()
                event.accepted = true
            }
        }

        // Fullscreen darkened background overlay
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.6)

            MouseArea {
                anchors.fill: parent
                onClicked: powerWindow.close()
            }
        }

        // Center card modal
        Rectangle {
            id: modal
            anchors.centerIn: parent
            implicitWidth: 640
            implicitHeight: 210
            radius: 20
            color: Theme.surface
            border.color: Theme.border
            border.width: 1

            scale: focusScope.opacity > 0.01 ? 1.0 : 0.94
            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.OutBack }
            }

            // Stop click propagation inside the modal card
            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 20

                // Header title
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Power Menu"
                        font.family: Theme.fontFamily
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: Theme.foreground
                    }

                    Item { Layout.fillWidth: true }

                    // Current user badge
                    Rectangle {
                        implicitWidth: userRow.implicitWidth + 14
                        implicitHeight: 24
                        radius: 12
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                        border.color: Theme.primary
                        border.width: 1

                        RowLayout {
                            id: userRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "󰀉"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: Theme.primary
                            }
                            Text {
                                text: Quickshell.env("USER") || "user"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.foreground
                            }
                        }
                    }
                }

                // Action cards row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    Repeater {
                        model: powerWindow.actions

                        Rectangle {
                            id: actionCard
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 14

                            readonly property bool isSelected: powerWindow.selectedIndex === index

                            color: isSelected ? Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.18)
                                              : (cardMouse.containsMouse ? Qt.lighter(Theme.surface, 1.1) : Theme.surfaceMuted)

                            border.color: isSelected ? modelData.color : (cardMouse.containsMouse ? Theme.primary : Theme.border)
                            border.width: isSelected ? 2 : 1
                            scale: isSelected ? 1.04 : (cardMouse.containsMouse ? 1.02 : 1.0)

                            Behavior on scale {
                                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            Behavior on border.color {
                                ColorAnimation { duration: 150 }
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 8

                                // Large Action Icon
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.icon
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 28
                                    color: actionCard.isSelected ? modelData.color : Theme.foreground
                                }

                                // Action Label
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.name
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    font.weight: actionCard.isSelected ? Font.Bold : Font.DemiBold
                                    color: actionCard.isSelected ? modelData.color : Theme.foreground
                                }

                                // Action Subtitle
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.desc
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    color: actionCard.isSelected ? modelData.color : Theme.muted
                                }
                            }

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    powerWindow.selectedIndex = index
                                    powerWindow.execute(index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
