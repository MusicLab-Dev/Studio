import QtQuick 2.15
import QtQuick.Layouts 1.15
import "qrc:/SequencerView/SequencerViewContent"

Rectangle {
    id: sequencerView

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SequencerViewHeader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height * 0.1
            z: 1
        }

        SequencerViewContent {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height * 0.8
        }

        SequencerViewFooter {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height * 0.1
        }
    }
}
