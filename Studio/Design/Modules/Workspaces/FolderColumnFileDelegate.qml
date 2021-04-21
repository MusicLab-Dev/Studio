import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Row {
    property int depth: 0

    height: 20
    spacing: 4

    Image {
        id: image
        width: 20
        height: 20
        source: "qrc:/Assets/TestImage4.png"
    }

    DefaultTextButton {
        width: parent.width - image.width - parent.spacing
        text: fileName
        height: parent.height

        onReleased: {
            workspaceView.fileUrl = fileUrl
            workspaceView.acceptAndClose()
        }
    }
}
