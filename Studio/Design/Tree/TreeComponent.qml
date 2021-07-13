import QtQuick 2.0
import QtQuick.Layouts 1.3

import "../Default"

Rectangle {
    property alias mouseArea: dragHandler
    property alias text: text
    property var pressedCallBack: null

    anchors.centerIn: parent
    width: parent.width * 0.7
    height: parent.height * 0.5
    radius: 15

    DefaultText {
        id: text
        anchors.fill: parent
        text: ""
    }

    MouseArea {
        id: dragHandler
        anchors.fill: parent
        drag.target: dragHandler
        drag.smoothed: true

        drag.onActiveChanged: {
            if (drag.active) {
                console.log("ok")
            } else {

            }
        }

        onPressed: {
            close()
            if (pressedCallBack != null)
                pressedCallBack()
        }
    }

}
