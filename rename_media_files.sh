#!/bin/bash
USE_TS=$1

image_extensions=('JPG' 'JPEG' 'CR2' 'TIFF' 'PNG' 'HEIC')
video_extensions=('MOV' 'MP4' 'AVI' 'MPG')
media_extensions=("${image_extensions[@]}" "${video_extensions[@]}")

pwd
logfile="/tmp/rename`pwd | sed -r 's@/@_@g'`_`date +%Y-%m-%d_%H-%M-%S`.log"
pwd >> "$logfile"
for e in ${media_extensions[@]}; do
  echo "Rename *.$e files..."
  find * -maxdepth 0 -type f -iname "*.$e" -exec rename_media_file.sh "{}" "$USE_TS" \; 2>&1 | tee -a "$logfile"
done
echo "logfile is \"$logfile\""
