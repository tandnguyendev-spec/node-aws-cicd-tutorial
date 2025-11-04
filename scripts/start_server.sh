#!/usr/bin/env bash
set -euo pipefail

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

# Setup PM2 to start on system boot (run as ec2-user)
sudo -u ec2-user bash -c "cd /opt/demo-node-app/current && npx pm2 startup systemd -u ec2-user --hp /home/ec2-user" || true