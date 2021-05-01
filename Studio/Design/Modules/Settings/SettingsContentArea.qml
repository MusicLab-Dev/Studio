import QtQuick 2.15
import QtQuick.Controls 2.15

import SettingsListModel 1.0

ListView {
    property alias settingsProxyModel: settingsProxyModel

    id: settingsContentArea
    width: parent.width
    height: parent.height

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
            source: delegateCol.categoryVisible ? "qrc:/Modules/Settings/CategoryHeader.qml" : ""
            visible: delegateCol.categoryVisible
            width: settingsContentArea.width
            height: 40
        }

        Loader {
            id: delegateLoader
            width: settingsContentArea.width
            height: 40
            source: "qrc:/Modules/Settings/SettingsDelegates/" + type + "Delegate.qml"
        }
    }
}