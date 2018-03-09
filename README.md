# AutomatedSeedboxSync

This script will download a set of directories including sub-directories using LFTP and remove files and directories on remote server after completion.
The script will be locked during execution so it cannot be called until transfers are complete.
LFTP will loop back and retry downloading until there are no new files to download before removing the lock.
If for whatever reason the transfer is interrupted, next execution will continue where it left off.

Argument 1, "limit" is used to pass a transfer limit to the LFTP process.
If nothing is defined when script is called, a value of 0 is set which = unlimited.
Values are accepted in bytes per second or you can specify MB by using *M

Example: To throttle speed to 5 MB/s, call script like this: ./ass.sh 5M

After all transfers are complete, the script will look for any rar files inside the movies or tv directories, Filebot will run on those directories which will sort through the media (movies and tv), unpack, identify and move to appropriate media folders.

There are a few lftp variables which you may want to tweak depending on your network speed and latency.

  set mirror:use-pget-n <number>
	set mirror:parallel-transfer-count <number>
	set net:socket-buffer <bytes>
  
mirror:use-pget-n tells lftp how many simultaneous segments to download
mirror:parallel-transfer-count tells lftp how many simultaneous files to download
net:socket-buffer sets the buffer window. For high latency connections you will want to tweak this along with your available bandwidth.

See this link for calculating an appropriate buffer: http://www.onlamp.com/2005/11/17/tcp_tuning.html


--- Additional Seedbox Configuration Info ---

This script assumes your seedbox is creating hardlinks after torrents have completed to folders based on names such as ./movies and ./tv.
For rTorrent, see the sample.rtorrent.rc file which will:

-Move completed torrents to a directory based on their label name
-Afterwards, create hardlinks of the finished torrent file/directory to a separate folder specified in your remote_dir variable in the ASS script. In this example: ~/files/FTP/
-Calls a separate script, notify.sh, located on your seedbox to call your local client to execute the ASS script.

The notify.sh script holds a ssh command to connect to your local client where the ASS script lives and execute it in a screen so you may monitor it locally.

Example: ssh user@localclientIP "source .profile; screen -mdS ass ~/ass.sh"
