import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"

import NodeModel 1.0
import PartitionModel 1.0
import AudioAPI 1.0

MouseArea {
    function incrementXOffset(offset) {
        contentView.xOffset = Math.min(Math.max(contentView.xOffset + offset, contentView.xOffsetMin), contentView.xOffsetMax)
    }

    function incrementYOffset(offset) {
        contentView.yOffset = Math.min(Math.max(contentView.yOffset + offset, contentView.yOffsetMin), contentView.yOffsetMax)
    }

    function actionEvent() {
        if (!globalTextField.visible && treeSurface.selectionList.length) {
            var nodes = []
            for (var i = 0; i < treeSurface.selectionList.length; ++i)
                nodes.push(treeSurface.selectionList[i].node)
            modulesView.addNewPlannerWithMultipleNodes(nodes)
        }
    }

    function selectPartition(node, partitionIndex) {
        selectedPartitionNode = node
        selectedPartition = node.partitions.getPartition(partitionIndex)
        selectedPartitionIndex = partitionIndex
    }

    function animateMoveFocus(rect) {
        var center = Qt.point(
            rect.x + rect.width / 2,
            rect.y + rect.height / 2,
        )
        var delta = Qt.point(
            (width / 2) - center.x,
            (height / 2) - center.y
        )
        //app.setCursorPos(mapToGlobal(width / 2, height / 2))
        incrementXOffset(delta.x)
        incrementYOffset(delta.y)
    }

    function animateMoveFocusSelection() {
        var length = treeSurface.selectionList.length
        if (!length)
            return
        var focusRect = treeSurface.selectionList[0].getFocusRect()
        var focusLeft = focusRect.left
        var focusTop = focusRect.top
        var focusRight = focusRect.right
        var focusBottom = focusRect.bottom
        for (var i = 1; i < length; ++i) {
            var rect = treeSurface.selectionList[i].getFocusRect()
            focusLeft = Math.min(focusLeft, rect.x)
            focusTop = Math.min(focusTop, rect.y)
            focusRight = Math.max(focusRight, rect.right)
            focusBottom = Math.max(focusBottom, rect.bottom)
        }
        focusRect.x = focusLeft
        focusRect.y = focusTop
        focusRect.width = focusRight - focusLeft
        focusRect.height = focusBottom - focusTop
        animateMoveFocus(focusRect)
    }

    // Alias
    property alias treeSurface: treeSurface
    property alias partitionsPreview: partitionsPreview
    property PlayerBase playerBase: treeView.player.playerBase

    // Horizontal scroll
    property real xOffset: 0
    readonly property real xOffsetMin: Math.min(-treeSurface.scaledWidth / 2, -width / 2)
    readonly property real xOffsetMax: -xOffsetMin
    readonly property real xOffsetWidth: xOffsetMax * 2
    readonly property real xScrollIndicatorSize: xOffsetWidth ? 1 / ((xOffsetWidth + width) / width) : 1
    readonly property real xScrollIndicatorPos: (1 - xScrollIndicatorSize) *  (1 - ((xOffset - xOffsetMin) / xOffsetWidth))

    // Vertical scroll
    property real yOffset: 0
    readonly property real yOffsetMin: Math.min(-treeSurface.scaledHeight / 2, -height / 2)
    readonly property real yOffsetMax: -yOffsetMin
    readonly property real yOffsetWidth: yOffsetMax * 2
    readonly property real yScrollIndicatorSize: yOffsetWidth ? 1 / ((yOffsetWidth + height) / height) : 1
    readonly property real yScrollIndicatorPos: (1 - yScrollIndicatorSize) * (1 - ((yOffset - yOffsetMin) / yOffsetWidth))

    // Scroll gesture
    readonly property real wheelsPerXScrollPage: 3
    readonly property real wheelsPerYScrollPage: 3
    readonly property real xScrollFactor: width / (wheelsPerXScrollPage * 360 * 8)
    readonly property real yScrollFactor: height / (wheelsPerYScrollPage * 360 * 8)

    // Zoom
    property real zoom: 0.25
    readonly property real zoomMin: 0.4
    readonly property real zoomMax: 3
    readonly property real zoomWidth: zoomMax - zoomMin

    // Zoom gesture
    readonly property real wheelsPerZoomRange: 3
    readonly property real zoomFactor: 1 / (wheelsPerZoomRange * 360 * 8)

    // Timeline
    readonly property int timelineHeight: 10

    // Partition selection
    property var lastSelectedNode: null
    property NodeModel selectedPartitionNode: null
    property PartitionModel selectedPartition: null
    property int selectedPartitionIndex: 0

    // Pixels per beat precision used for partition preview
    property real pixelsPerBeatPrecision: 1 / 8

    // Piano
    property int targetOctave: 5
    readonly property int keysPerOctave: 12

    id: contentView

    onPressed: {
        if (mouse.modifiers & (Qt.ControlModifier | Qt.ShiftModifier))
            treeSurface.beginSelection(treeSurface.mapFromItem(contentView, Qt.point(mouse.x, mouse.y)))
    }

    onPositionChanged: {
        if (treeSurface.selectionActive)
            treeSurface.updateSelection(treeSurface.mapFromItem(contentView, Qt.point(mouse.x, mouse.y)))
    }

    onReleased: {
        if (treeSurface.selectionActive)
            treeSurface.endSelection()
        else
            treeSurface.resetSelection(true)
        treeComponentsPanel.close()
        contentView.lastSelectedNode = null
    }

    onXOffsetMinChanged: {
        if (xOffset < xOffsetMin)
            xOffset = xOffsetMin
    }

    onXOffsetMaxChanged: {
        if (xOffset >= xOffsetMax)
            xOffset = xOffsetMax
    }

    onYOffsetMinChanged: {
        if (yOffset < yOffsetMin)
            yOffset = yOffsetMin
    }

    onYOffsetMaxChanged: {
        if (yOffset >= yOffsetMax)
            yOffset = yOffsetMax
    }

    Component.onCompleted: animDelayTimer.start()

    Timer {
        id: animDelayTimer
        interval: 100
        onTriggered: {
            controlsBehavior.enabled = true
            partitionsBehavior.enabled = true
            treeComponentsPanelBehavior.enabled = true
        }
    }

    Connections {
        function launch(pressed, key) {
            if (contentView.lastSelectedNode) {
                contentView.lastSelectedNode.node.partitions.addOnTheFly(
                    AudioAPI.noteEvent(!pressed, (contentView.targetOctave * contentView.keysPerOctave) + key, AudioAPI.velocityMax, 0),
                    contentView.lastSelectedNode.node
                )
            }
        }

        id: notesConnections
        target: eventDispatcher
        enabled: treeView.moduleIndex === modulesView.selectedModule && contentView.lastSelectedNode

        function onNote0(pressed) { launch(pressed, 0) }
        function onNote1(pressed) { launch(pressed, 1) }
        function onNote2(pressed) { launch(pressed, 2) }
        function onNote3(pressed) { launch(pressed, 3) }
        function onNote4(pressed) { launch(pressed, 4) }
        function onNote5(pressed) { launch(pressed, 5) }
        function onNote6(pressed) { launch(pressed, 6) }
        function onNote7(pressed) { launch(pressed, 7) }
        function onNote8(pressed) { launch(pressed, 8) }
        function onNote9(pressed) { launch(pressed, 9) }
        function onNote10(pressed) { launch(pressed, 10) }
        function onNote11(pressed) { launch(pressed, 11) }
    }

    // Handle all mouse / touch gestures
    GestureArea {
        id: gestureArea
        anchors.fill: parent

        onOffsetScroll: {
            contentView.incrementXOffset(vx)
            contentView.incrementYOffset(vy)
        }

        onXScrolled: contentView.incrementXOffset(contentView.xScrollFactor * scroll)
        onYScrolled: contentView.incrementYOffset(contentView.yScrollFactor * scroll)

        onXZoomed: {
            var oldWidth = treeSurface.scaledWidth
            var oldHeight = treeSurface.scaledHeight
            var oldXRatio = Math.min(Math.max((xPos - treeSurface.x) / oldWidth, 0), 1) - 0.5
            var oldYRatio = Math.min(Math.max((yPos - treeSurface.y) / oldHeight, 0), 1) - 0.5
            contentView.zoom = Math.min(Math.max(contentView.zoom + contentView.zoomFactor * zoom, 0), 1)
            contentView.incrementXOffset(-oldXRatio * (treeSurface.scaledWidth - oldWidth))
            contentView.incrementYOffset(-oldYRatio * (treeSurface.scaledHeight - oldHeight))
        }
    }

    TreeSurface {
        readonly property real scaledWidth: width * scale
        readonly property real scaledHeight: height * scale

        id: treeSurface
        x: parent.width / 2 - scaledWidth / 2 + contentView.xOffset
        y: parent.height / 2 - scaledHeight / 2 + contentView.yOffset
        transformOrigin: Item.TopLeft
        scale: contentView.zoomMin + contentView.zoom * contentView.zoomWidth
    }

    TreeComponentsPanel {
        id: treeComponentsPanel
        anchors.top: treeControls.visible ? treeControls.bottom : parent.top
        anchors.bottom: partitionsPreview.top
        anchors.topMargin: 20
        anchors.bottomMargin: 20

        Behavior on x {
            id: treeComponentsPanelBehavior
            enabled: false
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
    }

    OverviewButton {
        id: overview
        anchors.right: parent.right
        anchors.rightMargin: 20
        width: parent.width * 0.12
        height: parent.height * 0.1
        anchors.top: treeControls.visible ? treeControls.bottom : parent.top
        anchors.topMargin: 20
    }

    ControlsFlow {
        id: treeControls
        width: parent.width
        node: contentView.lastSelectedNode ? contentView.lastSelectedNode.node : null
        y: !node ? -height : 0

        Behavior on y {
            id: controlsBehavior
            enabled: false

            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
                onRunningChanged: {
                    if (running && treeControls.requiredVisibility)
                        treeControls.visible = true
                    else if (!running && !treeControls.requiredVisibility)
                        treeControls.visible = true
                }
            }
        }
    }

    PartitionsPreview {
        id: partitionsPreview
        y: !requiredVisibility ? parent.height : parent.height - height
        nodeDelegate: lastSelectedNode
        enabled: requiredVisibility

        Behavior on y {
            id: partitionsBehavior
            enabled: false

            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
                onRunningChanged: {
                    if (running && partitionsPreview.requiredVisibility)
                        partitionsPreview.visible = true
                    else if (!running && !partitionsPreview.requiredVisibility)
                        partitionsPreview.visible = true
                }
            }
        }
    }

    TreeNodeTrashArea {
        width: 60
        height: width
        visible: treeSurface.dragTarget
        x: 5
        y: parent.height - (partitionsPreview.visible ? partitionsPreview.height : 0) - height - 5
    }

    ScrollBar {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: size !== 1
        orientation: Qt.Vertical
        size: contentView.yScrollIndicatorSize
        position: contentView.yScrollIndicatorPos
        policy: ScrollBar.AlwaysOn
        z: 10

        onPositionChanged: {
            if (Math.abs(position - contentView.yScrollIndicatorPos) > Number.EPSILON)
                contentView.yOffset = ((1 - (position / (1 - size))) * contentView.yOffsetWidth) + contentView.yOffsetMin
                // contentView.yOffset = contentView.yOffsetMin + contentView.yOffsetWidth * position / (1 - size)
        }
    }

    ScrollBar {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: partitionsPreview.top
        visible: size !== 1
        orientation: Qt.Horizontal
        size: contentView.xScrollIndicatorSize
        position: contentView.xScrollIndicatorPos
        policy: ScrollBar.AlwaysOn
        z: 10

        onPositionChanged: {
            if (Math.abs(position - contentView.xScrollIndicatorPos) > Number.EPSILON)
                contentView.xOffset = ((1 - (position / (1 - size))) * contentView.xOffsetWidth) + contentView.xOffsetMin
        }
    }

    DefaultImageButton {
        visible: contentView.lastSelectedNode && partitionsPreview.hide
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: height
        height: treeHeader.height / 2
        showBorder: false
        scaleFactor: 1
        source: "qrc:/Assets/Note.png"
        anchors.bottomMargin: 10
        anchors.rightMargin: 10

        onReleased: partitionsPreview.hide = false
    }
}
