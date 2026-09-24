#!/bin/bash
set -e

PIDFILE=/tmp/iris-mcp-server.pid
LOGFILE=/usr/irissys/mgr/iris-mcp.log
CONFIG=/opt/app/config-http.toml

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "iris-mcp-server is already running. PID=$(cat "$PIDFILE")"
  exit 0
fi

echo "Starting iris-mcp-server..."

nohup /usr/irissys/bin/iris-mcp-server \
  --log-level=debug \
  --log-output=file \
  --log-file="$LOGFILE" \
  --config="$CONFIG" \
  run \
  >/tmp/iris-mcp-server.out 2>/tmp/iris-mcp-server.err &

echo $! > "$PIDFILE"

echo "iris-mcp-server started. PID=$(cat "$PIDFILE")"
