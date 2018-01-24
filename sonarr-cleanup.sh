#!/bin/bash

sonarr_label="tv-sonarr"
base_dir=$(basename $sonarr_episodefile_sourcefolder)

if [ "${base_dir}" == "${sonarr_label}" ];then
	echo "Single file torrent, deleting..."
	rm ${sonarr_episodefile_sourcepath}
	exit 
else
	echo "Deleting torrent directories"
	rm -rf ${sonarr_episodefile_sourcefolder}
	exit
fi

