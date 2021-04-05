import QtQuick 2.15
import QtQuick.Controls 2.15

Text {
    width: delegate.width
    height: delegate.height / 2
    x: parent.width / 2 - width / 2
    y: title.y * 1.2
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    elide: Text.ElideRight
    color: pluginsSquareComponentHovered ? "#31A8FF" : "#FFFFFF"
    opacity: pluginsSquareComponentHovered ? 1 : 0.7
    font.pointSize: 12
    font.weight: Font.Thin
}
