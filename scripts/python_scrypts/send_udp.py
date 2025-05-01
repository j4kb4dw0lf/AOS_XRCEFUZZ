#!/usr/bin/env python3
import sys
import socket
import base64

def send_udp_packets(port, packets_data):

    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.bind(('localhost', 0))  # Bind to any available port
        source_port = sock.getsockname()[1]
        
        server_address = ('localhost', port)
        
        print(f"[•] Sending from source port {source_port} to destination port {port}")
        
        for i, packet_data in enumerate(packets_data, 1):
            
            packet_bytes = base64.b64decode(packet_data)
            sock.sendto(packet_bytes, server_address)
            
    except Exception as e:
        print(f"[ERROR] sending packets: {e}")
    finally:
        sock.close()

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 send_udp.py <port> <base64_packet1> [<base64_packet2> ...]")
        sys.exit(1)
    
    port = int(sys.argv[1])
    packets_data = sys.argv[2:]
    
    send_udp_packets(port, packets_data)
    print("[OK] Exiting")
