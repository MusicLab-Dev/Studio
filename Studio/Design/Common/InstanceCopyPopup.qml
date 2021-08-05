import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "../Default"
import "../Common"

import AudioAPI 1.0
import NodeModel 1.0
import PartitionModel 1.0

Item {
    function open(node, partitionNode, partition, instance) {
        openAnim.start()
        targetNode = node
        targetPartitionNode = partitionNode
        targetPartition = partition
        targetInstance = instance
        visible = true
    }

    function acceptAndClose() {
        targetNode.partitions.foreignPartitionInstanceCopy(targetPartition, targetInstance)
        targetNode = null
        targetPartitionNode = null
        targetPartition = null
        targetInstance = undefined
        visible = false
    }

    function cancelAndClose() {
        targetNode = null
        targetPartitionNode = null
        targetPartition = null
        targetInstance = undefined
        visible = false
    }

    property NodeModel targetNode: null
    property NodeModel targetPartitionNode: null
    property PartitionModel targetPartition: null
    property var targetInstance: undefined

    id: instanceCopyPopup
    width: parent.width
    height: parent.height
    visible: false

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: window; property: "opacity"; from: 0.1; to: 1; duration: 500; easing.type: Easing.Linear }
        PropertyAnimation { target: shadow; property: "opacity"; from: 0.1; to: 1; duration: 500; easing.type: Easing.Linear }
        PropertyAnimation { target: background; property: "opacity"; from: 0.1; to: 0.5; duration: 300; easing.type: Easing.Linear }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "grey"
        opacity: 0.5
    }

    DropShadow {
        id: shadow
        anchors.fill: window
        horizontalOffset: 4
        verticalOffset: 4
        radius: 8
        samples: 17
        color: "#80000000"
        source: window
    }

    MouseArea {
        id: ms
        anchors.fill: parent
        onReleased: { if (visible) cancelAndClose() }
    }

    ContentPopup {
        id: window
        width: Math.max(parent.width * 0.3, 400)
        height: Math.max(parent.height * 0.25, 250)

        Item {
            id: windowArea
            anchors.fill: parent
            anchors.margins: 30

            Column {
                DefaultText {
                    text: {
                        if (!targetNode || !targetPartitionNode || !targetPartition)
                            return ""
                        return qsTr("Do you want to copy partition '") + targetPartition.name + qsTr("' from '")
                            + targetPartitionNode.name + qsTr("' into '") + targetNode.name + "' ?"
                    }
                    width: windowArea.width
                    height: windowArea.height - confirmRow.height
                    wrapMode: Text.Wrap
                    font.pixelSize: 20
                    fontSizeMode: Text.Fit
                    color: "white"
                }

                Row {
                    id: confirmRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 30

                    TextRoundedButton {
                        text: qsTr("Yes")
                        hoverOnText: false

                        onReleased: acceptAndClose()
                    }

                    TextRoundedButton {
                        id: noButton
                        text: qsTr("No")

                        onReleased: cancelAndClose()
                    }
                }
            }
        }
    }
}
