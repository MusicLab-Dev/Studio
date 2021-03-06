import QtQuick 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0
import "../Default/"
import "../Common/"

RowLayout {
    spacing: 0

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.5

        DefaultImageButton {
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
            source: "qrc:/Assets/Next.png"
            height: width
            width: parent.width * 0.9
            anchors.centerIn: parent
            colorDefault: "white"
            enabled: false
        }
    }
}
