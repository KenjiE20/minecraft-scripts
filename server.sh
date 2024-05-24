#!/bin/bash

#Default Settings
export MC_SERVER_MAX_RAM=8G
export MC_SERVER_CRASH_COUNT=5
export MC_SERVER_CRASH_TIMER=600
export MC_SERVER_JAR=minecraft_server.1.20.4.jar

# Runtimes
MC_SERVER_RUNFILE=/tmp/MC_SERVER_RUN
MC_SERVER_DIRFILE=/tmp/MC_SERVER_DIR

echo "INFO: Starting script at $(date -u +%Y-%m-%d_%H:%M:%S)"
#echo "DEBUG: Dumping starting variables: "
#echo "DEBUG: MC_SERVER_MAX_RAM=$MC_SERVER_MAX_RAM"
#echo "DEBUG: MC_SERVER_CRASH_COUNT=$MC_SERVER_CRASH_COUNT"
#echo "DEBUG: MC_SERVER_CRASH_TIMER=$MC_SERVER_CRASH_TIMER"
#echo "DEBUG: MC_SERVER_JAR=$MC_SERVER_JAR"
#echo "DEBUG: Basic System Info: $(uname -a)"
#echo "DEBUG: Java Version info: "
#echo java -version
#echo "DEBUG: Dumping current directory listing"
#ls -s1h

# Safety lock
if [ -f "$MC_SERVER_RUNFILE" ]; then
	echo "ERROR: Server runfile already exists."
	run=false
else
	run=true
fi

# loop to restart server and check crash frequency
a=0
last_crash=$((SECONDS))

while $run ; do
	echo "Starting server"
	echo "INFO: Starting Server at $(date -u +%Y-%m-%d_%H:%M:%S)"
	# set runtimes
	echo $run > $MC_SERVER_RUNFILE
	pwd > $MC_SERVER_DIRFILE
	java -Xmx"$MC_SERVER_MAX_RAM" -jar "$MC_SERVER_JAR" --nogui
	b=$?
	b=1
	if [[ $b == 0 ]]; then
		#echo "DEBUG: Server ended with code 0"
		a=0
	else
		now=$((SECONDS))
		diff=$now-$last_crash
		if [[ $diff -gt $MC_SERVER_CRASH_TIMER ]]; then
			a=1
		else
			a=$((a+1))
		fi
		last_crash=$((SECONDS))
	fi
	if [[ "$a" == "$MC_SERVER_CRASH_COUNT" ]]; then
		echo "ERROR: Server has failed to start too many times in a row."
		run=false
		rm $MC_SERVER_RUNFILE
		rm $MC_SERVER_DIRFILE
		exit 1
	fi

	# Check if intentional shutdown
    	run=$(<"$MC_SERVER_RUNFILE")
    	if [ "$run" = "true" ]; then
		run=true
		echo ""
		echo "INFO: Server-auto-restart commencing"
		echo "Rebooting now!"
	else
		# cleanup
		run=false
		echo "INFO: Server shutdown at $(date -u +%Y-%m-%d_%H:%M:%S)"
		rm $MC_SERVER_RUNFILE
		rm $MC_SERVER_DIRFILE
    	fi
done
