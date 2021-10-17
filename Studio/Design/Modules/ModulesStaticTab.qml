import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"


MouseArea {
    readonly property bool isSelectedModule: tabIndex === modulesTabs.selectedModule
    property int tabIndex
    property alias title: titleLabel.text
    property alias color: background.color
    property url source: ""

    id: tabMouseArea
    width: modulesTabs.tabWidth
    height: modulesTabs.tabHeight
    hoverEnabled: true

    onPressed: modulesView.changeSelectedModule(tabIndex)

    Rectangle {
        id: background
        anchors.fill: parent
        color: drag.active ? themeManager.accentColor : tabMouseArea.isSelectedModule ? themeManager.backgroundColor : themeManager.contentColor
    }

    DefaultColoredImage {
        id: icon
        source: tabMouseArea.source
        x: 8
        y: 8
        width: parent.height - 16
        height: width
        color: titleLabel.color
    }

    DefaultText {
        id: titleLabel
        x: parent.height
        width: parent.width - parent.height
        height: parent.height
        color: drag.active ? "white" : tabMouseArea.containsPress ? themeManager.accentColor : tabMouseArea.containsMouse ? themeManager.semiAccentColor : tabMouseArea.isSelectedModule ? "white" : "lightgrey"
        fontSizeMode: Text.HorizontalFit
        text: modulesView.getModule(tabIndex).moduleName
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight
    }
}
