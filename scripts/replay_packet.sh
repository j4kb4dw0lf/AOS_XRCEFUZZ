#!/bin/bash

# Check if at least 2 arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <port> <packet1.raw> [<packet2.raw> ...]"
    exit 1
fi

PORT=$1
shift  

PACKETS=()
for packet_file in "$@"; do
    if [ ! -f "$packet_file" ]; then
        echo "[ERROR] File $packet_file not found!"
        exit 1
    fi
    PACKETS+=("$(base64 -w 0 "$packet_file")")
done

python3 python_scripts/send_udp.py "$PORT" "${PACKETS[@]}"
