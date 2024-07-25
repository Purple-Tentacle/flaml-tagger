# What

The main script is tag.sh, it tags flac-files based on a yaml file named tags.yaml.
A second script, coverexport.sh extracts the cover from the first file in the provided directory and writes it to cover.png

#  Why

I have a huge collection of Die drei Fragezeichen CDs digitzed as flac-files. And I always had differences between tags and file names, wrong tags, missing tags and so on.
This is why I came up with the idea of having a file inside the folder of each album containing all information I want to tag.

# Prerequisites
- [yq](https://github.com/mikefarah/yq?tab=readme-ov-file) to parse the yaml file
- [metaflac](https://xiph.org/flac/documentation_tools_metaflac.html) to tag the flac-files
- The files must be in the right alphabetical order

# Usage

## tags.sh

1. Put the tags.yaml file in the directory where the flac-files are
2. Enter the tag information to the tags.yaml file
3. Put a cover.png into the directory
4. Run the tags.sh, providing the directory with the flac-files, **without a trailing /**

### Examples

```
./tag.sh 004\ Die\ schwarze\ Katze
./tag sh "004 Die schwarze Katze"
./tag sh '004 Die schwarze Katze'
```

## coverexport.sh

Run the coverexport.sh, providing the directory with the flac-files
> [!NOTE]
> The script tries to export the cover from the first file in the directory
> Besides checking if a directory was provided, there is no error handling.

### Example

```
./coverexport.sh dsfkljsdkl
```

# Errors and exit-codes
- please provide directory path of files to be tagged
  - exit-code: 1
- file tags.yaml does not exist in directory [directory]
  - exit-code: 2
- file cover.png does not exist in directory [directory]
  - exit-code: 3
- more flac-files than definitions in yaml: 9
  - exit-code: 4
- less flac-files than definitions in yaml: 7
  - exit-code: 5
- please provide directory argument without trailing /
  - exit-code: 6
