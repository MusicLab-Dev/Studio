import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

ColumnLayout {
    spacing: 0

    Shape {
        id: shape
        Layout.preferredHeight: parent.height * 0.05
        Layout.preferredWidth: parent.height * 0.05
        Layout.alignment: Qt.AlignCenter

        ShapePath {
            fillColor: themeManager.foregroundColor
            strokeColor: "black"
            strokeWidth: 2
            strokeStyle: ShapePath.SolidLine
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

    Rectangle {
        Layout.alignment: Qt.AlignCenter
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.05
    }


    Behavior on x {
        SpringAnimation {
            spring: 2
            damping: 0.2
        }
    }
}
