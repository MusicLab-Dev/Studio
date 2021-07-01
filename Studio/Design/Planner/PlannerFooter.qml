import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Rectangle {
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    DefaultImageButton {
        visible: contentView.lastSelectedNode && partitionsPreview.hide
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.5
        showBorder: false
        scaleFactor: 1
        source: "qrc:/Assets/Note.png"

        onReleased: partitionsPreview.hide = false
    }

    PlannerPartitionsPreview {
        id: partitionsPreview
        y: -height
    }
}
