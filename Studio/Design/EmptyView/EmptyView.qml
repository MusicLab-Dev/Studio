import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Common"

Rectangle {
    id: emptyView
    color: "#001E36"

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.preferredHeight: parent.height * 0.333
            Layout.preferredWidth: parent.width

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
