import QtQuick
import QtQuick.Layouts
import ".."
import "../components"

Pill {
    id: root
    implicitWidth: contentRow.implicitWidth + 20
    implicitHeight: 28

    property bool isHovered: hoverArea.containsMouse
    property string utc5Time: "--:--"
    property string utc5Date: "--, -- ---"
    property string utcTime: "--:-- UTC"
    property string utcDate: "--, -- ---"

    function updateTime() {
        let nowMs = Date.now()
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

        // 1. Calculate UTC-5: Epoch ms minus 5 hours (5 * 3600000 ms)
        let d5 = new Date(nowMs - (5 * 3600000))
        let h5 = String(d5.getUTCHours()).padStart(2, '0')
        let m5 = String(d5.getUTCMinutes()).padStart(2, '0')
        root.utc5Time = h5 + ":" + m5

        let dayName5 = days[d5.getUTCDay()]
        let monthName5 = months[d5.getUTCMonth()]
        let dayNum5 = d5.getUTCDate()
        root.utc5Date = dayName5 + ", " + dayNum5 + " " + monthName5

        // 2. Calculate pure UTC
        let dUtc = new Date(nowMs)
        let hUtc = String(dUtc.getUTCHours()).padStart(2, '0')
        let mUtc = String(dUtc.getUTCMinutes()).padStart(2, '0')
        root.utcTime = hUtc + ":" + mUtc + " UTC"

        let dayNameUtc = days[dUtc.getUTCDay()]
        let monthNameUtc = months[dUtc.getUTCMonth()]
        let dayNumUtc = dUtc.getUTCDate()
        root.utcDate = dayNameUtc + ", " + dayNumUtc + " " + monthNameUtc
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateTime()
        Component.onCompleted: root.updateTime()
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: "󰥔"
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: root.isHovered ? Theme.accent : Theme.primary

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        Text {
            text: root.isHovered ? root.utcTime : root.utc5Time
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Bold
            color: root.isHovered ? Theme.accent : Theme.foreground

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        Rectangle {
            implicitWidth: 1
            implicitHeight: 12
            color: Theme.border
        }

        Text {
            text: root.isHovered ? root.utcDate : root.utc5Date
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: root.isHovered ? Theme.accent : Theme.muted

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
