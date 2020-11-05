#!/bin/bash
# convert_and_trim.sh
# Bash script that trims all videos in current directory
# $1 file format extension, excluding dot separator

for f in *.$1; do
    ./convert_and_trim.sh ${f%%.*}-tmp $f ${f%%.*}-short.ts "-20"
done
