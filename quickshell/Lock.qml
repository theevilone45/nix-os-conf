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

            LockContent {
                id: content
                anchors.fill: parent
                busy: root.busy
                error: root.error
                onSubmit: password => root.submit(password)

                Connections {
                    target: root

                    function onFailed() {
                        content.clear();
                    }
                }
            }
        }
    }
}
