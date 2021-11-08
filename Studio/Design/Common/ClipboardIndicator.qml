import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0
import ClipboardManager 1.0

import "../Default/"
import "../Common/"

import PluginModel 1.0

MouseArea {
    property string state: clipboardManager.state === ClipboardManager.State.Note ? "Notes" :
                                                                                    clipboardManager.state === ClipboardManager.State.Partition ? "Partitions" :
                                                                                                                                                  "Nothing"
    id: copypaste
    visible: clipboardManager.state !== ClipboardManager.State.Nothing
    hoverEnabled: true

    DefaultColoredImage {
        anchors.centerIn: parent
        width: height
        height: parent.height * 0.5
        id: name
        source: "qrc:/Assets/presse-papiers.png"
        color: themeManager.foregroundColor
    }

    ToolTip {
        id: toolTip
        anchors.centerIn: parent
        visible: parent.containsMouse

        contentItem: Text {
            text: "In Clipboard: " + clipboardManager.count + " " + copypaste.state
            color: "white"
        }

        background: Rectangle {
            color: themeManager.contentColor
            border.color: themeManager.foregroundColor
            border.width: 2
        }
    }

}
