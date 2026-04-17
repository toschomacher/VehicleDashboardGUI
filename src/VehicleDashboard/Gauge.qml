import QtQuick 2.15

Item {
    id: root
    width: 700
    height: 700

    property real speed: 0
    property real rpm: 0

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "white"
        border.width: 2
        radius: width / 2
    }
}