#!/bin/bash
f="$1"
d="$2"
F="$d/$f"

if [ -f "$F" ]; then
  s1=`wc -c "$f" | cut -d ' ' -f 1`
  s2=`wc -c "$F" | cut -d ' ' -f 1`
  if [ $s1 -eq $s2 ]; then
    cksum1=`md5sum -b "$f" | cut -d ' ' -f 1`
    cksum2=`md5sum -b "$F" | cut -d ' ' -f 1`
    if [ "$cksum1" == "$cksum2" ]; then
      rm -v "$f"
    else
      echo "\"$F\" exists, has the same size, but different md5sum than \"$f\""
    fi
  else
    echo "\"$F\" exists and has differrent size than \"$f\""
  fi
else
  mv -uv "$f" "$F"
fi
