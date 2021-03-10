import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Common"

Button {
    property string imgPath: ""
    property color colorDefault: "#FD9D57"
    property color colorOnPressed: Qt.tint(colorDefault, "#10FF0000")
    property color colorHovered: Qt.tint(colorDefault, "#10FF0000")
    property bool showBorder: true
    property string title: ""
    property string description: ""
    
    id: control
    hoverEnabled: true
    
    background: Rectangle {
        width: control.width
        height: control.height
        color: colorDefault
        border.width: 1
        border.color: "white"
        radius: 40
        visible: showBorder
    }
    
    indicator: ColumnLayout {
        anchors.centerIn: control
        height: control.height * 0.8
        width: control.width * 0.8

        Item {
            Layout.preferredHeight: parent.height * 0.4
            Layout.preferredWidth: parent.width

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                height: parent.width / 2
                width: parent.width / 2
                source: imgPath
            }
        }

        Item {
            Layout.preferredHeight: parent.height * 0.2
            Layout.preferredWidth: parent.width
        }

        Item {
            Layout.preferredHeight: parent.height * 0.2
            Layout.preferredWidth: parent.width

            Text {
                anchors.centerIn: parent
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: title
                font.pointSize: 24
                color: "white"
                width: parent.width
            }
        }

        Item {
            Layout.preferredHeight: parent.height * 0.2
            Layout.preferredWidth: parent.width

            Text {
                anchors.centerIn: parent
                text: description
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 16
                color: "white"
                width: parent.width
            }
        }
    }
}