import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root

    property real speed: 0
    property real rpm: 0

    width: 700
    height: 700

    Item {
        id: rings
        anchors.fill: parent
        visible: false

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

    Item {
        anchors.fill: parent

        // Background gradient
        Rectangle {
            anchors.fill: parent
            radius: width / 2

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#3a3a3a" }
                GradientStop { position: 0.3; color: "#2b2b2b" }
                GradientStop { position: 0.7; color: "#1f1f1f" }
                GradientStop { position: 1.0; color: "#0f0f0f" }
            }
        }

        // Texture
        Canvas {
            anchors.fill: parent
            opacity: 0.15

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                for (var i = 0; i < 2000; i++) {
                    var x = Math.random() * width;
                    var y = Math.random() * height;
                    var alpha = Math.random() * 0.05;
                    ctx.fillStyle = "rgba(255,255,255," + alpha + ")";
                    ctx.fillRect(x, y, 1, 1);
                }
            }
        }

        // Outer ring
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

        // Middle ring
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

        // Inner ring
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
}