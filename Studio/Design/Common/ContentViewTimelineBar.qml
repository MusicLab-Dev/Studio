import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15


Rectangle {
    Behavior on x {
        SpringAnimation {
            spring: 2
            damping: 0.2
        }
    }
}
