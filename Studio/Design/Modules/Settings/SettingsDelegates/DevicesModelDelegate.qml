import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../../Default"

Row {
    height: 40
    spacing: 5

    DefaultText {
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        color: "#295F8B"
    }

    DefaultComboBox {
        width: Math.max(parent.width * 0.15, 300)
        height: parent.height
        model: devicesModel
        textRole: "name"

        onActivated: {
            roleValue = textAt(index)
            if (app.currentPlayer) {
                app.currentPlayer.stop()
            }
            app.scheduler.reloadDevice(roleValue)
        }

        Component.onCompleted: {
            var idx = find(app.scheduler.device.name)
            if (idx === -1)
                idx = 0
            currentIndex = idx
        }
    }
}

