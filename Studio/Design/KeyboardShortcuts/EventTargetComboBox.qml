import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"
import "../Default"

import KeyboardEventListener 1.0

DefaultComboBox {
    id: control
    font.pointSize: 14
    model: KeyboardEventListener.TotalEventTarget
    displayText: eventDispatcher.keyboardListener.eventTargetToString(eventType)

    delegate: ItemDelegate {
        width: control.width - 4
        hoverEnabled: true
        highlighted: control.highlightedIndex === index

        contentItem: Text {
            text: eventDispatcher.keyboardListener.eventTargetToString(index)
            color: control.accentColor
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: parent.hovered ? themeManager.foregroundColor : themeManager.contentColor
        }
    }
}
