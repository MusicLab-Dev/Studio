import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Row {
    height: 40
    spacing: 5

    DefaultText {
        id: sliderDescription
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        color: "white"
        horizontalAlignment: Text.AlignLeft
    }

    DefaultText {
        text: slider.from
        color: "white"
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

    DefaultText {
        text: slider.to
        color: "white"
    }

}
