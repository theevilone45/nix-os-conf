import Quickshell
import QtQuick

// Clock and password prompt shared by the lock screen (Lock.qml) and the boot greeter (Greeter.qml),
// so the two look identical.
Item {
    id: root

    property bool busy: false
    property string error: ""
    property bool wallpaper: true

    signal submit(string password)

    function clear() {
        input.text = "";
        input.forceActiveFocus();
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }
    Image {
        anchors.fill: parent
        visible: root.wallpaper
        source: root.wallpaper ? "file://" + Theme.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
    Rectangle {
        anchors.fill: parent
        color: "#bb000000"
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Column {
        anchors.centerIn: parent
        spacing: 16

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: 96
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")
            color: Theme.dim
            font.family: Theme.font
            font.pixelSize: 20
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            height: 44
            color: Theme.bg
            border.color: root.error === "" ? Theme.accent : "#d04040"
            border.width: 2

            TextInput {
                id: input
                anchors.fill: parent
                anchors.margins: 10
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                color: Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                enabled: !root.busy
                focus: true

                Component.onCompleted: forceActiveFocus()
                onAccepted: root.submit(text)
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.busy ? "Checking..." : root.error
            color: "#d04040"
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
        }
    }
}
