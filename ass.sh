#!/bin/bash
limit=${1:-0}
NC='\033[0m'
Red='\033[0;31m'
Green='\033[0;32m'
Cyan='\033[0;36m'

#Welcome to Automated Seedbox Sync (ASS)
#Script created by vicelversa, latest update 1/24/2018

# Script variables, please plug-in your configuration here:
login=''
pass=''
host=''
port='22'
remote_dir=''
local_dir=''
filebot=''

# Filebot Configuration, please plug-in your Filebot configuration here:
movie_format="movieFormat=Movies/{n} ({y})/{n} ({y}) [{source} {vc} {vf} {channels}] {group}{' CD'+pi}"
tv_format="seriesFormat=TV/{n}/{episode.special ? 'Special' : 'Season '+s}/{n} - {episode.special ? 'S00E'+special.pad(2) : s00e00} - {t} [{source} {vc} {vf} {channels}] {group}"
pushbullet="pushbullet="
exclude_list="excludeList="
final_dir=''
filebot_log=''

# Start SFTP downloads, lock script
echo -e "${Cyan}Starting SFTP downloads${NC}"
base_name="$(basename "$0")"
lock_file="/tmp/$base_name.lock"
trap "rm -f $lock_file" SIGINT SIGTERM
if [ -e "$lock_file" ]
then
	echo -e "${Red}$base_name is running already.${NC}"
	exit
else
	touch "$lock_file"
	lftp -p "$port" -u "$login","$pass" sftp://"$host" << EOF
	set dns:fatal-timeout never
	set net:reconnect-interval-base 5
	set ftp:list-options -a
	set sftp:auto-confirm yes
	set pget:min-chunk-size 2M
	set mirror:use-pget-n 20
	set mirror:parallel-transfer-count 2
	set mirror:parallel-directories yes
	set net:socket-buffer 0
	set xfer:use-temp-file yes
	set xfer:temp-file-name *.lftp
	set net:limit-total-rate $limit
	mirror -c -v --loop --Remove-source-dirs "$remote_dir" "$local_dir"
EOF

# - OPTIONAL -
# This will put the lftp process in the background and script will wait for downloads to finish.
# To use, add queue in front of the above mirror command and uncomment the 2 lines below.
# You may re-attach to the lftp session by running lftp -c attach PID
#
#echo "Download in progress, waiting for job to finish..."
#while pgrep lftp > /dev/null; do sleep 1; done

# Remove script lock
rm -f "$lock_file"
trap - SIGINT SIGTERM
fi

echo -e "${Green}Downloads complete!${NC}"
echo -e "${Cyan}Starting post-processing...${NC}"

# Check for incomplete downloads
if [ $(find "$local_dir" -name "*.lftp" | wc -l) -gt 0 ]; then
        echo -e "${Red}Incomplete lftp transfers found in downloading directory. Aborting...${NC}"
	exit
else
:
fi

# Begin post-processing of downloaded files

# Check for files in your movies and tv LFTP transfer directories (./movies ./tv) and run Filebot
if find "$local_dir"movies/ "$local_dir"tv/ -mindepth 1 | read; then
        echo -e "${Cyan}Files found in Movies / TV directories, Starting FileBot...${NC}"
	"$filebot" -script fn:amc --output "$final_dir" --action move -non-strict "$local_dir"movies "$local_dir"tv --log-file "$filebot_log" --def "$exclude_list" "$movie_format" "$tv_format" "$pushbullet" "clean=y" "deleteAfterExtract=y"
else
:
fi

echo -e "${Green}Operation ASS complete.${NC}"
exit
