#!/bin/bash
f="$1"

FNAME=`basename "$f"`
FDIR=`dirname "$f"`
F=`echo "$FNAME" | tr '[:lower:]' '[:upper:]'`
e="${F##*.}"
if [ "$e" = 'LOG' ]; then
  exit 0
fi
logfile="rename_`date +%Y-%m-%d_%H-%M-%S`.log"

get_video_timestamp () {
  local TS=`mediainfo --Inform="Video;%Encoded_Date%" "$1" 2>/dev/null | cut -d ' ' -f 2,3 --output-delimiter='_' | sed -r 's/:/-/g'`
  echo "$TS"
}

get_image_timestamp () {
  local TS=`exiv2 -g 'Exif.Photo.DateTimeOriginal' print "$1" 2>/dev/null | sed -r 's/\s+/\t/g' | cut -f4- | sed -r 's/\t/_/g;s/:/-/g'`
  echo "$TS"
}

get_image_camera_model () {
  local MODEL=`exiv2 -g 'Exif.Image.Model' print "$1" 2>/dev/null | sed -r 's/\s+/\t/g' | cut -f4- | sed -r 's/\t/_/g;s/.*/\U&/g;s/_DIGITAL.*$//;s/_+$//g'`
  echo "$MODEL"
}

get_video_camera_model () {
  local MODEL=''
  echo "$MODEL"
}

get_file_timestamp () {
  local TS=`date -r "$1" +%Y-%m-%d_%H-%M-%S`
  echo "$TS"
}

index_name () {
  local _n="$1"
  local _e="$2"
  local __n="${_n}.${_e}"
  if [ "$FNAME" != "$__n" ]; then
    i=1
    while [[ -f "$FDIR/$__n" && "$FNAME" != "$__n" && $i -le 999 ]]; do
      __n="${_n}_`printf "%03i" $i`.${_e}"
      let i=$i+1
    done
  fi
  echo "$__n"
}

if [ -f "$f" ]; then
  if [[ "$e" == 'JPG' || "$e" == 'CR2' || "$e" == 'TIFF' || "$e" == 'JPEG' ]]; then
    D=`get_image_timestamp "$f"`
    M=`get_image_camera_model "$f"`
    T='IMAGE'
  elif [[ "$e" == 'MP4' || "$e" == 'MOV' || "$e" == 'AVI' || "$e" == 'MPG' ]]; then
    D=`get_video_timestamp "$f"`
    M=`get_video_camera_model "$f"`
    T='VIDEO'
  else
    D=''
    M=''
    T='UNKNOWN'
  fi

  if [ -z "$D" ]; then
    D=`get_file_timestamp "$f"`
  fi

  if [ -n "$M" ]; then
    n=$( index_name "${D}_${M}" "$e" )
  else
    n=$( index_name "${D}" "$e" )
  fi

  if [[ "$FNAME" != "$n" && "$n" != ".$e" ]]; then
    if [ "$T" = 'IMAGE' ]; then
      exiv2 -T rename "$f"
    fi
    cp -v --no-preserve=ownership "$f" "$FDIR/$n" && rm -v "$f"
  fi
fi

