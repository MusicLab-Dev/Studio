import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0

import "../Default/"
import "../Common/"

import PluginModel 1.0

Item {

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    Rectangle {
        color: "white"
        height: 1
        width: parent.width
        anchors.top: parent.top
    }


    ListView {
        id: listView
        anchors.centerIn: parent
        width: parent.width * 0.95
        height: parent.height * 0.5
        orientation: ListView.Horizontal

        spacing: 20

        model: sequencerView.node ? sequencerView.node.plugin : null


            delegate: Loader {
                focus: true

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





}

