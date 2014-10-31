#!/bin/sh

path_to_executable=$(which name_of_executable)
 if [ -x "$path_to_executable" ] ; then
    echo "It's here: $path_to_executable"
 fi
