import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Help"
import "../Common"

import NodeModel 1.0
import PartitionModel 1.0

Item {
    id: overview

    Rectangle {
        anchors.fill: parent
        radius: 6
        opacity: overviewMouse.containsMouse ? 1 : 0.6
        color: overviewMouse.containsMouse ? app.project.master.color : themeManager.backgroundColor
    }

    MouseArea {
        id: overviewMouse
        hoverEnabled: true
        anchors.fill: parent
        onPressed: {
           actionEvent()// modulesView.addNewPlannerWithMultipleNodes(treeSurface.selectionList/*app.project.master.getAllChildren()*/)
        }
    }

    DefaultText {
        anchors.fill: parent
        fontSizeMode: Text.Fit
        font.pixelSize: 30
        text: qsTr("Overview")
        color: overviewMouse.containsMouse ? "white" : app.project.master.color
    }

    HelpArea {
        name: qsTr("Planner overview")
        description: qsTr("Description")
        position: HelpHandler.Position.Bottom
        externalDisplay: true
    }
}
