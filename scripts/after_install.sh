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

# Move release into a versioned folder and update symlink
TS=$(date +%Y%m%d%H%M%S)
mkdir -p /opt/demo-node-app/releases
if [ -d /opt/demo-node-app/release ]; then
    mv /opt/demo-node-app/release /opt/demo-node-app/releases/$TS
fi
ln -sfn /opt/demo-node-app/releases/$TS /opt/demo-node-app/current
chown -R $APP_USER:$APP_USER /opt/demo-node-app


# Fetch secrets from AWS Secrets Manager and write .env
SECRET_NAME="prod/demo-node-app"
REGION="ap-southeast-1" # e.g., ap-southeast-1


# Ensure jq is available (AL2023 has it in extras; else install)
command -v jq >/dev/null 2>&1 || dnf install -y jq >/dev/null 2>&1 || apt-get update && apt-get install -y jq


JSON=$(aws secretsmanager get-secret-value \
--secret-id "$SECRET_NAME" \
--query SecretString \
--output text \
--region "$REGION")


ENV_FILE="/opt/demo-node-app/current/.env"
: > "$ENV_FILE"
# Convert JSON key/value to KEY=VALUE lines
printf "%s" "$JSON" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' >> "$ENV_FILE"


chown $APP_USER:$APP_USER "$ENV_FILE"
chmod 600 "$ENV_FILE"