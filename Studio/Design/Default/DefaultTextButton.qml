import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

Button {
    property alias textItem: textItem
    property alias rectItem: rectItem
    property alias showBorder: rectItem.visible

    id: control
    hoverEnabled: true
    font.pixelSize: 16

    onHoveredChanged: {
        if (hovered)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    contentItem: Item {
    }

    background: Rectangle {
        id: rectItem
        width: control.width
        height: control.height
        color: "transparent"
        radius: 6
        visible: false
        border.width: 1
        border.color: textItem.color
    }

    Text {
        id: textItem
        anchors.fill: parent
        verticalAlignment: Qt.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter
        text: control.text
        font: control.font
        color: control.pressed ? themeManager.accentColor : control.hovered ? themeManager.semiAccentColor : "white"
        fontSizeMode: Text.Fit
        // opacity: control.pressed ? 1.0 : control.hovered ? 0.85 : control.enabled ? 0.7 : 0.5
        // wrapMode: Text.Wrap
        // elide: Text.ElideRight
        // onFontInfoChanged: console.log(width)
    }
}
