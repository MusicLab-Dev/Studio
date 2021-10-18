import QtQuick 2.15
import QtGraphicalEffects 1.15

import ColoredSprite 1.0

Item {
    property alias source: image.source
    property alias color: overlay.color
    property alias playing: image.playing

    ColorOverlay {
        id: overlay
        anchors.fill: parent
        cached: false

        source: ColoredSprite {
            id: image
            width: overlay.width
            height: overlay.height
        }
    }
}
