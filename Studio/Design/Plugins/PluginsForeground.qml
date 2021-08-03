import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import PluginTableModel 1.0

import "../Default"

Rectangle {
    readonly property var filterNames: [
        qsTr("Effect"),
        qsTr("Analyzer"),
        qsTr("Delay"),
        qsTr("Distortion"),
        qsTr("Dynamics"),
        qsTr("EQ"),
        qsTr("Filter"),
        qsTr("Spatial"),
        qsTr("Generator"),
        qsTr("Mastering"),
        qsTr("Modulation"),
        qsTr("PitchShift"),
        qsTr("Restoration"),
        qsTr("Reverb"),
        qsTr("Surround"),
        qsTr("Tools"),
        qsTr("Network"),
        qsTr("Drum"),
        qsTr("Instrument"),
        qsTr("Piano"),
        qsTr("Sampler"),
        qsTr("Synth"),
        qsTr("External")
    ]
    property alias currentSearchText: searchText.text

    id: pluginsForeground
    color: Qt.lighter(themeManager.foregroundColor, 1.2)
    radius: 30

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
            color: "white"
            opacity: 0.42
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
                opacity: 0.3
                visible: parent.contentHeight > parent.height
            }

            model: [
                PluginTableModel.Tags.Effect,
                PluginTableModel.Tags.Analyzer,
                PluginTableModel.Tags.Delay,
                PluginTableModel.Tags.Distortion,
                PluginTableModel.Tags.Dynamics,
                PluginTableModel.Tags.EQ,
                PluginTableModel.Tags.Filter,
                PluginTableModel.Tags.Spatial,
                PluginTableModel.Tags.Generator,
                PluginTableModel.Tags.Mastering,
                PluginTableModel.Tags.Modulation,
                PluginTableModel.Tags.PitchShift,
                PluginTableModel.Tags.Restoration,
                PluginTableModel.Tags.Reverb,
                PluginTableModel.Tags.Surround,
                PluginTableModel.Tags.Tools,
                PluginTableModel.Tags.Network,
                PluginTableModel.Tags.Drum,
                PluginTableModel.Tags.Instrument,
                PluginTableModel.Tags.Piano,
                PluginTableModel.Tags.Sampler,
                PluginTableModel.Tags.Synth,
                PluginTableModel.Tags.External
            ]

            delegate: Row {
                width: listView.width

                DefaultCheckBox {
                    id: foregroundCheckBox
                    text: pluginsForeground.filterNames[index]
                    checked: false
                    width: parent.width * 0.85
                    height: 20
                    font.weight: Font.Light
                    borderColor: "white"
                    enabledColor: "black"
                    onCheckedChanged: {
                        if (checked)
                            pluginsView.currentFilter |= modelData
                        else
                            pluginsView.currentFilter &= ~modelData
                    }
                }

                Text {
                    x: parent.width
                    text: {
                        pluginsContentArea.count
                        pluginsContentArea.pluginTableProxy.getPluginsCount(modelData)
                    }
                    color: foregroundCheckBox.hovered ? "#00A3FF" : "#FFFFFF"
                    opacity: foregroundCheckBox.hovered ? 1.0 :  0.42
                    font.weight: Font.Thin
                }
            }
        }

    }
}
