import QtQuick 2.15

import "../Default"

MouseArea {
    enum Position {
        Center = 0,
        Top = 1,
        Bottom = 2,
        Left = 4,
        Right = 8
    }

    function open() {
        visible = true
    }

    function close() {
        visible = false
    }

    signal helpAreaRemoved(int removedIndex)

    property alias helpAreas: helpAreas

    id: helpHandler
    enabled: visible
    visible: false
    hoverEnabled: true
    anchors.fill: parent

    onPressed: close()

    Rectangle {
        color: "black"
        opacity: 0.75
        anchors.fill: parent
    }

    Repeater {
        id: repeater
        model: ListModel {
            id: helpAreas
        }

        delegate: Rectangle {
            id: delegate
            color: "transparent"
            border.color: themeManager.accentColor
            border.width: 1
            radius: 10
            x: areaX
            y: areaY
            width: areaWidth
            height: areaHeight

            Component.onCompleted: {
                console.log("DELEGATE", x, y, width, height, areaExternalDisplay, areaPosition, areaPosition & HelpHandler.Position.Top)
            }

            DefaultText {
                text: areaName
                font.pointSize: 16
                font.weight: Font.Light
                color: themeManager.accentColor

                anchors.centerIn: areaPosition === HelpHandler.Position.Center ? parent : undefined

                anchors.top: (areaPosition & HelpHandler.Position.Top) ? parent.top : undefined
                anchors.bottom: (areaPosition & HelpHandler.Position.Bottom) ? parent.bottom : undefined
                anchors.left: (areaPosition & HelpHandler.Position.Left) ? parent.left : undefined
                anchors.right: (areaPosition & HelpHandler.Position.Right) ? parent.right : undefined

                anchors.horizontalCenter: areaPosition === HelpHandler.Position.Top || areaPosition === HelpHandler.Position.Bottom ? parent.horizontalCenter : undefined
                anchors.verticalCenter: areaPosition === HelpHandler.Position.Left || areaPosition === HelpHandler.Position.Right ? parent.verticalCenter : undefined

                anchors.topMargin: (areaExternalDisplay && (areaPosition & HelpHandler.Position.Top)) ? -height - areaSpacing : areaSpacing
                anchors.bottomMargin: (areaExternalDisplay && (areaPosition & HelpHandler.Position.Bottom)) ? -height - areaSpacing : areaSpacing
                anchors.leftMargin: (areaExternalDisplay && (areaPosition === HelpHandler.Position.Left)) ? -width - areaSpacing : areaSpacing
                anchors.rightMargin: (areaExternalDisplay && (areaPosition === HelpHandler.Position.Right)) ? -width - areaSpacing : areaSpacing
            }
        }
    }
}
