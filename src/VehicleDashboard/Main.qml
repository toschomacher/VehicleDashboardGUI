import QtQuick
import QtQuick.Controls

Window {
    width: 1920
    height: 1080
    visible: true
    //visibility: Window.FullScreen
    title: qsTr("TOYOTA AYGO VIRTUAL COCKPIT ADDITION")

    property real aspectRatio: 16/9

    onWidthChanged: height = width / aspectRatio
    onHeightChanged: width = height * aspectRatio

    Rectangle {
        anchors.fill: parent
        color: "black"
    }
}