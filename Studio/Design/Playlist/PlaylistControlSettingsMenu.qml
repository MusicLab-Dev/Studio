import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0
import ControlModel 1.0

import "../Default"

DefaultMenu {
    property var rootParent: null
    property var targetItem: null
    property NodeModel targetNode: null
    property ControlModel targetControl: null
    property int targetControlIndex: 0

    function openMenu(newParent, node, control, controlIndex) {
        targetItem = newParent
        targetNode = node
        targetControl = control
        targetControlIndex = controlIndex
        open()
    }

    function closeMenu() {
        targetItem = null
        targetNode = null
        targetControl = null
        targetControlIndex = 0
        close()
    }

    Component.onCompleted: rootParent = parent

    onTargetItemChanged: {
        if (targetItem)
            parent = targetItem
        else
            parent = rootParent
    }

    id: controlAddMenu

    Action {
        text: qsTr("Add automation")

        onTriggered: {
            targetControl.add()
            closeMenu()
        }
    }

    Action {
        text: qsTr("Remove")

        onTriggered: {
            targetNode.controls.remove(targetControlIndex)
            closeMenu()
        }
    }
}