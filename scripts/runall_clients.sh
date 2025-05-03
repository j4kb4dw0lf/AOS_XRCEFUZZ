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
    "./../Micro-XRCE-DDS-Client/build/examples/PublishBigHelloWorld/PublishBigHelloWorldClient"
    "./../Micro-XRCE-DDS-Client/build/examples/PingAgent/UDP/PingAgentUDP"
    "./../Micro-XRCE-DDS-Client/build/examples/SubscribeHelloWorldBestEffort/SubscribeHelloWorldClientBestEffort"
    "./../Micro-XRCE-DDS-Client/build/examples/PublishHelloWorldBestEffort/PublishHelloWorldClientBestEffort"
    "./../Micro-XRCE-DDS-Client/build/examples/BinaryEntityCreation/BinaryEntityCreation"
    "./../Micro-XRCE-DDS-Client/build/examples/PublishHelloWorld/PublishHelloWorldClient"
    "./../Micro-XRCE-DDS-Client/build/examples/MultiSessionHelloWorld/MultiSessionHelloWorld"
    "./../Micro-XRCE-DDS-Client/build/examples/SubscribeHelloWorld/SubscribeHelloWorldClient"
    "./../Micro-XRCE-DDS-Client/build/examples/TimeSync/TimeSync"
    "./../Micro-XRCE-DDS-Client/build/examples/ContinuousFragment/ContinuousFragment"
    "./../Micro-XRCE-DDS-Client/build/examples/TimeSyncWithCb/TimeSyncWithCb"
    "./../Micro-XRCE-DDS-Client/build/examples/SubscribeBigHelloWorld/SubscribBigBigClient"
)

sleep 2

# Launch all in parallel
pids=()
for exe in "${executables[@]}"; do
    if [[ -x "$exe" ]]; then
        echo "[•] Launching: $exe $ARGS"
        "$exe" $ARGS > /dev/null 2>&1 &
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

trap cleanup EXIT

sleep "$TIMEOUT"

cleanup

echo "[OK] All parallel tasks completed or terminated after timeout."

