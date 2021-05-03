import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

import AudioAPI 1.0

Shape {
    id: shape
    height: parent.height
    width: 30
    x: timelineBar.x - snapper.width - width / 2
    
    ShapePath {
        fillColor: Qt.lighter(themeManager.foregroundColor, 1.5)
        strokeColor: "transparent"
        
        PathLine {
            x: shape.x
            y: 0
        }
        PathLine {
            x: shape.width
            y: 0
        }
        PathLine {
            x: shape.width / 2
            y: shape.height
        }
    }
}
