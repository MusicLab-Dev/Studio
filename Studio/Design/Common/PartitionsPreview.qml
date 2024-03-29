import QtQuick 2.15
import QtQuick.Layouts 1.15

import CursorManager 1.0

import "../Default"

Rectangle {
    function newPartition() {
        var partitions = partitionsPreview.node.partitions
        var idx = partitions.count()
        if (partitions.add()) {
            partitions.getPartition(partitions.count() - 1).name = globalTextField.text
            contentView.selectPartition(partitionsPreview.node, idx)
            modulesView.addSequencerWithExistingPartition(partitionsPreview.node, idx)
        }
    }

    function addNewPartition() {
        globalTextField.open(partitionsPreview.node.partitions.getAvailablePartitionName(), newPartition, function () { }, false, node.color)
    }

    property var nodeDelegate: contentView.selectedNode
    readonly property var node: nodeDelegate ? nodeDelegate.node : null
    readonly property color nodeColor: nodeDelegate ? nodeDelegate.color : color
    readonly property color nodeAccentColor: nodeDelegate ? nodeDelegate.accentColor : color
    readonly property color nodeHoveredColor: nodeDelegate ? nodeDelegate.hoveredColor : color
    readonly property color nodePressedColor: nodeDelegate ? nodeDelegate.pressedColor : color
    readonly property string nodeName: node ? node.name : ""

    // Hide states
    property bool hide: false
    property bool requiredVisibility: nodeDelegate && !hide

    // Previews configuration
    readonly property real baseHeight: 70
    readonly property real delegatePerRow: 4
    readonly property real previewWidth: (previewFlow.width - delegatePerRow * previewFlow.spacing) / delegatePerRow

    id: partitionsPreview
    width: contentView.width
    height: Math.max(baseHeight, previewFlow.height) + 20
    color: themeManager.panelColor
    // border.color: nodeColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    RowLayout {
        id: headerRow
        height: parent.height
        width: parent.width * 0.15
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            DefaultImageButton {
                id: addPartitionButton
                width: height
                height: Math.min(parent.height / 2, partitionsPreview.baseHeight)
                anchors.centerIn: parent
                source: "qrc:/Assets/AddPartition.png"
                showBorder: false
                scaleFactor: 1
                colorDefault: partitionsPreview.nodeColor
                colorHovered: partitionsPreview.nodeHoveredColor
                colorOnPressed: partitionsPreview.nodePressedColor

                onClicked: partitionsPreview.addNewPartition()
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.65

            DefaultText {
                anchors.centerIn: parent
                width: parent.width * 0.8
                height: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.HorizontalFit
                font.pixelSize: 30
                color: partitionsPreview.nodeColor
                text: partitionsPreview.nodeName + "'s partitions"
                wrapMode: Text.Wrap
            }
        }

    }

    Rectangle {
        anchors.left: headerRow.right
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height * 0.8
        color: "black"
    }

    Flow {
        id: previewFlow
        y: 10
        anchors.left: headerRow.right
        anchors.right: closeButton.left
        anchors.leftMargin: 20
        anchors.rightMargin: 10
        spacing: 10

        Repeater {
            id: previewRepeater
            model: partitionsPreview.node ? partitionsPreview.node.partitions : null

            delegate: PartitionsPreviewDelegate {
                id: previewDelegate
                width: partitionsPreview.previewWidth
                height: partitionsPreview.baseHeight
            }
        }

        Rectangle {
            width: partitionsPreview.previewWidth
            height: partitionsPreview.baseHeight
            color: themeManager.contentColor
            //border.color: partitionsPreview.nodeColor
            //border.width: newPartitionArea.containsMouse ? 1 : 0
            radius: 3

            MouseArea {
                id: newPartitionArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: partitionsPreview.addNewPartition()

                onHoveredChanged: {
                    if (containsMouse)
                        cursorManager.set(CursorManager.Type.Clickable)
                    else
                        cursorManager.set(CursorManager.Type.Normal)
                }
            }

            DefaultColoredImage {
                anchors.centerIn: parent
                height: newPartitionArea.containsMouse ? parent.height * 0.7 : parent.height * 0.5
                width: height
                source: "qrc:/Assets/Plus.png"
                color: partitionsPreview.nodeColor

                Behavior on height {
                    NumberAnimation { duration: 100 }
                }
            }

            DefaultToolTip {
                visible: newPartitionArea.containsMouse
                text: qsTr("Add a new partition")
            }
        }
    }

    DefaultImageButton {
        id: closeButton
        width: height
        height: Math.min(parent.height * 0.25, partitionsPreview.baseHeight)
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 35
        source: "qrc:/Assets/Close.png"
        showBorder: false
        scaleFactor: 1
        colorDefault: partitionsPreview.nodeColor
        colorHovered: partitionsPreview.nodeHoveredColor
        colorOnPressed: partitionsPreview.nodePressedColor

        onReleased: partitionsPreview.hide = true
    }
}
