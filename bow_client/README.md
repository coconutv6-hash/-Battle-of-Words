# Bow Client (Flutter MVP)

Minimal, hot-seat playable version of Bow to validate the 8-second / 2-life gameplay loop before networking + visual polish.

## Features
- Local hot-seat mode (host vs guest) with quick name entry.
- Solo mode against bot (alternating rounds, bot answers automatically).
- Online room MVP (host creates room code, guest joins by code) via Supabase.
- Automatic role assignment (speaker vs responder) and 8-second timer.
- Word bank loaded from `assets/words.json`.
- Lives/points tracking, winner summary, and rematch/reset actions.

## Getting started
1. Install Flutter 3.19+.
2. From this directory run:
   ```bash
   flutter pub get
   flutter run
   ```
3. Enter two nicknames, tap “Stwórz lokalny pojedynek”, start the round, i przekazujcie sobie urządzenie.

## Online setup (Supabase MVP)

1. Create table in Supabase:

   ```sql
   create table if not exists public.bow_rooms (
     id uuid primary key default gen_random_uuid(),
     room_code text unique not null,
     host_name text not null,
     guest_name text,
     status text not null default 'waiting',
     game_state jsonb,
     answer_request jsonb,
     started_at timestamptz,
     created_at timestamptz not null default now()
   );
   ```

2. Run app with Supabase keys:

   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
     --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
   ```

3. In lobby, use **Online multiplayer (MVP)** to create/join room.

Roadmap:
- Server-side move validation and anti-cheat rules.
- Full synchronized game state across devices.
- Matchmaking / ranking layer and richer social flows.
