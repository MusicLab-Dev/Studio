import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15


Rectangle {

    color: "#00ECBA"

    Behavior on x {
        enabled: !app.scheduler.running

        SpringAnimation {
            spring: 1
            damping: 0.2
        }
    }
}
