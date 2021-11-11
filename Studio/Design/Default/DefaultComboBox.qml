import QtQuick 2.15
import QtQuick.Controls 2.15

import CursorManager 1.0

ComboBox {
    property alias rectBackground: rectBackground
    property alias listView: listView
    property color accentColor: themeManager.accentColor

    id: control
    hoverEnabled: true

    onPressedChanged: canvas.requestPaint()
    onHoveredChanged: {
        canvas.requestPaint()
        if (hovered)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    indicator: Canvas {
        id: canvas
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: comboBoxText.leftPadding / 2
        height: control.height / 4
        width: height * 1.5
        contextType: "2d"

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.moveTo(0, 0)
            ctx.lineTo(width, 0)
            ctx.lineTo(width / 2, height)
            ctx.closePath()
            ctx.fillStyle = control.pressed || popup.opened ? control.accentColor : "white"
            ctx.fill()
        }
    }

    contentItem: Text {
        id: comboBoxText
        text: control.displayText
        font: control.font
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        leftPadding: 15
        elide: Text.ElideRight
        color: control.hovered ? themeManager.accentColor : "white"
        padding: control.padding
    }

    background: Rectangle {
        id: rectBackground
        anchors.fill: control
        color: control.pressed ? themeManager.foregroundColor : themeManager.contentColor
        radius: 6
    }

    popup: Popup {
        id: popup
        y: control.height
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 2

        onOpenedChanged: canvas.requestPaint()

        contentItem: ListView {
            id: listView
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: themeManager.panelColor
            radius: 2
            //border.color: control.accentColor
            //border.width: 1
        }
    }

    delegate: ItemDelegate {
        id: itemDelegate
        width: control.width - 4
        hoverEnabled: true
        highlighted: control.highlightedIndex === index

        onHoveredChanged: {
            if (hovered)
                cursorManager.set(CursorManager.Type.Clickable)
            else
                cursorManager.set(CursorManager.Type.Normal)
        }

        contentItem: Text {
            text: control.textAt(index)
            color: "white"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            width: itemDelegate.width
            height: itemDelegate.height
            radius: 2
            color: parent.hovered ? themeManager.accentColor : themeManager.panelColor
        }
    }
}
