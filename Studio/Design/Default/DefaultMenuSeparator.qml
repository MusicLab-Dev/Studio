import QtQuick 2.15
import QtQuick.Controls 2.15

MenuSeparator {
    id: separator
    visible: enabled
    height: enabled ? implicitHeight : 0

    contentItem: Rectangle {
        implicitHeight: 1
        color: separator.enabled ? themeManager.accentColor : "transparent"
    }

    background: Item {}
}
