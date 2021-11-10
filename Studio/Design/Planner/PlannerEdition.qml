import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default"
import "../Common"

RowLayout {
    spacing: 10

    EditionModeSelector {
        id: editModeSelector
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.375
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

