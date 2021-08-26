import QtQuick 2.12
import QtQuick.Window 2.12

Rectangle {
    color: "#081D34"

    VueMetreTitle {
        id: vueMetreTitle
        width: parent.width * 0.8
        x: parent.width / 2 - width / 2
    }

    VueMetreLevelDisplayBackground {
        id: vueMetreLevelDisplayBackgroundLeft
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
    }

    VueMetreLevelDisplayBackground {
        id: vueMetreLevelDisplayBackgroundRight
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
    }

    ListView {
        visible: false
        id: leftCounter
        width: parent.width / 4
        spacing: 10

        model: vumetre.height / 100

        delegate: Rectangle {
            width: leftCounter.width
            height: vumetre.height / 100
            color: "gray"
        }
    }
}
