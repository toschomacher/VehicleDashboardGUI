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

        // Button 1 Cruise
        Rectangle {
            id: cruiseButton
            x: 82; y: 862
            width: 226; height: 180
            color: "#33FFFFFF"
            border.color: "white"
            border.width: 2
            radius: 5

            SequentialAnimation {
                id: flashAnim
                PropertyAnimation {
                    target: cruiseButton
                    property: "color"
                    to: "#80FFFFFF"
                    duration: 50
                }
                PropertyAnimation {
                    target: cruiseButton
                    property: "color"
                    to: "#33FFFFFF"
                    duration: 150
                }
            }

            Text {
                text: "CRUISE\nON"
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 45
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.2
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    flashAnim.start()
                    CC.active = true
                }
            }
        }

        // Button 2 increment speed +
        Rectangle {
            id: speedButton
            x: 340
            y: 862
            width: 226
            height: 180
            color: "#33FFFFFF"
            border.color: "white"
            border.width: 2
            radius: 5

            SequentialAnimation {
                id: flashAnimSpeed
                PropertyAnimation {
                    target: speedButton
                    property: "color"
                    to: "#80FFFFFF"
                    duration: 50
                }
                PropertyAnimation {
                    target: speedButton
                    property: "color"
                    to: "#33FFFFFF"
                    duration: 150
                }
            }

            Text {
                text: "SPEED\n+"
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 45
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.2
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    flashAnimSpeed.start()
                    CC.setSpeed = CC.setSpeed + 1
                }
            }
        }
    }
}