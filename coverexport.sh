#!/bin/bash
if [ -z "$1" ]; then
    echo "please provide directory path"
    exit 1
fi

dir=$1
files=($dir/*.flac)
file="${files[0]}"
metaflac --export-picture-to="$dir/cover.png" "$file"
