import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Row {
    property int depth: 0

    height: 20
    spacing: 4

    DefaultColoredImage {
        id: image
        width: 20
        height: 20
        source: "qrc:/Assets/TestImage4.png"
        color: themeManager.accentColor
    }

    DefaultTextButton {
        width: parent.width - image.width - parent.spacing
        text: fileName
        height: parent.height
        textItem.horizontalAlignment: Text.AlignLeft

        onReleased: {
            workspaceView.fileUrl = fileUrl
            workspaceView.acceptAndClose()
        }
    }
}
