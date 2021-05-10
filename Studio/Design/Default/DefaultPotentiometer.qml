import QtQuick 2.15
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.15

Dial {
    readonly property real range: Math.abs(Math.max(controlMinValue, controlMaxValue) - Math.min(controlMinValue, controlMaxValue))
    property string text: ""

    id: dial
    tickmarksVisible: true
    activeFocusOnPress: true

    style: DialStyle {
        id: dialStyle
        tickmarkStepSize: range

        handle: Rectangle {
            id: handler
            height: 6
            width: 6
            radius: 3
            color: Qt.darker("white", 1.65 - 0.65 * ((dial.value - dial.minimumValue) / dial.range))
        }

        background: Rectangle {
            color: "transparent"
            radius: width / 2

            Rectangle {
                anchors.centerIn: parent
                height: parent.width * 0.75
                width: parent.width * 0.75
                color: "transparent"
                radius: width / 2
                border.width: 1
                border.color: "white"

                DefaultText {
                    text: dial.text
                    anchors.fill: parent
                    fontSizeMode: Text.Fit
                    color: "white"
                }
            }
        }

        tickmarkLabel: Rectangle {
            id: tickmark
            height: 6
            width: 6
            radius: 3
            color: styleData.index ? "white" : "grey"
        }
    }
}
