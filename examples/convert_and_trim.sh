#!/bin/bash
# convert_and_trim.sh
# Bash script that uses ffmpeg to remove silences
# $1 working folder: files will be transferred to this folder
# $2 input file name
# $3 output file name
# $4 silencedetect threshold (e.g. -20)

# Used on Ubuntu 18.04 LTS
# Requires ffmpeg, ffprobe (ffprobe comes with ffmpeg)
# Place the video you want to shorten named vid.mp4 into same folder as this script
# Script will split video into several parts with sound and then merge said videos
# It will then clean up and produce a "shortened-vid.mp4"

# create directory
mkdir -p $1
# convert input file to ts
ffmpeg -i $2 $1/vid.ts
# navigate to working directory
cd $1

# Build appropriate files
ffmpeg -i vid.ts -filter_complex "[0:a]silencedetect=n=$4dB:d=0.3[outa]" \
-map [outa] -f s16le -y /dev/null |& F='-aq 30 -c copy -v warning' \
perl -ne 'INIT { $ss=0; $se=0; } if (/silence_start: (\S+)/) { $ss=$1; $ctr+=1; printf "ffmpeg -nostdin -i vid.ts -ss %f -t %f $ENV{F} -c copy -y %05d.ts\n", $se, ($ss-$se), $ctr; } if (/silence_end: (\S+)/) { $se=$1; } END { printf "ffmpeg -nostdin -i vid.ts -ss %f $ENV{F} -c copy -y %05d.ts\n", $se, $ctr+1; }' | bash -x

# delete files of size 0
find . -size 0 -print -delete

# temporarily rename vid.ts
mv vid.ts vid.ts.bak

for f in *.ts ; do 
	result=$(ffprobe -loglevel error "$f" 2>&1)
	if [ ! -n "$result" ]; then
		echo file \'"$f"\' >> list.txt; 
	fi; 
done

ffmpeg -f concat -safe 0 -i list.txt -c copy shortvid.ts

mv vid.ts.bak vid.ts

# Attempt to remove temporary file(s). Skip if timeout, meaning file could not be deleted
for f in *.ts; do
	timeout 3 rm ./$f
done

timeout 3 rm ./list.txt

mv shortvid.ts $3
