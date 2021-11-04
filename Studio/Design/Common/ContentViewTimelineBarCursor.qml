import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

import AudioAPI 1.0

Shape {
    property alias color: path.fillColor

    id: timelineCursor
    height: parent.height
    width: 15

    ShapePath {
        id: path
        fillColor: themeManager.contentColor
        strokeColor: "transparent"

        PathLine {
            x: timelineCursor.x
            y: 0
        }
        PathLine {
            x: timelineCursor.width
            y: 0
        }
        PathLine {
            x: timelineCursor.width / 2
            y: timelineCursor.height
        }
    }
}
