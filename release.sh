#!/bin/bash

# release.sh, Version 0.1.0
# Copyright (c) 2025, neuralpain
# https://github.com/neuralpain/oneclickwinrar
# A bundler for oneclickwinrar

# [ INFO ]
# edit the version in ./VERSION
version=$(<VERSION)
# change name of release
name="oneclickwinrar"

# [ FILES LIST ]
files_list=(
  "licenserar.cmd"
  "oneclickrar.cmd"
  "installrar.cmd"
  "unlicenserar.cmd"
)

complete_release=$name-$version.zip

mkdir dist

cp ./LICENSE ./VERSION ./README.txt dist

for file in "${files_list[@]}"; do
  cp $file dist
done

cp -r bin dist

cd dist

# Ensure that the `zip` package is installed (https://stackoverflow.com/a/55749636)
#     1. Navigate to this sourceforge page: https://sourceforge.net/projects/gnuwin32/files/zip/3.0/
#         1.1. Download `zip-3.0-bin.zip`
#         1.2. In the zipped file, in the `bin` folder, find the file `zip.exe`.
#         1.3. Extract the file `zip.exe` to your `mingw64` bin folder (`C:\Program Files\Git\mingw64\bin`)
#     2. Navigate to to this sourceforge page: https://sourceforge.net/projects/gnuwin32/files/bzip2/1.0.5/
#         2.1. Download `bzip2-1.0.5-bin.zip`
#         2.2. In the zipped file, in the bin folder, find the file `bzip2.dll`
#         2.3. Extract `bzip2.dll` to your `mingw64\bin` folder (same folder as above: `C:\Program Files\Git\mingw64\bin`)
zip -q $complete_release -r * || (echo -e "$return error: Failed to create archive." && return)

cd ..

mv ./dist/$complete_release ./release/$complete_release

[[ -f $complete_release ]] && echo -e "$return Archived success."

rm -rf dist
