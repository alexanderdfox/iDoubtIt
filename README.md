# iDoubtIt

A **Cheat** / **I Doubt It** card game clone — iOS (Swift + SpriteKit) and a browser version.

[![wakatime](https://wakatime.com/badge/github/alex-d-fox/iDoubtIt.svg)](https://wakatime.com/badge/github/alex-d-fox/iDoubtIt)

## Icons

App and web icons use the game palette (blue gradient, green felt, suit symbols, gold “!” badge). Regenerate anytime:

```bash
python3 Scripts/generate_icons.py
```

Outputs: `iDoubtIt/Game.xcassets/AppIcon.appiconset/` (iOS) and `assets/icons/` (favicon, PWA, Apple touch icon).

## Play in the browser

Open [`index.html`](index.html) in any modern browser (double-click or use a local server). No build step required.

## iOS app

Open `iDoubtIt.xcodeproj` in Xcode and run on a simulator or device.

- **Play** — 1–4 humans (pass-and-play); empty seats are AI. Set human count in Settings.
- **Watch AI** — four AIs play automatically (spectator mode).
- **Settings** — wacky mode, sound/music with volume, AI difficulty (Easy / Medium / Hard).
- **Extras on iOS** — haptic feedback on card select and key actions; active-seat highlight; toast messages; Main Menu on game over (no auto-exit).

## Rules (short)

Players take turns playing 1–4 cards face-down onto the pile, **claiming** the current rank (Ace → King, then Ace again). The next player may **Doubt**: if any of the last played cards don’t match the claim, the liar takes the whole pile; otherwise the doubter takes it. First to empty their hand wins.

**Wacky mode** (Settings on iOS, checkbox on web): up to 6 cards per play; jokers count as wild.
