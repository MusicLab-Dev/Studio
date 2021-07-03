import QtQuick 2.15

import AudioAPI 1.0

/*
    User of this class must implement the following "override" functions:

    bool addTarget(targetBeatRange, targetKey) {}
    bool removeTarget(targetIndex) {}
    BeatRange getTargetBeatRange(targetIndex) {}
*/
MouseArea {
    enum Mode {
        None,
        Insert,
        Move,
        Remove,
        ResizeLeft,
        ResizeRight,
        Brush,
        Select,
        SelectRemove
    }

    // Mouse to beat
    function getMouseBeatPrecision() {
        return Math.max(Math.floor((mouseX - contentView.xOffset) / contentView.pixelsPerBeatPrecision), 0)
    }
    function getPlacementBeatPrecision(mouseBeatPrecision) {
        var scopedBeatPrecision = mouseBeatPrecision - previewMouseBeatPrecisionOffset
        if (contentView.placementBeatPrecisionScale >= AudioAPI.beatPrecision)
            scopedBeatPrecision = scopedBeatPrecision - (scopedBeatPrecision % AudioAPI.beatPrecision)
        else if (contentView.placementBeatPrecisionScale !== 0)
            scopedBeatPrecision = scopedBeatPrecision - (scopedBeatPrecision % contentView.placementBeatPrecisionScale)
        return Math.max(scopedBeatPrecision, 0)
    }
    function getResizeLeftBeatPrecision(mouseBeatPrecision) {
        var scopedBeatPrecision = mouseBeatPrecision
        if (contentView.placementBeatPrecisionScale >= AudioAPI.beatPrecision)
            scopedBeatPrecision = scopedBeatPrecision - (scopedBeatPrecision % AudioAPI.beatPrecision)
        else if (contentView.placementBeatPrecisionScale !== 0)
            scopedBeatPrecision = scopedBeatPrecision - (scopedBeatPrecision % contentView.placementBeatPrecisionScale)
        return Math.max(scopedBeatPrecision, 0)
    }
    function getResizeRightBeatPrecision(mouseBeatPrecision) {
        var scopedBeatPrecision = mouseBeatPrecision
        if (contentView.placementBeatPrecisionScale >= AudioAPI.beatPrecision)
            scopedBeatPrecision = scopedBeatPrecision + (AudioAPI.beatPrecision - (scopedBeatPrecision % AudioAPI.beatPrecision))
        else if (contentView.placementBeatPrecisionScale !== 0)
            scopedBeatPrecision = scopedBeatPrecision - (contentView.placementBeatPrecisionScale - (scopedBeatPrecision % contentView.placementBeatPrecisionScale))
        return Math.max(scopedBeatPrecision, 0)
    }

    // Event begin rooting
    function changeMode(targetMode, mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange) {
        mode = targetMode
        switch (mode) {
        case PlacementArea.Mode.Insert:
            beginInsert(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.Move:
            beginMove(mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange)
            break
        case PlacementArea.Mode.Remove:
            beginRemove(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.ResizeLeft:
            beginResizeLeft(mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange)
            break
        case PlacementArea.Mode.ResizeRight:
            beginResizeRight(mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange)
            break
        case PlacementArea.Mode.Brush:
            beginBrush(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.Select:
            beginSelect(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.SelectRemove:
            beginSelectRemove(mouseBeatPrecision, mouseKey)
            break
        default:
            break
        }
    }

    // Preview
    function attachPreview(targetRange, targetKey) {
        previewRange = targetRange
        previewKey = targetKey
        previewRectangle.visible = true
    }
    function updatePreview(targetRange, targetKey) {
        previewRange = targetRange
        previewKey = targetKey
    }
    function detachPreview() {
        previewRectangle.visible = false
    }

    // Selection
    function moveSelection(offsetBeatPrecision, offsetKey) {
        var offset = selectionMoveBeatPrecision + offsetBeatPrecision
        var key = selectionMoveKeyOffset + offsetKey
        if (offset < -selectionFirstBeatPrecision)
            return false
        selectionMoveBeatPrecision = offset
        selectionMoveKeyOffset = key
        return true
    }
    function resizeLeftSelection(offsetBeatPrecision) {
        var offset = selectionResizeLeftBeatPrecision + offsetBeatPrecision
        var realMinWidth = selectionMinimumWidthBeatPrecision + selectionResizeRightBeatPrecision
        if (offset >= realMinWidth || offset < -selectionFirstBeatPrecision)
            return false
        selectionResizeLeftBeatPrecision = offset
        return true
    }
    function resizeRightSelection(offsetBeatPrecision) {
        var offset = selectionResizeRightBeatPrecision + offsetBeatPrecision
        var realMinWidth = selectionMinimumWidthBeatPrecision - selectionResizeLeftBeatPrecision
        if (offset <= -realMinWidth)
            return false
        selectionResizeRightBeatPrecision = offset
        return true
    }
    function constructSelectionTargets() {
        var ranges = []
        for (var i = 0; i < selectionList.count; ++i) {
            var item = selectionList.itemAt(i)
            ranges.push(constructTarget(item.realRange, item.key))
        }
        return ranges
    }
    function resetSelection() {
        selectionListModel = null
        selectionMoveKeyOffset = 0
        selectionMinimumWidthBeatPrecision = 0
        selectionFirstBeatPrecision = 0
        selectionMoveBeatPrecision = 0
        selectionResizeLeftBeatPrecision = 0
        selectionResizeRightBeatPrecision = 0
    }

    // Insert
    function beginInsert(mouseBeatPrecision, mouseKey) {
        var placementBeatPrecision = getPlacementBeatPrecision(mouseBeatPrecision)
        attachPreview(
            AudioAPI.beatRange(placementBeatPrecision, placementBeatPrecision + contentView.placementBeatPrecisionLastWidth),
            mouseKey
        )
    }
    function updateInsert(mouseBeatPrecision, mouseKey) {
        var placementBeatPrecision = getPlacementBeatPrecision(mouseBeatPrecision)
        updatePreview(
            AudioAPI.beatRange(placementBeatPrecision, placementBeatPrecision + contentView.placementBeatPrecisionLastWidth),
            mouseKey
        )
    }
    function endInsert(mouseBeatPrecision, mouseKey) {
        addTarget(previewRange, previewKey)
        detachPreview()
    }

    // Move
    function beginMove(mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange) {
        attachPreview(targetBeatRange, mouseKey)
        previewMouseBeatPrecisionOffset = mouseBeatPrecision - targetBeatRange.from
        if (targetIsPartOfSelection) {
            removeTargets(selectionListModel)
        } else
            removeTarget(targetIndex)
    }
    function updateMove(mouseBeatPrecision, mouseKey) {
        var placementBeatPrecision = getPlacementBeatPrecision(mouseBeatPrecision)
        var range = AudioAPI.beatRange(placementBeatPrecision, placementBeatPrecision + contentView.placementBeatPrecisionLastWidth)
        if (targetIsPartOfSelection && !moveSelection(range.from - previewRange.from, mouseKey - previewKey))
            return
        updatePreview(
            range,
            mouseKey
        )
    }
    function endMove(mouseBeatPrecision, mouseKey) {
        if (targetIsPartOfSelection) {
            addTargets(constructSelectionTargets())
        } else
            addTarget(previewRange, previewKey)
        detachPreview()
    }

    // Remove
    function beginRemove(mouseBeatPrecision, mouseKey) {
        var targetIndex = findTarget(mouseBeatPrecision)
        if (targetIndex !== -1)
            removeTarget(targetIndex)
    }
    function updateRemove(mouseBeatPrecision, mouseKey) {
        var targetIndex = findTarget(mouseBeatPrecision)
        if (targetIndex !== -1)
            removeTarget(targetIndex)
    }
    function endRemove(mouseBeatPrecision, mouseKey) {}

    // Resize Left
    function beginResizeLeft(mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange) { beginMove(mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange) }
    function updateResizeLeft(mouseBeatPrecision, mouseKey) {
        var placementBeatPrecision = getResizeLeftBeatPrecision(mouseBeatPrecision)
        var range = AudioAPI.beatRange(previewRange.from, previewRange.to) // Deep copy the preview range
        if (range.from === placementBeatPrecision)
            return
        else if (placementBeatPrecision < range.from)
            range.from += placementBeatPrecision - range.from
        else if (placementBeatPrecision < range.to)
            range.from -= range.from - placementBeatPrecision
        else
            return
        if (targetIsPartOfSelection && !resizeLeftSelection(range.from - previewRange.from))
            return
        updatePreview(range, previewKey)
    }
    function endResizeLeft(mouseBeatPrecision, mouseKey) {
        // Copy resized width
        contentView.placementBeatPrecisionLastWidth = previewRange.to - previewRange.from
        endMove(mouseBeatPrecision, mouseKey)
    }

    // Resize Right
    function beginResizeRight(mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange) { beginMove(mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange) }
    function updateResizeRight(mouseBeatPrecision, mouseKey) {
        var placementBeatPrecision = getResizeRightBeatPrecision(mouseBeatPrecision)
        var range = AudioAPI.beatRange(previewRange.from, previewRange.to) // Deep copy the preview range
        if (range.to === placementBeatPrecision)
            return
        else if (placementBeatPrecision > range.from)
            range.to = placementBeatPrecision
        else
            return
        if (targetIsPartOfSelection && !resizeRightSelection(range.to - previewRange.to))
            return
        updatePreview(range, previewKey)
    }
    function endResizeRight(mouseBeatPrecision, mouseKey) {
        // Copy resized width
        contentView.placementBeatPrecisionLastWidth = previewRange.to - previewRange.from
        endMove(mouseBeatPrecision, mouseKey)
    }

    // Brush
    function beginBrush(mouseBeatPrecision, mouseKey) {
        var placementBeatPrecision = getPlacementBeatPrecision(mouseBeatPrecision)
        var range = AudioAPI.beatRange(placementBeatPrecision, placementBeatPrecision + contentView.placementBeatPrecisionLastWidth)
        addTarget(range, mouseKey)
        brushLastBeatRange = AudioAPI.beatRange(range.from, range.to + contentView.placementBeatPrecisionBrushStep)
    }
    function updateBrush(mouseBeatPrecision, mouseKey) {
        var placementBeatPrecision = getPlacementBeatPrecision(mouseBeatPrecision)
        if (mouseBeatPrecision < brushLastBeatRange.from || mouseBeatPrecision > brushLastBeatRange.to) {
            var range = AudioAPI.beatRange(brushLastBeatRange.to, brushLastBeatRange.to + contentView.placementBeatPrecisionLastWidth)
            if (findOverlapTarget(AudioAPI.beatRange(range.from + 1, range.to - 1), mouseKey) === -1)
                addTarget(range, mouseKey)
            brushLastBeatRange = AudioAPI.beatRange(range.from, range.to + contentView.placementBeatPrecisionBrushStep)
        }
    }
    function endBrush(mouseBeatPrecision, mouseKey) {}

    // Select
    function beginSelect(mouseBeatPrecision, mouseKey) {
        selectionBeatPrecisionFrom = mouseBeatPrecision
        selectionBeatPrecisionTo = mouseBeatPrecision
    }
    function updateSelect(mouseBeatPrecision, mouseKey) {
        selectionBeatPrecisionTo = mouseBeatPrecision
    }
    function endSelect(mouseBeatPrecision, mouseKey) {
        var min = Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
        var max = Math.max(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
        selectionListModel = selectTargets(AudioAPI.beatRange(min, max), 0, 0)
        if (!selectionList.count)
            return
        var firstRange = selectionList.itemAt(0).range
        var firstBeat = firstRange.from
        var minimumWidth = firstRange.to - firstRange.from
        for (var i = 1; i < selectionList.count; ++i) {
            var range = selectionList.itemAt(i).range
            minimumWidth = Math.min(minimumWidth, range.to - range.from)
        }
        selectionMinimumWidthBeatPrecision = minimumWidth
        selectionFirstBeatPrecision = firstBeat
    }

    // Select Remove
    function beginSelectRemove(mouseBeatPrecision, mouseKey) { beginSelect(mouseBeatPrecision, mouseKey) }
    function updateSelectRemove(mouseBeatPrecision, mouseKey) { updateSelect(mouseBeatPrecision, mouseKey) }
    function endSelectRemove(mouseBeatPrecision, mouseKey) {
        var min = Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
        var max = Math.max(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
        var selection = selectTargets(AudioAPI.beatRange(min, max), 0, 0)
        removeTargets(selection)
    }

    signal copyTarget(int targetIndex)

    // General
    property int mode: PlacementArea.Mode.None

    // Preview
    property var previewRange: AudioAPI.beatRange(0, 0)
    property int previewKey: 0
    property int previewMouseBeatPrecisionOffset: 0
    property alias previewRectangle: previewRectangle

    // Brush
    property var brushLastBeatRange: AudioAPI.beatRange(0, 0)

    // Selection overlay
    property int selectionBeatPrecisionFrom: 0
    property int selectionBeatPrecisionTo: 0

    // Selection
    property var selectionListModel: null
    property bool targetIsPartOfSelection: false
    property int selectionMinimumWidthBeatPrecision: 0
    property int selectionFirstBeatPrecision: 0

    // Selection - Move
    property int selectionMoveBeatPrecision: 0
    property int selectionMoveKeyOffset: 0

    // Selection - Resize
    property int selectionResizeLeftBeatPrecision: 0
    property int selectionResizeRightBeatPrecision: 0

    id: placementArea
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPressed: {
        var mouseBeatPrecision = getMouseBeatPrecision()
        var mouseKey = 0
        var isSelection = mouse.modifiers & (Qt.ControlModifier | Qt.ShiftModifier) || contentView.editMode === ContentView.EditMode.Select
        var isRemove = mouse.buttons & Qt.RightButton

        if (mode !== PlacementArea.Mode.None) {
            console.log("PlacementArea: An action is still not completed")
            return
        }

        targetIsPartOfSelection = false
        previewMouseBeatPrecisionOffset = 0
        brushLastBeatRange = AudioAPI.beatRange(0, 0)
        // Selection
        if (isSelection) {
            resetSelection()
            if (isRemove)
                changeMode(PlacementArea.Mode.SelectRemove, mouseBeatPrecision, mouseKey)
            else
                changeMode(PlacementArea.Mode.Select, mouseBeatPrecision, mouseKey)
        // Remove
        } else if (isRemove) {
            resetSelection()
            changeMode(PlacementArea.Mode.Remove, mouseBeatPrecision, mouseKey)
        // Insert, Move, Brush or Resize
        } else {
            var targetIndex = findTarget(mouseBeatPrecision)
            // Insert or Brush
            if (targetIndex === -1) {
                // Discard the selection
                if (selectionListModel) {
                    resetSelection()
                    return
                }
                // If we don't have a copied beat precision we use default one
                if (contentView.placementBeatPrecisionLastWidth === 0)
                    contentView.placementBeatPrecisionLastWidth = contentView.placementBeatPrecisionDefaultWidth
                // Brush
                if (contentView.editMode === ContentView.EditMode.Brush)
                    changeMode(PlacementArea.Mode.Brush, mouseBeatPrecision, mouseKey)
                // Insert
                else
                    changeMode(PlacementArea.Mode.Insert, mouseBeatPrecision, mouseKey)
            // Move or Resize
            } else {
                targetIsPartOfSelection = selectionListModel ? selectionListModel.indexOf(targetIndex) !== -1 : false
                // If the target is not part of selection, we discard the selection
                if (!targetIsPartOfSelection)
                    resetSelection()
                var targetBeatRange = getTargetBeatRange(targetIndex)
                var noteWidthBeatPrecision = (targetBeatRange.to - targetBeatRange.from)
                var noteWidth = noteWidthBeatPrecision * contentView.pixelsPerBeatPrecision
                var resizeThreshold = Math.min(noteWidth * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
                // Copy target width
                contentView.placementBeatPrecisionLastWidth = targetBeatRange.to - targetBeatRange.from        // Copy target width
                // Emit the copy signal
                copyTarget(targetIndex)
                // Detect left resize
                if ((mouseBeatPrecision - targetBeatRange.from) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                    changeMode(PlacementArea.ResizeLeft, mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange)
                // Detect right resize
                else if ((targetBeatRange.to - mouseBeatPrecision) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                    changeMode(PlacementArea.ResizeRight, mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange)
                // Move
                else
                    changeMode(PlacementArea.Mode.Move, mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange)
            }
        }
    }

    onPositionChanged: {
        var mouseBeatPrecision = getMouseBeatPrecision()
        var mouseKey = 0

        switch (mode) {
        case PlacementArea.Mode.Insert:
            updateInsert(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.Move:
            updateMove(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.Remove:
            updateRemove(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.ResizeLeft:
            updateResizeLeft(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.ResizeRight:
            updateResizeRight(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.Brush:
            updateBrush(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.Select:
            updateSelect(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.SelectRemove:
            updateSelectRemove(mouseBeatPrecision, mouseKey)
            break
        default:
            break
        }
    }

    onReleased: {
        var mouseBeatPrecision = getMouseBeatPrecision()
        var mouseKey = 0

        switch (mode) {
        case PlacementArea.Mode.Insert:
            endInsert(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.Move:
            endMove(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.Remove:
            endRemove(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.ResizeLeft:
            endResizeLeft(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.ResizeRight:
            endResizeRight(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.Brush:
            endBrush(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.Select:
            endSelect(mouseBeatPrecision, mouseKey)
            break
        case PlacementArea.Mode.SelectRemove:
            endSelectRemove(mouseBeatPrecision, mouseKey)
            break
        default:
            break
        }
        mode = PlacementArea.Mode.None
    }

    Rectangle {
        id: selectionOverlay
        visible: mode === PlacementArea.Mode.Select || mode === PlacementArea.Mode.SelectRemove
        x: contentView.xOffset + Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo) * contentView.pixelsPerBeatPrecision
        width: Math.abs(selectionBeatPrecisionTo - selectionBeatPrecisionFrom) * contentView.pixelsPerBeatPrecision
        height: contentView.rowHeight
        color: "grey"
        opacity: 0.5
        border.color: "white"
        border.width: 1
    }

    Rectangle {
        id: previewRectangle
        x: contentView.xOffset + previewRange.from * contentView.pixelsPerBeatPrecision
        width: (previewRange.to - previewRange.from) * contentView.pixelsPerBeatPrecision
        height: contentView.rowHeight
        visible: false
        color: nodeDelegate.color
        border.color: nodeDelegate.accentColor
        border.width: 2
    }

    Rectangle {
        x: contentView.xOffset + brushLastBeatRange.from * contentView.pixelsPerBeatPrecision
        width: (brushLastBeatRange.to - brushLastBeatRange.from) * contentView.pixelsPerBeatPrecision
        height: contentView.rowHeight
        // visible: previewRectangle.visible && contentView.editMode === ContentView.EditMode.Brush
        color: "transparent"
        border.color: nodeDelegate.accentColor
        border.width: 2
    }

    Repeater {
        id: selectionList
        model: selectionListModel

        delegate: Rectangle {
            property var range: getTargetBeatRange(modelData)
            property int key: getTargetKey(modelData)
            property var realRange: {
                return AudioAPI.beatRange(
                    range.from + placementArea.selectionResizeLeftBeatPrecision + placementArea.selectionMoveBeatPrecision,
                    range.to + placementArea.selectionResizeRightBeatPrecision + placementArea.selectionMoveBeatPrecision
                )
            }

            x: contentView.xOffset + realRange.from * contentView.pixelsPerBeatPrecision
            width: (realRange.to - realRange.from) * contentView.pixelsPerBeatPrecision
            height: contentView.rowHeight
            color: "white"
            opacity: 0.5
        }
    }
}