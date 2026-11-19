import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root

    property alias hovered: mouseArea.containsMouse
    property bool clickable: false
    signal clicked()

    implicitHeight: 28
    radius: 8

    color: hovered && clickable ? Qt.lighter(Theme.surface, 1.15) : Theme.surface
    border.color: hovered && clickable ? Theme.primary : Theme.border
    border.width: 1

    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.clickable) {
                root.clicked()
            }
        }
    }
}
