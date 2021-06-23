import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    color: "transparent"
    border.color: pluginsSquareComponentArea.containsMouse ? "#31A8FF" : "white"
    border.width: 1
    radius: width / 4
}
