import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    property real headerFactor: 0.1

    id: grill
    color: "#4A8693"
    
    ScrollView {
        anchors.fill: parent
        
        ListView {
            model: ListModel {

                ListElement {
                    keyColor: "white"
                    name : "F7"
                }
                
                ListElement {
                    keyColor: "black"
                    name : "E#7"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "E7"
                }
                
                ListElement {
                    keyColor: "black"
                    name : "D#7"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "D7"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "C7"
                }
                
                ListElement {
                    keyColor: "black"
                    name : "B#6"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "B6"
                }
                
                ListElement {
                    keyColor: "black"
                    name : "A#6"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "A6"
                }
                
                ListElement {
                    keyColor: "black"
                    name : "G#6"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "G6"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "F6"
                }
                
                ListElement {
                    keyColor: "black"
                    name : "D#6"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "D6"
                }
                
                ListElement {
                    keyColor: "black"
                    name : "C#6"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "C6"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "B5"
                }
                
                ListElement {
                    keyColor: "black"
                    name : "A#5"
                }
                
                ListElement {
                    keyColor: "white"
                    name : "A5"
                }
            }
            
            delegate: RowLayout {
                height: 50
                width: grill.width
                y : index * 50
                spacing: 0
                
                Rectangle {
                    height: 50
                    Layout.preferredWidth: parent.width * headerFactor
                    color: keyColor
                    border.width: 1
                    
                    Text {
                        text: name
                        color: keyColor === "white" ? "black" : "white"
                    }
                }
                
                Rectangle {
                    Layout.alignment: Qt.AlignBottom
                    height: 1
                    Layout.preferredWidth: parent.width
                    color: "black"
                }
            }
        }
    }
}
