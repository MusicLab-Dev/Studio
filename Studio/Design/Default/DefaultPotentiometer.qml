import QtQuick 2.15
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.15

Item {
    property alias dial: dial

    // inputs
    property alias value: dial.value
    property alias maximumValue: dial.maximumValue
    property alias minimumValue: dial.minimumValue
    property alias stepSize: dial.stepSize

    // style
    property alias tickmarksVisible: dial.tickmarksVisible
    property string label: ""

    id: potentiometer

    ColumnLayout {
        spacing: 0.0
        height: parent.height
        width: parent.height

        Text {
            text: label
            color: "white"
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            // layout
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: label !== "" ? parent.width : 0
            Layout.preferredHeight: label !== "" ? parent.height : 0
            Layout.alignment: Qt.AlignVCenter
        }

        Dial {
            id: dial

            style: DialStyle {
                id: dialStyle
                tickmarkStepSize: 1

                handle: Rectangle {
                    id: handler
                    height: 5
                    width: 1
                    color: "white"
                    transform: Rotation {
                        angle: (-180 + 30) + value * (360 - 30 * 2)
                        origin.x: handler.width / 2
                        origin.y: handler.height / 2
                    }
                }

                background: Rectangle {
                    color: "transparent"
                    radius: 50

                    Rectangle {
                        anchors.centerIn: parent
                        height: parent.width * 0.75
                        width: parent.width * 0.75
                        color: Qt.darker(themeManager.backgroundColor, 1.2)
                        radius: 50
                        border.color: "black"
                        border.width: 1

                        DefaultText {
                            text: "Atk"
                            anchors.fill: parent
                            fontSizeMode: Text.Fit
                            color: "white"
                        }
                    }
                }

                tickmarkLabel: Rectangle {
                    id: tickmarkLabel
                    height: dial.height * 0.05
                    width: 1
                    color: "white"
                    transform: Rotation {
                        angle: styleData.index / (maximumValue - minimumValue) * 280 - 140
                        origin.x: tickmarkLabel.width / 2
                        origin.y: tickmarkLabel.height / 2
                    }
                }
            }

            // layout
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
