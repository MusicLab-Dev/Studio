import QtQuick 2.15
import QtQuick.Window 2.15

import "../Modules/Plugins"
import "../Modules/Workspaces"
import "../Modules/Settings"
import "../Default/"
import "../Common/"

Window {
    visible: true
    width: 1920
    height: 1080
    title: qsTr("MusicLab")

    //PluginsView {
    //    anchors.fill: parent
    //}

    //WorkspacesView {
    //    anchors.fill: parent
    //}

    SettingsView {
        anchors.fill: parent
    }

    /* Widgets */
    //DefaultCheckBox {
    //    x: 0
    //    y: 10
    //}
    //
    //DefaultComboBox {
    //    width: 150
    //    height: 40
    //    x: 8
    //    y: 100
    //    model: [ "Option 1", "Option 2", "Option 3"]
    //}
    //
    //DefaultFoldButton {
    //    x: 8
    //    y: 200
    //}
    //
    //DefaultImageButton {
    //    x: 8
    //    y: 270
    //    width: 50
    //    height: 50
    //}
    //
    //DefaultMenuButton {
    //    x: 8
    //    y: 400
    //    width: 50
    //    height: 40
    //}
    //
    //DefaultScrollBar {
    //    x: 400
    //    y: 10
    //    width: 10
    //    height: 300
    //}
    //
    //DefaultTextButton {
    //    x: 8
    //    y: 500
    //    text: "+ NEW WORKSPACE"
    //}
    //
    //DefaultTextInput {
    //    x: 8
    //    y: 600
    //    placeholderText: "Please enter your answer"
    //}
    //
    //AddPluginButton {
    //    x: 8
    //    y: 700
    //    width: 150
    //    height: 164
    //}
    //
    //AddPreviewButton {
    //    x: 8
    //    y: 900
    //    width: 103
    //    height: 70
    //}
    //
    //SettingsCategoryButton {
    //    x: 200
    //    y: 750
    //    width: 308
    //    height: 82
    //    text: "File"
    //}
}
