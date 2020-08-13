# Silence-Trimming-with-FFMPEG
Trim silences from videos with FFMPEG

Requirements: FFMPEG

Files:

* to_ts.sh: Convert a video into TS.
* silence_trim.sh: Detect silences in vid.ts, split the video into multiple videos by detecting the silences then combine the files into shortvid.ts. Note that you may have to manually change the threshold in the command and the separated files are not deleted as Ubuntu LTS may have problems deleting thousands of files in one go.

Rationale

TS format used for as it supports file level concatenation (so that it's easier to split / combine the files during the silence detection section)


