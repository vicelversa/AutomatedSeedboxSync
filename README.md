# AutomatedSeedboxSync
Automated Seedbox Sync (ASS) Script
This script will download a set of directories including sub-directories using LFTP and remove files and directories on remote server after completion.
The script will be locked during execution so it cannot be called until transfers are complete.
LFTP will loop back and retry downloading until there are no new files to download before removing the lock.
If for whatever reason the transfer is interrupted, next execution will continue where it left off.

Argument 1, "limit" is used to pass a transfer limit to the LFTP process.
If nothing is defined when script is called, a value of 0 is set which = unlimited.
Values are accepted in bytes per second or you can specify MB by using *M

Example: To throttle speed to 5 MB/s, call script like this: ./ASS.sh 5M

After all transfers are complete, the script will look for any rar files inside the sonarr / radarr directories and extract them automatically
If files are found in movies or tv directories, Filebot will run on those directories which will sort through the media (movies and tv), unpack, identify and move to appropriate media folders.


--- Additional Seedbox Configuration Info ---

This script assumes your seedbox is creating hardlinks after torrents have completed to folders based on names such as ./movies and ./tv.
For rTorrent, see the sample.rtorrent.rc file which will:

-Move completed torrents to a directory based on their label name
-Afterwards, create hardlinks of the finished torrent file/directory to a separate folder specified in your remote_dir variable in the ASS script. In this example: ~/files/FTP/
-Calls a separate script, notify.sh, located on your seedbox to call your local client to execute the ASS script.

The notify.sh script holds a ssh command to connect to your local client where the ASS script lives and execute it in a screen so you may monitor it locally.

Example: ssh user@localclientIP "source .profile; screen -mdS ASS ~/ASS.sh"


--- Additional local Sonarr / Radarr Configuration Info ---

In order to use Sonarr and Radarr locally, you must configure it to communicate with your seedbox torrent application so it can send torrents to it to download.
This ASS script will handle downloading those files to a directory based on the torrent label name. We must then tell Sonarr and Radarr where to look for the completed transfers.

In Sonarr / Radarr, navigate to Settings, the Download client and make sure Advanced Settings are shown.
At the bottom there is a section for "Remote Path Mappings"

Host is your seedbox public URL

Remote Path is the directory on the seedbox finished torrents will end up.
-In this case, the rtorrent download client is set to set a label of "tv-sonarr" on all torrents sonarr sends to the seedbox.
-The rtorrent.rc config will move finished torrents to folders based on their label, so it will be something like: ~/files/tv-sonarr/

Local Path is well...the local directory on your client where the ASS script will transfer the files. Example: /Multimedia/Downloading/tv-sonarr/

Once sonarr/radarr sees the files in the local path, it will then process and copy those files to your media folders.
The copy function is a limitation and will leave you with multiple copies of files in your LFTP transfer directories.
You must also setup a cleanup post processing script to clean up those directories after successful import from sonarr/radarr.

See example sonar and radarr cleanup scripts
