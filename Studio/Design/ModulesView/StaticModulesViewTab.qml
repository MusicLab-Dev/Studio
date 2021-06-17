import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"

MouseArea {
    readonly property bool isSelectedModule: tabIndex === modulesTabs.selectedModule
    property int tabIndex
    property alias title: titleLabel.text

    id: tabMouseArea
    width: modulesTabs.tabWidth
    height: modulesTabs.tabHeight
    hoverEnabled: true

    onPressed: modulesView.changeSelectedModule(tabIndex)

    Rectangle {
        id: tab
        anchors.fill: parent
        color: tabMouseArea.isSelectedModule ? themeManager.foregroundColor : themeManager.backgroundColor
        border.color: "black"
        border.width: 1
    }

    DefaultText {
        id: titleLabel
        width: parent.width
        height: parent.height
        color: isSelectedModule ? "white" : tabMouseArea.containsPress ? "darkgrey" : tabMouseArea.containsMouse ? "grey" : "#E5E5E5"
        fontSizeMode: Text.HorizontalFit
        text: modulesView.getModule(tabIndex).moduleName
        elide: Text.ElideRight
    }
}