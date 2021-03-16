import QtQuick 2.5
import "../../Default/"
import "../../Common/"

Item {
    readonly property int nodesNb: 12
    readonly property real totalGridHeight: nodesNb * rowHeight

    id: playlistViewContentHeader

    // Component.onCompleted: app.project.master.add()

    Repeater {

        model: nodesNb //app.project.master

        delegate: Row {
            id: node
            height: rowHeight
            width: playlistViewContentHeader.width
            y: index * height

            Rectangle {
                height: parent.height
                width: parent.width / 2
                color: themeManager.foregroundColor

                Rectangle {
                    id: nodePanel
                    anchors.centerIn: parent
                    height: parent.height / 1.25
                    width: parent.width / 1.25
                    radius: 5
                    color: themeManager.accentColor

                    Text {
                        text: "Node " + index
                        color: themeManager.contentColor
                        anchors.centerIn: parent
                    }
                }
            }

            Rectangle {
                height: parent.height
                width: parent.width / 2
                color: themeManager.foregroundColor
                border.color: themeManager.contentColor

                Column {
                    anchors.margins: 5
                    anchors.fill: parent

                    DefaultComboBox {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: parent.height * 0.25

                        model: [
                            "Sequence1",
                            "Sequence2",
                            "Sequence3"
                        ]
                    }

                    Item {
                        height: parent.height * 0.1
                    }

                    DefaultColoredImage {
                        property real size: Math.min((parent.height + parent.width) / 4, parent.height * 0.65)

                        anchors.horizontalCenter: parent.horizontalCenter
                        height: size
                        width: size
                        source: "qrc:/Assets/Note.png"
                        color: nodePanel.color
                        fillMode: Image.Pad
                    }
                }

                MuteButton {
                    anchors.margins: 5
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.height * 0.25
                    width: height
                    // color: nodePanel.color
                }
            }
        }
    }
}
