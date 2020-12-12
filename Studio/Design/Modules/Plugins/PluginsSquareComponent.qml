import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    width: 161
    height: 161
    border.color: "black"
    border.width: 1
    visible: !pluginsView.currentFilter || pluginsView.currentFilter & modelData[1]
}
