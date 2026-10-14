import QtQuick

Rectangle {
    id: root

    property date today: new Date()
    property date shown: new Date(today.getFullYear(), today.getMonth(), 1)

    readonly property int offset: (shown.getDay() + 6) % 7 // weeks start on Monday

    function reset() {
        today = new Date();
        shown = new Date(today.getFullYear(), today.getMonth(), 1);
    }
    function step(months) {
        shown = new Date(shown.getFullYear(), shown.getMonth() + months, 1);
    }

    implicitWidth: 280
    implicitHeight: col.implicitHeight + 24
    color: Theme.bg
    border.color: Theme.accent
    border.width: 2

    Column {
        id: col
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                text: "<"
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: root.step(-1)
                }
            }
            Text {
                anchors.centerIn: parent
                text: Qt.formatDate(root.shown, "MMMM yyyy")
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
            Text {
                anchors.right: parent.right
                text: ">"
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: root.step(1)
                }
            }
        }

        Grid {
            columns: 7
            width: parent.width

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                Text {
                    required property string modelData
                    width: col.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.dim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
            }

            Repeater {
                model: 42

                Rectangle {
                    id: cell
                    required property int index
                    readonly property date day: new Date(root.shown.getFullYear(), root.shown.getMonth(), 1 - root.offset + index)
                    readonly property bool inMonth: day.getMonth() === root.shown.getMonth()
                    readonly property bool isToday: day.toDateString() === root.today.toDateString()

                    width: col.width / 7
                    height: 28
                    color: isToday ? Theme.accent : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: cell.day.getDate()
                        color: cell.inMonth ? Theme.fg : Theme.dim
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                    }
                }
            }
        }
    }
}
