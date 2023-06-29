#FFMPEG BASED VIDEO STREAM RECORDER AND MONITOR

*Objectives: 
1. Captures video from cameras via ffmpeg (video-capture.sh)
2. Monitors if the process is still runnning, otherwise kills it and restarts (monitor-running.sh)
3. Monitors if recording/stream is finished. In that case moves it to a different folder for further processing (monitor-finished.sh)

##Script: video-capture.sh
Streams the video and audio files from webcams into video files

###Parameters: 
storeID - identifies the store from where the streams are coming. This is used to construct the output file names

camera model - identifies the camera model used in the store. This determines what ffmpeg parameters to use

url - url from where to stream from

recording time (in seconds) - length of the streams (param -t in ffmpeg)

output directory of videos - where to create the files

output file extension - wav or mp4

###Files created:
All files' names created by this script start with the following name <storeID>-<camera model>-<date>-<time>

Let's call the above COMMON_FILE_NAME

Streamed file (video or audio): 
COMMON_FILE_NAME.<mp4|wav>

Log file: COMMON_FILE_NAME.<mp4|wav>.log

Running file: COMMON_FILE_NAME.<mp4|wav>.running (created while the stream is running and deleted when finished)

Finished file: COMMON_FILE_NAME.<mp4|wav>.finished (created when the stream is finished)

###Example line to run:
run.sh SARISARI001 DCS933L http://user:password@xxx.xxx.xxx.xxx/dgvideo.cgi 60 /home/julio/02nd_Disk/SariSariCapture mp4


##Script: monitor-running.sh
###Context
Each running process (ffmpeg) creates a mp4 video file and also a .runnning file.

###Process
For each running file it checks that:
	1. the corresponding video file is growing
	                     AND
	2. the word PTS is not appearing repetetively*
	 *There's an scenario in which the video keeps growing but is not recording anything
	  when that happens PTS (and DTS) word gets logged a lot
	  example " "

*If any of the conditions above is false then:
    1. Kill the corresponding ffmpeg process
    2. delete the runnining file
    3. create a 'killed' file

##Script: monitor-finished.sh
###Context
Each finished process (ffmpeg) creates a mp4 video file and also a .finished file.

###Process
For each finished file:
	1. If video file is zero then move the video file and related files (log, finished, etc) to a 'DISCARDED' directory
	2. ELSE: move the files to a 'FOR_PROCESSING' directory 
        AND ALSO: to a google storage bucket (but only the media file, not the control files or log)

