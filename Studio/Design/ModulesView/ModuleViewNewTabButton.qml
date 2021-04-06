import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Default"

Rectangle {
    property real barSize: width / 4

    id: newTabButton
    color: themeManager.foregroundColor
    border.color: "black"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            modules.insert(modulesViewContent.modules.count - 1, {
                title: "New component",
                path: "qrc:/EmptyView/EmptyView.qml",
                callback: modulesViewContent.nullCallback
            })
            modulesViewContent.componentSelected = modulesViewContent.modules.count - 2
        }
    }

    Rectangle {
        width: barSize
        height: barSize / 8
        anchors.centerIn: parent
        radius: 20
    }

    Rectangle {
        width: barSize / 8
        height: barSize
        anchors.centerIn: parent
        radius: 20
    }

    Behavior on x {
        SpringAnimation {
            id: animationX
            spring: 4
            damping: 0.3
            duration: 400
        }
    }
}
