 #!/usr/bin/env bash

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

printf '%s' "" > "$2"

while read -r line; do
    #echo -e "$line" >> "$2"
    # Print characters in the line
    for (( i=0; i<${#line}; i++ )); do
        printf '%s' "${line:$i:1}" >> "$2"
        sleep 0.25
    done
    echo "" >> "$2"
    sleep 1
done < "$1"

exit
