import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import PluginModel 1.0

import "../Default"

Rectangle {
    readonly property var filterNames: [
        [
            qsTr("Group"),
            qsTr("Mastering"),
            qsTr("Sequencer")
        ],
        [
            qsTr("Instrument"),
            qsTr("Synth"),
            qsTr("Drum"),
            qsTr("Sampler")
        ],
        [
            qsTr("Effect"),
            qsTr("Filter"),
            qsTr("Reverb"),
            qsTr("Delay"),
            qsTr("Distortion")
        ]
    ]
    property alias currentSearchText: searchText.text

    id: pluginsForeground
    color: themeManager.backgroundColor
    radius: 6

    Rectangle {
        width: parent.width * 0.1
        height: parent.height
        anchors.right: parent.right
        color: parent.color
    }

    Item {
        id: pluginsResearchTextInput
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.1
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height * 0.05
        width: parent.width * 0.8

        DefaultTextInput {
            id: searchText
            anchors.fill: parent
            placeholderText: qsTr("Research")
        }
    }

    Item {
        id: pluginsCheckBoxes
        width: parent.width * 0.9
        height: parent.height - (parent.height / 7) * 2
        anchors.top: pluginsResearchTextInput.top
        anchors.topMargin: parent.height * 0.1
        anchors.horizontalCenter: parent.horizontalCenter

        ListView {
            id: listView
            anchors.fill: parent
            spacing: parent.height * 0.04

            ScrollBar.vertical: DefaultScrollBar {
                color: themeManager.accentColor
                visible: parent.contentHeight > parent.height
            }

            model: [
                [
                    PluginModel.Tags.Group,
                    PluginModel.Tags.Mastering,
                    PluginModel.Tags.Sequencer
                ],
                [
                    PluginModel.Tags.Instrument,
                    PluginModel.Tags.Synth,
                    PluginModel.Tags.Drum,
                    PluginModel.Tags.Sampler
                ],
                [
                    PluginModel.Tags.Effect,
                    PluginModel.Tags.Filter,
                    PluginModel.Tags.Reverb,
                    PluginModel.Tags.Delay,
                    PluginModel.Tags.Distortion
                ]
            ]

            delegate: Column {
                property bool categoryChecked: false
                property int categoryIndex: index
                property int categoryFilter: modelData[0]

                id: filterColumn
                width: listView.width
                spacing: listView.spacing / 2

                Repeater {
                    model: modelData

                    delegate: Item {
                        width: listView.width
                        height: foregroundCheckBox.height
                        // visible: index === 0 || filterColumn.categoryChecked

                        DefaultCheckBox {
                            id: foregroundCheckBox
                            x: index === 0 ? 0 : listView.spacing
                            text: pluginsForeground.filterNames[filterColumn.categoryIndex][index]
                            checked: false
                            width: parent.width * 0.85 - x
                            height: 20
                            font.weight: Font.Light

                            Component.onCompleted: {
                                if (index === 0)
                                    checked = Qt.binding(function() { return filterColumn.categoryChecked })
                            }

                            onCheckedChanged: {
                                if (index === 0)
                                    filterColumn.categoryChecked = checked
                                else
                                    filterColumn.categoryChecked = filterColumn.categoryChecked || checked

                                if (checked) {
                                    pluginsView.currentFilter |= modelData
                                } else {
                                    var filter = (pluginsView.currentFilter & ~modelData)
                                    if (index !== 0)
                                        filter |= filterColumn.categoryFilter
                                    pluginsView.currentFilter = filter
                                }
                            }

                            Connections {
                                target: filterColumn
                                enabled: index !== 0
                                function onCategoryCheckedChanged() {
                                    if (!filterColumn.categoryChecked)
                                        foregroundCheckBox.checked = false
                                }
                            }
                        }

                        Text {
                            anchors.left: foregroundCheckBox.right
                            anchors.right: parent.right
                            height: parent.height
                            fontSizeMode: Text.Fit
                            text: {
                                pluginsContentArea.count // Retrigger on count changed
                                return pluginsContentArea.pluginTableProxy.getPluginsCount(modelData)
                            }
                            color: "white"
                            // font.weight: Font.Thin
                        }
                    }
                }
            }
        }
    }
}
