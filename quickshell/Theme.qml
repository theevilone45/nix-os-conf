pragma Singleton
import Quickshell
import QtQuick

QtObject {
    readonly property color bg: "#1a1a1a"
    readonly property color fg: "#ffffff"
    readonly property color dim: "#8a8a8a"
    readonly property color accent: "#519a66"
    readonly property string font: "CaskaydiaCove Nerd Font"
    readonly property int fontSize: 14

    // Edit and save to change the wallpaper; Quickshell reloads on save.
    readonly property string wallpaper: Quickshell.env("HOME") + "/Wallpapers/Unkown.jpg"
}
