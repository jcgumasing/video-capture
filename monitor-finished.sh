#!/bin/bash

#check parameters
if [ $# -ne 3 ]
  then
	#echo usage
	echo "parameters: <directory of videos to monitor> <google bucket to copy media files to> <seconds to wait for file growth"
	echo
	echo "example: /media/output/sarisari gs://sari-sari-root 10"
	echo
	exit 1
fi

#if params ok
param_monitor_dir=$1
param_output_bucket=$2
param_wait_time=$3
output_dir_for_processing=$param_monitor_dir'/FOR_PROCESSING'
output_gs_for_processing=$param_output_bucket'/FOR_PROCESSING/'
output_dir_discarded=$param_monitor_dir'/DISCARDED'

echo "Monitoring the files in : "$param_monitor_dir
echo "Wait time is : "$param_wait_time
echo

#create the DISCARDED and FOR_PROCESSING directories if they don't exist
#this is not needed for the GS bucket as folders are created automatically
if [ ! -d $output_dir_discarded ]
then
    mkdir $output_dir_discarded
fi

if [ ! -d $output_dir_for_processing ]
then
    mkdir $output_dir_for_processing
fi

while true; do
    #for all running processes 
    for file in $param_monitor_dir"/"*.finished
    do
        echo
        echo "-----------------"
        echo "Checking file: "$file
        #If file is deleted while in the loop then file returns directory/*.runnning which create issues
        #so do not run the proces in those cases
        if [ "${file: -10}" != "*.finished" ]
        then
            #Prepare initial variables
            file_name=${file/%.finished/}   #remove the .finished string from the file name
            count_of_bytes=$(stat -c%s $file_name)
        
            echo "Video file name: "$file_name
            echo "size "$count_of_bytes
        
            #check if file size is zero
            if [ $count_of_bytes -eq 0 ]
            then
                echo "File size 0, moving to DISCARDED"
                mv "$file_name"* "$output_dir_discarded"
            else #file size is greater than 0 so assume is ok and move to processing
                echo "File size > 0, moving to FOR_PROCESSING"
                gsutil -m cp "$file_name" $output_gs_for_processing
                mv "$file_name"* "$output_dir_for_processing"
            fi
        fi

        echo "Waiting "$param_wait_time" seconds"
        sleep $param_wait_time
    done
done