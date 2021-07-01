import QtQuick 2.15

import "../Default"

Column {
    property string moduleName: "Planner"
    property int moduleIndex

    function onNodeDeleted(targetNode) {
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        return false
    }

    function loadNode() {
        nodeList.loadNode(app.plannerNodeCache)
        app.plannerNodeCache = null
    }

    function loadMultipleNodes() {
        nodeList.loadNodes(app.plannerNodesCache)
        app.plannerNodesCache = []
    }

    property alias nodeList: contentView.nodeList

    id: plannerView
    focus: true

    PlannerHeader {
        id: plannerHeader
        width: parent.width
        height: parent.height * 0.15
        z: 1
    }

    PlannerContentView {
        id: contentView
        width: parent.width
        height: parent.height * 0.7
    }

    PlannerFooter {
        id: plannerFooter
        width: parent.width
        height: parent.height * 0.15
    }

    PlannerNodeMenu {
        id: plannerNodeMenu
    }

    PlannerPartitionMenu {
        id: plannerPartitionMenu
    }
}
