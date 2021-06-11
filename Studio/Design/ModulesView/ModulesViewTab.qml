import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Default"
import "../Common"

Rectangle {
    property bool dragActive: mouseArea.drag.active
    property string tabTitle

    id: moduleViewTab
    x: menuButton.width + playlistButton.width + (mouseArea.pressed ? index * tabWidth : index * tabWidth)
    y: mouseArea.pressed ? y : mouseArea.y
    color: componentSelected === index ? themeManager.foregroundColor : themeManager.backgroundColor
    border.color: "black"
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    onDragActiveChanged: {
        if (dragActive) {
            Drag.start();
        } else {
            Drag.drop();
        }
    }


    DropArea {
        width: parent.width / 2
        height: parent.height
        anchors.centerIn: parent
        enabled: index !== componentSelected

        onEntered: {
            if (index != componentSelected) {
                var indexTmp = index
                modules.move(index, componentSelected, 1)
                componentSelected = indexTmp
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAxis
        hoverEnabled: true

        onPressed: {
            componentSelected = index
        }

        onReleased: {
            moduleViewTab.y = 0
        }
    }

    Text {
        height: parent.height
        width: parent.width - closeBtn.width
        text: tabTitle
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: componentSelected === index ? "white" : mouseArea.containsMouse ? "black" : "#E5E5E5"
        elide: Text.ElideRight
        fontSizeMode: Text.Fit
        clip: true
    }

    CloseButton {
        id: closeBtn
        width: parent.height / 3
        height: width
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: width / 2

        onClicked: {
            if (componentSelected === modules.count - 1)
                componentSelected = modules.count > 1 ? modules.count - 2 : 0;
            if (modules.count === 1) {
                modulesView.addModule(1, {
                    title: "New component",
                    path: "qrc:/EmptyView/EmptyView.qml",
                    callback: modulesViewContent.nullCallback
                })
                componentSelected = 0
            }
            modules.removeModule(index)
        }
    }

    // Behavior on x {
    //     SmoothedAnimation {
    //         id: animationX
    //         velocity: 500
    //     }
    // }
}
