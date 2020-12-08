import QtQuick 2.15

Rectangle {
    color: index % 4 === 0 ? "red" : index % 4 === 1 ? "green" : index % 4 === 2 ? "yellow" : "purple"
    border.color: "blue"
    border.width: 5
}
