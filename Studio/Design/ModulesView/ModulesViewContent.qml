import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../PlaylistView"

Item {
    function getModule(idx) {
        if (idx < 0) {
            switch (idx) {
            case -1:
                return playlistView
            default:
                return null
            }
        } else
            return modulesLoadersRepeater.itemAt(idx).item
    }

    property alias selectedModule: modulesTabs.selectedModule
    property alias staticTabCount: modulesTabs.staticTabCount

    id: modulesViewContent

    Column {
        anchors.fill: parent

        ModulesViewTabs {
            id: modulesTabs
        }

        Item {
            id: modulesLoaders
            width: parent.width
            height: parent.height - modulesTabs.height

            PlaylistView {
                readonly property int tabIndex: 0

                id: playlistView
                anchors.fill: parent
                visible: modulesViewContent.selectedModule === tabIndex
            }

            Repeater {
                id: modulesLoadersRepeater
                model: modulesView.modules

                delegate: Loader {
                    readonly property int tabIndex: index + 1
                    readonly property bool isSelectedModule: modulesViewContent.selectedModule === tabIndex

                    anchors.fill: modulesLoaders
                    visible: isSelectedModule
                    enabled: isSelectedModule
                    focus: true
                    source: path

                    onVisibleChanged: focus = true

                    onLoaded: {
                        if (path === "")
                            return
                        item.moduleIndex = index
                        callback.target = item
                        callback.trigger()
                        focus = true
                        item.focus = true
                    }
                }
            }
        }
    }
}