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
  if [ $? -eq 0 ]; then
    echo "$TS"
  fi
}

get_file_timestamp () {
  local TS=`date -r "$1" +%Y-%m-%d_%H-%M-%S`
  if [ $? -eq 0 ]; then
    echo "$TS"
  fi
}

get_timestamp_by_filename () {
  local TS=`basename "$1" | cut -c 1-19 | egrep '[0-9]{4}-(0[1-9]|1[012])-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}'`
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
    D=`get_timestamp_by_filename "$f"`
    flag=1
  else
    flag=0
  fi

  if [ -n "$D" ]; then
    FSTAMP=`get_file_timestamp "$f"`
    if [ "$FSTAMP" != "$D" ]; then
      if [[ $flag -eq 0 && "$T" = 'IMAGE' ]]; then
        echo 'Change of modification timstamp by Exif metadata'
        exiv2 -T rename "$f"
      else
        if [ $flag -eq 1 ]; then
          echo 'Change of modification timstamp by file name'
        else
          echo 'Change of modification timstamp by metadata'
        fi
        STAMP=`echo $D | sed -r 's/_//g;s/-/./4;s/-//g'`
        touch --no-create -t $STAMP "$f"
      fi
    fi
  fi
fi
