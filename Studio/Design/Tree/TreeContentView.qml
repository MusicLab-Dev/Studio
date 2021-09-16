import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Help"
import "../Common"

import NodeModel 1.0
import PartitionModel 1.0

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

    // Alias
    property alias treeSurface: treeSurface
    property alias partitionsPreview: partitionsPreview

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

    ParallelAnimation {
        id: downOverlays
        PropertyAnimation {
            target: treeComponentsPanel
            property: "y"
            from: treeComponentsPanel.yBase
            to: treeComponentsPanel.yOpen
            duration: 300
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            target: overview
            property: "y"
            from: overview.yBase
            to: overview.yOpen
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: upOverlays
        PropertyAnimation {
            target: treeComponentsPanel
            property: "y"
            from: treeComponentsPanel.yOpen
            to: treeComponentsPanel.yBase
            duration: 300
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            target: overview
            property: "y"
            from: overview.yOpen
            to: overview.yBase
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    // Handle all mouse / touch gestures
    GestureArea {
        id: gestureArea
        anchors.fill: parent

        onOffsetScroll: {
            contentView.incrementXOffset(xOffset)
            contentView.incrementYOffset(yOffset)
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

        HelpArea {
            name: qsTr("Project's tree area")
            description: qsTr("Description")
            position: HelpHandler.Position.Top
        }
    }

    TreeHeader {
        id: treeHeader
        height: parent.height * 0.05
        width: parent.width
        z: 1
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
        property real yBase: treeHeader.height + 30
        property real yOpen: treeControls.height + 30

        id: treeComponentsPanel
        y: yBase
        width: parent.width * 0.15
        height: parent.height - (treeControls.visible ? treeControls.height : 0) - partitionsPreview.height - 35
        panelCategoryHeight: parent.height * 0.1
        xBase: parent.width
    }

    Item {
        property real yBase: treeHeader.height + 30
        property real yOpen: treeControls.height + 30

        id: overview
        y: yBase
        anchors.left: parent.left
        anchors.leftMargin: 20
        width: parent.width * 0.1
        height: parent.height * 0.1

        Rectangle {
            anchors.fill: parent
            radius: 16
            opacity: overviewMouse.containsMouse ? 1 : 0.6
            color: overviewMouse.containsMouse ? app.project.master.color : themeManager.foregroundColor
        }

        MouseArea {
            id: overviewMouse
            hoverEnabled: true
            anchors.fill: parent
            onPressed: {
                modulesView.addNewPlannerWithMultipleNodes(app.project.master.getAllChildren())
            }
        }

        DefaultText {
            anchors.fill: parent
            fontSizeMode: Text.Fit
            font.pixelSize: 30
            text: qsTr("Overview")
            color: overviewMouse.containsMouse ? themeManager.foregroundColor : app.project.master.color
        }

        HelpArea {
            name: qsTr("Planner overview")
            description: qsTr("Description")
            position: HelpHandler.Position.Bottom
            externalDisplay: true
        }
    }


    ControlsFlow {
        function open(newNode) {
            if (node) {
                node = newNode
            } else {
                node = newNode
                openAnimControl.start()
                downOverlays.start()
            }
        }

        function change(newNode) {
            node = newNode
        }

        function close() {
            if (treeControls.node) {
                closeAnimControl.start()
                upOverlays.start()
            }
        }

        id: treeControls
        anchors.top: treeHeader.bottom
        width: parent.width
        y: parent.height
        node: null

        ParallelAnimation {
            id: openAnimControl
            PropertyAnimation {
                target: treeControls
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutCubic
            }
            PropertyAnimation {
                target: treeHeader
                property: "y"
                from: 0
                to: -treeHeader.height
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        ParallelAnimation {
            id: closeAnimControl
            PropertyAnimation {
                target: treeHeader
                property: "y"
                from: -treeHeader.height
                to: 0
                duration: 300
                easing.type: Easing.OutCubic
            }
            PropertyAnimation {
                target: treeControls
                property: "opacity"
                from: 1
                to: 0
                duration: 300
                easing.type: Easing.OutCubic
            }
            onFinished: treeControls.node = null
        }
    }

    PartitionsPreview {
        id: partitionsPreview
        anchors.bottom: parent.bottom

        HelpArea {
            name: qsTr("Partitions")
            description: qsTr("Description")
            position: HelpHandler.Position.Top
            externalDisplay: true
            visible: partitionsPreview.visible
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
        width: 6

        onPositionChanged: {
            if (Math.abs(position - contentView.yScrollIndicatorPos) > Number.EPSILON)
                contentView.yOffset = ((1 - (position / (1 - size))) * contentView.yOffsetWidth) + contentView.yOffsetMin
                // contentView.yOffset = contentView.yOffsetMin + contentView.yOffsetWidth * position / (1 - size)
        }
    }

    ScrollBar {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: partitionsPreview.visible ? partitionsPreview.top : parent.bottom
        visible: size !== 1
        orientation: Qt.Horizontal
        size: contentView.xScrollIndicatorSize
        position: contentView.xScrollIndicatorPos
        policy: ScrollBar.AlwaysOn
        height: 6

        onPositionChanged: {
            // position = (1 - size) *  (1 - ((xOffset - xOffsetMin) / xOffsetWidth))
            // position / (1 - size) = 1 - ((xOffset - xOffsetMin) / xOffsetWidth)
            // (position / (1 - size)) + ((xOffset - xOffsetMin) / xOffsetWidth) = 1
            // ((xOffset - xOffsetMin) / xOffsetWidth) = 1 - (position / (1 - size))
            // xOffset - xOffsetMin = (1 - (position / (1 - size))) * xOffsetWidth
            // xOffset = ((1 - (position / (1 - size))) * xOffsetWidth) + xOffsetMin


            // position / (1 - size) = -((xOffset - xOffsetMin) / xOffsetWidth) + 1
            // (position / (1 - size)) - 1 = -((xOffset - xOffsetMin) / xOffsetWidth)
            // -((position / (1 - size)) - 1) = (xOffset - xOffsetMin) / xOffsetWidth
            // -((position / (1 - size)) - 1) * xOffsetWidth = xOffset - xOffsetMin

            if (Math.abs(position - contentView.xScrollIndicatorPos) > Number.EPSILON)
                contentView.xOffset = ((1 - (position / (1 - size))) * contentView.xOffsetWidth) + contentView.xOffsetMin
                // contentView.xOffset = (-((position / (1 - size)) - 1) * contentView.xOffsetWidth) - contentView.xOffsetMin
                // contentView.xOffset = contentView.xOffsetWidth * position / (1 - size)
        }
    }

    DefaultImageButton {
        visible: contentView.lastSelectedNode && partitionsPreview.hide
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.rightMargin: 10
        width: height
        height: treeFooter.height / 2
        showBorder: false
        scaleFactor: 1
        source: "qrc:/Assets/Note.png"

        onReleased: partitionsPreview.hide = false
    }

    DefaultImageButton {
        visible: contentView.lastSelectedNode && treeControls.hide
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.rightMargin: 10
        width: height
        height: treeFooter.height / 2
        showBorder: false
        scaleFactor: 1
        source: "qrc:/Assets/Controls.png"

        onReleased: treeControls.hide = false
    }
}
