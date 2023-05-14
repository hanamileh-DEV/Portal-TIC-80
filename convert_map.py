#!/usr/bin/env python3
# Generated by ChatGPT, improved by a human

import sys
from pathlib import Path

PATH_LEN = 50  # Maximum path length for printing
is_interactive = False

# Shorten a path to fit within a limited length (truncate if necessary)
def shorten_path(path, limit):
    path = path.absolute()
    parts = list(path.parts)

    # Collapse home directory
    if path.is_relative_to(Path.home()):
        parts = ["~"] + parts[len(Path.home().parts) :]

    # Shorten directories, one at a time
    for i in range(1, len(parts) - 1):
        if len(str(path)) <= limit:
            break
        parts[i] = parts[i][0]
        path = Path(*parts)

    result = str(Path(*parts))

    # Truncate
    if len(result) > limit:
        result = "…" + result[-(limit - 1) :]

    return result


# Ask user to select a map file interactively
def select_interactive():
    map_files = list(Path(".").glob("**/*.map"))
    if len(map_files) == 0:
        sys.exit("No .map files in current directory.")

    # Print current dir and list of files
    print(f"Current directory: {shorten_path(Path('.'), PATH_LEN)}")
    print()
    print("Available .map files:")
    for i, f in enumerate(map_files, 1):
        print(f"[{i}] {f}")
    print()

    # Ask the user for the index of the desired file
    while True:
        try:
            selection = int(input("Please select a file: "))
            if 1 <= selection <= len(map_files):
                break
            print("Out of range.")
        except ValueError:
            print("Not a number.")

    return map_files[selection - 1]


# Find the input path, either from command line or interactively
if len(sys.argv) >= 2:
    input_path = Path(sys.argv[1])
else:
    input_path = select_interactive()
    is_interactive = True
output_path = input_path.with_suffix(".lua")
if is_interactive:
    print()
    print(f'Reading "{input_path}".')


# Check that the file exists, isn't a directory, and it is 32640 bytes long (1 map bank)
if not input_path.exists():
    sys.exit(f'The file "{input_path}" was not found.')
if not input_path.is_file():
    sys.exit(f'"{input_path}" is not a regular file.')
if input_path.stat().st_size != 32640:
    sys.exit(f'"{input_path}" is not 32640 bytes long.')


def read_bitfield(value, fields):
    result = []
    for field in reversed(fields):
        result.insert(0, value & (1 << field) - 1)
        value >>= field
    return result


# Open a binary reading file in binary mode
with input_path.open("rb") as f:
    # Start by reading walls until we hit a block of 3 zero bytes
    walls = []
    while True:
        block = f.read(3)
        if block == b"\x00\x00\x00":
            # Indicates the end of wall data
            break
        val = int.from_bytes(block, "big")
        walls.append(read_bitfield(val, [4, 4, 4, 2, 2, 6]))

    # Then read objects until we hit a block of 6 zero bytes
    objs = []
    while True:
        block = f.read(6)
        if len(block) != 6 or block == b"\x00\x00\x00\x00\x00\x00":
            # End of object data
            break
        val = int.from_bytes(block, "big")
        # val >> 4 because hanamileh has never heard of consistency
        obj_data = read_bitfield(val >> 4, [12, 10, 12, 5, 5])
        obj_data[0] -= 1520
        obj_data[1] -= 116
        obj_data[2] -= 1520
        objs.append(obj_data)

# Save the blocks to the text file
with output_path.open("w") as f:
    f.write("maps[1][lvl_id] = { --map by: [your name]\n")
    f.write("	w={ -- walls\n")
    for wall in walls:
        f.write("		{" + ", ".join(str(num) for num in wall) + "},\n")
    f.write(
        """	},
	o={ --table for objects
""",
    )
    for obj in objs:
        f.write("		{" + ", ".join(str(num) for num in obj) + "},\n")
    f.write(
        """	},
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
""",
    )

if is_interactive:
    print(f'Map converted. Result is in "{output_path}".')
