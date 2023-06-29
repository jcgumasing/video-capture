#!/bin/bash

#Check the size of the MP4 files for the last xxx mins
#arg 1 = how many minutes of video to check
#arg 2 = minimun number of bytes we should have
#arg 3 = email to send the email to

while IFS=, read -r camera_id camera_model camera_url; do  #|| [[ -n "$camera" ]]; do
	#Ignore lines with # (commented out)
	[[ "$camera_id" =~ ^#.*$ ]] && continue
	
	#get the total size of the mp4files for the last $1 minutes
	total_size=$(find ~/datatailer-data/$camera_id -type f -mmin -$1 -name *.mp4 -print0 | xargs -0 stat -c "%s" | tr "s/^M//g" " " | paste -sd+ | bc)
	echo "Total size = " $total_size

	if [ $total_size -lt $2 ]; then
		echo "below the minimun, send email"
		echo "the total size of the mp4 files for camera "$camera_id "for the past "$1 " minutes is below the minimum expected (" $total_size " < " $2 ")" | mail -s "Video Server Alert - for camera: "$camera_id $3
	else
		echo "no problem. do not send email"
	fi
done < "$4"
