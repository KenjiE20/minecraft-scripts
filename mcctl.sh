#!/bin/bash

# Uses https://github.com/viral32111/rcon

MC_SERVER_RUNFILE=/tmp/MC_SERVER_RUN
MC_SERVER_DIRFILE=/tmp/MC_SERVER_DIR
MC_RCON_PWD=<rcon pwd>
export RESTIC_PASSWORD=<restic pwd>

cd "$(dirname "${BASH_SOURCE[0]}")"

rconSend() {
	./rcon-linux-arm64-glibc --minecraft --password $MC_RCON_PWD "$1"
}

if [[ $# -gt 0 ]]; then
	case "$1" in
		#################################################################
		"stop")
			if [ -f "$MC_SERVER_RUNFILE" ]; then
				echo false > $MC_SERVER_RUNFILE
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) 60 Second Warning."
				rconSend "say Server will shutdown in 60s !"
				sleep 30
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) 30 Second Warning."
				rconSend "say Server will shutdown in 30s !"
				sleep 20
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) 10 Second Warning."
				rconSend "say Server will shutdown in 10s !"
				sleep 10
				rconSend "stop"
			else
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) ERROR: Server runfile does not exist."
			fi
		;;
		################################################################
		"stop-now")
			if [ -f "$MC_SERVER_RUNFILE" ]; then
				echo false > $MC_SERVER_RUNFILE
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) 10 Second Warning."
				rconSend "say Server will shutdown in 10s !"
				sleep 10
				rconSend "stop"
			else
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) ERROR: Server runfile does not exist."
			fi
		;;
		#################################################################
		"restart")
			if [ -f "$MC_SERVER_RUNFILE" ]; then
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) 60 Second Warning."
				rconSend "say Server will restart in 60s !"
				sleep 30
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) 30 Second Warning."
				rconSend "say Server will restart in 30s !"
				sleep 20
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) 10 Second Warning."
				rconSend "say Server will restart in 10s !"
				sleep 10
				rconSend "stop"
			else
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) ERROR: Server runfile does not exist."
			fi
		;;
		#################################################################
		"reset-fetchr")
			read -p "Reset mc-fetchr server? (y/N)" -n1 -s confirm
			echo ""
			case $confirm in
				y|Y)
					rm -rdv ~/mc-fetchr/*
					cp -rvT ~/templates/mc-fetchr-template ~/mc-fetchr
					
					read -p "Send gamerule to server? (y/N)" -n1 -s input
					echo ""
					case $input in
						y|Y) rconSend "gamerule keepInventory true";;
					esac
				;;
			esac
		;;
		#################################################################
		"reset-chunk")
			read -p "Reset mc-chunk server? (y/N)" -n1 -s confirm
			echo ""
			case $confirm in
				y|Y)
					rm -rdv ~/mc-chunk/*
					cp -rvT ~/templates/mc-chunk-template ~/mc-chunk
					
					read -p "Send gamerule to server? (y/N)" -n1 -s input
					echo ""
					case $input in
						y|Y) rconSend "gamerule keepInventory true";;
					esac
				;;
			esac
		;;
		#################################################################
		"backup")
			if [ -f "$MC_SERVER_RUNFILE" ]; then
				# Check for game dir
				dir=$(<"$MC_SERVER_DIRFILE")
				
				if [ "$dir" = "/home/ubuntu/mc-vanilla" ]; then
					# Vanilla test world
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Starting backup for mc-vanilla"
					./backup.sh -c -i /home/ubuntu/mc-vanilla/world -r /home/ubuntu/backups/mc-vanilla -s localhost:25575:kivEmipJA378 -w rcon -v
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Backup Complete"
				elif [ "$dir" = "/home/ubuntu/mc-fabric" ]; then
					# Fabric server world
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Starting backup for mc-fabric"
					./backup.sh -c -i /home/ubuntu/mc-fabric/world -r /home/ubuntu/backups/mc-fabric -s localhost:25575:kivEmipJA378 -w rcon -v
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Backup Complete"
				elif [ "$dir" = "/home/ubuntu/mc-bcgp" ]; then
					# BigChadGuys+ modpack world
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Starting backup for mc-bcgp"
					./backup.sh -c -i /home/ubuntu/mc-bcgp/world -r /home/ubuntu/backups/mc-bcgp -s localhost:25575:kivEmipJA378 -w rcon -v
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Backup Complete"
				else
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) No valid running servers to backup"
				fi
			else
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) ERROR: Server runfile does not exist."
			fi
		;;
		#################################################################
		"single-backup")
			if [ -f "$MC_SERVER_RUNFILE" ]; then
				# Check for game dir
				dir=$(<"$MC_SERVER_DIRFILE")
				
				if [ "$dir" = "/home/ubuntu/mc-vanilla" ]; then
					# Vanilla test world
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Starting manual backup for mc-vanilla"
					./backup.sh -c -i /home/ubuntu/mc-vanilla/world -o /home/ubuntu/backups -s localhost:25575:kivEmipJA378 -w rcon -v
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Backup Complete"
				elif [ "$dir" = "/home/ubuntu/mc-fabric" ]; then
					# Fabric server world
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Starting manual backup for mc-fabric"
					./backup.sh -c -i /home/ubuntu/mc-fabric/world -o /home/ubuntu/backups -s localhost:25575:kivEmipJA378 -w rcon -v
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Backup Complete"
				elif [ "$dir" = "/home/ubuntu/mc-bcgp" ]; then
					# BigChadGuys+ modpack world
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Starting manual backup for mc-bcgp"
					./backup.sh -c -i /home/ubuntu/mc-bcgp/world -o /home/ubuntu/backups -s localhost:25575:kivEmipJA378 -w rcon -v
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Backup Complete"
				else
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) No valid running servers to backup"
				fi
			else
				echo "$(date -u +%Y-%m-%d_%H:%M:%S) ERROR: Server runfile does not exist."
			fi
		;;
		#################################################################
		"prune")
			# Loop through each subdirectory
			for D in /home/ubuntu/backups/*; do
				if [ -d "$D" ]; then
					# Run restic prune for each subdirectory
					echo "$(date -u +%Y-%m-%d_%H:%M:%S) Pruning $D"
					restic prune -r "$D"
				fi
			done
			du -h --max-depth=1 /home/ubuntu/backups/
		;;
		#################################################################
		*)
		echo "Usage : mcctl <stop | stop-now | restart | reset-fetchr | reset-chunk | backup | single-backup | prune>"
		;;
	esac
else
	echo "Usage : mcctl <stop | stop-now | restart | reset-fetchr | reset-chunk | backup | single-backup | prune>"
fi
