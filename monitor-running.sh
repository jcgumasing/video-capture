#!/bin/bash

#check parameters
if [ $# -ne 2 ]
  then
	#echo usage
	echo "parameters: <directory of videos to minitor> <secons to wait for file growth"
	echo
	echo "example: /media/output/sarisari 10"
	echo
	exit 1
fi

#if params ok
param_output_dir=$1
param_wait_time=$2
echo "Monitoring the videos in : "$param_output_dir
echo "Wait time is : "$param_wait_time
echo

while true; do
    #for all directories inside param folder
    for dir in $param_output_dir/*
    do
	#if directory then go in
	if [ -d "$dir" ]
	then
		echo "processing: " $dir

		#for all running processes 
		    for file in $dir"/"*.running
		    do
		        echo
		        echo "-----------------"
		        echo "Checking file: "$file
		        #If file is deleted while in the loop then file returns directory/*.runnning which create issues
		        #so do not run the proces in those cases
		        if [ "${file: -9}" != "*.running" ]
		        then
		            #Prepare initial variables
		            file_ok="true"
		            video_file_name=${file/%.running/}   #remove the .running string from the file name
		            count_of_bytes=$(stat -c%s $video_file_name)
        
		            echo "Video file name: "$video_file_name
		            echo "size "$count_of_bytes
        
		            #wait a a few seconds to let the file grow
		            echo "Waiting "$param_wait_time" seconds"
		            sleep $param_wait_time
		            echo "new size " $(stat -c%s $video_file_name)

		            #check not too many PTS words
		    	    if [ "$(tr ' ' '\n' < $video_file_name".log" | grep PTS | wc -l)" -gt 20 ]
		            then
		                file_ok="false"
		            #check if current video file size is growing
		            elif [ "$(stat -c%s $video_file_name)" -eq "$count_of_bytes" ]
		            then
		                file_ok="false"
		            fi

		            echo "status "$file_ok

		            #if not ok
		            if [ "$file_ok" == "false" ]
		            then
		                #Process got stuck, kill it... kill the ffmpeg process running for this mp4 file
						echo "Process got stuck, killing ffmpeg for: "$video_file_name
						# pkill using default signal sigterm (15) which is a soft kill
						pkill -f ffmpeg.*"$video_file_name"
						
						# Wait 2 seconds and then pkill using sigkill (9) just in case the above one didn't kill it. Reason for doing this is that sometimes the above kill does not work. Conditions were not found out so using pkill -9 is a workaround to ensure the process really gets killed
                        sleep 2
                        pkill -9 -f ffmpeg.*"$video_file_name"

		                touch "$video_file_name"".killed"
		                rm "$file"
		            else #Process ok, continue
		                echo "Process running ok"
		            fi
		        else
		            echo "Waiting "$param_wait_time" seconds"
		            sleep $param_wait_time
		        fi
		    done
	fi
   done
done
