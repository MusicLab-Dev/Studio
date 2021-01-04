import QtQuick 2.15
import QtGraphicalEffects 1.15

Image {
    property alias source: image.source
    property alias color: overlay.color
    property alias cached: overlay.cached
    property alias fillMode: image.fillMode

    ColorOverlay {
        id: overlay
        anchors.fill: parent
        cached: true

        source: Image {
            id: image
        }
    }
}
