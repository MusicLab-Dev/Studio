import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"

import PluginTableModel 1.0
import CursorManager 1.0

GridView {
    property alias pluginTableProxy: pluginTableProxy

    id: pluginsGrid
    cellWidth: 150
    cellHeight: cellWidth * 1.6
    clip: true

    model: PluginTableModelProxy {
        id: pluginTableProxy
        sourceModel: pluginTable
        tagsFilter: pluginsView.currentFilter
        nameFilter: pluginsForeground.currentSearchText
    }

    ScrollBar.vertical: DefaultScrollBar {
        id: scrollBar
        color: themeManager.accentColor
        opacity: 0.3
        //visible: parent.contentHeight > parent.height
        visible: false
    }

    delegate: PluginsDelegate {
    }
}
