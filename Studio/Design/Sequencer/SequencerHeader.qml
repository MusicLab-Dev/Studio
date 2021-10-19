import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0
import ClipboardManager 1.0

import "../Default/"
import "../Help/"
import "../Common/"

import PluginModel 1.0

Rectangle {
    property color hoveredColor: sequencerView.node ? Qt.darker(sequencerView.node.color, 1.8) : "black"
    property color pressedColor: sequencerView.node ? Qt.darker(sequencerView.node.color, 2.2) : "black"
    property color accentColor: sequencerView.node ? Qt.darker(sequencerView.node.color, 1.6) : "black"

    color: themeManager.contentColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
//        onClicked: helpHandler.open()
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
            color: sequencerView.node && (mousePluginButton.containsMouse || !sequencerControls.hide) ? sequencerView.node.color : themeManager.foregroundColor
            border.color: mousePluginButton.containsPress ? pressedColor : hoveredColor
            border.width: mousePluginButton.containsMouse && !sequencerControls.hide ? 2 : 0

            MouseArea {
                id: mousePluginButton
                hoverEnabled: true
                anchors.fill: parent

                onPressed: sequencerControls.hide = !sequencerControls.hide
            }

            DefaultText {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignLeft
                fontSizeMode: Text.HorizontalFit
                font.pointSize: 20
                color: (mousePluginButton.containsMouse || !sequencerControls.hide) ? themeManager.foregroundColor : sequencerView.node.color
                text: sequencerView.node ? sequencerView.node.name : qsTr("ERROR")
                wrapMode: Text.Wrap
            }
        }

        HelpArea {
            name: (sequencerControls.visible ? qsTr("Hide") : qsTr("Show")) + qsTr(" controls")
            description: qsTr("Description")
            position: HelpHandler.Position.Center
            externalDisplay: false
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
            color: sequencerView.node && mousePlannerButton.containsMouse ? sequencerView.node.color : themeManager.foregroundColor

            MouseArea {
                id: mousePlannerButton
                hoverEnabled: true

                anchors.fill: parent

                onPressed: {
                    modulesView.addNewPlanner(sequencerView.node)
                }
            }

            DefaultColoredImage {
                anchors.fill: parent
                anchors.margins: parent.width * 0.25
                source: "qrc:/Assets/Chrono.png"
                color: mousePlannerButton.containsMouse ? themeManager.foregroundColor : sequencerView.node ? sequencerView.node.color : "black"
            }
        }

        HelpArea {
            name: qsTr("Move to planner")
            description: qsTr("Description")
            position: HelpHandler.Position.Bottom
            externalDisplay: true
        }
    }

    SoundMeter {
        id: soundMeter
        anchors.left: plannerButton.right
        anchors.leftMargin: 10
        anchors.top: plannerButton.top
        anchors.bottom: plannerButton.bottom
        width: height / 3
        targetNode: sequencerView.node
        enabled: sequencerView.visible
        color: themeManager.foregroundColor

        HelpArea {
            name: qsTr("Sound meter")
            description: qsTr("Description")
            position: HelpHandler.Position.Right
            externalDisplay: true
        }
    }

    ClipboardIndicator {
        anchors.bottom: parent.bottom
        anchors.left: soundMeter.right
        anchors.top: parent.top
        anchors.leftMargin: parent.width * 0.01
        width: parent.width * 0.1

        HelpArea {
            name: qsTr("Clipboard")
            description: qsTr("Description")
            position: HelpHandler.Position.Bottom
            externalDisplay: true
        }
    }
}
