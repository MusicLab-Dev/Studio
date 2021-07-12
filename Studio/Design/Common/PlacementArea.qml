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

    // Implementer must call this function whener the selection could be refreshed
    function retreiveInsertedSelection() {
        if (!selectionInsertCache)
            return
        resetSelection()
        var list = []
        for (var i = 0; i < selectionInsertCache.length; ++i) {
            var index = findExactTarget(selectionInsertCache[i])
            if (index !== -1)
                list.push(index)
            else
                console.log("PlacementArea: Couldn't retreive inserted target")
        }
        selectionListModel = list
        selectionInsertCache = null
        refreshSelectionCache()
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
        if (contentView.placementBeatPrecisionScale !== 0)
            scopedBeatPrecision = scopedBeatPrecision - (scopedBeatPrecision % contentView.placementBeatPrecisionScale) + (previewRange.to % contentView.placementBeatPrecisionScale)
        if (previewRange.to <= scopedBeatPrecision)
            scopedBeatPrecision = previewRange.to - contentView.placementBeatPrecisionScale
        return Math.max(scopedBeatPrecision, 0)
    }
    function getResizeRightBeatPrecision(mouseBeatPrecision) {
        var scopedBeatPrecision = mouseBeatPrecision
        if (contentView.placementBeatPrecisionScale !== 0)
            scopedBeatPrecision = scopedBeatPrecision + (contentView.placementBeatPrecisionScale - (scopedBeatPrecision % contentView.placementBeatPrecisionScale)) + (previewRange.from % contentView.placementBeatPrecisionScale)
        if (previewRange.from >= scopedBeatPrecision)
            scopedBeatPrecision = previewRange.from + contentView.placementBeatPrecisionScale
        return Math.max(scopedBeatPrecision, 0)
    }

    // Mouse to key
    function getMouseKey() {
        return keyOffset + Math.max(Math.min(Math.floor((height - mouseY) / contentView.rowHeight), keyCount - 1), 0)
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
        attachTargetPreview()
    }
    function updatePreview(targetRange, targetKey) {
        var offsetBeatPrecision = targetRange.from - previewRange.from
        var offsetKey = targetKey - previewKey
        previewRange = targetRange
        previewKey = targetKey
        moveTargetPreview(offsetBeatPrecision, offsetKey)
    }
    function detachPreview() {
        detachTargetPreview()
        previewRectangle.visible = false
    }

    // Selection
    function moveSelectionBeat(offsetBeatPrecision) {
        // Compute beat offset
        if (selectionMinBeatPrecision + offsetBeatPrecision < 0)
            offsetBeatPrecision = -selectionMinBeatPrecision
        selectionMinBeatPrecision += offsetBeatPrecision
        selectionMoveBeatPrecision = selectionMoveBeatPrecision + offsetBeatPrecision
        return offsetBeatPrecision
    }
    function moveSelectionKey(offsetKey) {
        // Compute key offset
        if (selectionMinKey + offsetKey < keyOffset)
            offsetKey = keyOffset - selectionMinKey
        else if (selectionMaxKey + offsetKey >= keyOffset + keyCount)
            offsetKey = keyOffset + keyCount - selectionMaxKey - 1
        selectionMinKey += offsetKey
        selectionMaxKey += offsetKey
        selectionMoveKeyOffset = selectionMoveKeyOffset + offsetKey
        return offsetKey
    }
    function resizeLeftSelection(offsetBeatPrecision) {
        var offset = selectionResizeLeftBeatPrecision + offsetBeatPrecision
        var realMinWidth = selectionMinWidthBeatPrecision + selectionResizeRightBeatPrecision
        if (offset >= realMinWidth || selectionMinBeatPrecision + offsetBeatPrecision < 0)
            return false
        selectionMinBeatPrecision += offsetBeatPrecision
        selectionResizeLeftBeatPrecision = offset
        return true
    }
    function resizeRightSelection(offsetBeatPrecision) {
        var offset = selectionResizeRightBeatPrecision + offsetBeatPrecision
        var realMinWidth = selectionMinWidthBeatPrecision - selectionResizeLeftBeatPrecision
        if (offset <= -realMinWidth)
            return false
        selectionResizeRightBeatPrecision = offset
        return true
    }
    function constructSelectionTargets() {
        var ranges = []
        for (var i = 0; i < selectionList.count; ++i) {
            var item = selectionList.itemAt(i)
            ranges.push(constructTarget(item.realRange, item.realKey))
        }
        return ranges
    }
    function resetSelection() {
        selectionListModel = null
        selectionMoveKeyOffset = 0
        selectionMinWidthBeatPrecision = 0
        selectionMinBeatPrecision = 0
        selectionMinKey = 0
        selectionMaxKey = 0
        selectionMoveBeatPrecision = 0
        selectionMoveKeyOffset = 0
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
        var offsetBeatPrecision = placementBeatPrecision - previewRange.from
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
        var beatMoved = placementBeatPrecision !== previewRange.from
        var keyMoved = mouseKey !== previewKey
        if (!beatMoved && !keyMoved)
            return
        else if (targetIsPartOfSelection) {
            // Compute both beat & key selection move
            var offsetBeatPrecision = beatMoved ? moveSelectionBeat(placementBeatPrecision - previewRange.from) : 0
            var offsetKey = keyMoved ? moveSelectionKey(mouseKey - previewKey) : 0
            updatePreview(
                AudioAPI.beatRange(previewRange.from + offsetBeatPrecision, previewRange.to + offsetBeatPrecision),
                previewKey + offsetKey
            )
        } else {
            updatePreview(
                AudioAPI.beatRange(placementBeatPrecision, placementBeatPrecision + contentView.placementBeatPrecisionLastWidth),
                mouseKey
            )
        }
    }
    function endMove(mouseBeatPrecision, mouseKey) {
        if (targetIsPartOfSelection) {
            selectionInsertCache = constructSelectionTargets()
            addTargets(selectionInsertCache)
        } else
            addTarget(previewRange, previewKey)
        detachPreview()
    }

    // Remove
    function beginRemove(mouseBeatPrecision, mouseKey) {
        var targetIndex = findTarget(mouseBeatPrecision, mouseKey)
        if (targetIndex !== -1)
            removeTarget(targetIndex)
    }
    function updateRemove(mouseBeatPrecision, mouseKey) {
        var targetIndex = findTarget(mouseBeatPrecision, mouseKey)
        if (targetIndex !== -1)
            removeTarget(targetIndex)
    }
    function endRemove(mouseBeatPrecision, mouseKey) {}

    // Resize Left
    function beginResizeLeft(mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange) { beginMove(mouseBeatPrecision, mouseKey, targetIndex, targetBeatRange) }
    function updateResizeLeft(mouseBeatPrecision, mouseKey) {
        var placementBeatPrecision = getResizeLeftBeatPrecision(mouseBeatPrecision)
        if (previewRange.from === placementBeatPrecision ||
                (targetIsPartOfSelection && !resizeLeftSelection(placementBeatPrecision - previewRange.from)))
            return
        updatePreview(AudioAPI.beatRange(placementBeatPrecision, previewRange.to), previewKey)
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
        if (previewRange.to === placementBeatPrecision ||
                (targetIsPartOfSelection && !resizeRightSelection(placementBeatPrecision - previewRange.to)))
            return
        updatePreview(AudioAPI.beatRange(previewRange.from, placementBeatPrecision), previewKey)
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
        selectionKeyFrom = mouseKey
        selectionKeyTo = mouseKey
    }
    function updateSelect(mouseBeatPrecision, mouseKey) {
        selectionBeatPrecisionTo = mouseBeatPrecision
        selectionKeyTo = mouseKey
    }
    function endSelect(mouseBeatPrecision, mouseKey) {
        var min = Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
        var max = Math.max(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
        var minKey = Math.min(selectionKeyFrom, selectionKeyTo)
        var maxKey = Math.max(selectionKeyFrom, selectionKeyTo)
        selectionListModel = selectTargets(AudioAPI.beatRange(min, max), minKey, maxKey)
        refreshSelectionCache()
    }

    function refreshSelectionCache() {
        if (!selectionList.count)
            return
        var firstItem = selectionList.itemAt(0)
        var firstRange = firstItem.range
        var firstBeat = firstRange.from
        var minWidth = firstRange.to - firstRange.from
        var minKey = firstItem.key
        var maxKey = firstItem.key
        for (var i = 1; i < selectionList.count; ++i) {
            var item = selectionList.itemAt(i)
            var range = item.realRange
            var key = item.realKey
            minWidth = Math.min(minWidth, range.to - range.from)
            minKey = Math.min(minKey, key)
            maxKey = Math.max(maxKey, key)
        }
        selectionMinWidthBeatPrecision = minWidth
        selectionMinBeatPrecision = firstBeat
        selectionMinKey = minKey
        selectionMaxKey = maxKey
    }

    // Select Remove
    function beginSelectRemove(mouseBeatPrecision, mouseKey) { beginSelect(mouseBeatPrecision, mouseKey) }
    function updateSelectRemove(mouseBeatPrecision, mouseKey) { updateSelect(mouseBeatPrecision, mouseKey) }
    function endSelectRemove(mouseBeatPrecision, mouseKey) {
        var min = Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
        var max = Math.max(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
        var minKey = Math.min(selectionKeyFrom, selectionKeyTo)
        var maxKey = Math.max(selectionKeyFrom, selectionKeyTo)
        var selection = selectTargets(AudioAPI.beatRange(min, max), minKey, maxKey)
        removeTargets(selection)
    }

    signal copyTarget(int targetIndex)
    signal attachTargetPreview()
    signal moveTargetPreview(int offsetBeatPrecision, int offsetKey)
    signal detachTargetPreview()

    // General
    property int mode: PlacementArea.Mode.None
    property int keyOffset: 0
    property int keyCount: 1

    // Preview
    property var previewRange: AudioAPI.beatRange(0, 0)
    property int previewKey: 0
    property real previewMouseBeatPrecisionOffset: 0
    property alias previewRectangle: previewRectangle

    // Brush
    property var brushLastBeatRange: AudioAPI.beatRange(0, 0)

    // Selection overlay
    property int selectionBeatPrecisionFrom: 0
    property int selectionBeatPrecisionTo: 0
    property int selectionKeyFrom: 0
    property int selectionKeyTo: 0

    // Selection
    property var selectionListModel: null
    property var selectionInsertCache: null
    property bool targetIsPartOfSelection: false
    property int selectionMinWidthBeatPrecision: 0
    property int selectionMinBeatPrecision: 0
    property int selectionMinKey: 0
    property int selectionMaxKey: 0

    // Selection - Move
    property int selectionMoveBeatPrecision: 0
    property int selectionMoveKeyOffset: 0

    // Selection - Resize
    property int selectionResizeLeftBeatPrecision: 0
    property int selectionResizeRightBeatPrecision: 0

    property color color: "red"
    property color accentColor: "yellow"

    id: placementArea
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPressed: {
        var mouseBeatPrecision = getMouseBeatPrecision()
        var mouseKey = getMouseKey()
        var isSelection = mouse.modifiers & (Qt.ControlModifier | Qt.ShiftModifier) || contentView.editMode === ContentView.EditMode.Select
        var isRemove = mouse.button === Qt.RightButton

        if (mode !== PlacementArea.Mode.None) {
            console.log("PlacementArea: An action is still not completed")
            return
        }

        previewMouseBeatPrecisionOffset = 0
        targetIsPartOfSelection = false
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
            var targetIndex = findTarget(mouseBeatPrecision, mouseKey)
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
                // Emit the copy signal
                copyTarget(targetIndex)
                // Copy target width
                contentView.placementBeatPrecisionLastWidth = targetBeatRange.to - targetBeatRange.from        // Copy target width
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
        var mouseKey = getMouseKey()

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
        var mouseKey = getMouseKey()

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
        y: parent.height - (Math.max(selectionKeyFrom, selectionKeyTo) - keyOffset + 1) * contentView.rowHeight
        width: Math.abs(selectionBeatPrecisionTo - selectionBeatPrecisionFrom) * contentView.pixelsPerBeatPrecision
        height: (Math.abs(selectionKeyTo - selectionKeyFrom) + 1) * contentView.rowHeight
        color: "grey"
        opacity: 0.5
        border.color: "white"
        border.width: 1
    }

    Rectangle {
        id: previewRectangle
        x: contentView.xOffset + previewRange.from * contentView.pixelsPerBeatPrecision
        y: (keyCount - 1 - (previewKey - keyOffset)) * rowHeight
        width: (previewRange.to - previewRange.from) * contentView.pixelsPerBeatPrecision
        height: contentView.rowHeight
        visible: false
        color: placementArea.color
        border.color: placementArea.accentColor
        border.width: 2
    }

    Rectangle {
        x: contentView.xOffset + brushLastBeatRange.from * contentView.pixelsPerBeatPrecision
        width: (brushLastBeatRange.to - brushLastBeatRange.from) * contentView.pixelsPerBeatPrecision
        height: contentView.rowHeight
        // visible: previewRectangle.visible && contentView.editMode === ContentView.EditMode.Brush
        color: "transparent"
        border.color: placementArea.accentColor
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
            property int realKey: key + selectionMoveKeyOffset

            x: contentView.xOffset + realRange.from * contentView.pixelsPerBeatPrecision
            y: (keyCount - 1 - (realKey - keyOffset)) * rowHeight
            width: (realRange.to - realRange.from) * contentView.pixelsPerBeatPrecision
            height: contentView.rowHeight
            color: "white"
            opacity: 0.5
        }
    }
}