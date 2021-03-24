import QtQuick 2.15
import QtQuick.Layouts 1.15

import "qrc:/SequencerView/SequencerViewContent"

Rectangle {
    id: sequencerView
    focus: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SequencerViewHeader {
            id: sequencerViewHeader
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height * 0.1
            z: 1
        }

        SequencerViewContent {
            id: sequencerViewContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height * 0.8
        }

        SequencerViewFooter {
            id: sequencerViewFooter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height * 0.1
        }
    }

     Shortcut {
         sequence: StandardKey.ZoomIn
         onActivated: {
             if (sequencerViewContent.sequencerViewContentFlickable.rowHeight < 100)
                 sequencerViewContent.sequencerViewContentFlickable.rowHeight += 2
         }
     }

     Shortcut {
        sequence: StandardKey.ZoomOut
         onActivated: {
             if (sequencerViewContent.sequencerViewContentFlickable.rowHeight > 20)
                sequencerViewContent.sequencerViewContentFlickable.rowHeight -= 2
         }
     }
}
