#!/bin/bash

#Delete old files
#arg 1 = number of days old
#arg 2 = cameras list file

while IFS=, read -r camera_id camera_model camera_url || [[ -n "$camera" ]]; do
    #Ignore lines with # (commented out)
    [[ "$camera_id" =~ ^#.*$ ]] && continue

	find ~/datatailer-data/$camera_id -mtime +$1 -delete
done < "$2"

#also delete old log files
        find ~/datatailer-bin/video-capture/log -mtime +$1 -delete