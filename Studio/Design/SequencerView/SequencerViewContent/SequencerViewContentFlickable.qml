import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Item {
    property alias totalHeight: piano.totalGridHeight

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true
        contentHeight: totalHeight
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: DefaultScrollBar {
            policy: ScrollBar.AlwaysOn
        }

        SequencerViewContentPiano {
            id: piano
        }
    }

    SequencerViewContentGrid {
        anchors.fill: parent
        anchors.leftMargin: piano.keyWidth
    }
}