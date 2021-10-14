import QtQuick 2.15
import QtQuick.Controls 2.15

import SettingsListModel 1.0

ListView {
    property alias settingsProxyModel: settingsProxyModel

    id: settingsContentArea
    width: parent.width
    height: parent.height
    spacing: 10

    onCountChanged: {
        var lastCategory = ""
        var item = null
        for (var i = 0; i < count; i++) {
            item = itemAtIndex(i)
            item.categoryVisible = lastCategory !== item.paramCategory
            lastCategory = item.paramCategory
        }
    }

    model: SettingsListModelProxy {
        id: settingsProxyModel
        sourceModel: app.settings
    }

    delegate: Column {
        property string paramCategory: {
            var tmp = category
            var idx = tmp.lastIndexOf('/')
            if (idx === -1)
                return tmp
            var firstOccurence = tmp.indexOf('/', 1)
            if (firstOccurence === idx || firstOccurence === - 1)
                return tmp.substr(idx + 1)
            else
                return tmp.substr(firstOccurence + 1)
        }
        property bool categoryVisible: false

        id: delegateCol
        width: settingsContentArea.width

        Loader {
            id: categoryHeaderLoader
            source: delegateCol.categoryVisible ? "qrc:/Settings/CategoryHeader.qml" : ""
            visible: delegateCol.categoryVisible
            width: settingsContentArea.width
            height: 40
        }

        Item {
            width: delegateLoader.width
            height: delegateLoader.height

            Loader {
                id: delegateLoader
                width: settingsContentArea.width
                source: "qrc:/Settings/SettingsDelegates/" + type + "Delegate.qml"
                focus: true
            }

            MouseArea {
                id: delegateMouseArea
                propagateComposedEvents: true
                hoverEnabled: true
                anchors.fill: parent
                onClicked: mouse.accepted = false
                onPressed: mouse.accepted = false
                onReleased: mouse.accepted = false
                onDoubleClicked: mouse.accepted = false
                onPositionChanged: mouse.accepted = false
                onPressAndHold: mouse.accepted = false
            }

            ToolTip {
                id: toolTip
                text: help
                visible: delegateMouseArea.containsMouse && text !== ""
            }
        }
    }
}
