import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

Rectangle {
    id: root

    // Set by the bar; cards are only polled while the panel is open.
    property bool open: false

    // card name -> { active: string, profiles: [string] }
    property var cards: ({})

    readonly property var devices: Bluetooth.devices.values.filter(d => d.paired)

    function cardName(device) {
        return "bluez_card." + device.address.replace(/:/g, "_");
    }
    function refresh() {
        if (!cardsProc.running)
            cardsProc.running = true;
    }
    function parseCards(text) {
        let result = {};
        try {
            for (const c of JSON.parse(text)) {
                if (!c.name.startsWith("bluez_card."))
                    continue;
                result[c.name] = {
                    active: c.active_profile,
                    profiles: Object.keys(c.profiles).filter(p => p !== "off")
                };
            }
        } catch (e) {
            console.warn("bluetooth: could not parse pactl cards output:", e);
        }
        cards = result;
    }
    function setProfile(card, profile) {
        setter.command = ["pactl", "set-card-profile", card, profile];
        setter.running = true;
    }

    // Profiles are PipeWire card profiles, which Quickshell's Pipewire module
    // does not expose, so pactl is the one non-native dependency here.
    Process {
        id: cardsProc
        command: ["pactl", "-f", "json", "list", "cards"]
        stdout: StdioCollector {
            onStreamFinished: root.parseCards(text)
        }
    }
    Process {
        id: setter
        onExited: root.refresh()
    }
    Timer {
        interval: 1000
        repeat: true
        running: root.open
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    implicitWidth: 440
    implicitHeight: col.implicitHeight + 24
    color: Theme.bg
    border.color: Theme.accent
    border.width: 2

    Column {
        id: col
        anchors.fill: parent
        anchors.margins: 12
        spacing: 4

        Text {
            text: "BLUETOOTH"
            color: Theme.accent
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            font.bold: true
        }
        Text {
            visible: root.devices.length === 0
            text: Bluetooth.defaultAdapter ? "No paired devices" : "No Bluetooth adapter"
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
        }

        Repeater {
            model: root.devices

            Column {
                id: entry
                required property BluetoothDevice modelData
                readonly property var card: root.cards[root.cardName(modelData)]
                width: col.width
                spacing: 2

                Rectangle {
                    width: parent.width
                    height: 28
                    color: devArea.containsMouse ? Theme.accent : "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 6
                        anchors.right: status.left
                        elide: Text.ElideRight
                        text: (entry.modelData.connected ? "🟢 " : "⚪ ") + (entry.modelData.name || entry.modelData.deviceName)
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                    }
                    Text {
                        id: status
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        text: {
                            const s = entry.modelData.state;
                            if (s === BluetoothDeviceState.Connecting)
                                return "connecting...";
                            if (s === BluetoothDeviceState.Disconnecting)
                                return "disconnecting...";
                            if (entry.modelData.connected && entry.modelData.batteryAvailable)
                                return Math.round(entry.modelData.battery * 100) + "%";
                            return "";
                        }
                        color: Theme.dim
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                    }
                    MouseArea {
                        id: devArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: entry.modelData.connected = !entry.modelData.connected
                    }
                }

                // Audio profiles of a connected device
                Repeater {
                    model: entry.modelData.connected && entry.card ? entry.card.profiles : []

                    Rectangle {
                        id: profileRow
                        required property string modelData
                        readonly property bool active: entry.card.active === modelData
                        width: entry.width
                        height: 24
                        color: profArea.containsMouse ? Theme.accent : "transparent"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 28
                            anchors.right: parent.right
                            elide: Text.ElideRight
                            text: (profileRow.active ? "🟢 " : "    ") + profileRow.modelData
                            color: Theme.dim
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 3
                        }
                        MouseArea {
                            id: profArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.setProfile(root.cardName(entry.modelData), profileRow.modelData)
                        }
                    }
                }
            }
        }
    }
}
