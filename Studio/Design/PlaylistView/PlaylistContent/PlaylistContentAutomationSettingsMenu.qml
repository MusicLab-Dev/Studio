import QtQuick 2.15
import QtQuick.Controls 2.15

import ControlModel 1.0
import AutomationModel 1.0

import "../../Default"

DefaultMenu {
    property var rootParent: null
    property var targetItem: null
    property ControlModel targetControl: null
    property AutomationModel targetAutomation: null
    property int targetAutomationIndex: 0

    function openMenu(newParent, control, automation, automationIndex) {
        targetItem = newParent
        targetControl = control
        targetAutomation = automation
        targetAutomationIndex = automationIndex
        open()
    }

    function closeMenu() {
        targetItem = null
        targetControl = null
        targetAutomation = null
        targetAutomationIndex = 0
        close()
    }

    Component.onCompleted: rootParent = parent

    onTargetItemChanged: {
        if (targetItem)
            parent = targetItem
        else
            parent = rootParent
    }

    id: automationAddMenu

    Action {
        text: qsTr("Remove")

        onTriggered: {
            targetControl.remove(targetAutomationIndex)
            closeMenu()
        }
    }
}