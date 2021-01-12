import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../../Common"

Rectangle {
    property real headerFactor: 0.1

    width: parent.width
    height: parent.height
    color: "#001E36"

    ColumnLayout {
        width: parent.width
        height: parent.height
        spacing: 0

        PlaylistViewContentTimeline {
            id: timeline
            headerFactor: headerFactor
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width
            z: 1


            MouseArea {
                function manageTimelineCursorPos() {
                    timelineBar.x = Math.min(
                                Math.max(
                                    parent.width * headerFactor - timelineBar.width / 2,
                                    mouseX - (timelineBar.width / 2) + parent.width * headerFactor
                                    ),
                                parent.width - timelineBar.width / 2
                                )
                }

                x: parent.width * headerFactor
                height: parent.height
                width: parent.width - parent.width * headerFactor
                onPositionChanged: {
                    manageTimelineCursorPos()
                }

                onPressed: {
                    manageTimelineCursorPos()
                }
            }
        }

        PlaylistViewContentGrid {
            Layout.preferredHeight: parent.height * 0.96
            Layout.preferredWidth: parent.width
            headerFactor: headerFactor
        }
    }

    TimelineCursor {
        id: timelineBar
        x: parent.width * headerFactor + 200
        width: 25
        height: parent.height
    }
}


