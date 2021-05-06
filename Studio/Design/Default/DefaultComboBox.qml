import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: control
    hoverEnabled: true

    indicator: Canvas {
        id: canvas
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: comboBoxText.leftPadding / 2
        height: control.height / 4
        width: height * 1.5
        contextType: "2d"

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.pressed || popup.opened ? "#31A8FF" : control.hovered ? "#0D86CB" : themeManager.contentColor;
            context.fill();
        }

        Connections {
            target: control
            function onPressedChanged() { canvas.requestPaint() }
            function onHoveredChanged() { canvas.requestPaint() }
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
        color: control.pressed || popup.opened ? "#31A8FF" : control.hovered ? "#0D86CB" : themeManager.contentColor;
        padding: control.padding
    }

    background: Item {
        anchors.fill: control

        Rectangle {
            id: rectBackground
            anchors.fill: parent
            border.width: control.pressed ? 4 : 2
            border.color: control.pressed || popup.opened ? "#31A8FF" : control.hovered ? "#0D86CB" : themeManager.contentColor
            color: control.pressed ? themeManager.backgroundColor : themeManager.foregroundColor
            radius: 10
        }
    }

    popup: Popup {
        id: popup
        y: control.height
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 2

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: "#001E36"
            border.color: "#31A8FF"
            border.width: 2
        }
    }

    delegate: ItemDelegate {
        width: control.width - 4
        hoverEnabled: true
        highlighted: control.highlightedIndex === index

        contentItem: Text {
            text: control.textAt(index)
            color: parent.hovered ? "#001E36": "#295F8B"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: parent.hovered ? themeManager.backgroundColor : themeManager.foregroundColor
        }
    }
}
