#!/bin/bash
f="$1"

FNAME=`basename "$f"`
FDIR=`dirname "$f"`
F=`echo "$FNAME" | tr '[:lower:]' '[:upper:]'`
e="${F##*.}"

get_file_timestamp () {
  local TS=`date -r "$1" +'%Y:%m:%d %H:%M:%S`
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
      D=`get_timestamp_by_filename "$f"`
      ;;
    *)
      D=''
      ;;
  esac

  if [ -n "$D" ]; then
    STAMP=`echo $D | sed -r 's/_/ /;s/-/:/g'`
    exiv2 -M"set Exif.Photo.DateTimeOriginal $STAMP" "$f"
    exiv2 -M"set Exif.Photo.DateTimeDigitized $STAMP" "$f"
  fi
fi
