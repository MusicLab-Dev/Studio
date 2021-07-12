import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0

import "../Default/"
import "../Common/"

import PluginModel 1.0

Rectangle {
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    SequencerEdition {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        height: parent.height * 0.7
        width: parent.width * 0.4
    }


    Item {
        id: pluginButton
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.15
        height: parent.height

        Rectangle {
            property color hoveredColor: sequencerView.node ? Qt.darker(sequencerView.node.color, 1.8) : "black"
            property color pressedColor: sequencerView.node ? Qt.darker(sequencerView.node.color, 2.2) : "black"
            property color accentColor: sequencerView.node ? Qt.darker(sequencerView.node.color, 1.6) : "black"

            id: rectPluginButton
            anchors.centerIn: parent
            width: parent.width
            height: parent.height * 0.8
            radius: 15
            color: sequencerView.node ? sequencerView.node.color : "black"
            border.color: mouse.containsPress ? pressedColor : hoveredColor
            border.width: mouse.containsMouse ? 3 : 0

            MouseArea {
                id: mouse
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
                color: rectPluginButton.accentColor
                text: sequencerView.node ? sequencerView.node.name : "ERROR"
                wrapMode: Text.Wrap
            }
        }
    }

}
