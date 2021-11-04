import QtQuick 2.15

import "../Help"

Item {
    function open(filt) {
        filter = filt
        if (!launched)
            openAnimPanel.restart()
        launched = true
    }

    function close() {
        launched = false
        filter = 0
        closeAnimPanel.restart()
    }

    property int filter: 0
    property bool launched: false
    property real durationAnimation: 300
    property real widthContentRatio: 0.6
    property real panelCategoryWidth: width - width * widthContentRatio
    property real panelCategoryHeight: 100
    property real panelContentWidth: width * widthContentRatio
    property real xBase: 0
    property real xClose: -panelCategoryWidth
    property real xOpen: xBase

    id: treeComponentsPanel
    x: xClose

    HelpArea {
        name: qsTr("Plugins panel")
        description: qsTr("Description")
        position: HelpHandler.Position.Left
        externalDisplay: true
    }

    ParallelAnimation {
        id: openAnimPanel
        PropertyAnimation { target: treeComponentsPanel; property: "x"; to: treeComponentsPanel.xOpen; duration: durationAnimation; easing.type: Easing.OutBack }
    }

    ParallelAnimation {
        id: closeAnimPanel
        PropertyAnimation { target: treeComponentsPanel; property: "x"; to: treeComponentsPanel.xClose; duration: durationAnimation; easing.type: Easing.OutBack; }
    }

    SequentialAnimation {
        id: restartAnim
        ParallelAnimation {
            PropertyAnimation { target: treeComponentsPanel; property: "x"; to: treeComponentsPanel.xClose; duration: durationAnimation; easing.type: Easing.OutCubic; }
        }
        ScriptAction { script: treeComponentsPanel.filter = treeComponentsPanel.filterTemp }
        ParallelAnimation {
            PropertyAnimation { target: treeComponentsPanel; property: "x"; to: treeComponentsPanel.xOpen; duration: durationAnimation; easing.type: Easing.InCubic }
        }
    }
}
