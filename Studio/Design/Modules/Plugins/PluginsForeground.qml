import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

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

    id: pluginsForeground
    color: "#0D2D47"
    radius: 30

    Rectangle {
        width: parent.width * 0.1
        height: parent.height
        anchors.right: parent.right
        color: parent.color
    }

    Item {
        id: pluginsResearchTextInput
        width: parent.width * 0.8
        height : parent.height * 0.05
        x: (parent.width - width) / 2
        y: (parent.height - height) / 3

        DefaultTextInput {
            anchors.fill: parent
            color: "white"
            opacity: 0.42
        }
    }


    Item {
        id: pluginsCheckBoxes
        width: parent.width * 0.8
        height: parent.height * 0.5
        x: (parent.width - width) / 2
        y: pluginsResearchTextInput.y + pluginsResearchTextInput.height * 2

        ListView {
            id: listView
            anchors.fill: parent
            spacing: parent.height * 0.04

            model: [
                PluginsView.Effect,
                PluginsView.Analyzer,
                PluginsView.Delay,
                PluginsView.Distortion,
                PluginsView.Dynamics,
                PluginsView.EQ,
                PluginsView.Filter,
                PluginsView.Spatial,
                PluginsView.Generator,
                PluginsView.Mastering,
                PluginsView.Modulation,
                PluginsView.PitchShift,
                PluginsView.Restoration,
                PluginsView.Reverb,
                PluginsView.Surround,
                PluginsView.Tools,
                PluginsView.Network,
                PluginsView.Drum,
                PluginsView.Instrument,
                PluginsView.Piano,
                PluginsView.Sampler,
                PluginsView.Synth,
                PluginsView.External
            ]

            delegate: Row {
                width: listView.width

                DefaultCheckBox {
                    id: foregroundCheckBox
                    text: pluginsForeground.filterNames[index]
                    checked: false
                    width: 80
                    height: 20
                    font.weight: Font.Light
                    onCheckedChanged: {
                        if (checked)
                            pluginsView.currentFilter |= modelData
                        else
                            pluginsView.currentFilter &= ~modelData
                    }
                }

                Text {
                    x: parent.width - width
                    text: "0"
                    color: foregroundCheckBox.hovered ? "#00A3FF" : "#FFFFFF"
                    opacity: foregroundCheckBox.hovered ? 1.0 :  0.42
                    font.weight: Font.Thin
                }
            }
        }

    }
}
