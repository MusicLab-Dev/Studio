import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Common"

Rectangle {
    property string moduleName: qsTr("Empty")
    property int moduleIndex: -1

    id: emptyView
    color: themeManager.foregroundColor

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height * 0.333

            EmptyViewHeader {
                anchors.fill: parent
            }
        }

        Item {
            Layout.preferredHeight: parent.height * 0.666
            Layout.preferredWidth: parent.width

            EmptyViewContent {
                anchors.fill: parent
            }
        }
    }
}
