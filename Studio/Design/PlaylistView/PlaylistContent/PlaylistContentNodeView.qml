import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

Item {
    // Children nodes link
    property real linkWidth: 10
    property real linkSpacing: 10

    // Plugin header layout
    readonly property real pluginHeaderWidth: contentView.rowHeaderWidth * 0.5
    readonly property real pluginHeaderDisplayWidth: nodeView.pluginHeaderWidth - nodeView.pluginHeaderHorizontalPadding
    readonly property real pluginHeaderRadius: pluginHeaderWidth / 12
    readonly property real pluginHeaderHorizontalPadding: pluginHeaderLeftPadding + pluginHeaderRightPadding
    readonly property real pluginHeaderVerticalPadding: pluginHeaderTopPadding + pluginHeaderBottomPadding
    property real pluginHeaderLeftPadding: 2
    property real pluginHeaderRightPadding: 12
    property real pluginHeaderTopPadding: 6
    property real pluginHeaderBottomPadding: 6

    // Plugin header content
    readonly property real pluginHeaderSpacing: 2
    readonly property real pluginHeaderNameWidth: pluginHeaderDisplayWidth - pluginHeaderNameHeight * 2 - pluginHeaderSpacing * 4
    readonly property real pluginHeaderNameHeight: Math.min(30, (rowHeight - pluginHeaderVerticalPadding - pluginHeaderSpacing * 2))
    readonly property real pluginHeaderNamePointSize: pluginHeaderNameHeight * 0.6
    readonly property real pluginHeaderSettingsButtonX: pluginHeaderDisplayWidth - pluginHeaderNameHeight - pluginHeaderSpacing
    readonly property real pluginHeaderMuteButtonX: pluginHeaderSettingsButtonX - pluginHeaderNameHeight - pluginHeaderSpacing

    // Data header
    readonly property real dataHeaderWidth: contentView.rowHeaderWidth - pluginHeaderWidth
    readonly property real dataHeaderAndContentWidth: width - pluginHeaderWidth

    property real totalHeight: master.height

    id: nodeView
    clip: true

    PlaylistContentNodeDelegate {
        id: master
        node: app.project.master
        recursionIndex: 0
        y: contentView.yOffset
    }
}