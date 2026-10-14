import Quickshell
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
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

        // Which panel is open: "", "calendar", "audio", "bluetooth" or "power". Only one at a time.
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

        // Bluetooth trigger, opens the paired devices panel
        Item {
            id: bluetoothButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: audioButton.left
            anchors.rightMargin: 16
            width: bluetoothText.implicitWidth
            height: parent.height

            Text {
                id: bluetoothText
                anchors.centerIn: parent
                text: Bluetooth.defaultAdapter && !Bluetooth.defaultAdapter.enabled ? "Bluetooth off" : "Bluetooth"
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
            MouseArea {
                anchors.fill: parent
                onClicked: bar.toggle("bluetooth")
            }
        }

        // Audio trigger: live default output volume, opens the mixer
        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }
        Item {
            id: audioButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: clock.left
            anchors.rightMargin: 16
            width: audioText.implicitWidth
            height: parent.height

            readonly property var audio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null

            Text {
                id: audioText
                anchors.centerIn: parent
                text: !audioButton.audio ? "Audio" : (audioButton.audio.muted ? "Audio muted" : "Audio " + Math.round(audioButton.audio.volume * 100) + "%")
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
            }
            MouseArea {
                anchors.fill: parent
                onClicked: bar.toggle("audio")
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
            id: bluetoothPopup
            anchor.item: bluetoothButton
            anchor.edges: Edges.Bottom | Edges.Right
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.margins.top: 5
            implicitWidth: bluetoothPanel.implicitWidth
            implicitHeight: bluetoothPanel.implicitHeight
            visible: bar.openPanel === "bluetooth"
            color: "transparent"

            BluetoothPanel {
                id: bluetoothPanel
                anchors.fill: parent
                open: bluetoothPopup.visible
            }
        }

        PopupWindow {
            id: audioPopup
            anchor.item: audioButton
            anchor.edges: Edges.Bottom | Edges.Right
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.margins.top: 5
            implicitWidth: audioPanel.implicitWidth
            implicitHeight: audioPanel.implicitHeight
            visible: bar.openPanel === "audio"
            color: "transparent"

            AudioPanel {
                id: audioPanel
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
            windows: [calendarPopup, bluetoothPopup, audioPopup, powerPopup, bar]
            active: bar.openPanel !== ""
            onCleared: bar.openPanel = ""
        }
    }
}
