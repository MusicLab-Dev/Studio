import QtQuick 2.15

BoardBackground {
    property string moduleName: "Boards"
    property int moduleIndex: -1

    function onNodeDeleted(targetNode) { return false }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) { return false }

    id: boardViewBackground
    color: themeManager.foregroundColor

    BoardViewTitle {
        id: boardViewTitle
        width: parent.width
    }

    BoardManagerView {
        id: boardManagerView
        anchors.top: boardViewTitle.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.width * 0.02
        visible: !boardControlsView.visible
    }

    BoardControlsView {
        id: boardControlsView
        anchors.top: boardViewTitle.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.width * 0.02
    }

    Text {
        property bool closeButtonHovered: false

        id: closeBtn
        x: parent.width - width - height
        y: height
        text: "Back"
        font.pointSize: 14
        font.weight: Font.DemiBold
        color: closeBtn.closeButtonHovered ? themeManager.foreground : "#FFFFFF"
        opacity: closeBtn.closeButtonHovered ? 1 : 0.7
        visible: boardControlsView.visible

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: { closeBtn.closeButtonHovered = true }

            onExited: { closeBtn.closeButtonHovered = false }

            onReleased: { boardControlsView.close() }
        }
    }
}
