# Deploy via GitHub (push from Mac → pull on server)

Your `.gitignore` already excludes `.env`, `node_modules`, and `.next`, so your
secrets stay private. After the one-time setup, every update is just: Push → pull → build → restart.

═══════════════════════════════════════════════════════════
## PART 1 — Put your code on GitHub (from your Mac)  [easiest: GitHub Desktop]
═══════════════════════════════════════════════════════════

1. Download **GitHub Desktop** from https://desktop.github.com → install → open it.
2. **Sign in** to GitHub (create a free account at github.com if you don't have one).
3. Menu **File → Add Local Repository** → choose the folder
   `/Users/macbook/Desktop/worldcupdreamteam` → **Add Repository**.
   (It's already a git repo, so it'll just attach.)
4. Bottom-left: type a summary like `deploy latest` → click **Commit to main**.
5. Top bar: click **Publish repository**.
   - Name: `worldcupdreamteam`
   - You can keep **"Keep this code private"** checked (recommended) OR uncheck for public.
   - Click **Publish repository**.

✅ Your code is now on GitHub. For every future change: **Commit to main** → **Push origin**.

═══════════════════════════════════════════════════════════
## PART 2 — One-time setup on the server (SSH)
═══════════════════════════════════════════════════════════

In your SSH terminal:
```
cd /home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in

# 1) back up your .env so it is never lost
cp .env ~/env-backup 2>/dev/null || echo "(no .env yet — that's ok)"

# 2) connect this folder to your GitHub repo
git init
git remote add origin https://github.com/<YOUR-USERNAME>/worldcupdreamteam.git

# 3) pull the code (repo = source of truth)
git fetch origin
git reset --hard origin/main

# 4) make sure .env is still here (restore if needed)
cp ~/env-backup .env 2>/dev/null || true

# 5) build & run
npm ci
npm run build
pm2 restart wcdt
```
Replace `<YOUR-USERNAME>` with your GitHub username.

**If the repo is PRIVATE**, step 3 will ask for a username + password:
- Username = your GitHub username
- Password = a **Personal Access Token** (NOT your GitHub password). Create one:
  github.com → your avatar → **Settings → Developer settings → Personal access tokens
  → Tokens (classic) → Generate new token** → tick the **repo** scope → Generate →
  copy it and paste it as the password.
**If the repo is PUBLIC**, no password is needed.

═══════════════════════════════════════════════════════════
## PART 3 — Every future update (the easy routine)
═══════════════════════════════════════════════════════════

**On your Mac (GitHub Desktop):**
- Commit your changes → **Commit to main** → **Push origin**.

**On the server (SSH):**
```
cd /home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in
git pull
npm run build
pm2 restart wcdt
```

**Then:** Cloudflare → Purge Everything → open the site in Incognito.

That's it. No more dragging files in FileZilla. `.env` on the server is never touched
by git, so your Supabase keys stay safe.

---
### Notes
- Never commit `.env` (already ignored — keep it that way).
- The server builds its own `node_modules` and `.next` — never push those.
- If `git pull` ever says "local changes would be overwritten", run
  `git reset --hard origin/main` to force the repo version (your `.env` is safe).
