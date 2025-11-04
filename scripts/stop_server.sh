#!/usr/bin/env bash
set -euo pipefail

cd /opt/demo-node-app/release

# Stop app with PM2 if it exists
if npx pm2 describe demo-node-app > /dev/null 2>&1; then
    echo "Stopping app with PM2..."
    npx pm2 stop demo-node-app
    npx pm2 delete demo-node-app
    npx pm2 save
else
    echo "App not running in PM2"
fi