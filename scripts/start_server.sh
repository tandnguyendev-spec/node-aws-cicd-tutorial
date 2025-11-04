#!/usr/bin/env bash
set -euo pipefail

# Auto-detect the default user (ec2-user for Amazon Linux, ubuntu for Ubuntu, etc.)
if id ec2-user &>/dev/null; then
    APP_USER="ec2-user"
elif id ubuntu &>/dev/null; then
    APP_USER="ubuntu"
elif id admin &>/dev/null; then
    APP_USER="admin"
elif id centos &>/dev/null; then
    APP_USER="centos"
else
    echo "ERROR: Could not detect default system user"
    exit 1
fi

echo "Detected system user: $APP_USER"

cd /opt/demo-node-app/current

# Start or reload app with PM2
if npx pm2 describe demo-node-app > /dev/null 2>&1; then
    echo "App exists, reloading..."
    npx pm2 reload ecosystem.config.js
else
    echo "Starting app with PM2..."
    npx pm2 start ecosystem.config.js
fi

# Save PM2 process list
npx pm2 save

# Setup PM2 to start on system boot
sudo -u $APP_USER bash -c "cd /opt/demo-node-app/current && npx pm2 startup systemd -u $APP_USER --hp /home/$APP_USER" || true