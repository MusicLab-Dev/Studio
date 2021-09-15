import QtQuick 2.15
import QtGraphicalEffects 1.15

Image {
    property alias source: image.source
    property alias color: overlay.color
    property alias cached: overlay.cached
    property alias fillMode: image.fillMode
    property alias playing: image.playing

    ColorOverlay {
        id: overlay
        anchors.fill: parent
        cached: false

        source: AnimatedImage {
            id: image

            onPlayingChanged: {
                currentFrame = 0
            }
        }
    }
}
