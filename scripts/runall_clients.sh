#!/bin/bash

# Check for required arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <agent_port> <timeout_seconds>"
    exit 1
fi

PORT=$1
TIMEOUT=$2
ARGS="localhost $PORT"

# List of executables
executables=(
    "./PublishBigHelloWorld/PublishBigHelloWorldClient"
    "./PingAgent/UDP/PingAgentUDP"
    "./SubscribeHelloWorldBestEffort/SubscribeHelloWorldClientBestEffort"
    "./PublishHelloWorldBestEffort/PublishHelloWorldClientBestEffort"
    "./BinaryEntityCreation/BinaryEntityCreation"
    "./PublishHelloWorld/PublishHelloWorldClient"
    "./MultiSessionHelloWorld/MultiSessionHelloWorld"
    "./SubscribeHelloWorld/SubscribeHelloWorldClient"
    "./TimeSync/TimeSync"
    "./ShapesDemo/ShapeDemoClient"
    "./ContinuousFragment/ContinuousFragment"
    "./TimeSyncWithCb/TimeSyncWithCb"
    "./SubscribeBigHelloWorld/SubscribBigBigClient"
)

# Launch all in parallel
pids=()
for exe in "${executables[@]}"; do
    if [[ -x "$exe" ]]; then
        echo "[•] Launching: $exe $ARGS"
        "$exe" $ARGS &
        pids+=($!)  # Store PID
    else
        echo "[ERROR] Skipping: $exe (not found or not executable)"
    fi
done

# Function to kill all background jobs
cleanup() {
    echo "[•] Timeout reached! Killing all launched processes..."
    for pid in "${pids[@]}"; do
        if kill "$pid" 2>/dev/null; then
            echo "[•] Killed process $pid"
        fi
    done
}

# Set trap to cleanup on script termination (e.g., Ctrl+C)
trap cleanup EXIT

# Sleep for the specified timeout, then call cleanup
sleep "$TIMEOUT"

# Explicitly call cleanup (trap handles it, but we ensure it runs here too)
cleanup

echo "[OK] All parallel tasks completed or terminated after timeout."

