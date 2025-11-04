#!/usr/bin/env bash
set -euo pipefail

# Prepare dirs
mkdir -p /opt/demo-node-app/{release,logs}
chown -R ec2-user:ec2-user /opt/demo-node-app

# Stop running PM2 app if exists (handled again in ApplicationStop)
if [ -L "/opt/demo-node-app/current" ]; then
    cd /opt/demo-node-app/current
    if npx pm2 describe demo-node-app > /dev/null 2>&1; then
        echo "Stopping existing PM2 app..."
        npx pm2 stop demo-node-app || true
        npx pm2 delete demo-node-app || true
    fi
fi