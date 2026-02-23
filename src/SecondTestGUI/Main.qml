import QtQuick
import QtQuick.Controls

Window {
    width: 1920
    height: 1080
    visible: true
    title: qsTr("TOYOTA AYGO VIRTUAL COCKPIT ADDITION")

    property real aspectRatio: 16/9

    onWidthChanged: height = width / aspectRatio
    onHeightChanged: width = height * aspectRatio

    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
    }

    Text {
        id: message
        text: "Press the button..."
        font.pixelSize: 24
        color: "white"
        x: 1000
        y: 10
    }
    // Button 1 Cruise
    Rectangle {
        x: 42
        y: 862
        width: 226
        height: 180

        color: "#00FFFFFF"  // 0% visible

        MouseArea {
            anchors.fill: parent
            onClicked: {
                message.text = "Cruise control ON"
            }
        }
    }
    // Button 2 increment speed +
    Rectangle {
        x: 300
        y: 862
        width: 226
        height: 180

        color: "#00FFFFFF"  // 0% visible

        MouseArea {
            anchors.fill: parent
            onClicked: {
                message.text = "Speed increase + 1"
            }
        }
    }
    // Button 3 decrement speed -
    Rectangle {
        x: 564
        y: 862
        width: 226
        height: 180

        color: "#00FFFFFF"  // 0% visible

        MouseArea {
            anchors.fill: parent
            onClicked: {
                message.text = "Speed decrease - 1"
            }
        }
    }
    // Button 4 Reset
    Rectangle {
        x: 824
        y: 862
        width: 226
        height: 180

        color: "#00FFFFFF"  // 0% visible

        MouseArea {
            anchors.fill: parent
            onClicked: {
                message.text = "Reset"
            }
        }
    }
    // Button 5 Cancel
    Rectangle {
        x: 1082
        y: 862
        width: 226
        height: 180

        color: "#00FFFFFF"  // 0% visible

        MouseArea {
            anchors.fill: parent
            onClicked: {
                message.text = "Cancel"
            }
        }
    }
}
