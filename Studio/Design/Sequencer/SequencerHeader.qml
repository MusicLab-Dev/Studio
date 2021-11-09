import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.0

import "../Default/"
import "../Common/"

import PluginModel 1.0
import CursorManager 1.0
import ThemeManager 1.0
import ClipboardManager 1.0

Rectangle {
    property color hoveredColor: sequencerView.node ? Qt.darker(sequencerView.node.color, 1.8) : "black"
    property color pressedColor: sequencerView.node ? Qt.darker(sequencerView.node.color, 2.2) : "black"
    property color accentColor: sequencerView.node ? Qt.darker(sequencerView.node.color, 1.6) : "black"

    color: themeManager.backgroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    SequencerEdition {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        height: parent.height * 0.75
        width: parent.width * 0.4
    }

    Item {
        id: pluginButton
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.1
        height: parent.height * 0.7

        Rectangle {
            id: rectPluginButton
            anchors.fill: parent
            radius: 6
            color: sequencerView.node && (mousePluginButton.containsMouse || !sequencerControls.hide) ? sequencerView.node.color : themeManager.contentColor
            border.color: mousePluginButton.containsPress ? pressedColor : hoveredColor
            border.width: mousePluginButton.containsMouse && !sequencerControls.hide ? 2 : 0

            MouseArea {
                id: mousePluginButton
                hoverEnabled: true
                anchors.fill: parent

                onPressed: sequencerControls.hide = !sequencerControls.hide

                onHoveredChanged: {
                    if (containsMouse)
                        cursorManager.set(CursorManager.Type.Clickable)
                    else
                        cursorManager.set(CursorManager.Type.Normal)
                }
            }

            DefaultText {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignLeft
                fontSizeMode: Text.HorizontalFit
                font.pointSize: 20
                color: (mousePluginButton.containsMouse || !sequencerControls.hide) ? themeManager.contentColor : sequencerView.node.color
                text: sequencerView.node ? sequencerView.node.name : qsTr("ERROR")
                wrapMode: Text.Wrap
            }
        }

        DefaultToolTip {
            visible: mousePluginButton.containsMouse
            text: sequencerControls.hide ? qsTr("Open controls") : qsTr("Close controls")
        }
    }

    SequencerHeaderButton {
        id: plannerButton
        anchors.left: pluginButton.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7
        iconSource: "qrc:/Assets/Chrono.png"
        toolTipText: qsTr("Move to planner")

        mouseArea.onPressed: {
            modulesView.addNewPlanner(sequencerView.node)
        }
    }

    SequencerHeaderButton {
        id: importFile
        anchors.left: plannerButton.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7
        iconSource: "qrc:/Assets/Import.png"
        toolTipText: qsTr("Import a partition file")

        mouseArea.onPressed: {
            fileDialogImport.visible = true
        }

        FileDialog {
            id: fileDialogImport
            title: qsTr("Please choose a file")
            folder: shortcuts.home
            visible: false

            onAccepted: {
                var path = fileDialogImport.fileUrl.toString();
                path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"");
                partition.importPartition(path)
                visible = false
            }

            onRejected: {
                visible = false
            }
        }
    }

    SequencerHeaderButton {
        id: exportFile
        anchors.left: importFile.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7
        iconSource: "qrc:/Assets/Export.png"
        toolTipText: qsTr("Export this partition file")

        mouseArea.onPressed: {
            fileDialogExport.visible = true
        }

        FileDialog {
            id: fileDialogExport
            selectExisting: false
            title: qsTr("Export your partition")
            folder: shortcuts.home
            visible: false

            onAccepted: {
                var path = fileDialogExport.fileUrl.toString();
                path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"");
                partition.exportPartition(path)
                visible = false
            }
            onRejected: {
                visible = false
            }
        }
    }
}
