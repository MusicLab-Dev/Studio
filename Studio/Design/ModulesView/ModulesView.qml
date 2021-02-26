import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property alias modulesViewContent: modulesViewContent

    id: modulesView
    color: "#1F1F1F"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        /*
        ModulesViewBar {
            Layout.preferredHeight: parent.height * 0.05
            Layout.preferredWidth: parent.width
            // add min / max values
        }*/

        ModulesViewContent {
            id: modulesViewContent
            Layout.preferredHeight: parent.height * 1
            Layout.preferredWidth: parent.width
            // add min / max values
        }
    }
}
