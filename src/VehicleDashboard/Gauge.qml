import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root

    property real speed: 0
    property real rpm: 0

    width: 700
    height: 700

    property real startAngle: 135
    property real sweep: 270
    property real maxSpeed: 100

    // This offset shifts the needle so it aligns with the ticks.
    property real angleOffset: -45

    function speedToAngle(v) {
        return startAngle + (v / maxSpeed) * sweep + angleOffset
    }

    Item {
        id: rings
        anchors.fill: parent
        visible: false

        // OUTER RING
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

        // MIDDLE RING
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

        // INNER RING
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

    // BACKGROUND
    Item {
        anchors.fill: parent

        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                strokeWidth: 0

                fillGradient: RadialGradient {
                    centerX: rings.outerCx
                    centerY: rings.outerCy

                    GradientStop { position: 0.0; color: "#1a1a1d" }
                    GradientStop { position: 0.3; color: "#131417" }
                    GradientStop { position: 0.7; color: "#0b0b0d" }
                    GradientStop { position: 1.0; color: "#000000" }
                }

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

        Canvas {
            anchors.fill: parent
            opacity: 0.06

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                for (var y = 0; y < height; y += 10) {
                    for (var x = 0; x < width; x += 10) {
                        ctx.fillStyle = ((x + y) % 20 === 0) ? "#111111" : "#0a0a0a"
                        ctx.fillRect(x, y, 10, 10)
                    }
                }
            }
        }

        Rectangle {
            width: parent.width * 0.65
            height: width
            radius: width / 2
            anchors.centerIn: parent
            anchors.verticalCenterOffset: root.height * 0.04
            color: "#ffffff"
            opacity: 0.03
        }

        Shape {
            anchors.fill: parent
            opacity: 0.18
            antialiasing: true

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

    // RINGS
    Item {
        anchors.fill: parent

        // OUTER RING
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

        // MIDDLE RING
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

        // INNER RING
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

    // SPEED TICKS
    Repeater {
        model: 51

        delegate: Rectangle {
            property real value: index * 2
            property bool major: (value % 10 === 0)
            property real angle: root.startAngle + (value / 100) * root.sweep

            width: major ? root.width * 0.006 : root.width * 0.0015
            height: major ? root.width * 0.03 : root.width * 0.025
            radius: width / 2
            color: "#55000000"

            x: root.width / 2 + Math.cos(angle * Math.PI / 180) * root.width * 0.48 - width / 2
            y: root.height / 2 + Math.sin(angle * Math.PI / 180) * root.height * 0.48 - height / 2

            rotation: angle + 90
        }
    }

    // SPEED NUMBERS
    Repeater {
        model: 11

        delegate: Text {
            text: index * 10
            color: "white"
            font.pixelSize: Math.round(root.width * 0.075)
            font.bold: true

            property real angle: root.startAngle + (index / 10) * root.sweep

            x: root.width / 2 + Math.cos(angle * Math.PI / 180) * root.width * 0.39 - width / 2
            y: root.height / 2 + Math.sin(angle * Math.PI / 180) * root.height * 0.39 - height / 2
        }
    }

    // RPM LABELS
    Repeater {
        model: 7

        delegate: Text {
            text: index
            color: "#aaaaaa"
            font.pixelSize: Math.round(root.width * 0.045)

            property real angle: root.startAngle + (index / 6) * root.sweep

            x: root.width / 2 + Math.cos(angle * Math.PI / 180) * root.width * 0.26 - width / 2
            y: root.height / 2 + Math.sin(angle * Math.PI / 180) * root.height * 0.26 - height / 2
        }
    }

    // --- NEEDLE (FIXED POSITIONING) ---
    // Instead of anchoring to root center, we now align to the actual gauge center
    Rectangle {
        id: needle

        width: root.width * 0.012
        height: root.width * 0.42
        radius: width / 2
        color: "#ff3b3b"

        // using real gauge center (important for cut gauges)
        x: rings.outerCx - width / 2
        y: rings.outerCy - height

        transform: Rotation {
            origin.x: width / 2
            origin.y: height
            angle: root.speedToAngle(root.speed)
        }
    }

    // NEEDLE HIGHLIGHT
    Rectangle {
        width: root.width * 0.004
        height: root.width * 0.38
        radius: width / 2
        color: "#80ffffff"

        x: rings.outerCx - width / 2
        y: rings.outerCy - height

        transform: Rotation {
            origin.x: width / 2
            origin.y: height
            angle: root.speedToAngle(root.speed)
        }
    }

    // RPM LED ARC
    // This creates the glowing segmented arc around the outer ring.
    // Each segment lights up depending on the current RPM value.
    // We use opacity instead of visible so inactive segments are still faintly visible.
    // That makes the graph easier to debug and gives a better dashboard look.
    Repeater {
        model: 60   // number of LED segments

        delegate: Rectangle {
            width: root.width * 0.01
            height: root.width * 0.035
            radius: width / 2

            // Convert index to normalized position (0 → 1)
            property real t: index / (model - 1)

            // Map RPM (0–6000 assumed) into same normalized range
            property real rpmNorm: Math.min(root.rpm / 6000.0, 1.0)

            // Instead of hiding inactive segments completely, make them dim
            opacity: t <= rpmNorm ? 1.0 : 0.15

            // Color zones for the RPM bar graph
            color: {
                if (t < 0.7) return "#00e0ff"   // blue / teal normal range
                if (t < 0.9) return "#ffb000"   // orange warning range
                return "#ff3030"                // red high RPM range
            }

            // Position along the same arc as the outer scale
            property real angle: root.startAngle + t * root.sweep

            x: root.width / 2 + Math.cos(angle * Math.PI / 180) * root.width * 0.50 - width / 2
            y: root.height / 2 + Math.sin(angle * Math.PI / 180) * root.height * 0.50 - height / 2

            rotation: angle + 90
        }
    }

    // Temporary animation timer for testing the RPM LED arc
    Timer {
        interval: 30
        running: true
        repeat: true

        onTriggered: {
            root.rpm = (root.rpm + 100) % 6000
        }
    }
}