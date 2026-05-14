# DynamicIsland

DynamicIsland turns the MacBook notch into a focused command surface for media, system insight, and quick utilities. It stays out of the way until needed, then expands with responsive native SwiftUI controls.

Built over the open-source [Atoll](https://github.com/Ebullioscopic/Atoll) codebase by Ebullioscopic. This fork keeps the original GPL license and attribution while publishing under the DynamicIsland project.

<p align="center">
  <img src="https://i.postimg.cc/t49mW5yN/Screenshot-2026-03-02-at-6-00-22-PM.png" alt="DynamicIsland lock screen" width="920">
</p>

## Highlights

- Media controls for Apple Music, Spotify, and more with inline previews.
- Live Activities for media playback, Focus, screen recording, privacy indicators, downloads, and battery/charging.
- Lock screen widgets for media, timers, charging, Bluetooth devices, and weather.
- Lightweight system insight for CPU, GPU, memory, network, and disk usage.
- Productivity tools including timers, clipboard history, color picker, calendar previews, and Shelf.
- Customization for layouts, animations, hover behavior, and shortcut remapping.

## Other Features

- Gesture controls for opening and closing the notch and media navigation.
- Parallax hover interactions with smooth transitions.
- Lock screen appearance and positioning controls for panels and widgets.

<p align="center">
  <img src="https://i.postimg.cc/HkLGn6yH/846F86A4_A2F9_4CD6_BC84_1D720D377728_1_201_a.jpg" alt="DynamicIsland preview" width="920">
</p>

## Requirements

- macOS 14.0 or later.
- MacBook with a notch.
- Xcode 15+ to build from source.
- Permissions as needed: Accessibility, Camera, Calendar, Screen Recording, and Music.

## Build From Source

1. Clone the repository.
2. Open `DynamicIsland.xcodeproj` in Xcode.
3. Select the `DynamicIsland` scheme.
4. Build and run.

## Quick Start

- Hover near the notch to expand; click to enter controls.
- Use tabs for Media, Stats, Timers, Clipboard, and more.
- Adjust layout, appearance, and shortcuts from Settings.
- Add files to Shelf from Terminal: `open -a DynamicIsland /path/to/file`.

## Settings

- Choose appearance, animation style, and per-feature toggles.
- Remap global shortcuts and adjust hover behavior.
- Enable lock screen widgets and select data sources.

## Gesture Controls

- Two-finger swipe down to open the notch when hover-to-open is disabled; swipe up to close.
- Enable horizontal media gestures in Settings > General > Gesture control to turn the music pane into a trackpad for previous/next or +/-10 second seeks.
- Pick the gesture skip behavior independently from the skip button configuration so swipes can scrub while buttons change tracks, or vice versa.

## Troubleshooting

- After granting Accessibility or Screen Recording, quit and relaunch the app.
- If metrics are empty, enable categories in Settings > Stats.
- Media not responding: verify the player is active and Music permission is granted.

## License

DynamicIsland is released under the GPL v3 License. Refer to [LICENSE](LICENSE) for the full terms.

## Attribution

DynamicIsland is built over the open-source [Atoll](https://github.com/Ebullioscopic/Atoll) project by Ebullioscopic. Atoll itself builds on and credits several open-source projects and macOS app ideas, including:

- [Boring.Notch](https://github.com/TheBoredTeam/boring.notch) for foundational notch interaction, media, AirDrop, file dock, and calendar patterns.
- [Alcove](https://tryalcove.com) for interface inspiration around compact notch layouts and lock screen widgets.
- [Stats](https://github.com/exelban/stats) for system metrics collection patterns.
- [Open Meteo](https://open-meteo.com) for weather APIs.
- [SkyLightWindow](https://github.com/Lakr233/SkyLightWindow) for lock screen widget window rendering.
- [rtaudio](https://github.com/ZephyrCodesStuff/rtaudio) for live music visualizer work.
- [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) for terminal tab implementation.

See [NOTICE](NOTICE), [COPYRIGHT_ASSETS](COPYRIGHT_ASSETS), and [TRADEMARKS](TRADEMARKS) for additional attribution and legal notes.
