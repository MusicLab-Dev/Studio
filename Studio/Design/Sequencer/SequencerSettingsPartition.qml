import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

import "../Common"
import "../Default"

ColumnLayout {
    id: partitionComboBox

    RowLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true
        spacing: 5

        DefaultImageButton {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            foregroundColor: themeManager.contentColor
            colorHovered: sequencerView.node ? sequencerView.node.color : themeManager.accentColor
            source: "qrc:/Assets/Plus.png"

            onClicked: {
                sequencerView.player.stop()
                if (sequencerView.node.partitions.add()) {
                    sequencerView.changePartition(sequencerView.node.partitions.count() - 1)
                }
            }

            DefaultToolTip {
                text: "Add"
                visible: parent.hovered
            }
        }

        DefaultImageButton {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            foregroundColor: themeManager.contentColor
            colorHovered: sequencerView.node ? sequencerView.node.color : themeManager.accentColor
            source: "qrc:/Assets/Minus.png"

            onClicked: {
                sequencerView.player.stop()
                if (sequencerView.node.partitions.remove(partitionIndex)) {
                    if (sequencerView.node.partitions.count() <= 0)
                        modulesView.removeModule(moduleIndex)
                    else
                        sequencerView.changePartition(partitionIndex - 1)
                }
            }

            DefaultToolTip {
                text: "Delete"
                visible: parent.hovered
            }
        }

        DefaultImageButton {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            foregroundColor: themeManager.contentColor
            colorHovered: sequencerView.node ? sequencerView.node.color : themeManager.accentColor
            source: "qrc:/Assets/EditMod.png"

            onClicked: globalTextField.open(partition.name, function () { partition.name = globalTextField.text }, function () { }, false, sequencerView.node.color)

            DefaultToolTip {
                text: "Rename"
                visible: parent.hovered
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        DefaultImageButton {
            id: importFile
            Layout.fillHeight: true
            Layout.preferredWidth: height
            source: "qrc:/Assets/Import.png"
            foregroundColor: themeManager.contentColor
            colorHovered: sequencerView.node ? sequencerView.node.color : themeManager.accentColor

            onPressed: fileDialogImport.visible = true

            FileDialog {
                id: fileDialogImport
                title: qsTr("Please choose a file")
                folder: shortcuts.home
                visible: false

                onAccepted: {
                    partition.importPartition(urlToPath(fileDialogImport.fileUrl))
                    visible = false
                }

                onRejected: {
                    visible = false
                }
            }

            DefaultToolTip {
                text: "Import a partition File"
                visible: parent.hovered
            }
        }

        DefaultImageButton {
            id: exportFile
            Layout.fillHeight: true
            Layout.preferredWidth: height
            source: "qrc:/Assets/Export.png"
            foregroundColor: themeManager.contentColor
            colorHovered: sequencerView.node ? sequencerView.node.color : themeManager.accentColor

            onPressed: fileDialogExport.visible = true

            FileDialog {
                id: fileDialogExport
                selectExisting: false
                title: qsTr("Export your partition")
                folder: shortcuts.home
                visible: false

                onAccepted: {
                    partition.exportPartition(urlToPath(fileDialogExport.fileUrl))
                    visible = false
                }
                onRejected: {
                    visible = false
                }
            }

            DefaultToolTip {
                text: "Export your partition File"
                visible: parent.hovered
            }
        }
    }

    PartitionComboBox {
        Layout.fillHeight: true
        Layout.fillWidth: true
        partitions: sequencerView.node ? sequencerView.node.partitions : null
        currentIndex: sequencerView.partitionIndex

        onActivated: sequencerView.changePartition(index)
    }
}
