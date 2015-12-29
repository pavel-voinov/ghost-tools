#!/bin/bash
pwd
logfile="/tmp/rename`pwd | sed -r 's@/@_@g'`_`date +%Y-%m-%d_%H-%M-%S`.log"
pwd >> $logfile
find * -maxdepth 0 -type f -exec rename_media_file.sh "{}" \; 2>&1 | tee -a $logfile

echo "logfile is $logfile"
