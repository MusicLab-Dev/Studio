import QtQuick 2.15
import QtQuick.Controls 2.15

Text {
    x: parent.width / 2 - width / 2
    y: parent.height + height * 0.5
    horizontalAlignment: Text.AlignHCenter
    color: "#FFFFFF"
    opacity: 0.42
    font.pointSize: 16
    font.weight: Font.DemiBold
    elide: Text.ElideRight
}
