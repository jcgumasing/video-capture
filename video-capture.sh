#!/bin/bash

#check parameters
param_store_id=$1
param_camera_model=$2
param_url=$3
param_duration=$4
param_output_dir=$5
param_file_extension=$6
if [ $# -ne 6 ] || [[ "$param_camera_model" != "DCS933L" && "$param_camera_model" != "DCS935L"  && "$param_camera_model" != "NC450" && "$param_camera_model" != "CS-CV246" ]]
  then
	#echo usage
	echo "parameters: <storeID> <camera model> <url> <recording time (in seconds)> <output directory of videos> <mp4 | wav>"
	echo "accepted camera models: DCS933L | DCS9335L | NC450 | CS-CV246"
	echo
	echo "example:" "SARISARI0001 http://admin:julio@192.168.1.111/dgvideo.cgi DCS933L 3600 /media/output/sarisari mp4"
	echo
	exit 1
fi

#if params ok
echo "Streaming from camera model "$param_camera_model "url: " $param_url
echo "Running each video for "$param_duration "seconds"
echo "Outputting the videos to : "$param_output_dir
echo "File extension: "$param_file_extension

while true; do
	echo "starting in 3 seconds"
	echo
	sleep 3

	count_of_bytes=0

	#one folder per camera per day. Create the folder (-p only creates if not exist)
	date_folder=`date '+%Y%m%d'`
	mkdir -p $param_output_dir"/"$date_folder

	#start the process in bg &
	dir_file_name=$param_output_dir"/"$date_folder"/"$param_store_id-$param_camera_model"-"`date '+%Y%m%d-%H%M%S%2N'`.$param_file_extension
    dir_log_file=$dir_file_name".log"
    
	echo "New video started. Name: " $dir_file_name

	#create the outfile in case ffmpeg doesn't create it (when there is no connection). this is to avoid having errors with stat command in while loop
	touch $dir_file_name

	#run in a subshell () to avoid getting the DONE mesage when the process ends
    
    echo "Processing ffmpeg"
    
    #create a file to identify process is running
    touch $dir_file_name".running"

	case "$param_camera_model" in
		DCS935L) 
		echo "(ffmpeg -nostdin -y -i $param_url -acodec copy -vcodec copy -t $param_duration $dir_file_name 2> $dir_log_file ) "
		      (ffmpeg -nostdin -y -i $param_url -acodec copy -vcodec copy -t $param_duration $dir_file_name 2> $dir_log_file ) 
    	;;

		NC450)
		echo "(ffmpeg -nostdin -y -i $param_url -acodec copy -vcodec libx264 -acodec aac -t $param_duration $dir_file_name 2> $dir_log_file ) "
		      (ffmpeg -nostdin -y -i $param_url -acodec copy -vcodec libx264 -acodec aac -t $param_duration $dir_file_name 2> $dir_log_file )
		;;
		
		*)
		echo "(ffmpeg -nostdin -y -i $param_url -acodec copy -vcodec copy -t $param_duration $dir_file_name 2> $dir_log_file ) "
			  (ffmpeg -nostdin -y -i $param_url -acodec copy -vcodec copy -t $param_duration $dir_file_name 2> $dir_log_file )
	
	esac

	touch $dir_file_name".finished"
	rm $dir_file_name".running"
done
