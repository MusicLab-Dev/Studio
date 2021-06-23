import QtQuick 2.15
import QtQuick.Controls 2.15

import '../Common'

PluginsBackground {
    function open(accepted, canceled) {
        acceptedCallback = accepted
        canceledCallback = canceled
        selectedPath = ""
        visible = true
    }

    function acceptAndClose(path) {
        var accepted = acceptedCallback
        selectedPath = path
        visible = false
        acceptedCallback = null
        canceledCallback = null
        if (accepted)
            accepted()
    }

    function cancelAndClose() {
        var canceled = canceledCallback
        visible = false
        acceptedCallback = null
        canceledCallback = null
        if (canceled)
            canceled()
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

    TextRoundedButton {
        id: pluginsViewCloseButtonText
        text: "Close"
        x: pluginsView.width - width - height
        y: height

        onReleased: pluginsView.cancelAndClose()
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
