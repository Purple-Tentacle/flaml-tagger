#!/bin/bash
if [ -z "$1" ]; then
    echo "please provide directory path of files to be tagged"
    exit 1
fi

# check if tags.yaml file exists
if [ ! -f "$1"/tags.yaml ]; then
    echo "file tags.yaml does not exist in directory" "$1"
    exit 2
fi

# check if cover.png file exists
if [ ! -f "$1"/cover.png ]; then
    echo "file cover.png does not exist in directory" "$1"
    exit 3
fi

# check if number of flac-files and titles in yaml match
tracktotal=$(yq '.titles | length' "$1"/tags.yaml)
num_files=$(ls -1q "${1}"/*.flac | wc -l)
if ((num_files > tracktotal)); then
    echo "more flac-files than definitions in yaml:" "$num_files"
    exit 4
elif ((num_files < tracktotal)); then
    echo "less flac-files than definitions in yaml:" "$num_files"
    exit 5
fi

# check if directory argument has a trailing /
# this would lead to issues with folder renaming
if [ "${1: -1}" == "/" ];then
    echo "please provide directory argument without trailing /"
    exit 6
fi

album="$(yq '.albumnumber' "$1"/tags.yaml) $(yq '.album' "$1"/tags.yaml)"
albumartist=$(yq '.albumartist' "$1"/tags.yaml)
echo "$albumartist" "-" "$album"
echo "tagging and renaming" "$num_files" "files in" "$1"
date=$(yq '.date' "$1"/tags.yaml)
genre=$(yq '.genre' "$1"/tags.yaml)
description=$(yq '.description' "$1"/tags.yaml)
organisation=$(yq '.organisation' "$1"/tags.yaml)
conductor=$(yq '.conductor' "$1"/tags.yaml)
discnumber=$(yq '.discnumber' "$1"/tags.yaml)
disctotal=$(yq '.disctotal' "$1"/tags.yaml)

echo "removing all tags in directory" "$1"
metaflac --remove-all "$1"/*.flac # revove all tags
echo "scanning and writing gains/peaks, this will take some time"
metaflac --add-replay-gain "$1"/*.flac #scan for and write gains/peaks

i=0 # initialize index
echo "setting tags"
for file in "$1"/*.flac; do
    # set tags
    readarray -t artists < <(yq e ".titles.${i}.artists[]" "$1"/tags.yaml)
    for artist in "${artists[@]}"; do
        metaflac --set-tag=artist="$artist" "$file"
    done
    metaflac --set-tag=album="$album" "$file"
    metaflac --set-tag=albumartist="$albumartist" "$file"
    metaflac --set-tag=date="$date" "$file"
    metaflac --set-tag=genre="$genre" "$file"
    metaflac --set-tag=description="$description" "$file"
    metaflac --set-tag=organisation="$organisation" "$file"
    metaflac --set-tag=conductor="$conductor" "$file"
    metaflac --set-tag=tracktotal="$tracktotal" "$file"
    metaflac --set-tag=discnumber="$discnumber" "$file"
    metaflac --set-tag=disctotal="$disctotal" "$file"
    tracknumber=$(yq e .titles.[$i].tracknumber "$1"/tags.yaml)
    metaflac --set-tag=tracknumber="$tracknumber" "$file"
    title="${tracknumber} $(yq e .titles.[$i].title "$1"/tags.yaml)"
    echo "title:" $title
    metaflac --set-tag=title="$title" "$file"
    echo "importing cover picture"
    metaflac --import-picture-from="$1/cover.png" "$file" # set cover image
    echo "renaming file"
    mv "$file" "$1"/"$title".flac &> /dev/null # rename file
    i=$((i+1)) # increment index
done

#mv "$1" "$album" &> /dev/null #rename directory
# compare current directory name with intended name
if [ "$1" != "$album" ]; then
    echo "renaming directory to" "$1"
    mv "$1" "$album" #rename directory
else
    echo "directory name is ok, no rename needed"
fi

echo "done."
