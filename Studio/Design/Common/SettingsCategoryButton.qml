import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Button {
    property bool activated: false
    property string iconSource: "qrc:/Assets/Settings/SettingsCategoryButton.png"

    id: control
    hoverEnabled: true
    enabled: true // to test disable component

    background: Rectangle {
        width: control.width
        height: control.height
        border.width: control.pressed ? (height / 20) : control.hovered ? (height / 24) : 0
        border.color: control.pressed ? themeManager.accentColor : control.hovered ? "#0D86CB" : ""
        color: control.activated ? themeManager.accentColor : "#001E36"
        radius: width / 17
    }

    contentItem: Text {
        width: control.width - control.background.width
        height: control.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: control.text
        font: control.font
        color: control.pressed ? themeManager.accentColor : control.hovered ? "#0D86CB" : "#295F8B"
        elide: Text.ElideRight
    }

    indicator: DefaultColoredImage {
        width: control.width / 7
        height: control.height / 2
        x: control.width / 12
        y: (control.height - height) / 2
        source: iconSource
        color: control.activated ? "#001E36" : control.pressed || control.hovered ? "#0D86CB" : "#295F8B"
    }
}
