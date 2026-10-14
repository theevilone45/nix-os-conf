import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// Application launcher. Toggled over IPC: `quickshell ipc call launcher toggle`.
Scope {
    id: root

    property bool shown: false
    property string query: ""

    // Same terminal as $terminal in hyprland.conf; used for Terminal=true entries.
    readonly property string terminal: "kitty"

    function launch(entry) {
        shown = false;
        if (entry.runInTerminal)
            Quickshell.execDetached([terminal].concat(entry.command));
        else
            entry.execute();
    }

    readonly property var results: {
        const q = query.trim().toLowerCase();
        const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay);
        const rank = a => {
            const name = a.name.toLowerCase();
            if (q === "" || name.startsWith(q))
                return 0;
            if (name.includes(q))
                return 1;
            const rest = (a.genericName + " " + a.keywords.join(" ")).toLowerCase();
            return rest.includes(q) ? 2 : -1;
        };
        return apps.map(a => ({ entry: a, rank: rank(a) }))
            .filter(x => x.rank >= 0)
            .sort((x, y) => x.rank - y.rank || x.entry.name.localeCompare(y.entry.name))
            .map(x => x.entry);
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.query = "";
            root.shown = !root.shown;
        }
    }

    // Built only while open: fresh state each time and no icon loading at startup.
    LazyLoader {
        active: root.shown

        PanelWindow {
            id: window
            visible: true
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell-launcher"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Component.onCompleted: input.forceActiveFocus()

            // Click outside the box closes the launcher.
            MouseArea {
                anchors.fill: parent
                onClicked: root.shown = false
            }

            Rectangle {
                id: box
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height * 0.2
                width: 560
                height: inputRow.height + (list.count > 0 ? Math.min(list.count, 10) * 36 + 16 : 0) + 16
                color: Theme.bg
                border.color: Theme.accent
                border.width: 2

                // Swallow clicks so they don't reach the closing MouseArea.
                MouseArea {
                    anchors.fill: parent
                }

                Item {
                    id: inputRow
                    x: 8
                    y: 8
                    width: parent.width - 16
                    height: 36

                    TextInput {
                        id: input
                        anchors.fill: parent
                        anchors.margins: 6
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize + 2
                        focus: true

                        onTextChanged: {
                            root.query = text;
                            list.currentIndex = 0;
                        }
                        Keys.onEscapePressed: root.shown = false
                        Keys.onDownPressed: list.incrementCurrentIndex()
                        Keys.onUpPressed: list.decrementCurrentIndex()
                        Keys.onReturnPressed: {
                            const entry = root.results[list.currentIndex];
                            if (entry)
                                root.launch(entry);
                        }
                    }
                }

                ListView {
                    id: list
                    x: 8
                    y: inputRow.height + 16
                    width: parent.width - 16
                    height: Math.min(count, 10) * 36
                    clip: true
                    model: root.results
                    currentIndex: 0
                    highlightMoveDuration: 0

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        width: list.width
                        height: 36
                        color: index === list.currentIndex ? Theme.accent : "transparent"

                        Image {
                            id: icon
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            width: 24
                            height: 24
                            sourceSize: Qt.size(24, 24)
                            source: Quickshell.iconPath(row.modelData.icon, true)
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: icon.right
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            elide: Text.ElideRight
                            text: row.modelData.name
                            color: Theme.fg
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.launch(row.modelData)
                        }
                    }
                }
            }
        }
    }
}
