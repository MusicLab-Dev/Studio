import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../../Default"

Row {
    anchors.fill: parent

    Text {
        id: sliderDescription
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        color: "#295F8B"
    }

    Text {
        text: slider.from
        color: "#295F8B"
        x: sliderDescription.x + sliderDescription.width
        y: slider.y
    }

    DefaultSlider {
        id: slider
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height / 1.5
        from: range[0]
        to: range[1]
        stepSize: range[2]
        value: roleValue
        onValueChanged: roleValue = value
        snapMode: Slider.SnapAlways
    }

    Text {
        text: slider.to
        color: "#295F8B"
    }

}
