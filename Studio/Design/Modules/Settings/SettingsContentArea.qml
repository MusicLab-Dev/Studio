import QtQuick 2.15
import QtQuick.Controls 2.15

import SettingsListModel 1.0

Rectangle {
    id: settingsContentArea
    color: "#001E36"

    ListView {
        id: listView
        anchors.fill: parent

        model: SettingsListModelProxy {
        }

        delegate: Loader {
            width: listView.width
            height: 40
            source: "qrc:/Modules/Settings/SettingsDelegates/" + type + "Delegate.qml"
        }
    }
}