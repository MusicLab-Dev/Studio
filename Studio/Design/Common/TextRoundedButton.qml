import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

import "../Default"

DefaultTextButton {
    property bool hoverOnText: true

    id: textRoundedButton
    showBorder: true
    width: 70
    height: 30
    rectItem.color: textRoundedButton.hoverOnText ? "transparent" : (textRoundedButton.containsMouse ? themeManager.accentColor : "#1E6FB0")
    rectItem.radius: 5
    rectItem.border.color: textRoundedButton.containsMouse ? themeManager.accentColor : "#1E6FB0"
    rectItem.border.width: textRoundedButton.hoverOnText ? 1 : 0
}
