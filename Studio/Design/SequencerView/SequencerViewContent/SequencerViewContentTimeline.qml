import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

RowLayout {
    property real headerFactor: 0.1

    spacing: 0
    
    Rectangle {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * headerFactor
        color: "#001E36"
    }
    
    Rectangle {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width
        color: "#C4C4C4"

        Repeater {
            model: 12

            Rectangle {
                x: index * 200
                Text {
                    text: index
                }
            }
        }
    }
}
