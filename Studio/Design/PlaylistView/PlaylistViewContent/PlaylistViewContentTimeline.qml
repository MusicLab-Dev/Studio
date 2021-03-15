import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

RowLayout {
    property real headerFactor: 0.1

    spacing: 0
    
    Rectangle {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * headerFactor
        color: themeManager.foregroundColor
    }
    
    Rectangle {
        id: timeline
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width
        color: themeManager.disabledColor

        Repeater {
            model: 12

            Rectangle {
                x: index * 200
                height: timeline.height * 0.25
                width: 2
                color: "black"
                anchors.bottom: timeline.bottom

                Text {
                    text: index
                    anchors.bottom: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
