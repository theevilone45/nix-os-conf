import Quickshell
import Quickshell.Services.Greetd
import QtQuick

// Boot login screen. Runs as the greetd greeter under cage (see configuration.nix),
// not as part of the user shell; shares LockContent.qml with the lock screen.
ShellRoot {
    id: root

    readonly property string user: "marcins"
    readonly property var session: ["Hyprland"]
    readonly property var sessionEnv: ["XDG_SESSION_TYPE=wayland", "XDG_SESSION_DESKTOP=Hyprland", "XDG_CURRENT_DESKTOP=Hyprland"]

    property bool busy: false
    property string error: ""
    property string pending: ""

    function submit(password) {
        if (busy)
            return;
        busy = true;
        error = "";
        pending = password;
        Greetd.createSession(user);
    }

    function fail(message) {
        pending = "";
        busy = false;
        error = message;
        if (Greetd.state !== GreetdState.Inactive)
            Greetd.cancelSession();
        content.clear();
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, isError, responseRequired, echoResponse) {
            if (responseRequired) {
                const password = root.pending;
                root.pending = "";
                Greetd.respond(password);
            }
        }
        function onAuthFailure(message) {
            root.fail("Wrong password");
        }
        function onError(message) {
            root.fail("Login error");
        }
        function onReadyToLaunch() {
            Greetd.launch(root.session, root.sessionEnv, true);
        }
    }

    FloatingWindow {
        color: "black"

        LockContent {
            id: content
            anchors.fill: parent
            wallpaper: false
            busy: root.busy
            error: root.error
            onSubmit: password => root.submit(password)
        }
    }
}
