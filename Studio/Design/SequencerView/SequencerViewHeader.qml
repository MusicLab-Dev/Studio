import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0

import "../Default/"
import "../Common/"

import PluginModel 1.0

Rectangle {
    color: themeManager.foregroundColor

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 3

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.5

                    DefaultComboBox {
                        width: parent.width / 2
                        height: parent.height / 2
                        anchors.centerIn: parent
                        model: [
                            "Sequence1",
                            "Sequence2",
                            "Sequence3"
                        ]
                    }
                }

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.5

                    ModSelector {
                        itemsPath: [
                            "qrc:/Assets/NormalMod.png",
                            "qrc:/Assets/BrushMod.png",
                            "qrc:/Assets/SelectorMod.png",
                            "qrc:/Assets/CutMod.png",
                        ]
                        width: parent.width / 2
                        height: parent.height / 2
                        anchors.centerIn: parent

                        onItemSelectedChanged: {

                        }
                    }
                }
            }
        }

        ListView {
            Layout.preferredHeight: parent.height
            Layout.fillWidth: true
            orientation: ListView.Horizontal
            clip: true
            model: sequencerView.node ? sequencerView.node.plugin : null
            spacing: 2

            delegate: Loader {
                focus: true
                anchors.verticalCenter: parent.verticalCenter

                source: {
                    switch (controlType) {
                    case PluginModel.Boolean:
                        return "qrc:/Common/PluginControls/BooleanControl.qml"
                    case PluginModel.Integer:
                        return "qrc:/Common/PluginControls/IntegerControl.qml"
                    case PluginModel.Floating:
                        return "qrc:/Common/PluginControls/FloatingControl.qml"
                    case PluginModel.Enum:
                        return "qrc:/Common/PluginControls/EnumControl.qml"
                    default:
                        return ""
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.133

            ArrowNextPrev {
                anchors.fill: parent
            }
        }
    }
}
