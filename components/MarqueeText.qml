import QtQuick
import qs.Commons

Item {
    id: root

    property string textContent: ""
    property color textColor: Color.mOnSurface
    property int scrollSpeed: 60
    property real maxWidth: 200

    implicitHeight: clippedText.implicitHeight
    implicitWidth: Math.min(maxWidth, measurer.implicitWidth)
    clip: true

    Text {
        id: measurer
        visible: false
        font.family: "monospace"
        font.pixelSize: Style.fontSizeM
        text: root.textContent
    }

    readonly property bool needsScroll: measurer.implicitWidth > root.maxWidth

    Text {
        id: clippedText
        font.family: "monospace"
        font.pixelSize: Style.fontSizeM
        color: root.textColor
        text: root.needsScroll ? root.textContent + "   " + root.textContent : root.textContent
        x: 0

        NumberAnimation on x {
            from: 0
            to: -(measurer.implicitWidth + Style.fontSizeM * 1.8)
            duration: root.textContent.length * root.scrollSpeed
            loops: Animation.Infinite
            running: root.needsScroll && root.visible
        }
    }
}
