import QtQuick 2.15
import QtQuick.Controls 2.15

MenuSeparator {
    id: separator

    contentItem: Rectangle {
        implicitHeight: 1
        color: separator.enabled ? themeManager.semiAccentColor : "transparent"
    }

    background: Rectangle {
        color: themeManager.foregroundColor
    }
}
