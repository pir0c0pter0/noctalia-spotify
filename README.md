# noctalia-spotify

Terminal-aesthetic Spotify plugin for [Noctalia Shell](https://github.com/pir0c0pter0/noctalia-shell) (Quickshell).

Uses MPRIS — no API keys, no OAuth, no setup required. Just have Spotify running.

## Features

- **Bar Widget** — shows current track in the bar, auto-hides when Spotify is closed
- **Panel** — click to open full player with terminal aesthetic
- **Album Art** — fetches real album cover from Spotify via MPRIS
- **Real-time Spectrum** — audio visualizer powered by cava + SpectrumService
- **Seekable Progress Bar** — click to seek, with time display
- **Playback Controls** — play/pause, next, previous with hover feedback
- **Zero Setup** — works via MPRIS, no API keys or accounts needed
- **i18n** — English and Portuguese

## Prerequisites

- [Noctalia Shell](https://github.com/pir0c0pter0/noctalia-shell) v4.4.0+
- Spotify desktop app
- [cava](https://github.com/karlstav/cava) (for real-time audio spectrum)

## Installation

Copy the plugin folder to Noctalia's plugin directory:

```bash
git clone https://github.com/pir0c0pter0/noctalia-spotify.git
cp -r noctalia-spotify ~/.config/noctalia/plugins/spotify
```

Register the plugin in `~/.config/noctalia/plugins.json` under `states`:

```json
"spotify": {
    "enabled": true,
    "sourceUrl": "https://github.com/pir0c0pter0/noctalia-spotify"
}
```

Then restart Quickshell.

## Usage

1. Open Spotify on your machine
2. The widget appears in the bar automatically
3. Click it to open the player panel
4. Right-click for context menu (play/pause, settings)

## Architecture

```
┌──────────────┐       MPRIS/D-Bus       ┌─────────────────┐
│  Bar Widget  │◄───────────────────────►│  Spotify Client  │
│  + Panel     │   (no network needed)   │  (desktop app)   │
│  (QML)       │                         └─────────────────┘
└──────────────┘
       │
  Main.qml watches          ┌─────────────────┐
  Mpris.players for    ────►│  SpectrumService │
  Spotify identity          │  (cava backend)  │
                            └─────────────────┘
```

## File Structure

```
spotify/
├── manifest.json           # Plugin metadata
├── Main.qml                # MPRIS player detection + state
├── BarWidget.qml           # Bar capsule (track + play/pause)
├── Panel.qml               # Full player panel
├── Settings.qml            # Plugin settings UI
├── settings.json           # Default settings
├── components/
│   ├── AsciiEqualizer.qml  # Real-time audio spectrum visualizer
│   ├── MarqueeText.qml     # Scrolling text for long names
│   └── PlaybackControls.qml # Play/pause/skip controls
└── i18n/
    ├── en.json              # English translations
    └── pt.json              # Portuguese translations
```

## License

MIT
