# Updates

## code-server via nginx reverse proxy

Added VS Code in the browser (code-server) accessible at `/code/`, fronted by nginx for path-based routing.

### Architecture

```
Railway PORT → nginx → /code/*  → code-server (127.0.0.1:8082)
                     → /*       → wrapper (127.0.0.1:3000) → gateway (18789)
```

### Routes

| Path | Service |
|------|---------|
| `/` | OpenClaw web UI |
| `/setup` | Setup wizard |
| `/code/` | VS Code (code-server) |

### Authentication

code-server auth uses the `SETUP_PASSWORD` Railway env var. If unset, code-server runs with no authentication.

To use a separate password for code-server, set `CODE_SERVER_PASSWORD` in Railway env vars.

### Files changed

- **`Dockerfile`** — Added `nginx`, `gettext-base`, code-server tarball install. Changed entrypoint to `tini -g` + `start.sh`.
- **`nginx.conf.template`** — nginx config with path-based routing and WebSocket support.
- **`scripts/start.sh`** — Startup script that launches nginx, code-server, and the wrapper.
- **`railway.toml`** — No new variables required.

### Persistent storage

code-server data and extensions are stored at `/data/code-server` on the Railway volume, persisting across deploys.
