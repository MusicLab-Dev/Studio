import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Help"
import "../Common"

import NodeModel 1.0
import PartitionModel 1.0
import CursorManager 1.0

Item {
    readonly property bool multiSelection: treeSurface.selectionCount > 1
    readonly property color runtimeColor: multiSelection ? treeSurface.selectionList[0].node.color : app.project.master.color

    id: overview

    Rectangle {
        anchors.fill: parent
        radius: 6
        opacity: overviewMouse.containsMouse ? 1 : 0.6
        color: overviewMouse.containsMouse ? overview.runtimeColor : themeManager.backgroundColor
    }

    MouseArea {
        id: overviewMouse
        hoverEnabled: true
        anchors.fill: parent

        onPressed: overview.multiSelection ? contentView.actionEvent() : modulesView.addNewPlannerWithMultipleNodes(app.project.master.getAllChildren())

        onHoveredChanged: {
            if (containsMouse)
                cursorManager.set(CursorManager.Type.Clickable)
            else
                cursorManager.set(CursorManager.Type.Normal)
        }
    }

    DefaultText {
        anchors.fill: parent
        fontSizeMode: Text.Fit
        font.pixelSize: 23
        text: overview.multiSelection ? qsTr("Open selected (" + treeSurface.selectionCount + ")") : qsTr("Overview")
        color: overviewMouse.containsMouse ? themeManager.backgroundColor : overview.runtimeColor
    }

    HelpArea {
        name: qsTr("Planner overview")
        description: qsTr("Description")
        position: HelpHandler.Position.Bottom
        externalDisplay: true
    }
}
