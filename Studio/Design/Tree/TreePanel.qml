import QtQuick 2.0

Item {
    enum Type {
        Mixer,
        Sources,
        Effects,
        Tools,
        Void
    }

    function open(filt) {
        filter = filt
        if (!launched)
            openAnim.start()
        launched = true
    }

    function close() {
        launched = false
        filter = TreeComponentsPanel.Type.Void
        closeAnim.start()
    }

    property int filter: TreeComponentsPanel.Type.Void
    property bool launched: false
    property real durationAnimation: 300
    property real widthContentRatio: 0.6
    property real panelCategoryWidth: width - width * widthContentRatio
    property real panelCategoryHeight: 100
    property real panelContentWidth: width * widthContentRatio
    property real xBase: 0
    property real xClose: xBase - panelCategoryWidth
    property real xOpen: xBase - width

    id: panel
    x: xClose

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: panel; property: "x"; to: panel.xOpen; duration: durationAnimation; easing.type: Easing.OutBack }
    }

    ParallelAnimation {
        id: closeAnim
        PropertyAnimation { target: panel; property: "x"; to: panel.xClose; duration: durationAnimation; easing.type: Easing.OutBack; }
    }

    SequentialAnimation {
        id: restartAnim
        ParallelAnimation {
            PropertyAnimation { target: panel; property: "x"; to: panel.xClose; duration: durationAnimation; easing.type: Easing.OutCubic; }
        }
        ScriptAction { script: treeComponentsPanel.filter = treeComponentsPanel.filterTemp }
        ParallelAnimation {
            PropertyAnimation { target: panel; property: "x"; to: panel.xOpen; duration: durationAnimation; easing.type: Easing.InCubic }
        }
    }
}
