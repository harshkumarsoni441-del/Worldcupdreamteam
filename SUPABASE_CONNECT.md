# Connect Supabase to the live site & fix sign-up / login

Good to know: your live site already reaches Supabase (the "Invalid login credentials"
message is Supabase answering). So this is about **account settings**, not the connection.
Work through these in order.

---

## STEP 1 — Confirm WHICH Supabase project the live site uses
In your SSH terminal:
```
cd /home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in
grep SUPABASE .env
```
You'll see a line like:
```
NEXT_PUBLIC_SUPABASE_URL=https://ooddgvftjeqxurpvviwg.supabase.co
```
The part before `.supabase.co` (here `ooddgvftjeqxurpvviwg`) is your **project ref**.
👉 Write it down. The dashboard you fix MUST be this exact project.

## STEP 2 — Open the SAME project in Supabase
Go to https://supabase.com/dashboard → open the project whose URL matches Step 1.
(If you have several projects, this is the #1 cause of "users not saving" — you were
looking at the wrong one.)

## STEP 3 — Are the users actually there?
In that project: **Authentication → Users**.
- If you see your sign-ups (even as "Waiting for verification") → users ARE saving.
  The problem is just email confirmation → go to Step 4.
- If the list is empty after you sign up → sign-up is erroring → do Step 4 + Step 6.

## STEP 4 — Turn off email confirmation (fastest fix for launch)
**Authentication → Providers → Email** → turn **OFF** the **"Confirm email"** toggle → Save.
Now new sign-ups can log in immediately, no email link required.
(You can turn it back on later once email sending is set up.)

## STEP 5 — Set the site URLs (needed for confirmation emails + Google login)
**Authentication → URL Configuration:**
- **Site URL:** `https://www.worldcupdreamteam.in`
- **Redirect URLs:** add `https://www.worldcupdreamteam.in/**`
Save.

## STEP 6 — Make sure the profiles table exists (so the app can store the user row)
Some sign-up flows also write to a `profiles` table. If it's missing, sign-up can fail.
- **Table Editor** → check for a table named **`profiles`** and **`dream_teams`**.
- If `profiles` is missing, run this in **SQL Editor → New query → Run**:
```sql
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text,
  username text,
  city text,
  country text,
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "own profile read"  on public.profiles for select using (auth.uid() = id);
create policy "own profile write" on public.profiles for insert with check (auth.uid() = id);
create policy "own profile update" on public.profiles for update using (auth.uid() = id);
```

## STEP 7 — Test it
1. Open the live site in a fresh **Incognito** window.
2. Click **Sign up**, use a NEW email + password, submit.
3. Go back to Supabase → **Authentication → Users** → your new user should appear.
4. Now **Log in** with that same email + password → it should work.

---

## If you ever change the keys in `.env`
The `NEXT_PUBLIC_SUPABASE_*` values are baked in **at build time**, so after editing `.env`:
```
cd /home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in
npm run build
pm2 restart wcdt
```
Then hard-refresh the site (and purge Cloudflare if styling/JS looks stale).

## Where to copy the correct keys from (if you need to re-set them)
Supabase dashboard → **Project Settings (gear) → API**:
- **Project URL** → `NEXT_PUBLIC_SUPABASE_URL`
- **anon / public key** → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
Use the keys from the SAME project ref you found in Step 1.
