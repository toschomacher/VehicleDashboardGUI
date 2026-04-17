import QtQuick
import QtQuick.Controls

Window {
    width: 1920
    height: 1080
    visible: true
    visibility: Window.FullScreen
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

            speed: CAN && CAN.connected ? CAN.speed : 0
            rpm:   CAN && CAN.connected ? CAN.rpm   : 0
        }
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

    // Button 3 decrement speed -
    Rectangle {
        id: speedDownButton
        x: 604
        y: 862
        width: 226
        height: 180
        color: "#33FFFFFF"
        border.color: "white"
        border.width: 2
        radius: 5

        SequentialAnimation {
            id: flashAnimDown
            PropertyAnimation {
                target: speedDownButton
                property: "color"
                to: "#80FFFFFF"
                duration: 50
            }
            PropertyAnimation {
                target: speedDownButton
                property: "color"
                to: "#33FFFFFF"
                duration: 150
            }
        }

        Text {
            text: "SPEED\n-"
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
                flashAnimDown.start()
                CC.setSpeed = Math.max(0, CC.setSpeed - 1)
            }
        }
    }

    // Button 4 Reset
    Rectangle {
        id: resetButton
        x: 864
        y: 862
        width: 226
        height: 180
        color: "#33FFFFFF"
        border.color: "white"
        border.width: 2
        radius: 5

        SequentialAnimation {
            id: flashAnimReset
            PropertyAnimation {
                target: resetButton
                property: "color"
                to: "#80FFFFFF"
                duration: 50
            }
            PropertyAnimation {
                target: resetButton
                property: "color"
                to: "#33FFFFFF"
                duration: 150
            }
        }

        Text {
            text: "CRUISE\nRESET"
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
                flashAnimReset.start()
                CC.resume()
            }
        }
    }

    // Button 5 Cancel
    Rectangle {
        id: cancelButton
        x: 1122
        y: 862
        width: 226
        height: 180
        color: "#33FFFFFF"
        border.color: "white"
        border.width: 2
        radius: 5

        SequentialAnimation {
            id: flashAnimCancel
            PropertyAnimation {
                target: cancelButton
                property: "color"
                to: "#80FFFFFF"
                duration: 50
            }
            PropertyAnimation {
                target: cancelButton
                property: "color"
                to: "#33FFFFFF"
                duration: 150
            }
        }

        Text {
            text: "CRUISE\nCANCEL"
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
                flashAnimCancel.start()
                CC.active = false
            }
        }
    }

    // CAN status overlay
    Rectangle {
        id: canOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: (CAN && CAN.connected && CAN.alive) ? 0 : 0.85
        visible: opacity > 0.01
        z: 999

        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                id: statusText
                text: (!CAN || !CAN.connected)
                      ? "INITIALISING CAN"
                      : "WAITING FOR DATA"
                color: "white"
                font.pixelSize: 60
                font.bold: true
                opacity: 0.9

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.4; duration: 800 }
                    NumberAnimation { to: 0.9; duration: 800 }
                }
            }

            Text {
                id: dots
                color: "white"
                font.pixelSize: 50
                horizontalAlignment: Text.AlignHCenter

                property int step: 0

                text: step === 0 ? "." :
                      step === 1 ? ".." :
                                    "..."

                Timer {
                    interval: 400
                    running: canOverlay.visible
                    repeat: true
                    onTriggered: dots.step = (dots.step + 1) % 3
                }
            }

            Text {
                text: (!CAN || !CAN.connected)
                      ? "Checking interface (can0)"
                      : "Receiving frames..."
                color: "#aaaaaa"
                font.pixelSize: 28
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // GPIO26 has replaced the shutdown button logic
}