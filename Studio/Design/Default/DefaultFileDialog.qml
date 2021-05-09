import QtQuick 2.15
import QtQuick.Dialogs 1.3

FileDialog {
    readonly property bool cancelKeyboardEventsOnFocus: true

    onVisibleChanged: {
        eventDispatcher.cancelEvents = visible
    }
}
