import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
    id: root

    property var pluginApi: null

    // Spotify MPRIS player reference
    property var player: null
    property bool spotifyFound: player !== null
    property bool spotifyInstalled: false
    property bool launching: false

    // State from player
    property bool isPlaying: player ? player.playbackState === MprisPlaybackState.Playing : false
    property string trackTitle: player ? (player.trackTitle || "") : ""
    property string trackArtist: player ? (player.trackArtist || "") : ""
    property string trackAlbum: player ? (player.trackAlbum || "") : ""
    property string trackArtUrl: player ? (player.trackArtUrl || "") : ""
    property real trackLength: player ? (player.length || 0) : 0
    property real trackPosition: 0
    property bool canNext: player ? (player.canGoNext || false) : false
    property bool canPrev: player ? (player.canGoPrevious || false) : false
    property bool canSeek: player ? (player.canSeek || false) : false

    // Detect Spotify installation
    Process {
        id: detectProcess
        command: ["bash", "-c", "command -v spotify || flatpak info com.spotify.Client 2>/dev/null || snap list spotify 2>/dev/null"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.spotifyInstalled = text.trim().length > 0
            }
        }

        stderr: StdioCollector {}
    }

    Component.onCompleted: {
        detectProcess.running = true
        updatePlayer()
    }

    // Find Spotify in MPRIS players
    function findSpotifyPlayer() {
        if (!Mpris.players || !Mpris.players.values) return null
        var players = Mpris.players.values
        for (var i = 0; i < players.length; i++) {
            var p = players[i]
            if (!p) continue
            var id = String(p.identity || "").toLowerCase()
            var dbus = String(p.desktopEntry || "").toLowerCase()
            if (id === "spotify" || dbus === "spotify" || id.indexOf("spotify") >= 0) {
                return p
            }
        }
        return null
    }

    function updatePlayer() {
        var p = findSpotifyPlayer()
        if (p !== player) {
            player = p
            if (p) launching = false
        }
    }

    // Watch for MPRIS player list changes
    Connections {
        target: Mpris.players
        function onValuesChanged() {
            root.updatePlayer()
        }
    }

    // Track position updates
    Timer {
        interval: 1000
        repeat: true
        running: root.isPlaying && root.player !== null
        onTriggered: {
            if (root.player) {
                root.trackPosition = root.player.position || 0
            }
        }
    }

    Connections {
        target: root.player
        function onPositionChanged() {
            root.trackPosition = root.player ? (root.player.position || 0) : 0
        }
        function onPlaybackStateChanged() {
            if (root.player) {
                root.trackPosition = root.player.position || 0
            }
        }
    }

    // Launch Spotify in background
    Process {
        id: launchProcess
        command: ["bash", "-c",
            "if command -v spotify >/dev/null 2>&1; then spotify &" +
            " elif flatpak info com.spotify.Client >/dev/null 2>&1; then flatpak run com.spotify.Client &" +
            " elif snap list spotify >/dev/null 2>&1; then snap run spotify &" +
            " fi"
        ]
        stderr: StdioCollector {}
        stdout: StdioCollector {}
    }

    // Retry finding player after launch
    Timer {
        id: launchRetryTimer
        interval: 2000
        repeat: true
        running: root.launching
        property int retries: 0
        onTriggered: {
            root.updatePlayer()
            retries++
            if (root.spotifyFound || retries > 15) {
                running = false
                root.launching = false
                retries = 0
            }
        }
    }

    // Playback controls
    function togglePlayPause() {
        if (!player) {
            launchSpotify()
            return
        }
        if (player.playbackState === MprisPlaybackState.Playing) {
            player.pause()
        } else {
            player.play()
        }
    }
    function nextTrack() { if (player && player.canGoNext) player.next() }
    function prevTrack() { if (player && player.canGoPrevious) player.previous() }
    function seek(position) {
        if (player && player.canSeek) {
            player.position = position
            trackPosition = position
        }
    }
    function seekByRatio(ratio) {
        if (player && player.canSeek && player.length > 0) {
            var pos = ratio * player.length
            player.position = pos
            trackPosition = pos
        }
    }

    function launchSpotify() {
        if (launching) return
        launching = true
        launchRetryTimer.retries = 0
        launchProcess.running = true
    }

    function openSpotify() {
        launchSpotify()
    }

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "0:00"
        var m = Math.floor(seconds / 60)
        var s = Math.floor(seconds % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }
}
