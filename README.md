# Bow — Real-Time Vocabulary Duel

Bow is a two-player, turn-based vocabulary duel where each round lasts only eight seconds. Players swap roles between *speaker* and *translator*, lose lives on mistakes, and earn trophies for wins.

## Structure

- `docs/` – product brief, UX flow, data model notes.
- `bow_client/` – hot-seat Flutter MVP proving the core gameplay loop (8s timer, 2 lives, round swapping). Start here to test mechanics before wiring Supabase realtime + visual polish.

## Next steps

1. Validate gameplay locally (`bow_client`).
2. Introduce Supabase auth + realtime rooms following `docs/data-model-and-api.md` contracts.
3. Iterate on UI polish + matchmaking automation once mechanics feel solid.
