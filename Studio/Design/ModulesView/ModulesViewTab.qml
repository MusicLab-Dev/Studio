import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Default"
import "../Common"

Rectangle {
    property bool dragActive: mouseArea.drag.active
    property bool hoverDrop: false

    id: moduleViewTab
    color: componentSelected === index || hoverDrop ? themeManager.foregroundColor : themeManager.backgroundColor
    border.color: "black"
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    onDragActiveChanged: {
        if (dragActive)
            Drag.start();
        else
            Drag.drop();
    }


    DropArea {
        anchors.fill: parent
        enabled: index !== componentSelected

        onEntered: {
            hoverDrop = true
        }

        onExited: {
            hoverDrop = false
        }

        onDropped: {
            var indexTmp = index
            modules.move(index, componentSelected, 1)
            componentSelected = indexTmp
            hoverDrop = false
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag.target: parent

        onPressed: {
            componentSelected = index
        }
    }

    Text {
        anchors.centerIn: parent
        text: title
        color: componentSelected === index ? "white" : "black"
    }

    CloseButton {
        width: parent.height / 3
        height: width
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: width / 2
        visible: !(modules.count === 2 && title === "New component")

        onClicked: {
            if (componentSelected === modules.count - 2)
                componentSelected = modules.count - 3
            if (modules.count === 2) {
                modules.insert(1,
                               {
                                   title: "New component",
                                   path: "qrc:/EmptyView/EmptyView.qml",
                               })
                componentSelected = 0
            }
            modules.remove(index)
        }
    }


    Behavior on x {
        SpringAnimation {
            spring: 2
            damping: 0.3
            duration: 400
        }
    }

    Behavior on y {
        SpringAnimation {
            spring: 2
            damping: 0.3
            duration: 400
        }
    }
}
