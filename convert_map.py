#!/usr/bin/env python3

import os
import sys
# Generated by ChatGPT, improved by a human

# Get a filename, from the command line or interactively
if len(sys.argv) > 1:
    filename = sys.argv[1]
else:
    filename = input("Enter the file name: ")

# Add the .map extension if necessary
if not filename.endswith(".map"):
    filename += ".map"

# Check that the file exists, isn't a directory, and its size does not exceed 32640 bytes
if not os.path.exists(filename):
    sys.exit(f"The file \"{filename}\" was not found")
if os.path.isdir(filename):
    sys.exit(f"\"{filename}\" is a directory")
if os.path.getsize(filename) > 32640:
    sys.exit("The file is too large")

# Open a binary reading file in binary mode
with open(filename, "rb") as f:
    # We read the file to the end and break it into blocks of 3 bytes
    blocks = []
    while True:
        block = f.read(3)
        if len(block) < 3 or block == b"\x00\x00\x00":
            break
        val = int.from_bytes(block, "big")

        num6 = (val & 0b0000_0000_0000_0000_0011_1111) >> 0
        num5 = (val & 0b0000_0000_0000_0000_1100_0000) >> 6
        num4 = (val & 0b0000_0000_0000_0011_0000_0000) >> 8
        num3 = (val & 0b0000_0000_0011_1100_0000_0000) >> 10
        num2 = (val & 0b0000_0000_1100_0000_0000_0000) >> 14
        num1 = (val & 0b0000_1111_0000_0000_0000_0000) >> 16

        blocks.append((num1, num2, num3, num4, num5, num6))

# Save the blocks to the text file
with open(filename[0:-4] + ".lua", "w") as f:
    f.write("maps[1][lvl_id] = { --map by: [your name]\n")
    f.write("	w={ -- walls\n")
    for i, block in enumerate(blocks):
        f.write("		{" + ", ".join(str(num) for num in block) + "},\n")
    f.write("""	},
	o={ --table for objects
		--{X, Y, Z, type, [additional parameters]}
	},
	p={}, --table for portals (leave empty if the portals are not needed)
	lg={}, --light bridge generators
	lift={nil,nil}, --Initial and final elevator (X Y Z angle)
	pg_lvl=0, --portal gun lvl
	init = function()
		--its executed once before starting this lvl
	end,
	scripts = function()
		--its executed once per frame (usually 60 times per second)
	end
}
""")

print("Finished!")
