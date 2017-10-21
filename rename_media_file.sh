#!/bin/bash
f="$1"
use_ts=`echo ${2:-'N'} | tr '[:lower:]' '[:upper:]'` # should be Y

FNAME=`basename "$f"`
FDIR=`dirname "$f"`
F=`echo "$FNAME" | tr '[:lower:]' '[:upper:]'`
e="${F##*.}"

image_extensions=('JPG' 'CR2' 'TIFF' 'JPEG' 'PNG')
video_extensions=('MP4' 'MOV' 'AVI' 'MPG')
media_extensions=("${image_extensions[@]}" "${video_extensions[@]}")

# source: https://stackoverflow.com/questions/14366390/check-if-an-element-is-present-in-a-bash-array
array_contains2 () { 
  local array="$1[@]"
  local seeking=$2
  local in=1
  for element in "${!array}"; do
    if [[ $element == $seeking ]]; then
      in=0
      break
    fi
  done
  return $in
}

array_contains2 image_extensions "$e" && IS_IMAGE=1
array_contains2 video_extensions "$e" && IS_VIDEO=1

if [[ $IS_VIDEO -ne 1 && $IS_IMAGE -ne 1 ]]; then
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
  echo "$MODEL" | sed -r 's/[^[:alnum:]_%#,()\-]//g'
}

get_video_camera_model () {
  local MODEL=''
  echo "$MODEL" | sed -r 's/[^[:alnum:]_%#,()\-]//g'
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

if [[ -f $f ]]; then
  if [[ $IS_IMAGE -eq 1 ]]; then
    D=`get_image_timestamp "$f"`
    M=`get_image_camera_model "$f"`
  elif [[ $IS_VIDEO -eq 1 ]]; then
    D=`get_video_timestamp "$f"`
    M=`get_video_camera_model "$f"`
  else
    D=''
    M=''
  fi

  if [[ -z $D ]]; then
    echo "File \"$f\". No Exif data found. TS: `get_file_timestamp "$f"`"
    if [[ $use_ts == 'Y' ]]; then
      D=`get_file_timestamp "$f"`
      M=`echo "${FNAME%.*}" | sed -r 's/[^[:alnum:]_#]+/_/g'`
    fi
  fi

  if [[ -n $D ]]; then
    if [[ -n $M ]]; then
      n=$( index_name "${D}_${M}" "$e" )
    else
      n=$( index_name "${D}" "$e" )
    fi

    if [[ "$FNAME" != "$n" && "$n" != ".$e" ]]; then
      if [[ $IS_IMAGE -eq 1 ]]; then
        exiv2 -T rename "$f"
      fi
#      cp -v --no-preserve=ownership "$f" "$FDIR/$n" && rm -v "$f"
      mv -v "$f" "$FDIR/$n"
      nfname=${n%%.*}
      # Rename associated service files too
      for o in `ls "${f%%.*}".* 2>/dev/null`; do
        oe=`echo ${o##*.} | tr 'a-z' 'A-Z'`
        array_contains2 media_extensions "$oe" && tst=1
        if [[ $tst -ne 1 ]]; then
          mv -v "$o" "$FDIR/$nfname.$oe"
        fi
      done
    fi
  fi
fi
