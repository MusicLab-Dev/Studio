import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    property alias rectBackground: rectBackground
    property alias listView: listView
    property color accentColor: themeManager.accentColor

    id: control
    hoverEnabled: true

    onPressedChanged: canvas.requestPaint()
    onHoveredChanged: canvas.requestPaint()

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
            ctx.fillStyle = control.pressed || popup.opened ? control.accentColor : themeManager.contentColor
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
        color: control.pressed || popup.opened ? control.accentColor : themeManager.contentColor
        padding: control.padding
    }

    background: Rectangle {
        id: rectBackground
        anchors.fill: control
        border.width: 2
        border.color: control.hovered || popup.opened ? control.accentColor : themeManager.contentColor
        color: control.pressed ? themeManager.backgroundColor : themeManager.foregroundColor
        radius: 10
    }

    popup: Popup {
        id: popup
        y: control.height
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 2

        contentItem: ListView {
            id: listView
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: themeManager.foregroundColor
            border.color: control.accentColor
            border.width: 2
        }
    }

    delegate: ItemDelegate {
        width: control.width - 4
        hoverEnabled: true
        highlighted: control.highlightedIndex === index

        contentItem: Text {
            text: control.textAt(index)
            color: control.accentColor
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: parent.hovered ? themeManager.backgroundColor : themeManager.foregroundColor
        }
    }
}
