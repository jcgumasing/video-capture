#!/bin/bash

#Check there's a file input to read the cameras
if [ -z "$1" ]
  then
    echo "No argument supplied. Supply the file containing the list of cameras"
fi

#CREATE LOG DIRECTORY IF IT DOESNT EXIST
mkdir -p log

#Go over all cameras in the provided input file (e.g. cameras.list) and start the video capture and monitor scripts
while IFS=, read -r camera_id camera_model camera_url || [[ -n "$camera" ]]; do
	#Ignore lines with # (commented out)
	[[ "$camera_id" =~ ^#.*$ ]] && continue
	
	#run the video capture
	./video-capture.sh $camera_id $camera_model $camera_url 600 ~/datatailer-data/$camera_id mp4  > log/video-capture-$camera_id-`date '+%Y%m%d-%H%M%S%2N'`.log &

	#run the monitoring process
	./monitor-running.sh ~/datatailer-data/$camera_id 60 > log/monitor-running-$camera_id-`date '+%Y%m%d-%H%M%S%2N'`.log &
done < "$1"
