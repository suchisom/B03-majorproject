import sys

# Read the raw binary file output by the compiler
with open(sys.argv[1], "rb") as f:
    bytes_data = f.read()

# Write 32-bit words in Little-Endian format
with open(sys.argv[2], "w") as f:
    for i in range(0, len(bytes_data), 4):
        chunk = bytes_data[i:i+4]
        # Pad with zeros if the last instruction is cut off
        chunk += b'\x00' * (4 - len(chunk))
        # Combine 4 bytes into one 32-bit hex word (Little Endian reversal)
        word = (chunk[3] << 24) | (chunk[2] << 16) | (chunk[1] << 8) | chunk[0]
        f.write(f"{word:08x}\n")