# Easy upload guide — replace the old site with the new code

You will: (1) connect with FileZilla, (2) delete the old files, (3) upload the new
source files, (4) run 3 commands to build & start. ~15–20 min (uploads take a while).

### The golden rule
**Never upload `node_modules`, `.next`, or `.git`.** They are huge and break things.
You upload the *source* only, then the server rebuilds `node_modules` itself.

---

## STEP 1 — Connect with FileZilla (you already have it)
- Host: `sftp://5.189.171.64`  ·  Username: `worldcupdreamteam`  ·  your password  ·  Port: `22`
- Click **Quickconnect**.
- On the RIGHT side (server), open: `htdocs` → `www.worldcupdreamteam.in`
  This is your site folder.

## STEP 2 — Delete the OLD files
- In the server folder (`www.worldcupdreamteam.in`), select everything → right-click → **Delete**.
- If you see a file named `.env`, you can leave it (it has your keys). Delete the rest.

## STEP 3 — Upload the NEW files
On the LEFT side (your Mac), open `~/Desktop/worldcupdreamteam`.
Drag these into the server folder (skip the 3 forbidden ones):

UPLOAD these:
```
app/   components/   lib/   prisma/   public/
package.json   package-lock.json
next.config.ts   tsconfig.json   middleware.ts   next-env.d.ts
postcss.config.mjs   eslint.config.mjs
.gitignore   AGENTS.md   CLAUDE.md   README.md
```
DO NOT upload:  `node_modules/`   `.next/`   `.git/`   `.DS_Store`

> `public/` is the slow one (it has the 418 player images) — let it finish fully.

## STEP 4 — The `.env` file (this makes login work)
If you didn't keep one on the server, create `.env` in the site folder with:
```
NEXT_PUBLIC_SUPABASE_URL=https://ooddgvftjeqxurpvviwg.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your anon key from Supabase>
DATABASE_URL=<your supabase connection string>
```
(You can copy your Mac's `.env` values — same Supabase project = same accounts.)

## STEP 5 — Build & start (CloudPanel → your site → Terminal/SSH)
Run these 3 lines:
```bash
cd /home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in
npm ci && npm run build
pm2 restart wcdt || pm2 start npm --name wcdt -- start
```
Wait for "build" to finish with no red errors. Then open the site.

## STEP 6 — If login still fails
In Supabase dashboard → Authentication → URL Configuration:
- Site URL: `https://www.worldcupdreamteam.in`
- Redirect URLs: add `https://www.worldcupdreamteam.in/**`

---

### Next time (super fast)
After the first clean upload, you only re-upload the folders you changed (usually
`app/`, `components/`, `lib/`), then run STEP 5 again. No need to delete everything.
```
