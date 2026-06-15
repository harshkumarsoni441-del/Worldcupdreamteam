# Deploying World Cup Dream Team to worldcupdreamteam.in (CloudPanel)

Goal: make the live site match your localhost exactly — working tournament section,
blog/videos, build-team, leaderboard, and **Supabase login working**.

Server (from earlier sessions):
- Host/IP: `5.189.171.64` · domain `www.worldcupdreamteam.in`
- Site user: `worldcupdreamteam`
- Site folder: `/home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in/`
- Pre-installed: Node v22, npm, git, PM2 (install if missing)

> Do every step as the **site user**, not root, unless noted.

---

## STEP 1 — Get the latest code onto the server
Pick ONE method.

**A) Git (recommended).** On your Mac, from the project folder:
```bash
cd ~/Desktop/worldcupdreamteam
git add -A && git commit -m "deploy: latest build"
git push            # to your GitHub/GitLab remote
```
On the server (SSH in via CloudPanel terminal or `ssh worldcupdreamteam@5.189.171.64`):
```bash
cd /home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in
git pull            # first time: git clone <repo-url> .
```

**B) SFTP (FileZilla).** Upload the whole project EXCEPT `node_modules`, `.next`, and `.git`.
Make sure you also upload `public/` (the 418 FIFA player images live there) and `public/blog/`.

---

## STEP 2 — Create the server `.env` (this is what makes login work)
On the server, in the site folder, create `.env` with your REAL values:
```
NEXT_PUBLIC_SUPABASE_URL=https://ooddgvftjeqxurpvviwg.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your anon key>
DATABASE_URL=<your supabase connection string>
```
Notes:
- `NEXT_PUBLIC_*` vars are baked in **at build time**, so set them BEFORE step 3.
- Use the **same** Supabase project as localhost so existing accounts work.
- If you rotated the DB password (recommended), update `DATABASE_URL` here.

---

## STEP 3 — Install, build, run
```bash
cd /home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in
npm ci                # clean install (uses package-lock.json)
npm run build         # production build — must finish with no errors
npm i -g pm2          # if PM2 not installed
pm2 start npm --name wcdt -- start   # starts `next start` on port 3000
pm2 save
pm2 startup           # follow the printed command so it survives reboots
```
Re-deploys later are just: `git pull && npm ci && npm run build && pm2 restart wcdt`.

---

## STEP 4 — Nginx reverse proxy (CloudPanel → Node on port 3000)
In CloudPanel → your site → **Vhost**, add a location block so the domain proxies to the app:
```nginx
location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
}
```
Save → CloudPanel reloads Nginx. SSL: enable Let's Encrypt for the domain in CloudPanel.

---

## STEP 5 — Make Supabase auth work on the live domain
In the **Supabase dashboard → Authentication → URL Configuration**:
- **Site URL:** `https://www.worldcupdreamteam.in`
- **Redirect URLs:** add `https://www.worldcupdreamteam.in/**` and `https://www.worldcupdreamteam.in/auth/callback`
- If you use **Google login**: in Google Cloud console add the same domain + `/auth/callback` to authorized redirect URIs.

Without this, login will fail on the live site even though it works on localhost.

---

## STEP 6 — Verify
- `https://www.worldcupdreamteam.in` loads the homepage with the Live/Upcoming matches section
- `/tournaments/fifa` shows Live / Groups / Matches / Cities / Venues / Players
- `/blog` shows articles + 72 videos
- `/login` → sign in → `/play/build-team` saves a team → `/profile` shows it

---

## Common gotchas
- **Login fails live but works local** → STEP 5 (Supabase redirect URLs) or missing `NEXT_PUBLIC_*` at build time (rebuild after setting `.env`).
- **Broken player images** → `public/players/` wasn't uploaded, or folder names have trailing spaces.
- **502 Bad Gateway** → app not running (`pm2 logs wcdt`) or wrong proxy port.
- **Old version still showing** → run `pm2 restart wcdt` after each build.
