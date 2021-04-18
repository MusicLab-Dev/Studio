import QtQuick 2.15
import QtQuick.Controls 2.15

PluginsBackground {
    function open(accepted, canceled) {
        acceptedCallback = accepted
        canceledCallback = canceled
        selectedPath = ""
        visible = true
    }

    function acceptAndClose(path) {
        selectedPath = path
        visible = false
        acceptedCallback()
    }

    function cancelAndClose() {
        visible = false
        canceledCallback()
    }

    property var acceptedCallback: function() {}
    property var canceledCallback: function() {}

    property int currentFilter: 0
    property string selectedPath: ""

    id: pluginsView
    visible: false

    PluginsViewTitle {
        id: pluginsViewTitle
        x: (pluginsForeground.width + (parent.width - pluginsForeground.width) / 2) - width / 2
        y: height
    }

    Rectangle {
        id: pluginsViewCloseButton
        width: 70
        height: 30
        x: pluginsView.width - width - height
        y: height
        color: "transparent"
        radius: 5
        border.color: pluginsViewCloseButtonText.closeButtonHovered ? "#31A8FF" : "#1E6FB0"
        border.width: 1

        PluginsViewCloseButton {
            id: pluginsViewCloseButtonText
        }
    }


    PluginsForeground {
        id: pluginsForeground
        x: parent.parent.x
        y: parent.parent.y
        width: Math.max(parent.width * 0.2, 350)
        height: parent.height
    }

    PluginsContentArea {
        id: pluginsContentArea
        anchors.top: pluginsViewTitle.bottom
        anchors.left: pluginsForeground.right
        anchors.right: pluginsView.right
        anchors.bottom: pluginsView.bottom
        anchors.margins: parent.width * 0.05
    }
}
