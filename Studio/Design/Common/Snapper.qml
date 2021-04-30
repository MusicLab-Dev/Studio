import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

import "../Default"

DefaultComboBox {
    textRole: "label"
    valueRole: "value"

    model: ListModel {
        ListElement {
            label: "Free"
            value: 0
        }
        ListElement {
            label: "1/8"
            value: 16
        }
        ListElement {
            label: "1/4"
            value: 32
        }
        ListElement {
            label: "1/2"
            value: 64
        }
        ListElement {
            label: "1/1"
            value: 128
        }
        ListElement {
            label: "2/1"
            value: 256
        }
        ListElement {
            label: "3/1"
            value: 384
        }
        ListElement {
            label: "4/1"
            value: 512
        }
        ListElement {
            label: "6/1"
            value: 768
        }
        ListElement {
            label: "8/1"
            value: 1024
        }
    }
}
