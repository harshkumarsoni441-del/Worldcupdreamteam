#!/usr/bin/env bash
# Run this ON THE SERVER, inside the site folder, as the site user.
# Usage: bash deploy.sh
set -euo pipefail

SITE_DIR="/home/worldcupdreamteam/htdocs/www.worldcupdreamteam.in"
cd "$SITE_DIR"

echo "==> Pulling latest code"
git pull || echo "(no git remote — make sure files were uploaded via SFTP)"

if [ ! -f .env ]; then
  echo "!! .env is missing. Create it first (see DEPLOYMENT.md STEP 2) — login will not work without it."
  exit 1
fi

echo "==> Installing dependencies"
npm ci

echo "==> Building production bundle"
npm run build

echo "==> (Re)starting with PM2"
if pm2 describe wcdt >/dev/null 2>&1; then
  pm2 restart wcdt
else
  pm2 start npm --name wcdt -- start
  pm2 save
fi

echo "==> Done. Check: pm2 logs wcdt   and open https://www.worldcupdreamteam.in"
