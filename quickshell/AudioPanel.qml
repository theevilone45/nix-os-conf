import Quickshell.Services.Pipewire
import QtQuick

Rectangle {
    id: root

    readonly property var nodes: Pipewire.nodes.values

    function byClass(mediaClass) {
        return nodes.filter(n => n.audio && n.properties["media.class"] === mediaClass);
    }
    function appName(n) {
        return n.properties["application.name"] || n.description || n.name;
    }

    readonly property var sinks: byClass("Audio/Sink")
    readonly property var apps: byClass("Stream/Output/Audio")

    // Nodes only expose audio and properties once tracked.
    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    implicitWidth: 440
    implicitHeight: col.implicitHeight + 24
    color: Theme.bg
    border.color: Theme.accent
    border.width: 2

    component Header: Text {
        color: Theme.accent
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.bold: true
    }

    Column {
        id: col
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        Header {
            text: "OUTPUT"
        }
        Loader {
            width: parent.width
            active: Pipewire.defaultAudioSink !== null
            sourceComponent: MixerRow {
                node: Pipewire.defaultAudioSink
                label: node ? (node.description || node.name) : ""
            }
        }

        Repeater {
            model: root.sinks

            Rectangle {
                id: sinkEntry
                required property PwNode modelData
                readonly property bool isDefault: Pipewire.defaultAudioSink === modelData
                width: col.width
                height: 28
                color: area.containsMouse ? Theme.accent : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    width: parent.width - 12
                    elide: Text.ElideRight
                    text: (sinkEntry.isDefault ? "🟢 " : "⚪ ") + (sinkEntry.modelData.description || sinkEntry.modelData.name)
                    color: Theme.fg
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Pipewire.preferredDefaultAudioSink = sinkEntry.modelData
                }
            }
        }

        Header {
            text: "APPLICATIONS"
        }
        Text {
            visible: root.apps.length === 0
            text: "Nothing playing"
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
        }
        Repeater {
            model: root.apps

            MixerRow {
                required property PwNode modelData
                width: col.width
                node: modelData
                label: root.appName(modelData)
            }
        }
    }
}
