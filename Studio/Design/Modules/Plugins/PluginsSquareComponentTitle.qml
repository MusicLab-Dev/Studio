import QtQuick 2.15
import QtQuick.Controls 2.15

Text {
    x: parent.width / 2 - width / 2
    y: parent.height + height * 0.5
    color: pluginsSquareComponentHovered ? "#31A8FF" : "#FFFFFF"
    opacity: pluginsSquareComponentHovered ? 1 : 0.7
    font.pointSize: 14
    font.weight: Font.DemiBold
}
