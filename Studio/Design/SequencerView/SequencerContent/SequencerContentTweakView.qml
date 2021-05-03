import QtQuick 2.15
import QtQuick.Controls 2.15

import AudioAPI 1.0

import "../../Default"

Rectangle {

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false
    }

    Row {
        anchors.fill: parent

        Rectangle {
            color: themeManager.backgroundColor
            width: contentView.rowHeaderWidth
            height: parent.height
            border.color: "white"
            border.width: 1

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
            width: parent.width - contentView.rowHeaderWidth
            height: contentView.rowDataWidth
            color: themeManager.backgroundColor
            border.color: "white"
            border.width: 1

            Repeater {
                model: sequencerView.partition

                delegate: Rectangle {
                    readonly property var beatRange: range

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
