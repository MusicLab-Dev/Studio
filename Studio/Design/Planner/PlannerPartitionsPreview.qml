import QtQuick 2.15

import "../Default"

Rectangle {
    readonly property var nodeDelegate: contentView.lastSelectedNode
    readonly property var node: nodeDelegate ? nodeDelegate.node : null
    readonly property color nodeColor: nodeDelegate ? nodeDelegate.color : "white"
    readonly property color nodeAccentColor: nodeDelegate ? nodeDelegate.accentColor : "white"
    readonly property color nodeHoveredColor: nodeDelegate ? nodeDelegate.hoveredColor : "white"
    readonly property color nodePressedColor: nodeDelegate ? nodeDelegate.pressedColor : "white"
    readonly property string nodeName: node ? node.name : "ERROR"

    // Hide state
    property bool hide: false

    // Previews configuration
    readonly property real baseHeight: 60
    readonly property real delegatePerRow: 4
    readonly property real previewWidth: (previewFlow.width - delegatePerRow * previewFlow.spacing) / delegatePerRow

    id: partitionsPreview
    width: contentView.width
    height: Math.max(baseHeight, previewFlow.height) + 20
    color: themeManager.foregroundColor
    visible: nodeDelegate && !hide
    // border.color: nodeColor

    Rectangle {
        color: "white"
        width: parent.width
        height: 1
        anchors.bottom: parent.bottom
    }

    Row {
        id: headerRow
        height: parent.height
        padding: 10
        spacing: 10

        DefaultText {
            width: contentView.rowHeaderWidth / 2
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignLeft
            fontSizeMode: Text.HorizontalFit
            font.pointSize: 38
            color: partitionsPreview.nodeColor
            text: partitionsPreview.nodeName
            wrapMode: Text.Wrap
        }

        DefaultImageButton {
            width: height
            height: Math.min(parent.height / 2, partitionsPreview.baseHeight)
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/Assets/AddPartition.png"
            showBorder: false
            scaleFactor: 1
            colorDefault: partitionsPreview.nodeColor
            colorHovered: partitionsPreview.nodeHoveredColor
            colorOnPressed: partitionsPreview.nodePressedColor

            onReleased: {
                // Add a partition and select it on success
                var partitions = partitionsPreview.node.partitions
                var idx = partitions.count()
                if (partitions.add())
                    contentView.selectPartition(partitionsPreview.node, idx)
            }
        }
    }

    Flow {
        id: previewFlow
        y: 10
        anchors.left: headerRow.right
        anchors.right: closeButton.left
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        Repeater {
            id: previewRepeater
            model: partitionsPreview.node ? partitionsPreview.node.partitions : null

            delegate: PlannerPartitionsPreviewDelegate {
                id: previewDelegate
                width: partitionsPreview.previewWidth
                height: partitionsPreview.baseHeight
            }
        }
    }

    DefaultColoredImage {
        id: trashButton
        visible: false
        width: height
        height: Math.min(parent.height / 2, partitionsPreview.baseHeight)
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/Assets/Close.png"
        anchors.right: parent.right
        anchors.rightMargin: 10
        color: "red"
    }

    DefaultImageButton {
        id: closeButton
        visible: !trashButton.visible
        anchors.fill: trashButton
        source: "qrc:/Assets/Close.png"
        showBorder: false
        scaleFactor: 1
        colorDefault: partitionsPreview.nodeColor
        colorHovered: partitionsPreview.nodeHoveredColor
        colorOnPressed: partitionsPreview.nodePressedColor

        onReleased: partitionsPreview.hide = true
    }
}