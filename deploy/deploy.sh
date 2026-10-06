#!/bin/bash
# MyFuture API production deploy — run from project root on server or locally via rsync+ssh
set -euo pipefail

APP_NAME="myfuture-api"
APP_DIR="/var/www/${APP_NAME}"
REPO_BACKEND="$(cd "$(dirname "$0")/.." && pwd)/backend"

echo "==> Deploying to ${APP_DIR}"

sudo mkdir -p "$APP_DIR"
sudo chown -R "$(whoami):$(whoami)" "$APP_DIR" 2>/dev/null || true

rsync -av --delete \
  --exclude node_modules \
  --exclude .env \
  "${REPO_BACKEND}/" "${APP_DIR}/"

cd "$APP_DIR"
npm ci --omit=dev 2>/dev/null || npm install --omit=dev

if [ ! -f .env ]; then
  echo "ERROR: ${APP_DIR}/.env missing — create it before starting."
  exit 1
fi

if command -v pm2 >/dev/null; then
  pm2 delete "$APP_NAME" 2>/dev/null || true
  pm2 start src/index.js --name "$APP_NAME" --cwd "$APP_DIR"
  pm2 save
else
  echo "pm2 not found — start manually: node src/index.js"
fi

echo "==> Done. Health: curl http://127.0.0.1:4010/api/health"
