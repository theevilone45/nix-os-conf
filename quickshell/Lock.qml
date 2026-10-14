import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pam
import QtQuick

// Session lock on ext-session-lock: if Quickshell dies while locked, the
// compositor keeps the session locked. Recovery: switch to another TTY
// (Ctrl+Alt+F3), log in and run `pkill quickshell`, then switch back
// and start quickshell again.
Scope {
    id: root

    property string wallpaper: ""
    property bool busy: false
    property string error: ""
    property string pending: ""

    signal failed

    function submit(password) {
        if (busy)
            return;
        busy = true;
        error = "";
        pending = password;
        pam.start();
    }

    PamContext {
        id: pam
        config: "quickshell" // /etc/pam.d/quickshell, declared in configuration.nix

        onResponseRequiredChanged: {
            if (responseRequired)
                respond(root.pending);
        }
        onCompleted: result => {
            root.pending = "";
            root.busy = false;
            if (result === PamResult.Success) {
                sessionLock.locked = false;
            } else {
                root.error = result === PamResult.Failed ? "Wrong password" : "Authentication error";
                root.failed();
            }
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            sessionLock.locked = true;
        }
    }

    WlSessionLock {
        id: sessionLock

        WlSessionLockSurface {
            color: "black"

            Image {
                anchors.fill: parent
                source: root.wallpaper === "" ? "" : "file://" + root.wallpaper
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
            Rectangle {
                anchors.fill: parent
                color: "#bb000000"
            }

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            Column {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: 96
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")
                    color: Theme.dim
                    font.family: Theme.font
                    font.pixelSize: 20
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 320
                    height: 44
                    color: Theme.bg
                    border.color: root.error === "" ? Theme.accent : "#d04040"
                    border.width: 2

                    TextInput {
                        id: input
                        anchors.fill: parent
                        anchors.margins: 10
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        enabled: !root.busy
                        focus: true

                        Component.onCompleted: forceActiveFocus()
                        onAccepted: root.submit(text)

                        Connections {
                            target: root

                            function onFailed() {
                                input.text = "";
                                input.forceActiveFocus();
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.busy ? "Checking..." : root.error
                    color: "#d04040"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                }
            }
        }
    }
}
