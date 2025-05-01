#!/usr/bin/env python3

FILENAME = "INSERT_FILENAME"

DATA = bytearray([
#INSERT_BYTEARRAY
]
)

def create_raw_file():
    """Creates a .raw file with hardcoded name and data"""
    
    if not FILENAME.endswith('.raw'):
        output_file = '../../crash_packets/' + FILENAME + '.raw'
    else:
        output_file = '../../crash_packets/' + FILENAME
    
    try:
        with open(output_file, 'wb') as f:
            f.write(DATA)
        print(f"Successfully created {output_file}")
        print(f"Size: {len(DATA)} bytes")
        print(f"Hex content: {DATA.hex()}")
    except IOError as e:
        print(f"Error creating file: {e}")

if __name__ == "__main__":
    create_raw_file()