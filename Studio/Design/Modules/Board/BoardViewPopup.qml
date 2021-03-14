import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Item {
    enum DisplayArrangement {
        Top,
        Bottom,
        Left,
        Right,
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }


    property point openPoint: Qt.point(width / 2, height / 2)
    property int displayArrangement: {
        var isLeft = x <= width * 0.25
        var isRight = x >= width * 0.75
        var isTop = y <= height * 0.25
        var isBottom = y >= height * 0.75

        if (isLeft && isTop)
            return BoardViewPopup.
    }

    id: boardViewPopup
    property alias model: repeater.model
    width: boardViewBackground.width
    height: boardViewBackground.height

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
            width: 150
            height: 150
            x: {
                if (index <= 3) {
                    (btn.x + btn.width / 2 - width / 2) + Math.cos(180 * (index + 1)) * 400
                } else
                    (btn.x + btn.width / 2 - width / 2) + Math.cos(-180 * (index + 1)) * 400
            }
            y: {
                if (index <= 3) {
                    (btn.y + btn.height / 2 - height / 2) + Math.sin(180 * (index + 1)) * 400
                } else
                    (btn.y + btn.height / 2 - height / 2) + Math.sin(-180 * (index + 1)) * 400
            }
            radius: boardViewPopup.width * 0.5
            color: "#4A8693"

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
                text: bubbleTitle
                color: "lightgrey"
                font.pointSize: 12
            }
        }
    }
}
