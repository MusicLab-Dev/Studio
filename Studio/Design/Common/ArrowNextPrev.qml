import QtQuick 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0
import "../Default/"
import "../Common/"

Item {
    property alias prev: prev
    property alias next: next

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.5

            DefaultImageButton {
                id: prev

                source: "qrc:/Assets/Previous.png"
                height: width
                width: parent.width * 0.7
                anchors.centerIn: parent
                colorDefault: "white"
                enabled: false
                foregroundColor: themeManager.contentColor
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            DefaultImageButton {
                id: next

                source: "qrc:/Assets/Next.png"
                height: width
                width: parent.width * 0.7
                anchors.centerIn: parent
                colorDefault: "white"
                enabled: false
                foregroundColor: themeManager.contentColor
            }
        }
    }
}
