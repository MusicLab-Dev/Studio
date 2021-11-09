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
    }

    Item {
        id: plannerButton
        anchors.left: pluginButton.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7

        Rectangle {
            id: rectPlannerButton
            anchors.fill: parent
            radius: 6
            color: sequencerView.node && mousePlannerButton.containsMouse ? sequencerView.node.color : themeManager.contentColor

            MouseArea {
                id: mousePlannerButton
                anchors.fill: parent
                hoverEnabled: true

                onPressed: {
                    modulesView.addNewPlanner(sequencerView.node)
                }

                onHoveredChanged: {
                    if (containsMouse)
                        cursorManager.set(CursorManager.Type.Clickable)
                    else
                        cursorManager.set(CursorManager.Type.Normal)
                }
            }

            DefaultColoredImage {
                anchors.fill: parent
                anchors.margins: parent.width * 0.25
                source: "qrc:/Assets/Chrono.png"
                color: mousePlannerButton.containsMouse ? themeManager.contentColor : sequencerView.node ? sequencerView.node.color : "black"
            }
        }
    }

    Item {
        id: importFile
        anchors.left: plannerButton.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7

        FileDialog {
            id: fileDialogImport
            title: "Please choose a file"
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

        Rectangle {
            id: rectImportFile
            anchors.fill: parent
            radius: 6
            color: sequencerView.node && mouseImportFile.containsMouse ? sequencerView.node.color : themeManager.contentColor

            MouseArea {
                id: mouseImportFile
                anchors.fill: parent
                hoverEnabled: true

                onPressed: {
                    fileDialogImport.visible = true
                }

                onHoveredChanged: {
                    if (containsMouse)
                        cursorManager.set(CursorManager.Type.Clickable)
                    else
                        cursorManager.set(CursorManager.Type.Normal)
                }
            }

            DefaultColoredImage {
                anchors.fill: parent
                anchors.margins: parent.width * 0.25
                source: "qrc:/Assets/Import.png"
                color: mouseImportFile.containsMouse ? themeManager.contentColor : sequencerView.node ? sequencerView.node.color : "black"
            }
        }
    }

    Item {
        id: exportFile
        anchors.left: importFile.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7

        FileDialog {
            id: fileDialogExport
            selectExisting: false
            title: "Export your partition"
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

        Rectangle {
            id: rectExportFile
            anchors.fill: parent
            radius: 6
            color: sequencerView.node && mouseExportFile.containsMouse ? sequencerView.node.color : themeManager.contentColor

            MouseArea {
                id: mouseExportFile
                anchors.fill: parent
                hoverEnabled: true

                onPressed: {
                    fileDialogExport.visible = true
                }

                onHoveredChanged: {
                    if (containsMouse)
                        cursorManager.set(CursorManager.Type.Clickable)
                    else
                        cursorManager.set(CursorManager.Type.Normal)
                }
            }

            DefaultColoredImage {
                anchors.fill: parent
                anchors.margins: parent.width * 0.25
                source: "qrc:/Assets/Export.png"
                color: mouseExportFile.containsMouse ? themeManager.contentColor : sequencerView.node ? sequencerView.node.color : "black"
            }
        }
    }

    /*ClipboardIndicator {
        anchors.bottom: parent.bottom
        anchors.left: soundMeter.right
        anchors.top: parent.top
        anchors.leftMargin: parent.width * 0.01
        width: parent.width * 0.1
    }*/
}
