#!/usr/bin/env bash
set -euo pipefail

# Railway injects PORT — nginx listens there. Wrapper listens on 3000.
export NGINX_PORT="${PORT:-8080}"

# --- nginx -----------------------------------------------------------
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /tmp/nginx.conf
nginx -c /tmp/nginx.conf

# --- code-server ------------------------------------------------------
CS_DATA="/data/code-server"
mkdir -p "$CS_DATA"

CS_PASSWORD="${CODE_SERVER_PASSWORD:-${SETUP_PASSWORD:-}}"

if [ -n "${CS_PASSWORD:-}" ]; then
  export PASSWORD="$CS_PASSWORD"
fi

# Clear PORT so code-server doesn't steal it (it reads $PORT).
PORT= code-server \
  --bind-addr 127.0.0.1:8082 \
  --user-data-dir "$CS_DATA/data" \
  --extensions-dir "$CS_DATA/extensions" \
  --disable-telemetry \
  --disable-update-check \
  ${CS_PASSWORD:+--auth password} \
  ${CS_PASSWORD:---auth none} \
  &

# --- wrapper (foreground, gets signals via tini -g) -------------------
export PORT=3000
exec node src/server.js
