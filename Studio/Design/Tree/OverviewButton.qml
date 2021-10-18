import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Help"
import "../Common"

import NodeModel 1.0
import PartitionModel 1.0
import CursorManager 1.0

Item {
    id: overview

    Rectangle {
        anchors.fill: parent
        radius: 6
        opacity: overviewMouse.containsMouse ? 1 : 0.6
        color: overviewMouse.containsMouse ? app.project.master.color : themeManager.contentColor
    }

    MouseArea {
        id: overviewMouse
        hoverEnabled: true
        anchors.fill: parent
        onPressed: {
           modulesView.addNewPlannerWithMultipleNodes(app.project.master.getAllChildren())
        }

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
        font.pixelSize: 30
        text: qsTr("Overview")
        color: overviewMouse.containsMouse ? themeManager.contentColor : app.project.master.color
    }

    HelpArea {
        name: qsTr("Planner overview")
        description: qsTr("Description")
        position: HelpHandler.Position.Bottom
        externalDisplay: true
    }
}
