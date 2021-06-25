import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Repeater {
    property real linkBottom: 0

    id: nodeChildren

    model: nodeDelegate.showChildren ? nodeDelegate.node : null

    onCountChanged: {
        if (!count)
            linkBottom = Qt.binding(function() { return 0 })
    }

    delegate: Loader {
        source: "qrc:/Planner/PlannerNodeDelegate.qml"

        onLoaded: {
            item.parentDelegate = nodeDelegate
            if (index === nodeChildren.count - 1)
                nodeChildren.linkBottom = Qt.binding(function () {
                    return y + item.nodeHeaderBackground.y + item.nodeHeaderBackground.height / 2
                })
        }
    }
}