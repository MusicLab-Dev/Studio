import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Rectangle {
    enum DisplayArrangement {
        Center,
        Top,
        Bottom,
        Left,
        Right,
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }

    property real angleSpacing: 45
    property real maxArcAngle: 180
    property point openPoint: Qt.point(width / 2, height / 2)
    property real circleRadius: 150

    property int displayArrangement: {
        var isLeft = x >= width * 0.75
        var isRight = x <= width * 0.25
        var isTop = y >= height * 0.75
        var isBottom = y <= height * 0.25
        var isTopLeft = isTop && isLeft
        var isTopRight = isTop && isRight
        var isBottomLeft = isBottom && isLeft
        var isBottomRight = isBottom && isRight

        if (isTopLeft)
            return BubblePopup.TopLeft
        else if (isTopRight)
            return BubblePopup.TopRight
        else if (isBottomLeft)
            return BubblePopup.BottomLeft
        else if (isBottomRight)
            return BubblePopup.BottomRight
        else if (isTop)
            return BubblePopup.Top
        else if (isBottom)
            return BubblePopup.Bottom
        else if (isLeft)
            return BubblePopup.Left
        else if (isRight)
            return BubblePopup.Right
        else
            return BubblePopup.Center
    }

    property alias model: repeater.model

    id: bubblePopup
    // visible: false
    color: "grey"

    Repeater {
        id: repeater
        model: ListModel {
            ListElement {
                bubbleImage: "qrc:/Assets/Settings/Audio.png"
                bubbleTitle: "Title Audio"
                bubbleDescription: "This is a description"
            }
            ListElement {
                bubbleImage: "qrc:/Assets/Settings/Audio.png"
                bubbleTitle: "Title Audio"
                bubbleDescription: "This is a description"
            }
            ListElement {
                bubbleImage: "qrc:/Assets/Settings/Audio.png"
                bubbleTitle: "Title Audio"
                bubbleDescription: "This is a description"
            }
            ListElement {
                bubbleImage: "qrc:/Assets/Settings/Audio.png"
                bubbleTitle: "Title Audio"
                bubbleDescription: "This is a description"
            }
            ListElement {
                bubbleImage: "qrc:/Assets/Settings/Audio.png"
                bubbleTitle: "Title Audio"
                bubbleDescription: "This is a description"
            }
            ListElement {
                bubbleImage: "qrc:/Assets/Settings/Audio.png"
                bubbleTitle: "Title Audio"
                bubbleDescription: "This is a description"
            }
        }

        delegate: Rectangle {
            id: delegate
            width: 75
            height: 75
            x: {
                var radius = circleRadius
                var angle = index * angleSpacing
                if (angle > maxArcAngle) {
                    var arcIndex = (angle - maxArcAngle) / angleSpacing
                    var bubbleIndexInArc = index % (maxArcAngle / angleSpacing)
                    radius = radius * (arcIndex + 1)
                    angle = bubbleIndexInArc * angleSpacing / (arcIndex + 1)
                    console.log("Overflow at ", index, "angle=", angle, "radius=", radius)
                }
                var tmp = openPoint.x + radius * Math.cos((Math.PI / 180) * angle)
                return tmp - width / 2
                //x = a + R cos 
                //y = b + R sin 
                // if (index <= 3) {
                //     (btn.x + btn.width / 2 - width / 2) + Math.cos(180 * (index + 1)) * 400
                // } else
                //     (btn.x + btn.width / 2 - width / 2) + Math.cos(-180 * (index + 1)) * 400
            }
            y: {
                var radius = circleRadius
                var angle = index * angleSpacing
                if (angle > maxArcAngle) {
                    var arcIndex = (angle - maxArcAngle) / angleSpacing
                    var bubbleIndexInArc = index % (maxArcAngle / angleSpacing)
                    radius = radius * (arcIndex + 1)
                    angle = bubbleIndexInArc * angleSpacing / (arcIndex + 1)
                    console.log("Overflow at ", index, "angle=", angle, "radius=", radius)
                }
                var tmp = openPoint.y + radius * Math.sin((Math.PI / 180) * angle)
                return tmp - height / 2
                // if (index <= 3) {
                //     (btn.y + btn.height / 2 - height / 2) + Math.sin(180 * (index + 1)) * 400
                // } else
                //     (btn.y + btn.height / 2 - height / 2) + Math.sin(-180 * (index + 1)) * 400
            }
            radius: bubblePopup.width * 0.5
            color: mouseArea.bubbleHovered ? "red" : "#4A8693"

            Image {
                id: image
                width: parent.width * 0.8
                height: parent.height / 2
                x: parent.width / 2 - width / 2
                y: parent.width * 0.2
                source: bubbleImage
            }

            Text {
                id: text
                width: parent.width * 0.8
                horizontalAlignment: Text.AlignHCenter
                x: image.x
                y: image.y + image.height
                text: index + " " + bubbleTitle + " " + mouseArea.pressedButtons + " " + mouseArea.containsMouse + " " + mouseArea.bubbleHovered
                color: "lightgrey"
                font.pointSize: 12
            }

            MouseArea {
                property bool bubbleHovered: (pressedButtons & Qt.LeftButton) && containsMouse

                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true

                onReleased: {
                    text.color = "orange"
                }
            }
        }
    }
}
