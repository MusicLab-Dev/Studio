import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

DefaultSectionWrapper {
    label: "bpm"

//     SpinBox {
//         anchors.centerIn: parent
// //        text: qsTr("140:000")
// //        font.pixelSize: parent.height * 0.75
// //        color: "white"
//         from: 10
//         to: 300
//         value: app.project.bpm

//         onValueModified: {
//             // if (app.currentPlayer)
//             //     app.currentPlayer.prepareForBPMChange()
//             app.project.bpm = value
//         }
//     }
   DefaultTextInput {
       id: name
       anchors.centerIn: parent
       text: qsTr("140:000")
       font.pixelSize: parent.height * 0.75
       color: "white"

    //    onEditingFinished: {
    //        app.project.bpm = text
    //    }
   }
/*
    Rectangle {
        height: parent.height* 0.25
        width: parent.width * 0.25
        anchors.centerIn: parent.BottomLeft
    }*/
}
