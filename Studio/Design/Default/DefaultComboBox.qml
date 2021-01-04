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
        width: height
        height: control.height / 2
        contextType: "2d"

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.pressed || popup.opened ? "#31A8FF" : control.hovered ? "#0D86CB" : "#295F8B";
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
        verticalAlignment: Text.AlignVCenter
        leftPadding: 15
        elide: Text.ElideRight
        color: control.pressed || popup.opened ? "#31A8FF" : control.hovered ? "#0D86CB" : "#295F8B";
        padding: control.padding
    }

    background: Rectangle {
        anchors.fill: control
        border.width: control.pressed ? 4 : 2
        border.color: control.pressed || popup.opened ? "#31A8FF" : control.hovered ? "#0D86CB" : "#295F8B"
        color: control.pressed ? "#001E36" : "#001E36"
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
            text: modelData
            color: parent.hovered ? "#001E36": "#295F8B"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: parent.hovered ? "#295F8B": "#001E36"
        }
    }
}
