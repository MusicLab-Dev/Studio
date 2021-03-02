import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property alias modulesViewContent: modulesViewContent

    id: modulesView
    color: "#474747"


    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ModulesViewContent {
            id: modulesViewContent
            Layout.preferredHeight: parent.height * 1
            Layout.preferredWidth: parent.width
            // add min / max values
        }
    }
}
