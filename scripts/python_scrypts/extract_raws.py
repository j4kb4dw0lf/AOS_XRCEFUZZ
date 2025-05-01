from scapy.all import rdpcap, UDP, IP
from collections import defaultdict
import os
import sys

def extract_all_flows(pcap_file, server_port, output_dir):
    packets = rdpcap(pcap_file)
    flows = defaultdict(list)

    for pkt in packets:
        if IP in pkt and UDP in pkt:
            ip = pkt[IP]
            udp = pkt[UDP]
            if udp.dport == server_port:
                flow_id = (ip.src, udp.sport, ip.dst, udp.dport)
                if len(udp.payload) > 0:
                    flows[flow_id].append(bytes(udp.payload))

    if not flows:
	print("[ERROR]	No Packet Found")
        return

    os.makedirs(output_dir, exist_ok=True)

    for i, (flow_id, payloads) in enumerate(flows.items(), start=1):
        filename = os.path.join(output_dir, f"input_{i:03d}.raw")
        with open(filename, "wb") as f:
            for payload in payloads:
                f.write(payload)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 extract_raws.py <input.pcap> <server_port> <output_dir>")
        sys.exit(1)
    print("Extracting flows...")
    print("Extracting flows from", sys.argv[1], "to", sys.argv[3])
    print("Server port", sys.argv[2])
    print("Output dir", sys.argv[3])
    extract_all_flows(sys.argv[1], int(sys.argv[2]), sys.argv[3])
