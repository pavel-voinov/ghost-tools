#!/bin/bash
BASEDIR=${1:-'/media/NS4300N/Photos'}

pushd $BASEDIR

for y in ????; do
  touch --no-create -t "${y}01010000" $y
done

for d in ????/??; do
  y=`echo $d | sed -r 's@/@@'`
  touch --no-create -t "${y}010000" $d
done

popd
