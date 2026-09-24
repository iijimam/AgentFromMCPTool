#!/bin/bash
set -e

PIDFILE=/tmp/iris-mcp-server.pid

if [ ! -f "$PIDFILE" ]; then
  echo "PID file not found. Trying pkill..."
  pkill -INT -f "iris-mcp-server.*run" || true
  exit 0
fi

PID=$(cat "$PIDFILE")

if kill -0 "$PID" 2>/dev/null; then
  echo "Stopping iris-mcp-server. PID=$PID"
  kill -INT "$PID"

  for i in {1..30}; do
    if ! kill -0 "$PID" 2>/dev/null; then
      echo "iris-mcp-server stopped."
      rm -f "$PIDFILE"
      exit 0
    fi
    sleep 1
  done

  echo "Still running. Sending SIGTERM..."
  kill -TERM "$PID" || true
  sleep 3

  if kill -0 "$PID" 2>/dev/null; then
    echo "Still running. Sending SIGKILL..."
    kill -KILL "$PID" || true
  fi
else
  echo "Process is not running."
fi

rm -f "$PIDFILE"