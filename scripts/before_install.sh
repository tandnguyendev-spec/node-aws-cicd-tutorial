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

# Prepare dirs
mkdir -p /opt/demo-node-app/{release,logs}
chown -R $APP_USER:$APP_USER /opt/demo-node-app

# Stop running PM2 app if exists (handled again in ApplicationStop)
if [ -L "/opt/demo-node-app/current" ]; then
    cd /opt/demo-node-app/current
    if npx pm2 describe demo-node-app > /dev/null 2>&1; then
        echo "Stopping existing PM2 app..."
        npx pm2 stop demo-node-app || true
        npx pm2 delete demo-node-app || true
    fi
fi