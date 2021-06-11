import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default"

DefaultMenuButton {
    height: parent.height * 0.05
    width: parent.height * 0.05
    imageFactor: 0.75
    rect.color: themeManager.foregroundColor
    rect.border.color: "black"
    rect.border.width: 1
}
