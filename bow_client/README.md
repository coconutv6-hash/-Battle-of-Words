# Bow Client (Flutter MVP)

Minimal, hot-seat playable version of Bow to validate the 8-second / 2-life gameplay loop before networking + visual polish.

## Features
- Two players on one device (host vs guest) with quick name entry.
- Automatic role assignment (speaker vs responder) and 8-second timer.
- Word bank loaded from `assets/data/words.json`.
- Lives/points tracking, winner summary, and rematch/reset actions.

## Getting started
1. Install Flutter 3.19+.
2. From this directory run:
   ```bash
   flutter pub get
   flutter run
   ```
3. Enter two nicknames, tap “Stwórz lokalny pojedynek”, start the round, i przekazujcie sobie urządzenie.

Roadmap:
- Swap local ChangeNotifier for Supabase realtime room channel.
- Replace manual hot-seat flow with host/join flows per player device.
- Polish visuals (gradients, animations, trophy counters).
