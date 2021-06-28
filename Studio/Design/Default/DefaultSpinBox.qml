import QtQuick 2.15
import QtQuick.Controls 2.15

SpinBox {
    id: control
    hoverEnabled: true
    width: parent.width
    height: parent.height

    background: Rectangle {
        color: "#001E36"
        border.color: control.up.pressed ? themeManager.accentColor : control.hovered ? "#0D86CB" : "#295F8B"
    }

    contentItem: TextInput {
        text: control.textFromValue(control.value, control.locale)
        width: control.width / 2
        height: control.height

        font: control.font
        color: "#295F8B"
        selectionColor: "#21be2b"
        selectedTextColor: "#ffffff"
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        width: parent.width / 4
        color: "#001E36"
        border.color: control.up.pressed ? themeManager.accentColor : control.hovered ? "#0D86CB" : "#295F8B"

        Text {
            text: "+"
            font.pixelSize: control.font.pixelSize * 2
            color: control.up.pressed ? themeManager.accentColor : control.hovered ? "#0D86CB" : "#295F8B"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        width: parent.width / 4
        color: "#001E36"
        border.color: control.down.pressed ? themeManager.accentColor : control.hovered ? "#0D86CB" : "#295F8B"

        Text {
            text: "-"
            font.pixelSize: control.font.pixelSize * 2
            color: control.down.pressed ? themeManager.accentColor : control.hovered ? "#0D86CB" : "#295F8B"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
