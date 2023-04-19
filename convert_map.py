#!/usr/bin/env python3
# Generated by ChatGPT, improved by a human

import os
import sys

max_str_len = 50 # Maximum line length (constant)

# Request the file from the user
current_dir = os.getcwd()

separator = "\\"

# Output the current directory (hiding folder names, if necessary, so that the line length is not longer than the specified one)
dirs = current_dir.split(separator)
print_dir = current_dir

if len(current_dir) <= max_str_len:
    print("Current Dir:",current_dir)
else:
   dirs.pop(2)
   dirs.insert(2,"...")
   while len(separator.join(dirs)) > max_str_len and len(dirs) > 4:
      dirs.pop(3)
   print("Current Dir:",separator.join(dirs))


# A list of all .map files
print() #Empty string
print("Current file list:")

files = os.listdir(current_dir)

wav_files = [f for f in files if f.endswith(".map")]

for i,f in enumerate(wav_files,1):
   print(f"[{i}] {f}")

print() #Empty string

# Ask the user for the number of the desired file
while True:
   try:
      sel_file_index = int(input("Please select a file: "))
      if 1 <= sel_file_index <= len(wav_files):
         break
      else:
         print("Enter the correct file number!")
   except ValueError:
      print("Enter the number!")
      

# Open the selected file
filename = wav_files[sel_file_index-1]
print("Opening a file",filename,"...")


outfilename = filename[0:-4] + ".lua"

# Check that the file exists, isn't a directory, and its size does not exceed 32640 bytes
if not os.path.exists(filename):
    sys.exit(f"The file \"{filename}\" was not found.") # I'm not sure if it's necessary now, but it won't be superfluous
if os.path.isdir(filename):
    sys.exit(f"\"{filename}\" is a directory.")
if os.path.getsize(filename) > 32640:
    sys.exit("The file is too large.")

# Open a binary reading file in binary mode
with open(filename, "rb") as f:
    # We read the file to the end and break it into blocks of 3 bytes
    blocks = []
    while True:
        block = f.read(3)
        if len(block) < 3 or block == b"\x00\x00\x00":
            break
        val = int.from_bytes(block, "big")

        # We break the block into 6 numbers
        num6 = (val & 0b0000_0000_0000_0000_0011_1111) >> 0
        num5 = (val & 0b0000_0000_0000_0000_1100_0000) >> 6
        num4 = (val & 0b0000_0000_0000_0011_0000_0000) >> 8
        num3 = (val & 0b0000_0000_0011_1100_0000_0000) >> 10
        num2 = (val & 0b0000_0000_1100_0000_0000_0000) >> 14
        num1 = (val & 0b0000_1111_0000_0000_0000_0000) >> 16

        blocks.append((num1, num2, num3, num4, num5, num6))

# Save the blocks to the text file
with open(outfilename, "w") as f:
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

print(f"Finished! Result is in \"{outfilename}\".")
