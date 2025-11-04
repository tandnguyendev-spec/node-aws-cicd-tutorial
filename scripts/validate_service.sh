#!/usr/bin/env bash
set -euo pipefail


# Simple HTTP health check (adjust port/path)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/health)
if [ "$HTTP_CODE" != "200" ]; then
    echo "Health check failed with $HTTP_CODE"
    exit 1
fi