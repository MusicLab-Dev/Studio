import QtQuick 2.15

BoardBackground {
    function open() {
        visible = true
    }

    function close() {
        visible = false
    }

    id: boardsView
    color: themeManager.foregroundColor
    visible: false

    BoardsTitle {
        id: boardsViewTitle
        width: parent.width
    }

    BoardsManagerView {
        id: boardsManagerView
        anchors.top: boardsViewTitle.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.width * 0.02
        visible: !boardControlsView.visible
    }

    BoardControlsView {
        id: boardControlsView
        anchors.top: boardsViewTitle.bottom
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
