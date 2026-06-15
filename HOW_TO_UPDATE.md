# How to update the live site (worldcupdreamteam.in)

Use this every time a file changes. The routine is always the same:
**upload changed file(s) → build → restart → purge cache.**

Golden rule: only upload the **changed source files**. NEVER upload `node_modules`, `.next`, or `.git`.

---

## A. Upload the changed file(s) in FileZilla

1. **Connect** (if it says "Disconnected"): Host `sftp://5.189.171.64` · User `worldcupdreamteam` · your password · Port `22` → **Quickconnect**.

2. Point BOTH sides at the **same folder** as the file you changed. Easiest way — paste the path into the path boxes:
   - **Local site** box (left): `/Users/macbook/Desktop/worldcupdreamteam/components/shared`
   - **Remote site** box (right): `/home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in/components/shared`

3. On the **left**, find **`navbar.tsx`** → drag it to the **right** panel → choose **Overwrite**.

(For other updates, just change the folder in step 2 to wherever the changed file lives, e.g. `app/...`, `lib/...`.)

## B. Rebuild on the server (SSH terminal)

```
cd /home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in
npm run build
pm2 restart wcdt
```
- Wait for `npm run build` to finish with **no red errors** (it ends with the route list).
- If it errors, copy the message and send it to me.

## C. Clear the cache & view

1. Cloudflare → dash.cloudflare.com → your domain → **Caching → Configuration → Purge Everything**.
2. Open the site in a fresh **Incognito** window (Cmd+Shift+N).

That's it. Header/menu changes will be live.

---

### Quick reference — paths
- Site folder on server: `/home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in`
- Project folder on Mac: `/Users/macbook/Desktop/worldcupdreamteam`
- Restart only (no code change): `pm2 restart wcdt`
- Check it's running: `pm2 status`  ·  See logs: `pm2 logs wcdt --lines 20 --nostream`
