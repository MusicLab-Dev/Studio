import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default"
import "../Common"
import "../Help"

RowLayout {
    spacing: 10

    EditionModeSelector {
        id: editModeSelector
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.375
    }

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.3
        Layout.alignment: Qt.AlignHCenter

        Snapper {
            id: snapper
            height: parent.height * 0.4
            width: parent.width
            currentIndex: 4
            anchors.verticalCenter: parent.verticalCenter

            onActivated: {
                contentView.placementBeatPrecisionScale = currentValue
                contentView.placementBeatPrecisionLastWidth = 0
            }
        }
    }

    ArrowNextPrev {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.25
        Layout.alignment: Qt.AlignHCenter

        prev.onPressed: actionsManager.undo()
        prev.enabled: true
        next.onPressed: actionsManager.redo()
        next.enabled: true
    }
}

