import QtQuick
import QtQuick.Layouts
import qs.Commons

RowLayout {
    id: root

    property var mainInstance: null
    property bool isPlaying: false

    spacing: Style.marginL

    readonly property color activeColor: Color.mPrimary
    readonly property color inactiveColor: Color.mOnSurfaceVariant
    readonly property color hoverColor: Color.mOnSurface
    readonly property int fontSize: Style.fontSizeL

    // Previous
    Text {
        id: prevBtn
        font.family: "monospace"
        font.pixelSize: root.fontSize
        color: prevArea.containsMouse ? root.hoverColor : root.inactiveColor
        text: " ◄◄ "

        MouseArea {
            id: prevArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { if (root.mainInstance) root.mainInstance.prevTrack() }
        }
    }

    // Play/Pause
    Text {
        id: playPauseBtn
        font.family: "monospace"
        font.pixelSize: root.fontSize + 2
        color: playArea.containsMouse ? root.hoverColor : root.activeColor
        text: root.isPlaying ? " ❚❚ " : " ▶ "

        MouseArea {
            id: playArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { if (root.mainInstance) root.mainInstance.togglePlayPause() }
        }
    }

    // Next
    Text {
        id: nextBtn
        font.family: "monospace"
        font.pixelSize: root.fontSize
        color: nextArea.containsMouse ? root.hoverColor : root.inactiveColor
        text: " ►► "

        MouseArea {
            id: nextArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { if (root.mainInstance) root.mainInstance.nextTrack() }
        }
    }
}
