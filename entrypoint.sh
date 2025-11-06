#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Default paths
: "${TOKEN_FILE:=$HOME/.config/yandex-disk/passwd}"
: "${DATA:=/yandex}"

# Ensure required dirs exist
mkdir -p "$DATA" "$(dirname "$TOKEN_FILE")"

# Check for token - don't try to generate interactively
if [ ! -f "$TOKEN_FILE" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  No Yandex.Disk token found!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "To generate a token, run:"
    echo "  docker exec -it <container_id> bash"
    echo "  yandex-disk token $TOKEN_FILE"
    echo ""
    echo "Or mount an existing token file to: $TOKEN_FILE"
    echo ""
    echo "Waiting for token file to appear (checking every 10s)..."
    
    # Wait for token file to be created (by external process or volume mount)
    while [ ! -f "$TOKEN_FILE" ]; do
        sleep 10
        echo "Still waiting for token at $TOKEN_FILE..."
    done
    
    echo "✅ Token file detected!"
fi

echo "Using token at $TOKEN_FILE"

# Handle optional exclude dirs
excludedirs=""
if [ -n "${EXCLUDE:-}" ]; then
    excludedirs="--exclude-dirs=$EXCLUDE"
fi

# Dispatch command
case "${1:-start}" in
  start)
    echo "Starting Yandex.Disk daemon..."
    exec yandex-disk start --no-daemon --dir="$DATA" --auth="$TOKEN_FILE" ${excludedirs} ${OPTIONS:-}
    ;;
  sync)
    echo "Performing one-time sync..."
    exec yandex-disk sync --dir="$DATA" --auth="$TOKEN_FILE" ${excludedirs} ${OPTIONS:-}
    ;;
  *)
    exec "$@"
    ;;
esac