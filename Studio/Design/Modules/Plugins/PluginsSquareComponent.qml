import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    width: Math.min(160, parent.width / 6)
    height: width
    color: "transparent"
    border.color: pluginsSquareComponentHovered ? "#31A8FF" : "white"
    border.width: 1
    radius: width / 4
    visible: !pluginsView.currentFilter || pluginsView.currentFilter & factoryTags
}
