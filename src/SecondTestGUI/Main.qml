import QtQuick
import QtQuick.Controls

Window {
    width: 1920
    height: 1080
    visible: true
    title: qsTr("TOYOTA AYGO VIRTUAL COCKPIT ADDITION")

    property real aspectRatio: 16/9  // desired width:height ratio

        // enforce aspect ratio on resize
        onWidthChanged: height = width / aspectRatio
        onHeightChanged: width = height * aspectRatio

    // Background image
    Image {
        anchors.fill: parent
        source: "background.png" // file must be in the same folder as Main.qml at runtime
        fillMode: Image.PreserveAspectCrop
    }

    Column {
        anchors.centerIn: parent
        spacing: 20
        /*
        Text {
            id: message
            text: "Press the button..."
            font.pixelSize: 24
            color: "white" // change text color so it shows over the image
        }

        Button {
            id: helloButton
            text: "Say Hello"

            onClicked: {
                message.text = "Hello, World!"
            }
        }
        */
    }
}
