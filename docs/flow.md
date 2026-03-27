# Second-by-Second Flow (Single Round)

1. **Room active** – both players ready.
2. System assigns `speaker` / `responder` roles (alternating each correct round).
3. `t = 0s`
   - `round.prompt` event emitted.
   - Speaker screen shows EN word + voice cue.
   - Responder receives PL translation + disabled input until `t=1s` (gives speaker tiny head start to say word aloud).
4. `t = 1s`
   - Responder input enabled.
   - Countdown (8 → 0s) visible both sides.
5. `t = 0–8s`
   - Responder types (or speaks) answer.
   - On submit, request `POST /rounds/:id/answer`.
6. Validation:
   - If answer matches (case-insensitive, trimmed) before deadline → `correct`.
   - Else `wrong`.
   - If no submission by `t=8s` → `timeout` (treated as `wrong`).
7. Result fanout (`round.result`).
   - Correct: responder gains point, no life change, roles swap for next round.
   - Wrong: responder loses 1 life. If lives >0 → repeat with same speaker/responder? (Design choice: keep same roles until responder gets one right). For now: wrong answer keeps speaker same, responder stays until success, to reinforce learning.
8. **Life exhaustion**
   - When player reaches 0 lives → `player.life_lost` with `lives_left=0` + `room.finished` event after short delay.
9. Summary Screen
   - Both clients navigate to summary with stats & rematch CTA.
