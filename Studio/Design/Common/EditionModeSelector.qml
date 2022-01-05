import QtQuick 2.15

ModeSelector {
    id: editModeSelector
    itemsPaths: [
        "qrc:/Assets/NormalMod.png",
        "qrc:/Assets/BrushMod.png",
        "qrc:/Assets/SelectorMod.png",
        "qrc:/Assets/CutMod.png",
    ]
    itemsNames: [
        "Standard",
        "Brush",
        "Selector",
        "CutMod",
    ]
    itemUsableTill: 2

    placeholder: Snapper {
        id: brushSnapper
        height: editModeSelector.height - editModeSelector.rowContainer.height
        width: editModeSelector.width
        visible: contentView.editMode === ContentView.EditMode.Brush
        currentIndex: 0
        rectBackground.border.width: 0
        rectBackground.color: "transparent"

        onActivated: contentView.placementBeatPrecisionBrushStep = currentValue
    }

    onItemSelectedChanged: contentView.editMode = itemSelected
}
