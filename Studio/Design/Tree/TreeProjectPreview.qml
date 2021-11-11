import QtQuick 2.15
import QtGraphicalEffects 1.15

import ProjectPreview 1.0
import Scheduler 1.0
import AudioAPI 1.0

import "../Default"
import "../Common"

ProjectPreview {
    enum EditMode {
        None,
        Playback,
        Loop,
        InvertedLoop
    }

    // Input
    property PlayerBase playerBase

    // Loop cache
    property real loopFromX: playerBase.loopFrom * projectPreview.pixelsPerBeatPrecision
    property real loopToX: playerBase.loopTo * projectPreview.pixelsPerBeatPrecision

    id: projectPreview
    anchors.fill: parent
    beatLength: app.project.latestInstance

    Component.onCompleted: targets = [app.project.master]

//    Connections {
//        target: contentView.treeSurface

//        function onSelectionListModified() {
//            if (contentView.treeSurface.selectionList.length)
//                projectPreview.targets = contentView.treeSurface.makeNodeSelectionList()
//            else
//                projectPreview.targets = [app.project.master]
//        }
//    }

    Connections {
        target: app.project

        function onMasterChanged() {
            projectPreview.targets = [app.project.master]
        }
    }

    ContentViewTimelineMouseArea {
        id: timelineMouseArea
        anchors.fill: parent
        playerBase: projectPreview.playerBase
        pixelsPerBeatPrecision: projectPreview.pixelsPerBeatPrecision
    }

    DefaultToolTip {
        visible: timelineMouseArea.containsMouse
        text: "Project Preview"
    }

    Rectangle {
        visible: playerBase.hasLoop
        color: "grey"
        opacity: 0.6
        anchors.left: parent.left
        anchors.right: loopFromBar.visible ? loopFromBar.left : parent.right
        height: parent.height
    }

    Rectangle {
        visible: playerBase.hasLoop
        color: "grey"
        opacity: 0.6
        anchors.left: loopToBar.visible ? loopToBar.right : parent.right
        anchors.right: parent.right
        height: parent.height
    }

    Rectangle {
        id: loopFromBar
        x: projectPreview.loopFromX
        width: 1
        height: parent.height
        color: themeManager.accentColor
        visible: playerBase.hasLoop && projectPreview.loopFromX < parent.width
    }

    Rectangle {
        id: loopToBar
        x: projectPreview.loopToX
        width: 1
        height: parent.height
        color: themeManager.accentColor
        visible: playerBase.hasLoop && projectPreview.loopToX < parent.width
    }

    ContentViewTimelineBar {
        id: playToBar
        height: parent.height
        color: themeManager.timelineColor
        x: Math.max(Math.min(projectPreview.pixelsPerBeatPrecision * playerBase.currentPlaybackBeat, previewBackground.width), 0)
        visible: app.project.master.latestInstance !== 0
    }

    ContentViewTimelineBarCursor {
        id: playToCursor
        width: 10
        height: 10
        x: playToBar.x - width / 2
        visible: playToBar.visible
    }

    ContentViewTimelineBar {
        id: playFromBar
        height: parent.height
        color: "white"
        opacity: 0.5
        x: Math.max(Math.min(projectPreview.pixelsPerBeatPrecision * playerBase.playFrom, previewBackground.width), 0)
        visible: playToBar.visible
    }

    ContentViewTimelineBarCursor {
        id: playFromCursor
        opacity: 0.5
        width: 10
        height: 10
        x: playFromBar.x - width / 2
        color: "white"
        visible: playToBar.visible
    }
}
