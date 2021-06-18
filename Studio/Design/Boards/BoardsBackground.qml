import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: boardBackground
    width: parent.width * 0.97
    height: parent.height * 0.95
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    color: themeManager.foregroundColor
}
