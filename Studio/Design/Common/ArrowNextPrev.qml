import QtQuick 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0
import "../Default/"
import "../Common/"

RowLayout {
    property alias prev: prev
    property alias next: next

    spacing: 0

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.5

        DefaultImageButton {
            id: prev

            source: "qrc:/Assets/Previous.png"
            height: width
            width: parent.width * 0.9
            anchors.centerIn: parent
            colorDefault: "white"
            enabled: false
        }
    }

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.5

        DefaultImageButton {
            id: next

            source: "qrc:/Assets/Next.png"
            height: width
            width: parent.width * 0.9
            anchors.centerIn: parent
            colorDefault: "white"
            enabled: false
        }
    }
}
