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

# Read source file character by character and copy to destination file with a 1-second pause after each new line
while IFS= read -n 1 char; do
    echo -n "$char" >> "$2"
    printf "$char"
    printf "%d" "'$char" >> "$2"
        sleep 0.1
    if [ "$char" = "\n" ]; then
        printf "backslash n"        
        printf "\r\n" >> "$2"
        sleep 1
    fi
    if [ "$char" = '\r' ]; then
        printf "backslash r"
        echo -e '\r\n' >> "$2"
        sleep 1
    fi
    
done < "$1"


