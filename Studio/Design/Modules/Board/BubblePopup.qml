import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12

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

    function open() {
        visible = true
        enabled = true
    }
    
    function close() {
        visible = false
        enabled = false
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
    visible: false
    color: "white"

    MouseArea {
        anchors.fill: parent

        onReleased: bubblePopup.close()
    }

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

        delegate: Item {
            width: 75
            height: 75
            clip: false

            Rectangle {
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
            color: mouseArea.delegateHovered ? "#24A3FF" : "#31A8FF"


            DefaultColoredImage {
                id: image
                width: parent.width * 0.8
                height: parent.height / 2
                x: parent.width / 2 - width / 2
                y: parent.height / 2 - height / 2
                source: bubbleImage
                color: mouseArea.delegateHovered ? "#163752" : "#1A6DAA"
            }

            Text {
                id: text
                width: parent.width * 0.8
                horizontalAlignment: Text.AlignHCenter
                x: image.x
                y: delegate.height
                text: index + " " + bubbleTitle
                color: mouseArea.delegateHovered ? "#163752" : "#1A6DAA"
                font.pointSize: 12
            }

            MouseArea {
                property bool delegateHovered: false
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true

                onEntered: delegateHovered = true

                onExited: delegateHovered = false
            }
        }
        }
    }
}
