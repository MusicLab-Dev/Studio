import QtQuick 2.15
import QtQuick.Controls 2.15

Text {
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    elide: Text.ElideRight
    color: pluginsSquareComponentArea.containsMouse ? "#31A8FF" : "#FFFFFF"
    opacity: pluginsSquareComponentArea.containsMouse ? 1 : 0.7
    font.pointSize: 12
    font.weight: Font.Thin
}
