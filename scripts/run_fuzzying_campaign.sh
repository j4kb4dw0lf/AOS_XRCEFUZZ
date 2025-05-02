#!/bin/bash

cd /

# Check for required arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <port> <output_dir> <capture_time> [campaign_time] [verbosity]"
    echo "Example: $0 1234 output1 30 3600 4"
    exit 1
fi

PORT=$1
OUTPUT_DIR=$2
CAPTURE_TIME=$3
CAMPAIGN_TIME=${4:-0}  # Default infinite (0 means no timeout)
VERBOSITY=${5:-4}      # Default verbosity 4

# Validate verbosity
if [ "$VERBOSITY" -lt 0 ] || [ "$VERBOSITY" -gt 6 ]; then
    echo "[ERROR] Verbosity must be between 0-6"
    exit 1
fi

cleanup() {
    echo "[•] Cleaning up processes..."
    kill "$AGENT_PID" 2>/dev/null
    kill "$FUZZER_PID" 2>/dev/null
    pkill -P $$ 2>/dev/null
    rm -rf "$PORT" 2>/dev/null 
}

trap cleanup EXIT INT TERM

echo "[•] Starting MicroXRCEAgent on port $PORT with verbosity $VERBOSITY"
./app/Micro-XRCE-DDS/build/agent/src/agent-build/MicroXRCEAgent udp4 -p "$PORT" -v "$VERBOSITY" -d 7400 &
AGENT_PID=$!

sleep 2

echo "[•] Launching clients and capturing traffic for $CAPTURE_TIME seconds"
{
    # Run clients in background
    ./app/scripts/runall_clients.sh "$PORT" "$CAPTURE_TIME" &
    CLIENTS_PID=$!
    
    # Capture traffic in foreground
    ./app/scripts/aflnet_pcap_pipeline.sh "$PORT" "$CAPTURE_TIME"
    
    # Wait for clients to finish (they should be done by now due to timeout)
    wait "$CLIENTS_PID"
} &

wait

SEEDS_DIR="/app/aflnet/seeds"
mkdir -p "/app/aflnet/seeds"
echo "[•] Moving captured packets to seeds directory"
mv "$PORT" "$SEEDS_DIR" 2>/dev/null || {
    echo "[ERROR] Failed to move captured packets to seeds directory"
    exit 1
}

echo "[•] Starting AFLNet fuzzer campaign (timeout: ${CAMPAIGN_TIME:-infinite} seconds)"
if [ "$CAMPAIGN_TIME" -gt 0 ]; then
    timeout "$CAMPAIGN_TIME" \
    ./app/aflnet/afl-fuzz -d -i "$SEEDS_DIR/$PORT" -o "/app/aflnet/outputs/$OUTPUT_DIR" \
    -N "udp://127.0.0.1:$PORT" -R -P "XRCE-DDS" -m 100 \
    ./app/Micro-XRCE-DDS/build/agent/src/agent-build/MicroXRCEAgent udp4 -p "$PORT" -v "$VERBOSITY" -d 7400 &
else
    ./app/aflnet/afl-fuzz -d -i "$SEEDS_DIR/$PORT" -o "/app/aflnet/outputs/$OUTPUT_DIR" \
    -N "udp://127.0.0.1:$PORT" -R -P "XRCE-DDS" -m 100 \
    ./app/Micro-XRCE-DDS/build/agent/src/agent-build/MicroXRCEAgent udp4 -p "$PORT" -v "$VERBOSITY" -d 7400 &
fi
FUZZER_PID=$!

wait "$FUZZER_PID"

echo "[OK] Fuzzing campaign completed"

cd app
