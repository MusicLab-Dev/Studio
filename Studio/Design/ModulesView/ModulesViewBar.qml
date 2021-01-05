import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property bool tmp: true

    width: parent.width
    height: parent.width
    color: "#001E36"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.05

            MouseArea {
                anchors.fill: parent

                onReleased: {
                    modulesViewContent.modules.append({path: tmp ? "qrc:/SequencerView/SequencerView.qml" : "qrc:/PlaylistView/PlaylistView.qml", moduleZ: modulesViewContent.modules.count})
                    modulesViewContent.componentSelected = modulesViewContent.modules.count - 1
                    tmp = !tmp
                }

                Rectangle {
                    anchors.fill: parent
                    color: "green"
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.05
        }
    }
}
