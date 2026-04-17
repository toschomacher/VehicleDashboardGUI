import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root

    property real speed: 0
    property real rpm: 0
    property real displaySpeed: 0
    property real displayRPM: 0
    property real displayODO: 16625
    property real ccSetValue: 0
    property bool ccActivated: false
    property real smoothedRPM: 0
    property real smoothedThrottle: 0
    property real smoothedSpeed: 0
    property real smoothedBrake: 0
    property real smoothedClutch: 0
    property real prevThrottle: 0
    property real rawThrottle: 0

    width: 700
    height: 700

    property real startAngle: 135
    property real sweep: 270
    property real velocity: 0

    // =========================
    // RINGS / SHAPE GEOMETRY
    // =========================
    Item {
        id: rings
        anchors.fill: parent
        visible: false

        // ============================================
        // OUTER RING
        // ============================================
        property real outerRadius: root.width * 0.495
        property real outerCutY: root.height * 0.9487
        property real outerCx: root.width / 2
        property real outerCy: root.height * 0.50
        property real outerDy: outerCutY - outerCy

        property real outerCutAngleDeg:
            Math.asin(Math.max(-1, Math.min(1, outerDy / outerRadius))) * 180 / Math.PI

        property real outerLeftX:
            outerCx - Math.sqrt(Math.max(0, outerRadius * outerRadius - outerDy * outerDy))

        property real outerStartAngle: 180 - outerCutAngleDeg
        property real outerSweepAngle: 360 - 2 * outerCutAngleDeg + 80

        // ============================================
        // MIDDLE RING
        // ============================================
        property real middleRadius: root.width * 0.32
        property real middleCutY: root.height * 0.79
        property real middleCx: root.width / 2
        property real middleCy: root.height * 0.50
        property real middleDy: middleCutY - middleCy

        property real middleCutAngleDeg:
            Math.asin(Math.max(-1, Math.min(1, middleDy / middleRadius))) * 180 / Math.PI

        property real middleLeftX:
            middleCx - Math.sqrt(Math.max(0, middleRadius * middleRadius - middleDy * middleDy))

        property real middleStartAngle: 180 - middleCutAngleDeg
        property real middleSweepAngle: 360 - 2 * middleCutAngleDeg + 80

        // ============================================
        // INNER RING
        // ============================================
        property real innerRadius: root.width * 0.23
        property real innerCutY: root.height * 0.7085
        property real innerCx: root.width / 2
        property real innerCy: root.height * 0.50
        property real innerDy: innerCutY - innerCy

        property real innerCutAngleDeg:
            Math.asin(Math.max(-1, Math.min(1, innerDy / innerRadius))) * 180 / Math.PI

        property real innerLeftX:
            innerCx - Math.sqrt(Math.max(0, innerRadius * innerRadius - innerDy * innerDy))

        property real innerStartAngle: 180 - innerCutAngleDeg
        property real innerSweepAngle: 360 - 2 * innerCutAngleDeg + 80
    }

    // =========================
    // BACKGROUND (MASKED TO OUTER SHAPE)
    // =========================
    Item {
        width: parent.width
        height: parent.height
        anchors.fill: parent

        // ---------------------------
        // BASE SHAPE (matches outer ring)
        // ---------------------------
        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                strokeWidth: 0

                fillGradient: RadialGradient {
                    centerX: rings.outerCx
                    centerY: rings.outerCy

                    focalX: centerX
                    focalY: centerY

                    GradientStop { position: 0.0; color: "#1a1a1d" }
                    GradientStop { position: 0.3; color: "#131417" }
                    GradientStop { position: 0.7; color: "#0b0b0d" }
                    GradientStop { position: 1.0; color: "#000000" }
                }

                // SAME PATH AS OUTER RING
                startX: rings.outerLeftX
                startY: rings.outerCutY

                PathAngleArc {
                    centerX: rings.outerCx
                    centerY: rings.outerCy
                    radiusX: rings.outerRadius
                    radiusY: rings.outerRadius
                    startAngle: rings.outerStartAngle
                    sweepAngle: rings.outerSweepAngle
                }

                PathLine {
                    x: rings.outerLeftX
                    y: rings.outerCutY
                }
            }
        }

        // ---------------------------
        // SUBTLE TEXTURE
        // ---------------------------
        Canvas {
            anchors.fill: parent
            opacity: 0.06

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var size = 10

                for (var y = 0; y < height; y += size) {
                    for (var x = 0; x < width; x += size) {
                        var dark = ((x + y) % (size * 2)) === 0
                        ctx.fillStyle = dark ? "#111111" : "#0a0a0a"
                        ctx.fillRect(x, y, size, size)
                    }
                }
            }
        }

        // ---------------------------
        // CENTER DEPTH
        // ---------------------------
        Rectangle {
            width: parent.width * 0.65
            height: width
            radius: width / 2

            anchors.centerIn: parent
            anchors.verticalCenterOffset: root.height * 0.04

            color: "#ffffff"
            opacity: 0.03
        }

        // ---------------------------
        // EDGE DARKEN (vignette)
        // ---------------------------
        Shape {
            anchors.fill: parent
            opacity: 0.18

            ShapePath {
                strokeWidth: 0
                fillColor: "black"

                startX: rings.outerLeftX
                startY: rings.outerCutY

                PathAngleArc {
                    centerX: rings.outerCx
                    centerY: rings.outerCy
                    radiusX: rings.outerRadius
                    radiusY: rings.outerRadius
                    startAngle: rings.outerStartAngle
                    sweepAngle: rings.outerSweepAngle
                }

                PathLine {
                    x: rings.outerLeftX
                    y: rings.outerCutY
                }
            }
        }
    }

    // =========================
    // RINGS
    // =========================
    Item {
        anchors.fill: parent

        // -------- OUTER RING --------
        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                strokeWidth: 3
                strokeColor: "white"
                fillColor: "transparent"

                startX: rings.outerLeftX
                startY: rings.outerCutY

                PathAngleArc {
                    centerX: rings.outerCx
                    centerY: rings.outerCy
                    radiusX: rings.outerRadius
                    radiusY: rings.outerRadius
                    startAngle: rings.outerStartAngle
                    sweepAngle: rings.outerSweepAngle
                }

                PathLine {
                    x: rings.outerLeftX
                    y: rings.outerCutY
                }
            }
        }

        // -------- MIDDLE RING --------
        Shape {
            anchors.fill: parent
            opacity: 0.8
            antialiasing: true

            ShapePath {
                strokeWidth: 2
                strokeColor: "white"
                fillColor: "transparent"

                startX: rings.middleLeftX
                startY: rings.middleCutY

                PathAngleArc {
                    centerX: rings.middleCx
                    centerY: rings.middleCy
                    radiusX: rings.middleRadius
                    radiusY: rings.middleRadius
                    startAngle: rings.middleStartAngle
                    sweepAngle: rings.middleSweepAngle
                }

                PathLine {
                    x: rings.middleLeftX
                    y: rings.middleCutY
                }
            }
        }

        // -------- INNER RING --------
        Shape {
            anchors.fill: parent
            opacity: 0.8
            antialiasing: true

            ShapePath {
                strokeWidth: 2
                strokeColor: "white"
                fillColor: "transparent"

                startX: rings.innerLeftX
                startY: rings.innerCutY

                PathAngleArc {
                    centerX: rings.innerCx
                    centerY: rings.innerCy
                    radiusX: rings.innerRadius
                    radiusY: rings.innerRadius
                    startAngle: rings.innerStartAngle
                    sweepAngle: rings.innerSweepAngle
                }

                PathLine {
                    x: rings.innerLeftX
                    y: rings.innerCutY
                }
            }
        }
    }

    // =========================
    // RPM ARC (LED STYLE)
    // =========================
    Repeater {
        model: 80

        delegate: Rectangle {
            width: root.width * 0.02
            height: root.width * 0.008
            radius: height/2

            property int i: index
            property real t: i / 80
            property real angle: root.startAngle + t * root.sweep

            x: root.width/2 + Math.cos(angle * Math.PI/180) * root.width * 0.30 - width/2
            y: root.height/2 + Math.sin(angle * Math.PI/180) * root.height * 0.30 - height/2

            rotation: angle

            property bool major: ((i+1) % 10 === 0 && i <= 49)
            property int active: Math.floor(root.displayRPM / 100)

            color: {
                if (i < active) {
                    if (major) return "#ff9c00"
                    if (i > 65) return "#ff5050"
                    if (i > 55) return "#ffcd00"
                    return "#00d2ff"
                } else {
                    if (major) return "#00391c"
                    return "#2a2a2e"
                }
            }

            opacity: (i < active || major) ? 1.0 : 0.7
        }
    }

    // =========================
    // SPEED TICKS
    // =========================
    Repeater {
        model: 51

        delegate: Rectangle {
            property real value: index * 2
            property bool major: (value % 10 === 0)
            property real angle: root.startAngle + (value / 100) * root.sweep

            width: major ? root.width * 0.006 : root.width * 0.0015
            height: major ? root.width * 0.03  : root.width * 0.025

            color: "white"
            radius: width / 2

            x: root.width/2 + Math.cos(angle * Math.PI/180) * root.width * 0.48 - width/2
            y: root.height/2 + Math.sin(angle * Math.PI/180) * root.height * 0.48 - height/2

            rotation: angle + 90
        }
    }

    // =========================
    // SPEED NUMBERS
    // =========================
    Repeater {
        model: 11

        delegate: Text {
            text: index * 10
            color: "white"
            font.pixelSize: Math.round(root.width * 0.075)
            font.bold: true

            property real angle: root.startAngle + (index/10) * root.sweep

            x: root.width/2 + Math.cos(angle * Math.PI/180) * root.width * 0.39 - width/2
            y: root.height/2 + Math.sin(angle * Math.PI/180) * root.height * 0.39 - height/2
        }
    }

    // =========================
    // RPM NUMBERS
    // =========================
    Repeater {
        model: 9

        delegate: Text {
            text: index
            color: "#00d2ff"
            font.pixelSize: root.width * 0.05
            font.bold: true

            property real angle: root.startAngle + (index / 8) * root.sweep

            x: root.width/2 + Math.cos(angle * Math.PI/180) * root.width * 0.26 - width/2
            y: root.height/2 + Math.sin(angle * Math.PI/180) * root.width * 0.26 - height/2
        }
    }

    // =========================
    // NEEDLE
    // =========================
    Item {
        id: needle
        anchors.centerIn: parent

        property real angle: root.startAngle + (root.displaySpeed / 100) * root.sweep

        rotation: angle

        property real length: root.width * 0.17
        property real baseWidth: root.width * 0.016
        property real tipWidth: root.width * 0.0045
        property real offset: root.width * 0.3212

        Shape {
            anchors.fill: parent
            z: -3
            opacity: 0.15
            antialiasing: true

            ShapePath {
                strokeWidth: 0
                fillColor: "#ffffff"

                startX: needle.offset
                startY: -needle.baseWidth

                PathLine { x: needle.offset; y: needle.baseWidth }
                PathLine { x: needle.offset + needle.length; y: needle.tipWidth }
                PathLine { x: needle.offset + needle.length; y: -needle.tipWidth }
                PathLine { x: needle.offset; y: -needle.baseWidth }
            }
        }

        Shape {
            anchors.fill: parent
            opacity: 0.50
            z: -1
            antialiasing: true

            ShapePath {
                strokeWidth: 0
                fillColor: "black"

                startX: needle.offset + 2
                startY: -needle.baseWidth / 2 + 2

                PathLine { x: needle.offset + 2; y: needle.baseWidth / 2 + 2 }
                PathLine { x: needle.offset + needle.length + 2; y: needle.tipWidth / 2 + 2 }
                PathLine { x: needle.offset + needle.length + 2; y: -needle.tipWidth / 2 + 2 }
                PathLine { x: needle.offset + 2; y: -needle.baseWidth / 2 + 2 }
            }
        }

        // Main needle colour and shape
        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                strokeWidth: 0

                fillGradient: LinearGradient {
                    x1: needle.offset
                    y1: 0
                    x2: needle.offset + needle.length
                    y2: 0

                    GradientStop { position: 0.00; color: "#878787" }
                    GradientStop { position: 0.10; color: "#ffffff" }
                    GradientStop { position: 0.84; color: "#ffffff" }
                    GradientStop { position: 0.85; color: "#ff2d00" }
                    GradientStop { position: 1.00; color: "#ff2d00" }
                }

                startX: needle.offset
                startY: -needle.baseWidth / 2

                PathLine { x: needle.offset; y: needle.baseWidth / 2 }
                PathLine { x: needle.offset + needle.length; y: needle.tipWidth / 2 }
                PathLine { x: needle.offset + needle.length; y: -needle.tipWidth / 2 }
                PathLine { x: needle.offset; y: -needle.baseWidth / 2 }
            }
        }

        Shape {
            anchors.fill: parent
            opacity: 0.25
            antialiasing: true

            ShapePath {
                strokeWidth: 0
                fillColor: "#ffffff"

                startX: needle.offset + needle.length * 0.10
                startY: -needle.baseWidth * 0.25

                PathLine {
                    x: needle.offset + needle.length * 0.10
                    y: 0
                }

                PathLine {
                    x: needle.offset + needle.length * 0.92
                    y: needle.tipWidth * 0.10
                }

                PathLine {
                    x: needle.offset + needle.length * 0.92
                    y: -needle.tipWidth * 0.15
                }

                PathLine {
                    x: needle.offset + needle.length * 0.10
                    y: -needle.baseWidth * 0.25
                }
            }
        }

        Shape {
            anchors.fill: parent
            opacity: 0.20
            antialiasing: true

            ShapePath {
                strokeWidth: 0
                fillColor: "black"

                startX: needle.offset
                startY: 0

                PathLine { x: needle.offset; y: needle.baseWidth / 2 }
                PathLine { x: needle.offset + needle.length; y: needle.tipWidth / 2 }
                PathLine { x: needle.offset + needle.length; y: needle.tipWidth * 0.20 }
                PathLine { x: needle.offset; y: 0 }
            }
        }
    }

    // =========================
    // DIGITAL SPEED (CENTERED, NO RECTANGLE)
    // =========================
    Item {
        id: digitalSpeed
        width: root.width * 0.34
        height: root.width * 0.22

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.height * -0.07

        Text {
            id: speedText

            text: Math.round(root.displaySpeed)
            color: "white"

            font.pixelSize: root.width * 0.23
            font.bold: false

            lineHeight: 1.0
            lineHeightMode: Text.FixedHeight

            anchors.horizontalCenter: parent.horizontalCenter
            y: 30
        }

        Text {
            id: unitText

            text: "MPH"
            color: "#ff9c00"

            font.pixelSize: root.width * 0.10
            font.bold: false

            lineHeight: 1.0
            lineHeightMode: Text.FixedHeight

            anchors.horizontalCenter: parent.horizontalCenter
            y: speedText.y + speedText.height * 0.88
        }

        Text {
            id: rpmText

            text: Math.round(root.displayRPM)
            color: "#00d2ff"

            font.pixelSize: root.width * 0.075
            font.bold: false

            lineHeight: 1.0
            lineHeightMode: Text.FixedHeight

            anchors.horizontalCenter: parent.horizontalCenter
            y: speedText.y + speedText.height * 1.31
        }

        Text {
            id: odometerText

            text: "<span style='color:#ff9c00; font-size:" + Math.round(root.width * 0.043) + "px;'>ODO </span>" +
                  "<span style='color:#ffffff; font-size:" + Math.round(root.width * 0.070) + "px;'>" + Math.round(root.displayODO) + "</span>" +
                  "<span style='color:#ff9c00; font-size:" + Math.round(root.width * 0.035) + "px;'> miles </span>"

            textFormat: Text.RichText

            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.round(speedText.y + speedText.height * 1.75)
        }

        Text {
            id: readyText

            text: root.smoothedRPM < 50 ? "READY" : ""
            color: "#00ff66"

            font.pixelSize: Math.round(root.width * 0.055)
            font.bold: false

            lineHeight: 1.0
            lineHeightMode: Text.FixedHeight

            anchors.horizontalCenter: parent.horizontalCenter
            y: -15
        }
    }

    // =========================
    // THROTTLE BAR
    // =========================
    Item {
        id: throttleBar

        width: 110
        height: 982

        x: 1496
        y: 5

        property real finalThrottle:
            root.ccActivated
                ? (CC ? CC.outputThrottle : 0)
                : (CAN ? CAN.throttle : 0)

        property real value: finalThrottle / 100

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#00ff66"
            border.width: 4
            radius: 4
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            color: "#020611"
            radius: 3
        }

        Rectangle {
            id: fill

            width: parent.width - 12
            x: 6
            height: (parent.height - 12) * throttleBar.value
            y: parent.height - height - 6
            radius: 2

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1db954" }
                GradientStop { position: 1.0; color: "#3cff7a" }
            }

            opacity: 0.95
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6

            color: "transparent"
            border.color: "#000000"
            border.width: 2
            radius: 3
            opacity: 0.5
        }

        Text {
            text: Math.round(throttleBar.value * 100) + "%"
            color: "#3cff7a"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -60

            font.pixelSize: 40
            y: 100
        }
    }

    // =========================
    // BRAKE BAR
    // =========================
    Item {
        id: brakeBar

        width: 110
        height: 982

        x: 1346
        y: 5

        property real value: root.smoothedBrake > 0.5 ? 1 : 0

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#ff2d00"
            border.width: 4
            radius: 4
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            color: "#020611"
            radius: 3
        }

        Rectangle {
            id: fillB

            width: parent.width - 12
            x: 6
            height: (parent.height - 12) * brakeBar.value
            y: parent.height - height - 6
            radius: 2

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#e62900" }
                GradientStop { position: 1.0; color: "#ff2d00" }
            }

            opacity: 0.95
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6

            color: "transparent"
            border.color: "#000000"
            border.width: 2
            radius: 3
            opacity: 0.5
        }

        Text {
            text: brakeBar.value > 0 ? "BRAKE" : " "
            color: "#ff2d00"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -60

            font.pixelSize: 40
            y: 100
        }
    }

    // =========================
    // CLUTCH BAR
    // =========================
    Item {
        id: clutchBar

        width: 110
        height: 982

        x: 1196
        y: 5

        property real value: root.smoothedClutch > 0.5 ? 1 : 0

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#fff134"
            border.width: 4
            radius: 4
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            color: "#020611"
            radius: 3
        }

        Rectangle {
            id: fillC

            width: parent.width - 12
            x: 6
            height: (parent.height - 12) * clutchBar.value
            y: parent.height - height - 6
            radius: 2

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ffed01" }
                GradientStop { position: 1.0; color: "#fff134" }
            }

            opacity: 0.95
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6

            color: "transparent"
            border.color: "#000000"
            border.width: 2
            radius: 3
            opacity: 0.5
        }

        Text {
            text: clutchBar.value > 0 ? "CLUTCH" : " "
            color: "#fff134"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -60

            font.pixelSize: 40
            y: 100
        }
    }

    // =========================
    // Coolant Temperature and Air to Fuel Ratio readings
    // =========================
    Item {
        id: coolanTempBar
        width: 300
        height: 800 // Increased to prevent bottom content from being cut off
        x: 860
        y: 10

        property real coolantTemp: CAN && CAN.connected ? CAN.coolant : 0
        property real airFuelRatio: CAN && CAN.connected ? CAN.afr : 0

        Column {
            anchors.centerIn: parent
            spacing: 5 // Base spacing for the column

            // Block 1: Coolant Number
            Text {
                text: coolanTempBar.coolantTemp + "°C"
                color: "white"
                font.pixelSize: 130
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // --- TEMPERATURE IMAGE LOGIC ---
            Image {
                id: tempIcon
                width: 200
                height: 200
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter

                // Logic for switching temperature icons
                source: coolanTempBar.coolantTemp < 50 ? "images/tempblue.png" :
                        coolanTempBar.coolantTemp < 95 ? "images/temporange.png" : "images/tempred.png"

                onStatusChanged: if (status === Image.Error) console.log("Can't find image at: " + source)
            }

            // --- ADDITIONAL SPACE (SPACER) ---
            Item {
                width: 1
                height: 100 // Adjust this value to increase/decrease the gap
            }

            // Block 2: AFR Section
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                Text {
                    text: coolanTempBar.airFuelRatio.toFixed(1)
                    color: "white"
                    font.pixelSize: 130
                    anchors.horizontalCenter: parent.horizontalCenter
                    lineHeight: 0.9
                    lineHeightMode: Text.ProportionalHeight
                }

                Image {
                    id: afrIcon
                    width: 150
                    height: 125
                    source: "images/afr.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter

                    onStatusChanged: if (status === Image.Error) console.log("Can't find AFR image at: " + source)
                }
            }
        }
    }

    // =========================
    // Cruise control indicator
    // =========================
    Item {
        id: ccBar
        width: 250
        height: 400

        // ADJUST POSITION: If -250 is off-screen, try moving it inside the view
        // x: 50
        x: -250
        y: 0

        Column {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                Text {
                    id: valTxt
                    // Changed to root.ccSetValue to listen to the Gauge's property
                    text: Math.round(root.ccSetValue)

                    // Color updates based on root activation state
                    color: root.ccActivated ? "#00ce25" : "#404040"
                    font.pixelSize: 130
                    font.bold: true
                }

                Text {
                    text: "MPH"
                    color: root.ccActivated ? "#00ce25" : "#404040"
                    font.pixelSize: 40
                    anchors.bottom: valTxt.bottom
                    anchors.bottomMargin: 12
                }
            }

            Image {
                id: ccIcon
                width: 200
                height: 200

                // Updated to root.ccActivated
                source: root.ccActivated ? "images/ccon.png" : "images/ccoff.png"
                fillMode: Image.PreserveAspectFit

                onStatusChanged: if (status === Image.Error) console.log("Missing: " + source)
            }
        }
    }
}
