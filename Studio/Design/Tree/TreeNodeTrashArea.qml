import QtQuick 2.15

import "../Default"

DefaultColoredImage {
    property bool containsDrag: false

    id: trashArea
    source: "qrc:/Assets/Trash.png"
    color: containsDrag ? Qt.darker("red", 1.3) : "red"

    Connections {
        enabled: treeSurface.dragActive
        target: treeSurface

        function onDragPointChanged() {
            trashArea.containsDrag = treeSurface.dragTarget && trashArea.contains(trashArea.mapFromItem(treeSurface, treeSurface.dragPoint))
        }

        function onTargetDropped() {
            if (trashArea.containsDrag) {
                trashArea.containsDrag = false
                var node = treeSurface.dragTarget
                if (node.parentNode) {
                    modulesView.onNodeDeleted(node)
                    node.parentNode.remove(node.parentNode.getChildIndex(node))
                }
            }
        }
    }
}
