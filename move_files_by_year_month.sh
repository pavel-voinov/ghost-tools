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
  if [ -f "$_F" ]; then
    s1=`wc -c "$_f" | cut -d ' ' -f 1`
    s2=`wc -c "$_F" | cut -d ' ' -f 1`
    if [ $s1 -eq $s2 ]; then
      rm -v "$_f"
    else
      n=$( index_name "$_F" )
      cp -v --no-preserve=ownership "$_f" "$_d/$n" && rm -v "$_f"
    fi
  else
    cp -v --no-preserve=ownership "$_f" "$_F" && rm -v "$_f"
  fi
}

IFS=$(echo -en "\n\b")
for f in `find * -type f -regextype posix-extended -regex '[0-9]{4}-(0[1-9]|1[012])-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}.*'`; do
  Y=`echo "$f" | cut -d '-' -f 1`
  M=`echo "$f" | cut -d '-' -f 2`
  if [ $Y -gt 1970 ]; then
    mkdir -p "$BASEDIR/$Y/$M" && touch --no-create -t "${Y}01010000" "$BASEDIR/$Y" && touch --no-create -t "${Y}${M}010000" "$BASEDIR/$Y/$M"
    move_file "$f" "$BASEDIR/$Y/$M"
  fi
done
