import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./modules"

ShellRoot {
    id: root

    PanelWindow {
        id: topBar

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: 4
            left: 8
            right: 8
            bottom: 0
        }

        implicitHeight: 36
        color: "transparent"

        // Avoid windows overlapping the bar
        exclusiveZone: 40

        WlrLayershell.layer: WlrLayer.Top

        RowLayout {
            anchors.fill: parent
            spacing: 8

            // -------------------------------------------------------------
            // Left: Workspaces with Nyverune brand diamonds (◆ / ◇)
            // -------------------------------------------------------------
            Workspaces {
                id: workspacesModule
            }

            // -------------------------------------------------------------
            // Center: Placeholder for future widgets (currently empty)
            // -------------------------------------------------------------
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // -------------------------------------------------------------
            // Right: Status modules
            // -------------------------------------------------------------
            RowLayout {
                spacing: 8

                // Updates available (shown only if > 0)
                UpdatesStatus {
                    id: updatesModule
                }

                // Volume level & mute
                AudioStatus {
                    id: audioModule
                }

                // Microphone in use (shown only when in active use)
                MicStatus {
                    id: micModule
                }

                // Network connection status
                NetworkStatus {
                    id: networkModule
                }

                // Battery percentage & low alert
                BatteryStatus {
                    id: batteryModule
                }

                // Clock (UTC-5 & Date by default, strictly UTC on hover)
                ClockDate {
                    id: clockModule
                }
            }
        }
    }
}
