#!/bin/bash

# This script is used to feed text to openSCAD

# Check if correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_file> <destination_file>"
    exit 1
fi

# Check if source file exists
if [ ! -f "$1" ]; then
    echo "Source file not found!"
    exit 1
fi

# Read source file character by character and copy to destination file with a 1-second pause after each new line
while IFS= read -r line; do
    echo(length(line))
    echo "$line" >> "$2"
    sleep 1
done < "$1"




