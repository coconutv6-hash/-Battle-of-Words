# Data Model & API Contracts

## Entities

### users
| field | type | notes |
| --- | --- | --- |
| id | uuid | Supabase auth user id |
| username | text | display name, unique |
| trophies | int | total wins |
| avatar_url | text | optional |

### rooms
| field | type | notes |
| --- | --- | --- |
| id | uuid |
| code | text | 6-char uppercase, indexed |
| host_id | uuid | FK → users.id |
| status | enum(`waiting`,`active`,`finished`) |
| created_at | timestamptz |

### room_players
| field | type |
| --- | --- |
| room_id | uuid |
| user_id | uuid |
| lives | smallint (default 2) |
| points | smallint |
| role | enum(`speaker`,`responder`) |
| last_action_at | timestamptz |

### words
| field | type |
| --- | --- |
| id | uuid |
| en | text |
| pl | text |
| difficulty | enum(`easy`,`med`,`hard`) |
| tags | text[] |

### rounds
| field | type |
| --- | --- |
| id | uuid |
| room_id | uuid |
| word_id | uuid |
| speaker_id | uuid |
| responder_id | uuid |
| started_at | timestamptz |
| expires_at | timestamptz |
| status | enum(`prompt`,`answered`,`failed`) |
| responder_answer | text |
| correctness | enum(`correct`,`wrong`,`timeout`) |

## Realtime Events (Supabase channel `room:{code}`)

| event | payload |
| --- | --- |
| `room.started` | room snapshot + players |
| `round.prompt` | `{ round_id, word, speaker_id, responder_id, deadline }` |
| `round.result` | `{ round_id, correctness, responder_answer, lives, points }` |
| `player.life_lost` | `{ user_id, lives_left }` |
| `room.finished` | `{ winner_id, stats }` |

## REST / RPC Endpoints

1. `POST /rooms`
   - body: `{ username }`
   - returns: `{ roomCode, token }`
2. `POST /rooms/{code}/join`
   - body: `{ username }`
   - returns: `{ token, roomState }`
3. `POST /rooms/{code}/start`
   - auth: host token
4. `POST /rounds/{id}/answer`
   - body: `{ answer }`
   - validates ≤8s + correctness.

Auth tokens can be Supabase JWT; initial MVP may use magic linkless session keyed by room_code + username.
