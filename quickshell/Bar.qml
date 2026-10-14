import Quickshell
import Quickshell.Hyprland
import QtQuick

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }
        margins {
            top: 5
            left: 10
            right: 10
        }
        implicitHeight: 30
        color: Theme.bg

        // Which panel is open: "", "calendar" or "power". Only one at a time.
        property string openPanel: ""
        function toggle(name) {
            openPanel = openPanel === name ? "" : name;
        }

        // Workspaces
        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
            spacing: 4

            Repeater {
                model: Hyprland.workspaces.values
                    .filter(w => w.id > 0)
                    .sort((a, b) => a.id - b.id)

                Rectangle {
                    id: ws
                    required property HyprlandWorkspace modelData
                    width: 28
                    height: 22
                    color: modelData.focused ? Theme.accent : "transparent"
                    border.color: modelData.urgent ? "#d04040" : (modelData.focused ? Theme.accent : Theme.dim)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: ws.modelData.name
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + ws.modelData.id)
                    }
                }
            }
        }

        // Clock, opens the calendar
        Item {
            id: clock
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: powerButton.left
            anchors.rightMargin: 16
            width: clockText.implicitWidth
            height: parent.height

            SystemClock {
                id: sysClock
                precision: SystemClock.Minutes
            }
            Text {
                id: clockText
                anchors.centerIn: parent
                text: Qt.formatDateTime(sysClock.date, "ddd d MMM  HH:mm")
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
            MouseArea {
                anchors.fill: parent
                onClicked: bar.toggle("calendar")
            }
        }

        // Power trigger, opens the power panel
        Item {
            id: powerButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            width: powerText.implicitWidth
            height: parent.height

            Text {
                id: powerText
                anchors.centerIn: parent
                text: "Power"
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
            MouseArea {
                anchors.fill: parent
                onClicked: bar.toggle("power")
            }
        }

        PopupWindow {
            id: calendarPopup
            anchor.item: clock
            anchor.edges: Edges.Bottom | Edges.Right
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.margins.top: 5
            implicitWidth: calendar.implicitWidth
            implicitHeight: calendar.implicitHeight
            visible: bar.openPanel === "calendar"
            color: "transparent"

            onVisibleChanged: if (visible) calendar.reset()

            Calendar {
                id: calendar
                anchors.fill: parent
            }
        }

        PopupWindow {
            id: powerPopup
            anchor.item: powerButton
            anchor.edges: Edges.Bottom | Edges.Right
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.margins.top: 5
            implicitWidth: powerPanel.implicitWidth
            implicitHeight: powerPanel.implicitHeight
            visible: bar.openPanel === "power"
            color: "transparent"

            PowerPanel {
                id: powerPanel
                anchors.fill: parent
                onDone: bar.openPanel = ""
            }
        }

        // Close any panel on outside click; the bar is included so clicking
        // a trigger toggles instead of close-then-reopen.
        HyprlandFocusGrab {
            windows: [calendarPopup, powerPopup, bar]
            active: bar.openPanel !== ""
            onCleared: bar.openPanel = ""
        }
    }
}
