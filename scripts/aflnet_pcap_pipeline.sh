#!/bin/bash

# Usage: ./aflnet_pcap_pipeline.sh <PORT> <CAPTURE_DURATION_SECONDS>

PORT=$1
DURATION=$2
PCAP_FILE="$1.pcap"
SEEDS_DIR=$1
PYTHON_SCRIPT="python_scripts/extract_raws.py"

if [ -z "$PORT" ] || [ -z "$DURATION" ]; then
  echo "Usage: $0 <PORT> <CAPTURE_DURATION_SECONDS>"
  exit 1
fi

echo "[•] Starting capture of UDP packets to $PORT for $DURATION seconds..."

timeout "$DURATION" tcpdump -i any port "$PORT" -w "$PCAP_FILE" -n > /dev/null 2>&1 

echo "[OK] Capture completed: $PCAP_FILE"

echo "[•] Extracting client flows towards server's port $PORT..."
python3 "$PYTHON_SCRIPT" "$PCAP_FILE" "$PORT" "$PORT"

if [ $? -ne 0 ]; then
  echo "[ERROR] Failed to convert the .pcap file to .raw files"
  exit 1
fi

echo "[OK] Collection of .raw files ready in folder: $SEEDS_DIR"

rm "$PCAP_FILE"

