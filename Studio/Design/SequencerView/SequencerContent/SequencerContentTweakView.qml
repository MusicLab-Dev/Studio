import QtQuick 2.15
import QtQuick.Controls 2.15

import AudioAPI 1.0

import "../../Default"

Rectangle {
    id: tweakView

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false
        onPressedChanged: forceActiveFocus()
    }

    Row {
        anchors.fill: parent

        Rectangle {
            color: themeManager.backgroundColor
            width: contentView.rowHeaderWidth
            height: parent.height
            border.color: "white"
            border.width: 1
            z: 1

            Column {
                height: parent.width / 2
                width: parent.width / 2
                anchors.centerIn: parent

                DefaultColoredImage {
                    height: parent.width
                    width: parent.width
                    source: tweaker.itemsPaths[tweaker.itemSelected]
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                DefaultText {
                    text: tweaker.itemsNames[tweaker.itemSelected]
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                    fontSizeMode: Text.Fit
                }
            }
        }

        Rectangle {
            property variant scaleSteps: ["100", "75", "50", "25"]

            id: tweakViewContent
            width: parent.width - contentView.rowHeaderWidth
            height: contentView.rowDataWidth
            color: themeManager.backgroundColor
            border.color: "white"
            border.width: 1

            Repeater {
                model: tweakViewContent.scaleSteps

                delegate: Column {
                    y: tweakView.height / 4  * index

                    Rectangle {
                        height: 1
                        width: tweakViewContent.width
                        color: "black"
                        opacity: index === 2 ? 1 : 0.5
                    }
                    DefaultText {
                        text: tweakViewContent.scaleSteps[index] + "%"
                        color: Qt.lighter(themeManager.backgroundColor)
                        x: 3
                    }
                }
            }

            Repeater {
                model: sequencerView.partition

                delegate: Rectangle {
                    readonly property var beatRange: range

                    id: note
                    y: height * (velocity / AudioAPI.velocityMax) - height / 2
                    x: contentView.xOffset + beatRange.from * contentView.pixelsPerBeatPrecision
                    width: (beatRange.to - beatRange.from) * contentView.pixelsPerBeatPrecision
                    height: 4
                    color: themeManager.getColorFromChain(key)

                    MouseArea {
                        anchors.fill: parent

                        onPressed: {
                            velocity = mouseY * AudioAPI.velocityMax / height
                            console.info(velocity) //65535
                        }
                        onPositionChanged: {
                            velocity = mouseY * AudioAPI.velocityMax / height
                            console.info(velocity) // 65535
                        }
                    }

                    Rectangle {
                        y: note.height / 2
                        height: note.height * 4
                        width: height
                        anchors.verticalCenter: note.verticalCenter
                        color: themeManager.getColorFromChain(key)
                        border.width: 0.5
                        border.color: Qt.lighter(themeManager.getColorFromChain(key))
                        radius: 20
                    }
                }
            }
        }
    }

    Behavior on y {
        SpringAnimation {
            spring: 4
            damping: 0.4
            duration: 200
        }
    }
}
