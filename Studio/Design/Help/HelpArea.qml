import QtQuick 2.15

Item {
    function initHelpArea() {
        if (index !== -1)
            destroyHelpArea()
        index = helpHandler.helpAreas.count
        var rect = helpHandler.mapFromItem(helpArea, x, y, width, height)
        helpHandler.helpAreas.append({
            areaX: rect.x,
            areaY: rect.y,
            areaWidth: rect.width,
            areaHeight: rect.height,
            areaName: name,
            areaDescription: description,
            areaPosition: position,
            areaExternalDisplay: externalDisplay,
            areaSpacing: spacing
        })
    }

    function updateHelpArea() {
        if (index !== -1) {
            var rect = helpHandler.mapFromItem(helpArea, x, y, width, height)
            helpHandler.helpAreas.set(index, {
                areaX: rect.x,
                areaY: rect.y,
                areaWidth: rect.width,
                areaHeight: rect.height,
                areaName: name,
                areaDescription: description,
                areaPosition: position,
                areaExternalDisplay: externalDisplay,
                areaSpacing: spacing
            })
        }
    }

    function destroyHelpArea() {
        if (index !== -1) {
            helpHandler.helpAreas.remove(index)
            helpHandler.helpAreaRemoved(index)
            index = -1
        }
    }

    property string name: ""
    property string description: ""
    property int index: -1
    property int position: HelpHandler.Position.Center
    property bool externalDisplay: false
    property int spacing: 10

    id: helpArea
    anchors.fill: parent

    Component.onCompleted: {
        if (visible)
           initHelpArea()
    }

    onVisibleChanged: {
        if (visible)
            initHelpArea()
        else
            destroyHelpArea()
    }

    onWidthChanged: updateHelpArea()
    onHeightChanged: updateHelpArea()
    onXChanged: updateHelpArea()
    onYChanged: updateHelpArea()
    onNameChanged: updateHelpArea()

    Connections {
        target: parent

        function onXChanged() { updateHelpArea() }
        function onYChanged() { updateHelpArea() }
    }

    Connections {
        target: helpHandler
        enabled: index !== -1

        function onHelpAreaRemoved(removedIndex) {
            if (index > removedIndex)
                index = index - 1
        }
    }
}