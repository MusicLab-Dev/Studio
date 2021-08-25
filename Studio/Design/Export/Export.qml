import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "../Default"
import "../Common"

import Scheduler 1.0

Item {
    function open() {
        openAnim.start()
        visible = true
    }

    function close() {
        visible = false
    }

    function start() {
        exporting = true
        var path = app.project.path
        if (!path.length)
            path = app.project.name
        saveFileDialog.open()
    }

    function cancel() {
        exporting = false
        app.scheduler.stop()
    }

    property bool exporting: false

    id: exportPopup
    width: parent.width
    height: parent.height
    visible: false

    Connections {
        target: app.scheduler
        enabled: exportPopup.exporting

        function onExportCompleted() {
            exporting = false
            close()
        }

        function onExportCanceled() {
            exporting = false
            close()
        }

        function onExportFailed() {
            exporting = false
        }
    }

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: window; property: "opacity"; from: 0.1; to: 1; duration: 500; easing.type: Easing.Linear }
        PropertyAnimation { target: shadow; property: "opacity"; from: 0.1; to: 1; duration: 500; easing.type: Easing.Linear }
        PropertyAnimation { target: background; property: "opacity"; from: 0.1; to: 0.5; duration: 300; easing.type: Easing.Linear }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "grey"
        opacity: 0.5
    }

    DropShadow {
        id: shadow
        anchors.fill: window
        horizontalOffset: 4
        verticalOffset: 4
        radius: 8
        samples: 17
        color: "#80000000"
        source: window
    }

    MouseArea {
        id: ms
        anchors.fill: parent
        onReleased: { if (visible && !exporting) close() }
    }

    ContentPopup {
        id: window
        width: Math.max(parent.width * 0.3, 400)
        height: windowCol.height + 2 * windowArea.anchors.margins

        MouseArea { // Used to prevent missclic from closing the window
            anchors.fill: parent
        }

        Item {
            id: windowArea
            anchors.fill: parent
            anchors.margins: 30

            Column {
                id: windowCol
                width: windowArea.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                DefaultText {
                    text: qsTr("Export project '") + app.project.name + qsTr("' ?")
                    width: windowArea.width
                    height: 30
                    wrapMode: Text.Wrap
                    font.pixelSize: 20
                    fontSizeMode: Text.Fit
                    color: "white"
                }

                Row {
                    id: progressRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    width: windowArea.width
                    height: cancelButton.height

                    Rectangle {
                        id: progressBar
                        width: progressRow.width - cancelButton.width - progressRow.spacing
                        height: cancelButton.height
                        border.color: exportPopup.exporting ? themeManager.foregroundColor : themeManager.disabledColor
                        border.width: 2
                        color: "transparent"

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: app.scheduler.currentBeat / app.scheduler.maxBeat * parent.width
                            anchors.margins: parent.border.width
                            color: themeManager.accentColor
                        }

                        DefaultText {
                            anchors.fill: parent

                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 20
                            text: app.scheduler.currentBeat / app.scheduler.maxBeat * 100 + "% (" + app.scheduler.currentBeat + " / " + app.scheduler.maxBeat + ")"
                        }

                    }

                    TextRoundedButton {
                        id: cancelButton
                        text: qsTr("Cancel")
                        enabled: exportPopup.exporting

                        onReleased: exportPopup.cancel()
                    }
                }

                Row {
                    id: confirmRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: noButton.height
                    spacing: 30
                    visible: !exportPopup.exporting

                    TextRoundedButton {
                        text: qsTr("Yes")
                        hoverOnText: false

                        onReleased: exportPopup.start()
                    }

                    TextRoundedButton {
                        id: noButton
                        text: qsTr("No")

                        onReleased: exportPopup.close()
                    }
                }
            }
        }
    }

    DefaultFileDialog {
        id: saveFileDialog
        title: qsTr("Save a project file")
        folder: shortcuts.home
        nameFilters: [ "All files (*)" ]
        selectExisting: false
        visible: false

        onAccepted: {
            app.scheduler.exportProject(fileUrl.toString() + ".wav")
            saveFileDialog.close()
        }

        onRejected: saveFileDialog.close()
    }

    /*
    Timer {
        running: exporting

        onTriggered: {
            = currentBeat
        }
    }*/
}
