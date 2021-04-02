import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Row {
    property alias headerWidth: headerRect.width

    Rectangle {
        id: headerRect
        width: 0
        height: parent.height
        color: themeManager.foregroundColor
    }

    Rectangle {
        id: timeline
        width: parent.width - headerRect.width
        color: themeManager.disabledColor
    }
}
