#!/bin/bash
pwd
logfile="rename_`date +%Y-%m-%d_%H-%M-%S`.log"
find * -maxdepth 0 -type f -exec rename_media_file.sh "{}" \; 2>&1 | tee -a $logfile

echo "logfile is $logfile"
