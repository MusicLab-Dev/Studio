import QtQuick 2.0

Item {
    function open(filt) {
        filter = filt
        if (!launched)
            openAnimPanel.start()
        launched = true
    }

    function close() {
        launched = false
        filter = 0
        closeAnimPanel.start()
    }

    property int filter: 0
    property bool launched: false
    property real durationAnimation: 300
    property real widthContentRatio: 0.6
    property real panelCategoryWidth: width - width * widthContentRatio
    property real panelCategoryHeight: 100
    property real panelContentWidth: width * widthContentRatio
    property real xBase: 0
    property real xClose: xBase - panelCategoryWidth
    property real xOpen: xBase - width

    id: treeComponentsPanel
    x: xClose

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
