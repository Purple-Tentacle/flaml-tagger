#!/bin/bash
if [ -z "$1" ]; then
    echo "please provide directory path"
    exit 1
fi

file=$(find "$1" -maxdepth 1 -type f | head -n 1)
echo "$file"
metaflac --export-picture-to="$1/cover.png" "$file"
