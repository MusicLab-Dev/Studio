import QtQuick 2.15

import "../Default"

Rectangle {
    readonly property var nodeDelegate: contentView.lastSelectedNode

    id: partitionsPreview
    color: themeManager.foregroundColor
    visible: nodeDelegate
    border.color: nodeDelegate ? nodeDelegate.color : "black"

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
            font.pointSize: 28
            color: nodeDelegate ? nodeDelegate.accentColor : "black"
            text: nodeDelegate ? nodeDelegate.node.name : "ERROR"
            wrapMode: Text.Wrap
        }

        DefaultImageButton {
            width: height
            height: Math.min(parent.height / 2, 50)
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/Assets/AddPartition.png"
            showBorder: false
            scaleFactor: 1
            colorDefault: nodeDelegate ? nodeDelegate.accentColor : "black"
            colorHovered: nodeDelegate ? nodeDelegate.hoveredColor : "black"
            colorOnPressed: nodeDelegate ? nodeDelegate.pressedColor : "black"

            onReleased: nodeDelegate.node.partitions.add()
        }
    }

    Row {
        readonly property real realWidth: (width - padding * 2 - Math.max(previewRepeater.count -1, 0) * spacing)
        property real previewWidth: realWidth / previewRepeater.count

        id: previewRow
        anchors.left: headerRow.right
        width: parent.width - (headerRow.width + trashButton.width)
        height: parent.height
        spacing: 10
        padding: 10

        Repeater {
            id: previewRepeater
            model: nodeDelegate ? nodeDelegate.node.partitions : null

            delegate: Rectangle {
                property var partition: partitionInstance.instance

                id: previewDelegate
                width: previewRow.previewWidth
                height: partitionsPreview.height - previewRow.padding * 2
                anchors.verticalCenter: parent.verticalCenter
                color: "red"

                DefaultText {
                    anchors.fill: parent
                    fontSizeMode: Text.Fit
                    font.pointSize: 38
                    text: previewDelegate.partition ? previewDelegate.partition.name : "ERROR"
                }
            }
        }
    }

    DefaultColoredImage {
        id: trashButton
        visible: false
        width: height
        height: parent.height * 0.6
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/Assets/Close.png"
        anchors.right: parent.right
        anchors.rightMargin: 10
    }
}