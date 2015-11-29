#!/bin/bash
f="$1"

FNAME=`basename "$f"`
FDIR=`dirname "$f"`
F=`echo "$FNAME" | tr '[:lower:]' '[:upper:]'`
e="${F##*.}"

get_video_timestamp () {
  local TS=`mediainfo --Inform="Video;%Encoded_Date%" "$1" 2>/dev/null | cut -d ' ' -f 2,3 --output-delimiter='_' | sed -r 's/:/-/g'`
  echo "$TS"
}

get_image_timestamp () {
  local TS=`exiv2 -g 'Exif.Photo.DateTimeOriginal' print "$1" 2>/dev/null | sed -r 's/\s+/\t/g' | cut -f4- | sed -r 's/\t/_/g;s/:/-/g'`
  echo "$TS"
}

get_file_timestamp () {
  local TS=`date -r "$1" +%Y-%m-%d_%H-%M-%S`
  echo "$TS"
}

if [ -f "$f" ]; then
  case "$e" in
    JPG|CR2|TIFF|JPEG)
      D=`get_image_timestamp "$f"`
      T='IMAGE'
      ;;
    MP4|MOV|AVI|MPG|MPEG)
      D=`get_video_timestamp "$f"`
      T='VIDEO'
      ;;
    *)
      D=''
      T='UNKNOWN'
      ;;
  esac

  if [ -z "$D" ]; then
    D=`get_file_timestamp "$f"`
  fi

  if [ "$T" = 'IMAGE' ]; then
    exiv2 -T rename "$f"
  else
    echo "`date -r $f` vs $D"
  fi
fi
