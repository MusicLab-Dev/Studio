import QtQuick 2.15

import "../Default"

DefaultImageButton {
    property real barSize: width / 4

    id: expandButton
    showBorder: true
    borderColor: "black"
    backgroundRadius: 0
    backgroundColor: themeManager.backgroundColor
    rotation: modulesTabs.expanded ? 270 : 90
    transformOrigin: Item.Center
    source: "qrc:/Assets/Next.png"
    colorDefault: "white"
    scaleFactor: 0.4

    onReleased: modulesTabs.expanded = !modulesTabs.expanded
}
