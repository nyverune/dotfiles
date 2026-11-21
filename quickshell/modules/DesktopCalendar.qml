import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."

PanelWindow {
    id: root

    // Position at bottom-left of the desktop screen
    anchors {
        bottom: true
        left: true
    }

    margins {
        bottom: 24
        left: 28
    }

    implicitWidth: 290
    implicitHeight: 275
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Bottom

    property int displayedYear: 2026
    property int displayedMonth: 10 // 0-indexed (10 = November)
    property int selectedDay: 1
    property int selectedMonth: 10
    property int selectedYear: 2026

    property var calendarDays: []

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    readonly property var dayNamesShort: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    Component.onCompleted: {
        let now = new Date()
        displayedYear = now.getFullYear()
        displayedMonth = now.getMonth()
        selectedDay = now.getDate()
        selectedMonth = displayedMonth
        selectedYear = displayedYear
        rebuildCalendar()
    }

    function rebuildCalendar() {
        let now = new Date()
        let todayYear = now.getFullYear()
        let todayMonth = now.getMonth()
        let todayDay = now.getDate()

        // 1st of displayed month
        let firstDate = new Date(displayedYear, displayedMonth, 1)
        // JS getDay(): 0=Sun, 1=Mon, ..., 6=Sat
        // We want Monday = index 0, ..., Sunday = index 6
        let firstDayIndex = (firstDate.getDay() + 6) % 7

        // Days in current & previous months
        let daysInMonth = new Date(displayedYear, displayedMonth + 1, 0).getDate()
        let daysInPrevMonth = new Date(displayedYear, displayedMonth, 0).getDate()

        let list = []

        // Previous month tail
        for (let i = firstDayIndex - 1; i >= 0; i--) {
            list.push({
                day: daysInPrevMonth - i,
                isCurrentMonth: false,
                isToday: false,
                isSelected: false
            })
        }

        // Current month days
        for (let d = 1; d <= daysInMonth; d++) {
            let isTod = (displayedYear === todayYear && displayedMonth === todayMonth && d === todayDay)
            let isSel = (displayedYear === selectedYear && displayedMonth === selectedMonth && d === selectedDay)
            list.push({
                day: d,
                isCurrentMonth: true,
                isToday: isTod,
                isSelected: isSel
            })
        }

        // Next month fill to 35 or 42 cells
        let targetCount = list.length > 35 ? 42 : 35
        let nextCount = targetCount - list.length
        for (let n = 1; n <= nextCount; n++) {
            list.push({
                day: n,
                isCurrentMonth: false,
                isToday: false,
                isSelected: false
            })
        }

        calendarDays = list
    }

    function prevMonth() {
        if (displayedMonth === 0) {
            displayedMonth = 11
            displayedYear--
        } else {
            displayedMonth--
        }
        rebuildCalendar()
    }

    function nextMonth() {
        if (displayedMonth === 11) {
            displayedMonth = 0
            displayedYear++
        } else {
            displayedMonth++
        }
        rebuildCalendar()
    }

    function jumpToday() {
        let now = new Date()
        displayedYear = now.getFullYear()
        displayedMonth = now.getMonth()
        selectedDay = now.getDate()
        selectedMonth = displayedMonth
        selectedYear = displayedYear
        rebuildCalendar()
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
            anchors.margins: 12
            spacing: 8

            // Top Header: Month, Year, and Nav Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                // Icon + Month Year Title
                RowLayout {
                    spacing: 6
                    Layout.fillWidth: true

                    Text {
                        text: "󰸗"
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                        color: Theme.accent
                    }

                    Text {
                        text: root.monthNames[root.displayedMonth] + " " + root.displayedYear
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        color: Theme.foreground
                    }
                }

                // "Today" Button
                Rectangle {
                    implicitWidth: todayText.implicitWidth + 12
                    implicitHeight: 22
                    radius: 6
                    color: todayMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.5)
                    border.color: todayMouse.containsMouse ? Theme.primary : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.4)
                    border.width: 1

                    Text {
                        id: todayText
                        anchors.centerIn: parent
                        text: "Today"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        color: todayMouse.containsMouse ? Theme.foreground : Theme.muted
                    }

                    MouseArea {
                        id: todayMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.jumpToday()
                    }
                }

                // Prev Month Button
                Rectangle {
                    implicitWidth: 22
                    implicitHeight: 22
                    radius: 6
                    color: prevMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.35) : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.4)
                    border.color: prevMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        color: prevMouse.containsMouse ? Theme.foreground : Theme.muted
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.prevMonth()
                    }
                }

                // Next Month Button
                Rectangle {
                    implicitWidth: 22
                    implicitHeight: 22
                    radius: 6
                    color: nextMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.35) : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.4)
                    border.color: nextMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.3)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        color: nextMouse.containsMouse ? Theme.foreground : Theme.muted
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.nextMonth()
                    }
                }
            }

            // Weekday Headers
            RowLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: root.dayNamesShort

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 18

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: (index >= 5) ? Theme.accent : Theme.muted // Highlight weekends
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.25)
            }

            // Days Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 3
                columnSpacing: 2

                Repeater {
                    model: root.calendarDays

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 22
                        radius: 6

                        // Styling states
                        readonly property bool isToday: modelData.isToday
                        readonly property bool isSel: modelData.isSelected
                        readonly property bool isCur: modelData.isCurrentMonth

                        color: isToday
                               ? Theme.primary
                               : (isSel
                                  ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28)
                                  : (cellMouse.containsMouse && isCur ? Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.6) : "transparent"))

                        border.color: isSel
                                      ? Theme.primary
                                      : (isToday ? Qt.lighter(Theme.primary, 1.2) : "transparent")
                        border.width: isSel || isToday ? 1 : 0

                        Text {
                            anchors.centerIn: parent
                            text: String(modelData.day)
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: isToday || isSel

                            color: isToday
                                   ? "#FFFFFF"
                                   : (isCur ? (isSel ? Theme.foreground : Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.88))
                                            : Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.35))
                        }

                        MouseArea {
                            id: cellMouse
                            anchors.fill: parent
                            enabled: modelData.isCurrentMonth
                            hoverEnabled: true
                            cursorShape: modelData.isCurrentMonth ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                root.selectedDay = modelData.day
                                root.selectedMonth = root.displayedMonth
                                root.selectedYear = root.displayedYear
                                root.rebuildCalendar()
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.25)
            }

            // Footer: Selected Date Description
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                function getSelectedInfo() {
                    let d = new Date(root.selectedYear, root.selectedMonth, root.selectedDay)
                    let dayNamesFull = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                    let dayName = dayNamesFull[d.getDay()]
                    let mName = root.monthNames[root.selectedMonth].substring(0, 3)

                    // Calculate day of year
                    let start = new Date(root.selectedYear, 0, 0)
                    let diff = d - start
                    let oneDay = 1000 * 60 * 60 * 24
                    let dayOfYear = Math.floor(diff / oneDay)

                    // Calculate week number
                    let weekNum = Math.ceil((((d - new Date(root.selectedYear, 0, 1)) / 86400000) + 1) / 7)

                    return dayName + ", " + root.selectedDay + " " + mName + " • D" + dayOfYear + " W" + weekNum
                }

                Text {
                    text: parent.getSelectedInfo()
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    color: Theme.muted
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: root.selectedDay === (new Date()).getDate() && root.selectedMonth === (new Date()).getMonth() ? "● Selected: Today" : "● Selected"
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    color: Theme.accent
                }
            }
        }
    }
}
