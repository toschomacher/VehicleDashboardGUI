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

    Image {
    anchors.fill: parent
    source: "images/background.png"
    fillMode: Image.PreserveAspectCrop

    Gauge {
        id: gauge
        x: 298
        y: 36
        width: 840
        height: 840
        speed: 0
        rpm: 0
    }
}
}