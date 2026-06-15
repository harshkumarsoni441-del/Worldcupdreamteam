# World Cup Dream Team — Project Status & Build Log
_Last updated: 9 June 2026_

This document captures the current state of the WCDT build so it can be added to the Claude Project knowledge. It supersedes the older memory notes (Wix migration / image cleanup / server deployment), which are no longer the active workstream.

---

## What WCDT is
A fan-engagement platform for **IPL 2026, FIFA World Cup 2026, and T20 World Cup 2026**. Fans build a dream XI, change one player per day, follow live match scores, and climb a fantasy leaderboard. Built as a production Next.js app (not the old Wix site).

## Tech stack (unchanged)
Next.js 16 (App Router) · TypeScript (strict) · Tailwind · Supabase (Postgres + Auth) · framer-motion · Vercel. Data access is via the **Supabase JS client directly** (Prisma schema exists in `/prisma` but the running app uses Supabase tables such as `dream_teams`, `profiles`, `votes`).

---

## Current status — DONE
1. **FIFA tournament page** (`app/tournaments/fifa/page.tsx`) — tabs for **Live / Groups / Matches / Cities / Venues / Players**. Shows tournament dates, all 12 groups, every group-stage fixture with date/time/city/venue, 16 host cities, 16 venues, and the player browser.
2. **Player role data fixed** — 182 FIFA players were wrongly labelled "FORWARD". Every nation now has a valid GK/DEF/MID/FWD spread so formations work.
3. **Build Team** (`app/play/build-team/page.tsx`) — **football-pitch UI**, always starts fresh/empty, formation rules enforced, one-tap **Auto-pick**, captain selection (cricket), saves to `dream_teams`.
4. **Profile** (`app/profile/page.tsx`) — shows the full saved XI grouped by position; **one-player-per-day swap** lives here (the daily engagement loop).
5. **Scoring + Leaderboard** (`lib/scoring.ts`, `app/play/leaderboard/page.tsx`) — FPL-style fantasy scoring; leaderboard ranks real users by their XI's points (captain ×2).
6. **Live scores** — Live/Upcoming match section on the **home page** and the FIFA **Live** tab.

## Current status — PENDING
- **API-Football live sync** — the cron/job that fetches real live scores + player stats into Supabase and flips matches to "LIVE". Until built, live sections show real upcoming fixtures (no scores) and the leaderboard uses demo player points.
- Optional: T20/IPL live + scoring parity, knockout-stage fixtures once draws are set.

---

## New / key files added
| File | Purpose |
|---|---|
| `lib/data/fifa-schedule.ts` | 16 venues, 16 cities, 12 groups, all 72 group matchups (verified anchors + auto-scheduled rest) |
| `lib/data/team-rules.ts` | Squad rules (formation/position limits, max-per-team), player lookup, validation |
| `lib/scoring.ts` | FPL-style scoring engine + demo player points + `teamPoints()` |
| `lib/data/live.ts` | Production live source. **`DEMO_MODE = false`**. Real fixtures, no fake scores |
| `lib/data/live-demo.ts` | Demo data (only used if `DEMO_MODE` is true) |
| `components/shared/live-matches.tsx` | Home-page Live/Upcoming matches section |
| `supabase-migration.sql` | Optional DB upgrade (not required — current save works without it) |

---

## Selection rules (Build Team)
**FIFA (football):** exactly 1 GK, 3–5 DEF, 3–5 MID, 1–3 FWD = 11. Max 5 players per nation.
**IPL / T20 (cricket):** 1–2 WK, 3–5 BAT, 1–4 All-rounders, 3–5 BOWL = 11, plus a captain. Max 6 per team.
- Build Team always opens empty. Saving creates/overwrites the user's team for that tournament.
- The **daily 1-player change is done in Profile**, limited to once per day (tracked per device).
- Captain is stored as the first id in `player_ids` (no extra DB column needed).

## Scoring rules (Leaderboard)
Played +1 · Goal +4 FWD / +5 MID / +6 DEF–GK · Assist +3 · Clean sheet +4 (DEF–GK) / +1 (MID) · Yellow −1 · Red −3 · Player of the Match +3 · **Captain ×2**. A user's leaderboard points = sum of their XI's player points.

## Data accuracy notes
- Venues, host cities, and the 12-group draw are the **real, confirmed** 2026 data.
- All 72 group matchups are real; 9 early fixtures have verified exact date/venue, the rest are auto-scheduled within the correct window (swap in official slots or pull via API).
- Player posters are AI-generated/promotional (the app shows a "fictional player" disclaimer).

---

## How live data will work (the plan)
1. A scheduled job (Vercel cron, every ~1–2 min during matches) calls **API-Football** (FIFA) / **CricAPI** (cricket) using the keys in `.env`.
2. It writes live scores + per-player stats into Supabase (`matches`, `player_stats`).
3. `lib/scoring.ts` converts stats → points; the home Live section, FIFA Live tab, and leaderboard read from this and update automatically (Supabase Realtime).
- Real live numbers require matches actually in play **and** an API plan that includes live coverage.

## How to run / test
```
npm run dev
```
- Home: `localhost:3000` → Live/Upcoming matches section
- Tournament: `/tournaments/fifa` → Live / Groups / Matches / Cities / Venues / Players
- Build: `/play/build-team` → pitch view + Auto-pick → Save
- Profile: `/profile` → see XI, swap 1 player/day
- Leaderboard: `/play/leaderboard`
