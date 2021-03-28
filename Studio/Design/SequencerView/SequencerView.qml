import QtQuick 2.15
import QtQuick.Layouts 1.15

import PartitionModel 1.0

ColumnLayout {
    property PartitionModel partition: null

    id: sequencerView
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
        Layout.preferredHeight: parent.height * 0.8
        Layout.preferredWidth: parent.width
    }

    SequencerViewFooter {
        id: sequencerViewFooter
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.1
        Layout.preferredWidth: parent.width
    }
}
