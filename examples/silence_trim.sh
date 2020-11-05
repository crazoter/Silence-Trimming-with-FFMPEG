#!/bin/bash
# Used on Ubuntu 18.04 LTS
# Requires ffmpeg, ffprobe (ffprobe comes with ffmpeg)
# Place the video you want to shorten named vid.mp4 into same folder as this script
# Script will split video into several parts with sound and then merge said videos
# It will then clean up and produce a "shortened-vid.mp4"

# Expected preconditions:
# * ffmpeg and ffprobe are available
# * No files with the .ts extension other than "vid.ts" in the current directory
# * System supports bash commands

# Expected post-conditions:
# * tons of numbered .ts files (there aren't deleted as Ubuntu LTS has problem deleting the batch immediately after processing. They can be safely deleted after restarting)
# * list.txt
# * shortvid.ts which is the shortened video

# Recommended post-script actions:
# Convert output into a more space-efficient file format e.g. x265

# Known bugs:
# Audio may glitch out (observed on VLC player). User can remedy by changing the timestamp manually (e.g. left and right cursor keys)

ffmpeg -i vid.ts -filter_complex "[0:a]silencedetect=n=-30dB:d=0.3[outa]" -map [outa] -f s16le -y /dev/null |& F='-aq 30 -c copy -v warning' perl -ne 'INIT { $ss=0; $se=0; } if (/silence_start: (\S+)/) { $ss=$1; $ctr+=1; printf "ffmpeg -nostdin -i vid.ts -ss %f -t %f $ENV{F} -c copy -y %05d.ts\n", $se, ($ss-$se), $ctr; } if (/silence_end: (\S+)/) { $se=$1; } END { printf "ffmpeg -nostdin -i vid.ts -ss %f $ENV{F} -c copy -y %05d.ts\n", $se, $ctr+1; }' | bash -x

# delete files of size 0
find . -size 0 -print -delete

# temporarily rename vid.ts
mv vid.ts vid.ts.bak

# build list.txt
for f in *.ts ; do 
	# verify that the file has no errors; if it does, don't include in the list to merge
	result=$(ffprobe -loglevel error "$f" 2>&1)
	if [ ! -n "$result" ]; then
		echo file \'"$f"\' >> list.txt; 
	fi; 
done

# merge chosen files
ffmpeg -f concat -safe 0 -i list.txt -c copy shortvid.ts

mv vid.ts.bak vid.ts

# rm ./*mkv
# rm ./list.txt
