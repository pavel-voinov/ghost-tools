#!/bin/bash
BASEDIR=${1:-'/media/NS4300N/Photos'}

index_name () {
  local _d=`dirname "$1"`
  local _f=`basename "$1"`
  local _n="${_f%%.*}"
  local _e="${_f##*.}"
  local __n="$_f"
  i=1
  while [[ -f "$_d/$__n" && $i -le 999 ]]; do
    __n="${_n}_`printf "%03i" $i`.${_e}"
    let i=$i+1
  done
  echo "$__n"
}

move_file () {
  local _f="$1"
  local _d="$2"
  local _F="$_d/$_f"
  local _fn="${_f%.*}"
  local _fe="${_f##*.}"
  local _FN="$_d/$_fn"

  # try to find the same file
  local _found=0
  if [ -f "$_F" ]; then
    local s1=`wc -c "$_f" | cut -d ' ' -f 1`
    local s2=0
    local cksum1=`md5sum -b "$_f" | cut -d ' ' -f 1`
    local cksum2=''

    for x in `ls -1 $_F ${_FN}_[0-9][0-9][0-9].${_fe} 2>/dev/null`; do
      # compare by size
      s2=`wc -c "$x" | cut -d ' ' -f 1`
      if [ $s1 -eq $s2 ]; then
        # compare by md5sum
        cksum2=`md5sum -b "$x" | cut -d ' ' -f 1`
        if [ "$cksum1" == "$cksum2" ]; then
          _found=1
          _dup_file="$x"
        fi
      fi
    done

    if [ $_found -eq 1 ]; then
      echo "Duplicate of \"$_dup_file\""
      rm -v "$_f"
    else
      n=$( index_name "$_F" )
      cp -v --no-preserve=ownership "$_f" "$_d/$n" && rm -v "$_f" && chmod 0664 "$_d/$n"
    fi
  else
    cp -v --no-preserve=ownership "$_f" "$_F" && rm -v "$_f" && chmod 0664 "$_F"
  fi
}

IFS=$(echo -en "\n\b")
for f in `find * -type f -regextype posix-extended -regex '[0-9]{4}-(0[1-9]|1[012])-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}.*'`; do
  Y=`echo "$f" | cut -d '-' -f 1`
  M=`echo "$f" | cut -d '-' -f 2`
  if [ $Y -gt 1970 ]; then
    mkdir -p "$BASEDIR/$Y/$M" && chmod 0775 "$BASEDIR/$Y/$M" && touch --no-create -t "${Y}01010000" "$BASEDIR/$Y" && touch --no-create -t "${Y}${M}010000" "$BASEDIR/$Y/$M"
    move_file "$f" "$BASEDIR/$Y/$M"
  fi
done
