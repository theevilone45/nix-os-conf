import Quickshell.Services.Pipewire
import QtQuick

// One volume row for a PipeWire node; the node must be tracked by a PwObjectTracker.
Item {
    id: root

    required property PwNode node
    property string label: ""

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
        value: root.node.audio ? root.node.audio.volume : 0
        muted: root.node.audio ? root.node.audio.muted : false
        onMoved: v => {
            if (root.node.audio)
                root.node.audio.volume = v;
        }
    }
    Text {
        id: pct
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: mute.left
        anchors.rightMargin: 8
        width: 36
        horizontalAlignment: Text.AlignRight
        text: root.node.audio ? Math.round(root.node.audio.volume * 100) + "%" : ""
        color: Theme.dim
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
    }
    Text {
        id: mute
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        text: root.node.audio && root.node.audio.muted ? "🔇" : "🔊"
        font.pixelSize: Theme.fontSize

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            onClicked: {
                if (root.node.audio)
                    root.node.audio.muted = !root.node.audio.muted;
            }
        }
    }
}
