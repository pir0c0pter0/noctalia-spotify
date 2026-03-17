import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property var mainInstance: pluginApi?.mainInstance
    readonly property bool spotifyFound: mainInstance?.spotifyFound ?? false
    readonly property bool spotifyInstalled: mainInstance?.spotifyInstalled ?? false
    readonly property bool isPlaying: mainInstance?.isPlaying ?? false
    readonly property string trackTitle: mainInstance?.trackTitle ?? ""
    readonly property string trackArtist: mainInstance?.trackArtist ?? ""

    readonly property var settings: pluginApi?.pluginSettings ?? ({})
    readonly property bool showArtist: settings.showArtist ?? true
    readonly property int maxTitleLength: settings.maxTitleLength ?? 25

    readonly property string screenName: screen ? screen.name : ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)

    readonly property string displayText: {
        if (!spotifyFound) return "♫"
        if (!trackTitle) return "♫"
        var t = trackTitle
        if (showArtist && trackArtist) {
            t = trackArtist + " — " + t
        }
        if (t.length > maxTitleLength) {
            t = t.substring(0, maxTitleLength) + "…"
        }
        return t
    }

    readonly property real contentWidth: {
        if (isVertical) return capsuleHeight
        return contentRow.implicitWidth + Style.marginM * 2
    }
    readonly property real contentHeight: capsuleHeight

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    visible: spotifyFound || spotifyInstalled

    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        color: mouseArea.containsMouse ? Color.mHover : Style.capsuleColor
        radius: Style.radiusL
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: Style.marginS

            // Play/pause indicator
            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "monospace"
                font.pixelSize: Style.fontSizeS
                color: root.isPlaying ? Color.mPrimary : Color.mOnSurface
                text: root.isPlaying ? "▶" : "❚❚"

                SequentialAnimation on opacity {
                    running: root.isPlaying && root.visible
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.5; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                    onRunningChanged: if (!running) parent.opacity = 1.0
                }
            }

            // Track info
            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "monospace"
                font.pixelSize: Style.fontSizeS
                color: Color.mOnSurface
                text: root.displayText
                visible: !root.isVertical
            }
        }
    }

    NPopupContextMenu {
        id: contextMenu

        model: {
            var items = []
            if (spotifyFound) {
                items.push({
                    "label": isPlaying
                        ? (pluginApi?.tr("widget.tooltip") ?? "Pause")
                        : (pluginApi?.tr("widget.tooltip") ?? "Play"),
                    "action": "play-pause",
                    "icon": isPlaying ? "player-pause" : "player-play"
                })
            } else {
                items.push({
                    "label": pluginApi?.tr("widget.open-spotify") ?? "Open Spotify",
                    "action": "open-spotify",
                    "icon": "spotify"
                })
            }
            items.push({
                "label": pluginApi?.tr("bar.settings") ?? "Settings",
                "action": "widget-settings",
                "icon": "flask"
            })
            return items
        }

        onTriggered: action => {
            contextMenu.close()
            PanelService.closeContextMenu(screen)
            if (action === "play-pause" && mainInstance) {
                mainInstance.togglePlayPause()
            } else if (action === "open-spotify" && mainInstance) {
                mainInstance.openSpotify()
            } else if (action === "widget-settings") {
                BarService.openPluginSettings(screen, pluginApi.manifest)
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                if (pluginApi) {
                    pluginApi.togglePanel(root.screen, root)
                }
            } else if (mouse.button === Qt.RightButton) {
                PanelService.showContextMenu(contextMenu, root, screen)
            }
        }
    }
}
