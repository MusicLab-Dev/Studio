import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Common"

RowLayout {
    
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333
        
        ClickableCard {
            title: "Sequencer"
            description: "create musical sequences"
            imgPath: "qrc:/Assets/Piano.png"
            colorDefault: "#FD9D57"
            anchors.centerIn: parent
            height: parent.height / 1.25
            width: parent.width / 1.5
            onClicked: {
                modules.insert(index, {
                                   title: "Sequencer",
                                   path: "qrc:/SequencerView/SequencerView.qml",
                               })
                modules.remove(index)
            }
        }
    }

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333
        
        ClickableCard {
            title: "Playlist"
            description: "Bring musical sequences to create your music"
            imgPath: "qrc:/Assets/Soundwave.png"
            colorDefault: "#2E6C98"
            anchors.centerIn: parent
            height: parent.height / 1.25
            width: parent.width / 1.5
            onClicked: {
                modules.insert(index, {
                                   title: "Playlist",
                                   path: "qrc:/PlaylistView/PlaylistView.qml",
                               })
                modules.remove(index)
            }
        }
    }

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333
        
        ClickableCard {
            title: "Board"
            description: "Connect your Boards for a better experience"
            imgPath: "qrc:/Assets/Board.png"
            colorDefault: "#D272AC"
            anchors.centerIn: parent
            height: parent.height / 1.25
            width: parent.width / 1.5
            onClicked: {
                modules.insert(index, {
                                   title: "Board",
                                   path: "qrc:/BoardView/BoardView.qml",
                               })
                modules.remove(index)
            }
        }
    }
}
