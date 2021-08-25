import QtQuick 2.15
import QtQuick.Controls 2.15

Text {
    id: settingsViewTitle
    text: settingsContentArea.settingsProxyModel.tags ? qsTr("Results") : settingsContentArea.settingsProxyModel.category
    color: "lightgrey"
    font.pointSize: 34
}
