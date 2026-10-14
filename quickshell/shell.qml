import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    Bar {}

    // Edit and save to change the wallpaper; Quickshell reloads on save.
    property string wallpaper: Quickshell.env("HOME") + "/Wallpapers/Unkown.jpg"

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "quickshell-wallpaper"
            exclusionMode: ExclusionMode.Ignore
            color: "black"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Image {
                anchors.fill: parent
                source: "file://" + wallpaper
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }
    }
}
