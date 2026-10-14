import QtQuick

Item {
    id: root

    property real value: 0
    property bool muted: false

    signal moved(real value)

    implicitHeight: 20

    function clamp(x) {
        return Math.max(0, Math.min(1, x));
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        color: "#444444"
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: track.width * root.clamp(root.value)
        height: track.height
        color: root.muted ? Theme.dim : Theme.accent
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: (track.width - width) * root.clamp(root.value)
        width: 10
        height: 18
        color: Theme.fg
    }
    MouseArea {
        anchors.fill: parent
        onPressed: mouse => root.moved(root.clamp(mouse.x / width))
        onPositionChanged: mouse => {
            if (pressed)
                root.moved(root.clamp(mouse.x / width));
        }
        onWheel: wheel => root.moved(root.clamp(root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)))
    }
}
