#!/bin/bash
set -e

trap "echo Stopping MCP...; /opt/app/stop-mcp.sh" SIGTERM SIGINT

(
  echo "Waiting for IRIS to be ready..."

  until iris session IRIS -U %SYS "write 1 halt" >/dev/null 2>&1; do
    sleep 2
  done
  echo "IRIS is ready. Starting MCP..."
  /opt/app/start-mcp.sh
) &

echo "Starting IRIS..."
exec /iris-main "$@"