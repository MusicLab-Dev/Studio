import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Row {
    readonly property real barWidth: (width - 2 * spacing - categoryLabel.width) / 2

    spacing: 20

    Rectangle {
        width: barWidth
        height: 2
        anchors.verticalCenter: parent.verticalCenter
        color: "#295F8B"
    }

    DefaultText {
        id: categoryLabel
        color: "#295F8B"
        text: settingsContentArea.settingsProxyModel.tags ? category.substr(1) : paramCategory
        height: parent.height
    }

    Rectangle {
        width: barWidth
        height: 2
        anchors.verticalCenter: parent.verticalCenter
        color: "#295F8B"
    }
}