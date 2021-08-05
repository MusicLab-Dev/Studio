import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3

import "../Default"

import AudioAPI 1.0
import NodeModel 1.0
import PartitionModel 1.0

Item {
    function open(node, partition, instance) {
        console.log("Open", node.name, partition.name)
        animOpen.start()
        targetNode = node
        targetPartition = partition
        targetInstance = instance
        visible = true
    }

    function acceptAndClose() {
        targetNode.partitions.foreignPartitionInstanceCopy(targetPartition, targetInstance)
        targetNode = null
        targetPartition = null
        targetInstance = undefined
        animClose.start()
    }

    function cancelAndClose() {
        targetNode = null
        targetPartition = null
        targetInstance = undefined
        animClose.start()
    }

    property NodeModel targetNode: null
    property PartitionModel targetPartition: null
    property var targetInstance: undefined

    id: instanceCopyPopup
    width: parent.width
    height: parent.height
    visible: false

    MouseArea {
        id: ms
        anchors.fill: parent
        onReleased: { if (visible) cancelAndClose() }
    }

    Rectangle {
        id: rect
        anchors.fill: parent
        opacity: 0
        color: "grey"

        OpacityAnimator {
            id: animOpen
            target: rect
            from: 0
            to: 0.85
            duration: 200
        }

        OpacityAnimator {
            id: animClose
            target: rect
            from: 0.85
            to: 0
            duration: 100

            onFinished: instanceCopyPopup.visible = false
        }
    }

    Rectangle {
        id: popupBackground
        anchors.centerIn: parent
        width: parent.width * 0.5
        height: parent.height * 0.5

        Column {

            DefaultText {
                text: targetNode && targetPartition ? qsTr("Do you want to copy partition '") + targetPartition.name + qsTr("' from node '") + targetNode.name + "'" : ""
                width: popupBackground.width
                height: popupBackground.height * 0.6
            }

            Row {
                DefaultTextButton {
                    width: popupBackground.width / 2
                    height: popupBackground.height * 0.4
                    text: qsTr("Yes")

                    onClicked: {
                        acceptAndClose()
                    }
                }

                DefaultTextButton {
                    width: popupBackground.width / 2
                    height: popupBackground.height * 0.4
                    text: qsTr("No")

                    onClicked: {
                        cancelAndClose()
                    }
                }
            }
        }
    }
}
