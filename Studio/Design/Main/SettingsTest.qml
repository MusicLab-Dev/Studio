import QtQuick 2.0
import QtQuick.Controls 2.15

import SettingsListModel 1.0
import SettingsListModelProxy 1.0

Item {

    SettingsListModel {
        id: settingsListModel
        Component.onCompleted: {
            read(":/Templates/SettingsTest.json", "ValuesTest.json");
            load();
        }
    }

    ListView {
        anchors.fill: parent

        model: SettingsListModelProxy {
            id: proxy
            sourceModel: settingsListModel
            dynamicSortFilter: true
        }

        delegate:
            Loader {
                id: delegateLoader
                width: settingsListModel.width
                height: 40
                source: "qrc:/Modules/Settings/SettingsDelegates/" + type + "Delegate.qml"
            }
        }



    TextField {
        id: textfield
        anchors.right: parent.right
        width: 200
        hoverEnabled: true
        onTextChanged: {
            proxy.tags = text
        }
    }

    TextField {
        id: textfieldCategory
        y: 100
        anchors.right: parent.right
        width: 200
        hoverEnabled: true
        onTextChanged: {
            proxy.category = text
        }
    }

    Button {
        anchors.bottom: parent.bottom
        onClicked: {

            settingsListModel.saveValues()
        }
    }

}
