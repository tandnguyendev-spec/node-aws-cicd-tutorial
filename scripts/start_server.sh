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

# Load NVM for the APP_USER and run PM2 commands
# This function runs commands as APP_USER with nvm loaded
run_as_user_with_nvm() {
    sudo -u $APP_USER bash -c "
        export NVM_DIR=\"/home/$APP_USER/.nvm\"
        [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"
        cd /opt/demo-node-app/current
        $1
    "
}

# Install dependencies
echo "Installing dependencies..."
run_as_user_with_nvm "npm install --production"

# Start or reload app with PM2
if run_as_user_with_nvm "npx pm2 describe demo-node-app" > /dev/null 2>&1; then
    echo "App exists, reloading..."
    run_as_user_with_nvm "npx pm2 reload ecosystem.config.js"
else
    echo "Starting app with PM2..."
    run_as_user_with_nvm "npx pm2 start ecosystem.config.js"
fi

# Save PM2 process list
run_as_user_with_nvm "npx pm2 save"

# Setup PM2 to start on system boot
run_as_user_with_nvm "npx pm2 startup systemd -u $APP_USER --hp /home/$APP_USER" || true