#!/bin/bash


AGENT_REPO_DIR="/app/Micro-XRCE-DDS-Agent"

WORKED_ON_COMMIT="155cfaaf8b7abac2e85d4a62d3649b09ace0be55"

set -e

usage() {
    echo "Usage: $0 [workon|latest]"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

ACTION=$1

# Validate the action
if [ "$ACTION" != "workon" ] && [ "$ACTION" != "latest" ]; then
    usage
fi

echo "[•] Time Capsule Initiated"

if [ ! -d "$AGENT_REPO_DIR" ]; then
    echo "[ERROR] Repository directory not found at $AGENT_REPO_DIR"
    exit 1
fi

cd "$AGENT_REPO_DIR" || exit 1

echo "[•] Cleaning repository"
git clean -fdx 
git reset --hard HEAD 
echo "[OK] Repository clean."

if [ "$ACTION" = "workon" ]; then
    echo "[•] Switching to 'worked on' commit: $WORKED_ON_COMMIT"
    if ! git checkout "$WORKED_ON_COMMIT"; then
        echo "[ERROR] Failed to checkout commit $WORKED_ON_COMMIT."
        exit 1
    fi
    echo "[OK] Successfully checked out commit."


elif [ "$ACTION" = "latest" ]; then
    echo "[•] Switching to head of 'main' branch"
    if ! git checkout main; then
        echo "[ERROR] Failed to checkout 'main' branch."
        exit 1
    fi
    if ! git pull origin main; then
        echo "[ERROR] Failed to pull latest changes from 'main'."
        exit 1
    fi
    echo "[OK] Successfully switched to and pulled latest 'main'."
fi

echo "[•] Rebuilding the agent..."

# Build Micro-XRCE-DDS-patched-agent
mkdir -p /app/Micro-XRCE-DDS-Agent/build && \
cd /app/Micro-XRCE-DDS-Agent/build && \
cmake .. && \
make && \
make install && \
cd ../..

echo "[OK] Agent build and install complete, Time Capsule Process Finished"

exit 0