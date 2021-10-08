import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"
import "../Default"

import KeyboardEventListener 1.0

Column {
    readonly property real rightPadding: scrollBar.width + 15
    readonly property real rowHeight: 50

    id: keyboardShortcutsContent
    spacing: 20

    Row {
        id: keyboardCategories
        width: parent.width - keyboardShortcutsContent.rightPadding
        spacing: 20

        DefaultText {
            width: parent.width * 0.25 - parent.spacing * 3 / 4
            height: keyboardShortcutsContent.rowHeight
            horizontalAlignment: Text.AlignLeft
            font.pointSize: 15
            text: qsTr("Command")
            font.underline: true
            color: "lightgrey"
        }

        DefaultText {
            width: parent.width * 0.15 - parent.spacing * 3 / 4
            height: keyboardShortcutsContent.rowHeight
            horizontalAlignment: Text.AlignLeft
            font.pointSize: 15
            text: qsTr("Keybinding")
            font.underline: true
            color: "lightgrey"
        }

        DefaultText {
            width: parent.width * 0.07 - parent.spacing * 3 / 4
            height: keyboardShortcutsContent.rowHeight
            font.pointSize: 15
            text: qsTr("Repeat")
            horizontalAlignment: Text.AlignLeft
            font.underline: true
            color: "lightgrey"
        }

        DefaultText {
            width: parent.width * 0.33 - parent.spacing * 3 / 4
            height: keyboardShortcutsContent.rowHeight
            horizontalAlignment: Text.AlignLeft
            font.pointSize: 15
            text: qsTr("Description")
            font.underline: true
            color: "lightgrey"
        }

        TextRoundedButton {
            width: parent.width * 0.20 - parent.spacing * 3 / 4
            height: keyboardShortcutsContent.rowHeight / 1.35
            y: parent.height / 2 - height / 2
            font.pointSize: 15
            text: qsTr("Add Keyboard Shortcut")

            onReleased: {
                eventDispatcher.keyboardListener.add(0, 0, KeyboardEventListener.Action)
                shortcutsListView.positionViewAtEnd()
            }

        }
    }

    ListView {
        property int selectedIndex: -1

        id: shortcutsListView
        width: parent.width
        height: parent.height - keyboardCategories.height - parent.spacing
        spacing: 10
        clip: true
        model: eventDispatcher.keyboardListener

        delegate: MouseArea {
            readonly property bool isSelectedShortcut: index === shortcutsListView.selectedIndex
            readonly property int delegateIndex: index

            id: rowDelegate
            width: shortcutsListView.width - keyboardShortcutsContent.rightPadding
            height: keyboardShortcutsContent.rowHeight
            hoverEnabled: true

            onPressed: shortcutsListView.selectedIndex = index

            Rectangle {
                anchors.fill: parent
                color: themeManager.foregroundColor
                radius: 8
                visible: rowDelegate.isSelectedShortcut || rowDelegate.containsMouse
            }

            Row {
                anchors.fill: parent
                spacing: 20

                EventTargetComboBox {
                    id: eventTargetComboBox
                    width: parent.width * 0.25 - parent.spacing * 3 / 4
                    height: 40
                    y: rowDelegate.height / 2 - height / 2
                    hoverEnabled: true

                    onActivated: eventType = index

                    onPressedChanged: shortcutsListView.selectedIndex = rowDelegate.delegateIndex

                }

                DefaultTextButton {
                    width: parent.width * 0.15 - parent.spacing * 3 / 4
                    height: keyboardShortcutsContent.rowHeight
                    font.pointSize: 14
                    text: {
                        if (eventKey === 0)
                            return qsTr("Undefined")
                        else
                            return eventDispatcher.keyboardListener.keyToString(eventKey, eventModifiers)
                    }

                    onReleased: {
                        keySequencePopup.open(
                            function() {
                                eventKey = keySequencePopup.key
                                eventModifiers = keySequencePopup.modifiers
                            },
                            function() {}
                        )
                        shortcutsListView.selectedIndex = index
                    }
                }

                Item {
                    width: parent.width * 0.07 - parent.spacing * 3 / 4
                    height: keyboardShortcutsContent.rowHeight

                    DefaultCheckBox {
                        width: height
                        height: parent.height / 2
                        anchors.centerIn: parent
                        text: ""
                        checked: eventRepeat

                        onCheckedChanged: {
                            eventRepeat = checked
                            shortcutsListView.selectedIndex = index
                        }
                    }
                }

                DefaultText {
                    width: parent.width * 0.48 - parent.spacing * 3 / 4
                    height: keyboardShortcutsContent.rowHeight
                    horizontalAlignment: Text.AlignLeft
                    text: eventDispatcher.keyboardListener.eventTargetToDescription(eventType)
                    wrapMode: Text.Wrap
                    color: "lightgrey"
                }

                DefaultTextButton {
                    width: parent.width * 0.05 - parent.spacing * 3 / 4
                    height: keyboardShortcutsContent.rowHeight
                    text: "X"
                    font.pointSize: 14
                    font.bold: true
                    visible: rowDelegate.isSelectedShortcut || rowDelegate.containsMouse

                    onReleased: eventDispatcher.keyboardListener.remove(index)
                }
            }
        }

        ScrollBar.vertical: DefaultScrollBar {
            id: scrollBar
            color: themeManager.accentColor
            visible: true
        }
    }
}
