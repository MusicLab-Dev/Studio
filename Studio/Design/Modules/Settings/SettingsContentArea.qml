import QtQuick 2.15
import QtQuick.Controls 2.15

import SettingsListModel 1.0

Rectangle {
    id: settingsContentArea
    color: "#001E36"

    ListView {
        id: listView
        anchors.fill: parent

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
            id: settingsModel
        }

        delegate: Column {
            property string paramCategory: subcategory
            property bool categoryVisible: false

            id: delegateCol
            width: listView.width

            Loader {
                id: categoryHeaderLoader
                source: delegateCol.categoryVisible ? "qrc:/Modules/Settings/CategoryHeader.qml" : ""
                visible: delegateCol.categoryVisible
                width: listView.width
                height: 20
            }

            Loader {
                id: delegateLoader
                width: listView.width
                height: 40
                source: "qrc:/Modules/Settings/SettingsDelegates/" + type + "Delegate.qml"
            }
        }
    }
}
