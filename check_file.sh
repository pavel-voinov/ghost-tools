#!/bin/bash
f="$1"
d="$2"

CURRENT_DIR=$( pushd $(dirname $0) >/dev/null; pwd; popd >/dev/null )

if [ ! -d $d ]; then
  echo "$d is not found"
  exit 2
fi

F="$d/$f"

if [ -f "$F" ]; then
  s1=`wc -c "$f" | cut -d ' ' -f 1`
  s2=`wc -c "$F" | cut -d ' ' -f 1`
  if [ $s1 -eq $s2 ]; then
    rm -v "$f"
  else
    echo "\"$F\" exists and has differrent size than \"$f\""
    echo "\"$F\" - $s2"
    echo "\"$f\" - $s1"
  fi
else
  echo "\"$F\" does not exist"
fi
