import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control
    hoverEnabled: true

    contentItem: Text {
         text: control.text
         font: control.font
         color: control.pressed ? "#31A8FF" : control.hovered ? "#31A8FF" : control.enabled ? "#FFFFFF" : "#FFFFFF"
         // the component is invisible because it is design to be on dark background and its color is based on white
         opacity: control.pressed ? 1.0 : control.hovered ? 0.51 : control.enabled ? 0.71 : 0.44
         elide: Text.ElideRight
         verticalAlignment: Qt.AlignVCenter
         horizontalAlignment: Qt.AlignHCenter
     }

    background: Item {}
}
