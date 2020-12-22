import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    property real headerFactor: 0.1

    width: parent.width
    height: parent.height
    color: "#001E36"

    ColumnLayout {
        width: parent.width
        height: parent.height
        spacing: 0

        SequencerViewContentTimeline {
            id: timeline
            headerFactor: headerFactor
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width
            z: 1
        }

        SequencerViewContentGrid {
            Layout.preferredHeight: parent.height * 0.98
            Layout.preferredWidth: parent.width
            headerFactor: headerFactor
        }
    }

    SequencerViewContentTimelineBar {
        x: parent.width * headerFactor + 200
        width: 25
        height: parent.height
    }
}


