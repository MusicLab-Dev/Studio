import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Repeater {
    id: nodeChildren

    model: nodeDelegate.showChildren ? nodeDelegate.node : null

    delegate: Loader {
        source: "qrc:/Planner/PlannerNodeDelegate.qml"

        onLoaded: {
            item.parentDelegate = nodeDelegate
        }
    }
}