import QtQuick 2.15

import PluginModel 1.0

Loader {
    property color color

    id: delegateLoader

    source: {
        switch (controlType) {
        case PluginModel.Boolean:
            return "qrc:/Common/PluginControls/BooleanControl.qml"
        case PluginModel.Integer:
            return "qrc:/Common/PluginControls/IntegerControl.qml"
        case PluginModel.Floating:
            return "qrc:/Common/PluginControls/FloatingControl.qml"
        case PluginModel.Enum:
            return "qrc:/Common/PluginControls/EnumControl.qml"
        default:
            return ""
        }
    }

    onLoaded: {
        item.accentColor = color
    }
}