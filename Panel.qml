import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import "components"

Item {
    id: root

    property var pluginApi: null

    readonly property var geometryPlaceholder: panelContent
    property real contentPreferredWidth: 380 * Style.uiScaleRatio
    property real contentPreferredHeight: panelContent.implicitHeight + Style.marginL * 2

    readonly property var mainInstance: pluginApi?.mainInstance
    readonly property bool spotifyFound: mainInstance?.spotifyFound ?? false
    readonly property bool launching: mainInstance?.launching ?? false
    readonly property bool isPlaying: mainInstance?.isPlaying ?? false
    readonly property string trackTitle: mainInstance?.trackTitle ?? ""
    readonly property string trackArtist: mainInstance?.trackArtist ?? ""
    readonly property string trackAlbum: mainInstance?.trackAlbum ?? ""
    readonly property string trackArtUrl: mainInstance?.trackArtUrl ?? ""
    readonly property real trackLength: mainInstance?.trackLength ?? 0
    readonly property real trackPosition: mainInstance?.trackPosition ?? 0

    readonly property color textColor: Color.mOnSurface
    readonly property color dimColor: Color.mOnSurfaceVariant
    readonly property color accentColor: Color.mPrimary
    readonly property color surfaceColor: Color.mSurfaceContainerLow
    readonly property int fontSize: Style.fontSizeM

    ColumnLayout {
        id: panelContent
        anchors.fill: parent
        anchors.margins: Style.marginL
        spacing: Style.marginM

        // Header prompt
        Text {
            font.family: "monospace"
            font.pixelSize: root.fontSize
            color: root.accentColor
            text: "spotify@noctalia:~$"
        }

        // Spotify not found
        ColumnLayout {
            visible: !root.spotifyFound
            spacing: Style.marginS
            Layout.fillWidth: true

            Text {
                font.family: "monospace"
                font.pixelSize: root.fontSize
                color: root.launching ? root.dimColor : Color.mError
                text: root.launching
                    ? "[ ] " + (pluginApi?.tr("panel.launching") ?? "launching spotify...")
                    : "[ERR] " + (pluginApi?.tr("panel.no-device") ?? "Spotify not detected")
            }

            Text {
                visible: !root.launching
                font.family: "monospace"
                font.pixelSize: root.fontSize
                color: root.accentColor
                text: "> " + (pluginApi?.tr("panel.open-spotify") ?? "open spotify")

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (mainInstance) mainInstance.openSpotify()
                    }
                }
            }
        }

        // Now playing content
        ColumnLayout {
            visible: root.spotifyFound
            spacing: Style.marginM
            Layout.fillWidth: true

            // Track info
            ColumnLayout {
                visible: root.trackTitle !== ""
                spacing: Style.marginS
                Layout.fillWidth: true

                // Album art + info row
                RowLayout {
                    spacing: Style.marginM
                    Layout.fillWidth: true

                    // Album art (real image if available, ASCII fallback)
                    Item {
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64

                        // Clip mask for rounded corners
                        Rectangle {
                            id: artMask
                            anchors.fill: parent
                            radius: Style.radiusM
                            color: root.surfaceColor
                            clip: true

                            Image {
                                id: albumArt
                                anchors.fill: parent
                                source: root.trackArtUrl
                                fillMode: Image.PreserveAspectCrop
                                visible: status === Image.Ready
                                smooth: true
                            }
                        }

                        // Border overlay
                        Rectangle {
                            anchors.fill: parent
                            radius: Style.radiusM
                            color: "transparent"
                            border.color: root.dimColor
                            border.width: 1
                        }

                        // ASCII fallback
                        Text {
                            anchors.centerIn: parent
                            font.family: "monospace"
                            font.pixelSize: root.fontSize
                            color: root.dimColor
                            text: "┌──────┐\n│ ♫  ♪ │\n│  ♪ ♫ │\n└──────┘"
                            lineHeight: 1.0
                            visible: !albumArt.visible
                        }
                    }

                    // Track details
                    ColumnLayout {
                        spacing: 3
                        Layout.fillWidth: true

                        // Track title
                        MarqueeText {
                            textContent: root.trackTitle
                            textColor: root.textColor
                            maxWidth: 240
                        }

                        // Artist
                        Text {
                            font.family: "monospace"
                            font.pixelSize: root.fontSize
                            color: root.accentColor
                            text: root.trackArtist
                            elide: Text.ElideRight
                            Layout.maximumWidth: 240
                        }

                        // Album
                        Text {
                            font.family: "monospace"
                            font.pixelSize: root.fontSize - 1
                            color: root.dimColor
                            text: root.trackAlbum
                            elide: Text.ElideRight
                            Layout.maximumWidth: 240
                            visible: root.trackAlbum !== ""
                        }
                    }
                }

                Item { Layout.preferredHeight: Style.marginXS }

                // Progress section
                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true

                    // Progress bar (clickable)
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 12

                        // Background track
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 3
                            radius: 1.5
                            color: root.dimColor
                            opacity: 0.3
                        }

                        // Filled track
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: {
                                var total = root.trackLength > 0 ? root.trackLength : 1
                                var ratio = Math.min(1, root.trackPosition / total)
                                return parent.width * ratio
                            }
                            height: 3
                            radius: 1.5
                            color: root.accentColor
                        }

                        // Seek dot
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: {
                                var total = root.trackLength > 0 ? root.trackLength : 1
                                var ratio = Math.min(1, root.trackPosition / total)
                                return parent.width * ratio - width / 2
                            }
                            width: 8
                            height: 8
                            radius: 4
                            color: root.accentColor
                            visible: seekArea.containsMouse || root.isPlaying
                        }

                        MouseArea {
                            id: seekArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                if (mainInstance && root.trackLength > 0) {
                                    var ratio = mouse.x / parent.width
                                    mainInstance.seekByRatio(Math.max(0, Math.min(1, ratio)))
                                }
                            }
                        }
                    }

                    // Time row
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            font.family: "monospace"
                            font.pixelSize: root.fontSize - 1
                            color: root.dimColor
                            text: mainInstance ? mainInstance.formatTime(root.trackPosition) : "0:00"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            font.family: "monospace"
                            font.pixelSize: root.fontSize - 1
                            color: root.dimColor
                            text: mainInstance ? mainInstance.formatTime(root.trackLength) : "0:00"
                        }
                    }
                }

                // Equalizer (real spectrum)
                AsciiEqualizer {
                    playing: root.isPlaying
                    barColor: root.accentColor
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 18
                }
            }

            // Nothing playing
            Text {
                visible: root.trackTitle === ""
                font.family: "monospace"
                font.pixelSize: root.fontSize
                color: root.dimColor
                text: pluginApi?.tr("panel.nothing-playing") ?? "no track playing"
            }

            Item { Layout.preferredHeight: Style.marginXS }

            // Playback controls
            PlaybackControls {
                mainInstance: root.mainInstance
                isPlaying: root.isPlaying
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
