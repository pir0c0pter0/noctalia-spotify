import QtQuick
import qs.Commons
import qs.Services.Media

Item {
    id: root

    property bool playing: false
    property color barColor: Color.mPrimary

    implicitHeight: 20
    implicitWidth: parent ? parent.width : 200

    readonly property bool hasRealData: !SpectrumService.isIdle && SpectrumService.values.length > 0
    readonly property int barCount: 32
    readonly property real gap: 1.5
    readonly property real barWidth: root.width > 0 ? Math.max(2, (root.width - (barCount - 1) * gap) / barCount) : 3

    // Smoothed values for fluid animation
    property var smoothValues: new Array(barCount).fill(0)

    readonly property string spectrumId: "plugin:spotify:" + Date.now() + Math.random()

    Component.onCompleted: {
        SpectrumService.registerComponent(spectrumId)
    }

    Component.onDestruction: {
        SpectrumService.unregisterComponent(spectrumId)
    }

    // Fast update loop using scene graph rectangles
    Repeater {
        model: root.barCount

        Rectangle {
            x: index * (root.barWidth + root.gap)
            width: root.barWidth
            height: Math.max(1, root.smoothValues[index] * root.height)
            y: root.height - height
            radius: 1
            color: root.barColor

            Behavior on height {
                NumberAnimation { duration: 50; easing.type: Easing.OutQuad }
            }
        }
    }

    // High-frequency update from SpectrumService
    Connections {
        target: SpectrumService
        function onValuesChanged() {
            if (!root.playing || !root.visible) return
            root.updateBars()
        }
    }

    // Fallback random animation
    Timer {
        interval: 50
        repeat: true
        running: root.playing && root.visible && !root.hasRealData
        onTriggered: root.updateBars()
    }

    function updateBars() {
        var values = SpectrumService.values
        var newVals = new Array(barCount)

        for (var i = 0; i < barCount; i++) {
            if (hasRealData && values.length > 0) {
                var specIdx = Math.floor(i * values.length / barCount)
                var val = values[specIdx] || 0
                newVals[i] = Math.min(1.0, val * 2.0)
            } else if (playing) {
                newVals[i] = Math.random() * 0.7 + 0.05
            } else {
                newVals[i] = 0
            }
        }

        smoothValues = newVals
    }
}
