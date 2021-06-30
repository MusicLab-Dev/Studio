import QtQuick 2.15
import QtQuick.Controls 2.15

import '../Default'

DefaultText {
    width: parent.width
    y: parent.height + height * 0.5
    color: pluginsSquareComponentArea.containsMouse ? themeManager.accentColor : "#FFFFFF"
    opacity: pluginsSquareComponentArea.containsMouse ? 1 : 0.7
    font.pointSize: 14
    font.weight: Font.DemiBold
    elide: Qt.ElideRight
}
