import Quickshell
import Quickshell.Wayland
import QtQuick

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
            source: "file://" + Theme.wallpaper
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }
}
