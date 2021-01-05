import QtQuick 2.15
import QtQuick.Layouts 1.15
import "qrc:/SequencerView/SequencerViewContent"

Rectangle {
    id: sequencerView

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SequencerViewHeader {
            Layout.preferredHeight: parent.height * 0.125
            Layout.preferredWidth: parent.width
            z: 1
        }

        SequencerViewContent {
            Layout.preferredHeight: parent.height * 0.75
            Layout.preferredWidth: parent.width
        }

        SequencerViewFooter {
            Layout.preferredHeight: parent.height * 0.125
            Layout.preferredWidth: parent.width
        }
    }
}
