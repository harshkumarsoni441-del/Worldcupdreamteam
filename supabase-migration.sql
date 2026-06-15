-- ============================================================
-- World Cup Dream Team — dream_teams upgrade
-- Run ONCE in Supabase → SQL Editor → New query → Run.
-- Enables: captain, daily 1-transfer tracking, one team per user per tournament.
-- ============================================================

-- 1) New columns (safe, additive)
alter table public.dream_teams
  add column if not exists captain_id      text,
  add column if not exists last_transfer_at timestamptz,
  add column if not exists updated_at       timestamptz default now();

-- 2) Collapse any duplicate teams to ONE per user per tournament (keep newest).
--    Required before we can add the unique constraint the app upserts against.
delete from public.dream_teams a
using public.dream_teams b
where a.user_id   = b.user_id
  and a.tournament = b.tournament
  and (a.created_at < b.created_at
       or (a.created_at = b.created_at and a.id < b.id));

-- 3) One active team per user per tournament
alter table public.dream_teams
  drop constraint if exists dream_teams_user_tournament_key;
alter table public.dream_teams
  add  constraint dream_teams_user_tournament_key unique (user_id, tournament);
