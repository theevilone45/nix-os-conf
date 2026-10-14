import Quickshell.Services.Pipewire
import QtQuick

// One volume row for a PipeWire node; the node must be tracked by a PwObjectTracker.
Item {
    id: root

    required property PwNode node
    property string label: ""

    // The node can vanish briefly, e.g. when a Bluetooth profile switch recreates it.
    readonly property var audio: node ? node.audio : null

    height: 28

    Text {
        id: name
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width: 110
        elide: Text.ElideRight
        text: root.label
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
    }
    VolumeSlider {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: name.right
        anchors.leftMargin: 8
        anchors.right: pct.left
        anchors.rightMargin: 8
        value: root.audio ? root.audio.volume : 0
        muted: root.audio ? root.audio.muted : false
        onMoved: v => {
            if (root.audio)
                root.audio.volume = v;
        }
    }
    Text {
        id: pct
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: mute.left
        anchors.rightMargin: 8
        width: 36
        horizontalAlignment: Text.AlignRight
        text: root.audio ? Math.round(root.audio.volume * 100) + "%" : ""
        color: Theme.dim
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
    }
    Text {
        id: mute
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        text: root.audio && root.audio.muted ? "🔇" : "🔊"
        font.pixelSize: Theme.fontSize

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            onClicked: {
                if (root.audio)
                    root.audio.muted = !root.audio.muted;
            }
        }
    }
}
