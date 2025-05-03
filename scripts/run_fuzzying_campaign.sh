#!/bin/bash

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

SESSION_NAME="fuzz_session"

cleanup() {
    echo "[•] Cleaning up tmux session and temp files..."
    tmux kill-session -t "$SESSION_NAME" 2>/dev/null
    rm -rf "$PORT" 2>/dev/null
}

trap cleanup EXIT INT TERM

# Setup seeds and output dirs
SEEDS_DIR="/app/aflnet/seeds"
mkdir -p "$SEEDS_DIR"
mkdir -p "/app/aflnet/outputs"
rm -rf "$SEEDS_DIR/$PORT"

echo "[•] Capturing traffic for $CAPTURE_TIME seconds"
./../Micro-XRCE-DDS-Agent/build/MicroXRCEAgent udp4 -p "$PORT" -v "$VERBOSITY" -d 7400 > /dev/null 2>&1 &
AGENT_PID=$!

echo "[•] Launching clients and capturing traffic for $CAPTURE_TIME seconds"

./runall_clients.sh "$PORT" "$CAPTURE_TIME" &
CLIENTS_PID=$!

./aflnet_pcap_pipeline.sh "$PORT" "$CAPTURE_TIME" &
PCAP_PID=$!

wait "$CLIENTS_PID"
wait "$PCAP_PID"

kill "$AGENT_PID" 2>/dev/null

echo "[•] Moving captured packets to seeds directory"
if [ -d "$PORT" ]; then
    mv "$PORT" "$SEEDS_DIR" 2>/dev/null || {
        echo "[ERROR] Failed to move captured packets to seeds directory"
        exit 1
    }
else
    echo "[ERROR] Directory $PORT does not exist"
    exit 1
fi

tmux kill-session -t "$SESSION_NAME" 2>/dev/null

tmux new-session -d -s "$SESSION_NAME" -n fuzzing

# Left pane → MicroXRCEAgent
tmux send-keys -t "$SESSION_NAME":0.0 "./../Micro-XRCE-DDS-Agent/build/MicroXRCEAgent udp4 -p $PORT -v $VERBOSITY -d 7400" C-m

# Split right pane → AFLNet
tmux split-window -h -t "$SESSION_NAME":0
if [ "$CAMPAIGN_TIME" -gt 0 ]; then
    tmux send-keys -t "$SESSION_NAME":0.1 "timeout $CAMPAIGN_TIME ./../aflnet/afl-fuzz -d -i $SEEDS_DIR/$PORT -o /app/aflnet/outputs/$OUTPUT_DIR -N udp://127.0.0.1/$PORT -R -P XRCE-DDS -m 100 ./../Micro-XRCE-DDS-Agent/build/MicroXRCEAgent udp4 -p $PORT -v $VERBOSITY -d 7400" C-m
else
    tmux send-keys -t "$SESSION_NAME":0.1 "./../aflnet/afl-fuzz -d -i $SEEDS_DIR/$PORT -o /app/aflnet/outputs/$OUTPUT_DIR -N udp://127.0.0.1/$PORT -R -P XRCE-DDS -m 100 ./../Micro-XRCE-DDS-Agent/build/MicroXRCEAgent udp4 -p $PORT -v $VERBOSITY -d 7400" C-m
fi

# Attach the tmux session so the user sees the split
tmux attach-session -t "$SESSION_NAME"

echo "[OK] Fuzzing campaign completed"