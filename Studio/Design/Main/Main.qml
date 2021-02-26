import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import "../Modules/Board"

Window {
    visible: true
    width: 1920
    height: 1080
    title: qsTr("MusicLab")

    BoardView {
        anchors.fill: parent
    }
}
