pragma Singleton
import QtQuick

QtObject {
    // Desktop entry IDs (filename without .desktop) pinned as icons on the bar, left to right.
    readonly property var apps: [
        "org.qutebrowser.qutebrowser",
        "steam",
        "dev.zed.Zed"
    ]
}
