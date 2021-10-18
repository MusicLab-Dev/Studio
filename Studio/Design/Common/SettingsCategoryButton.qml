import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Button {
    property string iconSource: "qrc:/Assets/Settings/SettingsCategoryButton.png"

    id: control
    hoverEnabled: true
    enabled: true // to test disable component

    background: Rectangle {
        id: rect
        width: control.width
        height: control.height
        border.width: control.pressed || control.hovered ? 2 : 0
        border.color: control.pressed ? themeManager.accentColor : control.hovered ? themeManager.semiAccentColor : "white"
        color: themeManager.contentColor
        radius: 6
    }

    contentItem: Item {

    }

    Text {
        width: control.width
        height: control.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: control.text
        font: control.font
        color: "white"
        elide: Text.ElideRight
    }

    indicator: DefaultColoredImage {
        width: control.width / 7
        height: control.height / 2
        x: control.width / 12
        y: (control.height - height) / 2
        source: iconSource
        color: rect.border.color
    }
}
