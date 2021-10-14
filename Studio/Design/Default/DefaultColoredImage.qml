import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    property alias image: image
    property alias source: image.source
    property alias color: overlay.color
    property alias cached: overlay.cached
    property alias fillMode: image.fillMode

    ColorOverlay {
        id: overlay
        anchors.fill: parent
        cached: false

        source: Image {
            id: image
            width: overlay.width
            height: overlay.height
            antialiasing: true
            cache: true
            mipmap: true
            smooth: true
            fillMode: Image.PreserveAspectFit
        }
    }
}
