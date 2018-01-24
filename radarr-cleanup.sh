#!/bin/bash

radarr_label="movies-radarr"
base_dir=$(basename $radarr_moviefile_sourcefolder)

if [ "${base_dir}" == "${radarr_label}" ];then
	echo "Single file torrent, deleting..."
	rm ${radarr_moviefile_sourcepath}
	exit 
else
	echo "Deleting torrent directories"
	rm -rf ${radarr_moviefile_sourcefolder}
	exit
fi

