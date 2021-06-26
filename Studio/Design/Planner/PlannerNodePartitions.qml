import QtQuick 2.15

import "../Default"

Row {
    id: nodePartitions

    Item {
        id: nodePartitionsHeader
        width: contentView.rowHeaderWidth
        height: contentView.rowHeight

        Item {
            id: nodePartitionsBackground
            x: nodeDelegate.isChild ? contentView.childOffset : contentView.headerMargin
            y: contentView.headerHalfMargin
            width: contentView.rowHeaderWidth - x - contentView.headerMargin
            height: nodePartitionsHeader.height

            DefaultText {
                x: 10
                width: parent.width * 0.5
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                fontSizeMode: Text.HorizontalFit
                font.pointSize: 28
                color: nodeDelegate.accentColor
                text: nodeDelegate.node ? nodeDelegate.node.name : "ERROR"
                wrapMode: Text.Wrap
            }

            DefaultImageButton {
                readonly property bool isMuted: nodeDelegate.node ? nodeDelegate.node.muted : false

                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: Math.min(parent.height / 2, 50)
                source: isMuted ? "qrc:/Assets/Muted.png" : "qrc:/Assets/Unmuted.png"
                showBorder: false
                scaleFactor: 1
                colorDefault: nodeDelegate.accentColor
                colorHovered: nodeDelegate.hoveredColor
                colorOnPressed: nodeDelegate.pressedColor

                onReleased: nodeDelegate.node.muted = !isMuted
            }
        }
    }

    Item {
        id: nodePartitionsData
        width: contentView.rowDataWidth
        height: nodePartitionsHeader.height
    }
}