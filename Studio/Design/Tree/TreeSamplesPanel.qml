import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import PluginTableModel 1.0

import "../Default"

TreePanel {

    enum Type {
        Samples,
        Void
    }

    Item {
        id: panelCategory
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: panelCategoryWidth
        height: parent.height

        TreeComponentCategory {
            y: parent.height - height
            text.text: qsTr("Samples")
            filter: TreeSamplesPanel.Type.Samples
        }
    }

    Item {
        property real widthOffset: 50

        id: panelContent
        anchors.left: panelCategory.right
        anchors.top: parent.top
        width: panelContentWidth
        height: parent.height

        Rectangle {
            id: panelContentBackground
            width: parent.width + panelContent.widthOffset
            height: parent.height
            color: Qt.darker(themeManager.contentColor, 1.1)
        }

        MouseArea {
            anchors.fill: parent
            onPressedChanged: forceActiveFocus()
            onWheel: {} // Steal wheel events
        }

        ListView {
            id: treeComponentsListView
            anchors.centerIn: parent
            width: parent.width
            height: parent.height * 0.95
            clip: true
            spacing: 20
            model: PluginTableModelProxy {

            }

            delegate: Item {

            }
        }
    }

}
