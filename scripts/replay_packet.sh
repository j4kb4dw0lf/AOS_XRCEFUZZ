#!/bin/bash

# Check if at least 2 arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <port> <packet1.raw> [<packet2.raw> ...]"
    exit 1
fi

PORT=$1
shift  # Remove port from arguments, leaving only packet files

# Convert all .raw files to base64 and pass to Python script at once
PACKETS=()
for packet_file in "$@"; do
    if [ ! -f "$packet_file" ]; then
        echo "Error: File $packet_file not found!"
        exit 1
    fi
    PACKETS+=("$(base64 -w 0 "$packet_file")")
done

# Call Python script with all packets
python3 send_udp.py "$PORT" "${PACKETS[@]}"