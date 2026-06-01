# iDoubtIt

A **Cheat** / **I Doubt It** card game clone — iOS (Swift + SpriteKit) and a browser version.

[![wakatime](https://wakatime.com/badge/github/alex-d-fox/iDoubtIt.svg)](https://wakatime.com/badge/github/alex-d-fox/iDoubtIt)

## Play in the browser

Open [`index.html`](index.html) in any modern browser (double-click or use a local server). No build step required.

## iOS app

Open `iDoubtIt.xcodeproj` in Xcode and run on a simulator or device.

## Rules (short)

Players take turns playing 1–4 cards face-down onto the pile, **claiming** the current rank (Ace → King, then Ace again). The next player may **Doubt**: if any of the last played cards don’t match the claim, the liar takes the whole pile; otherwise the doubter takes it. First to empty their hand wins.

**Wacky mode** (Settings on iOS, checkbox on web): up to 6 cards per play; jokers count as wild.
