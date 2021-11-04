import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "../Default"
import "../Common"

import Scheduler 1.0

Item {
    function open() {
        progressRatio = 0
        error = false
        if (app.project.path.length)
            selectedPath = app.project.path + ".wav"
        else
            selectedPath = app.project.name + ".wav"
        openAnim.restart()
        visible = true
    }

    function close() {
        visible = false
        closed()
    }

    function start() {
        exporting = true
        error = false
        app.scheduler.exportProject(selectedPath)
    }

    function cancel() {
        exporting = false
        app.scheduler.stop()
        progressRatio = 0
    }

    signal exported(string path)
    signal canceled
    signal failed
    signal closed

    property bool exporting: false
    property real progressRatio: 0
    property string selectedPath: ""
    property bool error: false

    id: exportPopup
    width: parent.width
    height: parent.height
    visible: false

    Timer {
        running: exportPopup.exporting
        repeat: true
        interval: 16

        onTriggered: {
            if (app.project.master.latestInstance)
                progressRatio = Math.min(app.scheduler.currentBeat / app.project.master.latestInstance, 1)
            else
                progressRatio = 1
        }
    }

    Connections {
        target: app.scheduler
        enabled: exportPopup.exporting

        function onExportCompleted() {
            exporting = false
            exportPopup.exported(exportPopup.selectedPath)
            close()
        }

        function onExportCanceled() {
            exporting = false
            exportPopup.canceled()
            close()
        }

        function onExportFailed() {
            error = true
            exporting = false
            exportPopup.failed()
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
        radius: 6
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
            onPressed: forceActiveFocus()
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
                    id: pathRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    width: windowArea.width
                    height: cancelButton.height

                    DefaultTextInput {
                        width: parent.width - openFileButton.width - pathRow.spacing
                        height: cancelButton.height
                        text: selectedPath
                        enabled: !exportPopup.exporting

                        onTextChanged: selectedPath = text
                    }

                    TextRoundedButton {
                        id: openFileButton
                        text: qsTr("Select")
                        enabled: !exportPopup.exporting

                        onReleased: saveFileDialog.open()
                    }
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
                        border.color: exportPopup.exporting ? themeManager.contentColor : themeManager.disabledColor
                        border.width: 2
                        color: exportPopup.error ? "red" : "transparent"

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: exportPopup.progressRatio * parent.width
                            anchors.margins: parent.border.width
                            color: exportPopup.error ? "darkred" : themeManager.accentColor
                        }

                        DefaultText {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 20
                            text: (exportPopup.progressRatio * 100).toFixed() + "%"
                            color: "white"
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
                        filled: true

                        onReleased: exportPopup.start()
                    }

                    TextRoundedButton {
                        id: noButton
                        text: qsTr("No")
                        visible: !exportPopup.exporting

                        onReleased: exportPopup.close()
                    }
                }
            }
        }
    }

    DefaultFileDialog {
        id: saveFileDialog
        title: qsTr("Choose export path")
        folder: shortcuts.home
        nameFilters: [ "All files (*)" ]
        selectExisting: false
        visible: false

        onAccepted: {
            exportPopup.selectedPath = mainWindow.urlToPath(fileUrl.toString())
            if (!exportPopup.selectedPath.endsWith(".wav"))
                exportPopup.selectedPath = exportPopup.selectedPath + ".wav"
            saveFileDialog.close()
        }

        onRejected: saveFileDialog.close()
    }
}
