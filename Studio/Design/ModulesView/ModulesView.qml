import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property alias modulesViewContent: modulesViewContent

    id: modulesView
    color: "#31A8FF"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ModulesViewBar {
            Layout.preferredHeight: parent.height * 0.075
            Layout.preferredWidth: parent.width
            // add min / max values
        }

        ModulesViewContent {
            id: modulesViewContent
            Layout.preferredHeight: parent.height * 0.925
            Layout.preferredWidth: parent.width
            // add min / max values
        }
    }
}
