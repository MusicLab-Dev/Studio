import QtQuick 2.15

import AudioAPI 1.0
import NodeModel 1.0

import "../Default"

Item {
    function getDecibelRatio(db) {
        if (db >= 12)
            return 1
        else if (db <= -60)
            return 0
        else
            return (db + 60) / 72
    }

    function enableAnalysis() {
        if (analysisRequested)
            console.error("Sound meter lost track of its node")
        targetNode.incrementAnalysisRequestCount()
        analysisRequested = true
    }

    function disableAnalysis() {
        if (analysisRequested && targetNode) {
            targetNode.decrementAnalysisRequestCount()
            analysisRequested = false
        }
        peakPosition = 0
        rmsPosition = 0
    }

    property NodeModel targetNode
    property real peakPosition: 0
    property real rmsPosition: 0
    property real gainPosition: 0
    readonly property real unitSpacing: height / 12
    property bool analysisRequested: false
    property bool muted: false
    property color color: targetNode ? targetNode.color : "white"
    property color backgroundColor: themeManager.foregroundColor
    property alias mouseArea: mouseArea

    id: soundMeter

    onTargetNodeChanged: {
        if (targetNode) {
            gainPosition = getDecibelRatio(targetNode.plugin.getControl(0))
            if (enabled)
                enableAnalysis()
        }
    }

    onEnabledChanged: {
        if (enabled)
            enableAnalysis()
        else if (analysisRequested)
            disableAnalysis()
    }

    Component.onDestruction: disableAnalysis()

    Connections {
        enabled: analysisRequested
        target: app.scheduler

        function onAnalysisCacheUpdated() {
            if (app.scheduler.running) {
                var volume = targetNode.getVolumeCache()
                peakPosition = getDecibelRatio(volume.peak)
                rmsPosition = getDecibelRatio(volume.rms)
            }
        }

        function onRunningChanged() {
            if (!app.scheduler.running) {
                peakPosition = 0
                rmsPosition = 0
            }
        }
    }

    Connections {
        // enabled: analysisRequested
        target: targetNode ? targetNode.plugin : null

        function onControlValueChanged(paramId) {
            if (paramId === 0)
                gainPosition = getDecibelRatio(targetNode.plugin.getControl(0))
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            soundMeter.muted = !soundMeter.muted
        }
    }

    Rectangle {
        id: soundMeterBackground
        visible: !muted
        anchors.fill: parent
        anchors.margins: 1
        radius: 2

        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(soundMeter.color, 1.5) }
            GradientStop { position: 0.33; color: soundMeter.color }
            GradientStop { position: 1.0; color: Qt.darker(soundMeter.color, 1.5) }
        }

        Rectangle {
            color: backgroundColor
            x: -1
            y: -1
            width: parent.width + 2
            height: (parent.height + 2) * (1 - soundMeter.rmsPosition)
            radius: 2
        }

        Rectangle {
            visible: y !== parent.height
            width: parent.width
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * (1 - soundMeter.peakPosition)
        }

        Rectangle {
            width: parent.width
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * (1 - soundMeter.gainPosition)
            color: themeManager.accentColor
        }
    }

    Rectangle {
        visible: mouseArea.containsMouse || muted
        anchors.fill: parent
        color: "red"
        opacity: 0.5
        radius: 2
    }

    DefaultColoredImage {
        anchors.centerIn: parent
        width: parent.width * 0.7
        height: width
        visible: mouseArea.containsMouse
        source: muted ? "qrc:/Assets/Muted.png" : "qrc:/Assets/Unmuted.png"
        color: "white"
    }
}
