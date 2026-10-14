pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Current wallpaper: the choice saved in the state file, else the Theme default.
// pick() runs yazi in kitty and applies the file it opens.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string stateFile: (Quickshell.env("XDG_STATE_HOME") || home + "/.local/state") + "/quickshell/wallpaper"
    readonly property string chooserFile: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/quickshell-wallpaper-choice"

    property string saved: ""
    readonly property string path: saved !== "" ? saved : Theme.wallpaper

    function pick() {
        if (!picker.running)
            picker.running = true;
    }

    function choose(file) {
        if (!/\.(jpe?g|png|webp|bmp|gif)$/i.test(file))
            return;
        saved = file;
        writer.command = ["sh", "-c", 'mkdir -p "$(dirname "$1")" && printf %s "$2" > "$1"', "sh", stateFile, file];
        writer.running = true;
    }

    FileView {
        path: root.stateFile
        blockLoading: true
        printErrors: false
        onLoaded: root.saved = text().trim()
    }

    Process {
        id: writer
    }

    Process {
        id: picker
        command: ["sh", "-c", 'rm -f "$1"; kitty --class wallpaper-picker yazi --chooser-file="$1" "$2"; head -n 1 "$1" 2>/dev/null', "sh", root.chooserFile, root.home + "/Wallpapers"]
        stdout: StdioCollector {
            onStreamFinished: root.choose(text.trim())
        }
    }
}
