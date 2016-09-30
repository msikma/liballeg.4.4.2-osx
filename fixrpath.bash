#!/usr/bin/env bash

if [[ $# -eq 0 ]]; then
    echo "Usage: fixrpath.bash old_link_path"
    echo
    echo "Alters executables by forcing them to look for liballeg.4.4.dylib"
    echo "in a relative location (../lib/liballeg.4.4.dylib). For this to"
    echo "work, you need to supply the absolute path linker currently used"
    echo "by these executables. See readme.md for more information."

    mbpath=`otool -lv tools/dat | grep -i "liballeg.4.4.dylib" | \
            sed -n -e "s/^.*name //p" | sed -n -e "s/dylib.*$/dylib/p"`
    if [[ $mbpath != *"@rpath"* ]]; then
        echo
        echo "The absolute path may be the following (from running otool -lv):"
        echo $mbpath
    else
        echo
        echo "Detected @rpath in liballeg.4.4.dylib link in tools/dat."
        echo "You may already have run the script before."
    fi

    exit 1
fi

# Find all executables, except in .git/, and except .dylib and .bash files.
find . -path ./.git -prune -o  -not -name "*.dylib" -not -name "*.bash" \
     -type f -perm +111 -print | while read line; do
    install_name_tool -add_rpath @loader_path/../lib/ $line
    install_name_tool -change $1 @rpath/liballeg.4.4.dylib $line
done
