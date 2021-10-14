import QtQuick 2.15
import QtQuick.Controls 2.15

DefaultImageButton {
    property bool activated: false

    id: control
    source: "qrc:/Assets/FoldButton.png"
    scaleFactor: 1
    image.rotation: control.activated ? 0 : -90

    background: Item {}

    onReleased: activated = !activated
}
