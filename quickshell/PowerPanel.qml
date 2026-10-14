import Quickshell
import QtQuick

Rectangle {
    id: root

    signal done

    readonly property var entries: [
        { label: "Lock", command: ["quickshell", "ipc", "call", "lock", "lock"] },
        { label: "Reboot", command: ["systemctl", "reboot"] },
        { label: "Shutdown", command: ["systemctl", "poweroff"] }
    ]

    implicitWidth: 180
    implicitHeight: col.implicitHeight + 16
    color: Theme.bg
    border.color: Theme.accent
    border.width: 2

    Column {
        id: col
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        Repeater {
            model: root.entries

            Rectangle {
                id: entry
                required property var modelData
                width: col.width
                height: 32
                color: area.containsMouse ? Theme.accent : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: entry.modelData.label
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.done();
                        Quickshell.execDetached(entry.modelData.command);
                    }
                }
            }
        }
    }
}
