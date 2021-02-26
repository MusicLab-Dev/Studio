import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Rectangle {
    id: settingsForeground
    color: "#0D2D47"
    radius: 30

    Rectangle {
        width: parent.width * 0.1
        height: parent.height
        anchors.right: parent.right
        color: parent.color
    }

    Item {
        id: settingsResearchTextInput
        width: parent.width * 0.8
        height : parent.height * 0.05
        x: (parent.width - width) / 2
        y: (parent.height - height) / 25

        DefaultTextInput {
            anchors.fill: parent
            placeholderText: qsTr("Default files")
            color: "white"
            opacity: 0.42
        }
    }

    Column {
        height: parent.height - settingsResearchTextInput.height
        y: settingsResearchTextInput.y + settingsResearchTextInput.height * 1.5
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12
        
        Repeater {
            model: ListModel {
                ListElement {
                    categoryName: "Midi"
                    categoryIcon: "Midi.png"
                }
                ListElement {
                    categoryName: "Audio"
                    categoryIcon: "Audio.png"
                }
                ListElement {
                    categoryName: "General"
                    categoryIcon: "General.png"
                }
                ListElement {
                    categoryName: "File"
                    categoryIcon: "File.png"
                }
                ListElement {
                    categoryName: "Project"
                    categoryIcon: "Project.png"
                }
                ListElement {
                    categoryName: "Info"
                    categoryIcon: "Info.png"
                }
                ListElement {
                    categoryName: "Debug"
                    categoryIcon: "Debug.png"
                }
                ListElement {
                    categoryName: "About"
                    categoryIcon: "About.png"
                }
            }

            SettingsForegroundCard {

            }
        }
    }



}
