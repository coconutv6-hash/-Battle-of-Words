# Bow UI Mockups (Textual)

## 1. Lobby / Home
- **AppBar**: Title "Bow" + trophy counter (icon + number)
- **Body layout**: `Column`
  - Card: "Create Room" button (primary). Tap → generates room code & copies to clipboard.
  - Divider "— or —"
  - TextField for 6-char room code + "Join" button.
  - Mini leaderboard strip (top 3 friends) for future use (placeholder list).
- **Footer**: small print "2 lives · 8s per turn".

## 2. Waiting Room / Match Setup
- Shows room code big & share button.
- Lists connected players (avatar, username, current trophies).
- Host sees CTA "Start Duel" once ≥2 players.
- Guests see "Ready" badge when host starts.

## 3. Round View — Speaker (Prompt Owner)
- Background gradient (teal → navy) to differentiate role.
- Center card with English word (large typography).
- Subtext "Say it aloud now" + countdown circle (8 → 0s).
- Footer status chips: Your lives (♥♥), Opponent lives (♥♥ or ♥♡), trophy progression bar.

## 4. Round View — Responder
- Warm gradient (gold → orange).
- Header: shows prompt giver name + micro avatar.
- Main area: Polish translation text.
- Countdown progress bar (animated 8s) + number badge.
- Input: large outlined TextField with mic button (future voice input) + send CTA.
- Feedback toast inline: ✅ Correct (with +1 score) or ❌ Wrong (-1 life) after submission.

## 5. Life Lost Overlay
- Semi-transparent red overlay with vibration effect note.
- Text: "Oops! 'slippery' ≠ 'śliska'. 1 life left." + next-turn countdown.

## 6. Match Summary
- Winner badge (trophy icon + confetti).
- Cards for each player: stats (correct answers, fastest time, streak).
- Buttons: "Rematch", "New Opponent", "Share result".

## Component tokens
- Typography: Manrope / Inter, weight 600 for headings.
- Primary color: #4C6FFF, accent: #FFAD49, danger: #FF5C5C.
- Buttons: rounded 16px, drop shadow 2dp.
