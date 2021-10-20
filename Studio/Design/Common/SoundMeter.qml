import QtQuick 2.15

import AudioAPI 1.0
import NodeModel 1.0

import "../Default"

Rectangle {
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
    property alias mouseArea: mouseArea

    id: soundMeter
    radius: 2
    color: themeManager.backgroundColor

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

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            soundMeter.muted = !soundMeter.muted
        }
    }

    Item {
        id: soundMeterBackground
        visible: !muted
        anchors.fill: parent 

        Rectangle {
            id: background
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * (soundMeter.rmsPosition)

            radius: 2

            gradient: Gradient {
                GradientStop { position: 0.0; color: "red" }
                GradientStop { position: 0.33; color: "yellow" }
                GradientStop { position: 1.0; color: "green" }
            }

            Behavior on height {
                NumberAnimation { duration: 50 }
            }
        }

        Repeater {
            id: reapeater
            model: 11

            delegate: Rectangle {
                anchors.right: soundMeterBackground.right
                color: "white"
                width: index === 1 ? parent.width : 3
                height: 1
                y: (1 + index) * soundMeterBackground.height / 12
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * (1 - soundMeter.peakPosition) - 2
            radius: 2

            Behavior on y {
                NumberAnimation { duration: 50 }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * (1 - soundMeter.gainPosition)
            color: themeManager.accentColor
            radius: 2
        }

        /*Text {
            verticalAlignment: Text.AlignVCenter
            text: "12"
            anchors.left: parent.right
            y: height / -2
            anchors.leftMargin: 4
            font.pointSize: 6
            color: "white"
        }

        Text {
            verticalAlignment: Text.AlignVCenter
            text: "0"
            anchors.left: parent.right
            anchors.leftMargin: 4
            y: soundMeter.unitSpacing * 2 - height / 2
            font.pointSize: 6
            color: "white"
        }

        Text {
            verticalAlignment: Text.AlignVCenter
            text: "-30"
            anchors.left: parent.right
            anchors.leftMargin: 3
            y: soundMeter.unitSpacing * 7 - height / 4
            font.pointSize: 6
            color: "white"
        }

        Text {
            verticalAlignment: Text.AlignVCenter
            text: "-60"
            anchors.left: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 3
            anchors.bottomMargin: height / -2
            font.pointSize: 6
            color: "white"
        }*/
    }
}
