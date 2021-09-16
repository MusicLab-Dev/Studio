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

    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
        onClicked: helpHandler.open()
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
        width: parent.width * 0.15
        height: parent.height * 0.75

        Rectangle {
            id: rectPluginButton
            anchors.fill: parent
            radius: 15
            color: sequencerView.node ? sequencerView.node.color : "black"
            border.color: mousePluginButton.containsPress ? pressedColor : hoveredColor
            border.width: mousePluginButton.containsMouse ? 3 : 0

            MouseArea {
                id: mousePluginButton
                hoverEnabled: true

                anchors.fill: parent

                onPressed: {
                    if (!sequencerControls.visible)
                        sequencerControls.open()
                    else
                        sequencerControls.close()

                }
            }

            DefaultText {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignLeft
                fontSizeMode: Text.HorizontalFit
                font.pointSize: 20
                color: accentColor
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
            radius: 15
            color: sequencerView.node ? sequencerView.node.color : "black"
            border.color: mousePlannerButton.containsPress ? pressedColor : hoveredColor
            border.width: mousePlannerButton.containsMouse ? 3 : 0

            MouseArea {
                id: mousePlannerButton
                hoverEnabled: true

                anchors.fill: parent

                onPressed: {
                    modulesView.addNewPlanner(sequencerView.node)
                }
            }

            DefaultText {
                anchors.fill: parent
                fontSizeMode: Text.HorizontalFit
                font.pointSize: 20
                color: accentColor
                text: "<"
                wrapMode: Text.Wrap
            }
        }

        HelpArea {
            name: qsTr("Move to planner")
            description: qsTr("Description")
            position: HelpHandler.Position.Bottom
            externalDisplay: true
        }
    }

    Item {
        id: helpButton

        anchors.left: plannerButton.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7

        Rectangle {
            id: rectHelpButton
            anchors.fill: parent
            radius: 15
            color: sequencerView.node ? sequencerView.node.color : "black"
            border.color: mouseHelpButton.containsPress ? pressedColor : hoveredColor
            border.width: mouseHelpButton.containsMouse ? 3 : 0

            MouseArea {
                id: mouseHelpButton
                hoverEnabled: true

                anchors.fill: parent

                onPressed: helpHandler.open()
            }

            DefaultText {
                anchors.fill: parent
                fontSizeMode: Text.HorizontalFit
                font.pointSize: 20
                color: accentColor
                text: "?"
                wrapMode: Text.Wrap
            }
        }
    }

    SoundMeter {
        id: soundMeter
        anchors.left: helpButton.right
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        width: height / 3
        targetNode: sequencerView.node
        enabled: sequencerView.visible

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
