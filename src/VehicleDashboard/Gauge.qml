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
                    focalX: centerX
                    focalY: centerY

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
    // TODO: Speed numbers and ticks next

}