#!/bin/sh

# Create a diff result of files
# (c) 2014 Ch.Gembalski

# --------------------
# - Global VAR       -
# --------------------

# Enable 1 to get debug output
DEBUG=0
DEBUG_FILE_NAME=medialist.log
# medialist folder
BASE_DIR=.medialist
# Filename local DB
LOCAL_FILE_DB=media.db
# Filename tmp File List
LOCAL_FILE_TMP=tmpmedia.db
# Data scan path
DATA_SCAN_PATH=""
# Data scan path file
DATA_SCAN_FILE=mediascan.db
# Data missing
DATA_MISS_FILE=tmpmiss.db
# Data exporting
DATA_EXPORT_FILE=tmpexport.db
# Media Export File
MEDIA_EXPORT_FILE=mediaexport.tar

# --------------------
# - FUNCTIONS        -
# --------------------

# DEBUG Function
DBG () {
	if [ $DEBUG -eq 1 ] ; then
		echo $(date) " $1" >> "$DEBUG_FILE_NAME"
	fi
}

# Check if user is root
IS_ROOT () {
	if [ "$(id -u)" != "0" ] ; then
		echo "Only root allowed." 1>&2
		DBG "medialist - end"
		exit 1
	fi
}

# Show help text
SHOW_HELP () {
	echo "medialist [arg]"
	echo "---------------"
	echo "args :"
	echo "[h]elp   - this help"
	echo "?        - this help"
	echo "[i]nit   - create new database"
	echo "           init [scanpath]"
	echo "[u]pdate - update existing database"
	echo "[a]dd    - add new scanpath"
	echo "           add [scanpath]"
	echo "[e]xport - create database export file"
	echo "[d]iff   - create database diff package"
	echo "           diff [otherdb].tar.gz"
	echo "[w]rite  - write local db"
	echo "           write [dbfilename].tar.gz"
	echo "[m]3u    - create playlist"
	echo "           m3u [filename].m3u"

	DBG "medialist - end"
	exit 1
}

# Init DB 
INIT_DATABASE () {

	DBG "start init"

	# Check if path entered
	DBG "scanpath=$DATA_SCAN_PATH"
	if [ -z "$DATA_SCAN_PATH" ] ; then
		echo "missing scanpath"
		DBG "medialist - end"
		exit 1
	fi
	# Check if path exist
	if [ -d "$DATA_SCAN_PATH" ] ; then
		DBG "$DATA_SCAN_PATH found"
	else
		DBG "missing $DATA_SCAN_PATH"
		echo "missing $DATA_SCAN_PATH"
		DBG "medialist - end"
		exit 1
	fi
	# Prepare BASE_DIR
	if [ -d "$HOME/$BASE_DIR" ] ; then
		DBG "$HOME/$BASE_DIR found"
	else
		DBG "create $HOME/$BASE_DIR"
		mkdir "$HOME/$BASE_DIR"
	fi

	# Check if DB File exist
	if [ -w "$HOME/$BASE_DIR/$LOCAL_FILE_DB" ] ; then
		while true; do
			read -p "Delete existing Database? [Y/N]" yn
			case $yn in
				[Yy]* )
				DBG "delete $HOME/$BASE_DIR/$LOCAL_FILE_DB"
				rm "$HOME/$BASE_DIR/$LOCAL_FILE_DB"
				break
				;;
				[Nn]* )
				DBG "medialist - end"
				exit 1
				;;
			esac
		done
	fi
	# Create new LOCAL_FILE_DB
	DBG "crate $HOME/$BASE_DIR/$LOCAL_FILE_DB"
	touch "$HOME/$BASE_DIR/$LOCAL_FILE_DB"

	# scanfile exisit?
	if [ -w "$HOME/$BASE_DIR/$DATA_SCAN_FILE" ] ; then
		DBG "delete $HOME/$BASE_DIR/$DATA_SCAN_FILE"
		rm "$HOME/$BASE_DIR/$DATA_SCAN_FILE"
	fi
	# Create and fill DATA_SCAN_FILE
	DBG "create $HOME/$BASE_DIR/$DATA_SCAN_FILE"
	touch "$HOME/$BASE_DIR/$DATA_SCAN_FILE"
	echo "$DATA_SCAN_PATH" >> "$HOME/$BASE_DIR/$DATA_SCAN_FILE"

	DBG "done init"

	# Do initial scan now
	SCAN_FILE_LIST 1

	DBG "medialist - end"
	exit 1

}

# Scan files and add to db
SCAN_FILE_LIST () {

	DBG "start scan file list"

	while read p ; do

		# Remove LOCAL_FILE_TMP if exist
		if [ -f "$HOME/$BASE_DIR/$LOCAL_FILE_TMP" ] ; then
			DBG "delete $HOME/$BASE_DIR/$LOCAL_FILE_TMP"
			rm "$HOME/$BASE_DIR/$LOCAL_FILE_TMP"
		fi

		if [ "$1" -eq 1 ] ; then
			# Scan to $HOME/$BASE_DIR/$LOCAL_FILE_DB
			find $p -type f -print | sed "s|$p||g" >> "$HOME/$BASE_DIR/$LOCAL_FILE_DB"
		else
			# Scan to $HOME/$BASE_DIR/$LOCAL_FILE_TMP
			find $p -type f -print | sed "s|$p||g" >> "$HOME/$BASE_DIR/$LOCAL_FILE_TMP"

			# diff against $HOME/$BASE_DIR/$LOCAL_FILE_DB
			grep -vxFf "$HOME/$BASE_DIR/$LOCAL_FILE_DB" "$HOME/$BASE_DIR/$LOCAL_FILE_TMP" >> "$HOME/$BASE_DIR/$LOCAL_FILE_DB"
		fi

		# Sort DB File
		sort "$HOME/$BASE_DIR/$LOCAL_FILE_DB" -o "$HOME/$BASE_DIR/$LOCAL_FILE_DB"

	done < "$HOME/$BASE_DIR/$DATA_SCAN_FILE"

	# Clean up tmp file
	# Remove LOCAL_FILE_TMP if exist
 	if [ -f "$HOME/$BASE_DIR/$LOCAL_FILE_TMP" ] ; then
 		DBG "delete $HOME/$BASE_DIR/$LOCAL_FILE_TMP"
 		rm "$HOME/$BASE_DIR/$LOCAL_FILE_TMP"
 	fi

	DBG "done scan file list"

}

# add new scan path or do scan
UPDATE_DATABASE () {

	DBG "start update"

	# Check if DB File exist
	if [ -w "$HOME/$BASE_DIR/$LOCAL_FILE_DB" ] ; then
		DBG "success $HOME/$BASE_DIR/$LOCAL_FILE_DB"
	else
		DBG "missing $HOME/$BASE_DIR/$LOCAL_FILE_DB"
		echo "missing $HOME/$BASE_DIR/$LOCAL_FILE_DB"
		echo "run medialist -i first"
		DBG "medialist -end"
		exit 1
	fi

	# Check if path entered
	DBG "scanpath=$DATA_SCAN_PATH"
	if [ -z "$DATA_SCAN_PATH" ] ; then
		# No path do scan
		DBG "no path do scan"
		SCAN_FILE_LIST 0
	else
		# Check if path exist
		if [ -d "$DATA_SCAN_PATH" ] ; then
 			DBG "$DATA_SCAN_PATH found"
 		else
 			DBG "missing $DATA_SCAN_PATH"
 			echo "missing $DATA_SCAN_PATH"
 			DBG "medialist - end"
 			exit 1
 		fi
		# add path
		echo "$DATA_SCAN_PATH" >> "$HOME/$BASE_DIR/$DATA_SCAN_FILE"

	fi

	DBG "done update"

}

# export local database
WRITE_DATABASE () {

	DBG "start write"

	# Check if path entered
	DBG "scanpath=$DATA_SCAN_PATH"
	if [ -z "$DATA_SCAN_PATH" ] ; then
		# No path
		echo "missing filename"
		exit 1
	fi

	# Remove .tar.gz if entered
	DATA_SCAN_PATH=$(echo $DATA_SCAN_PATH | sed "s|.tar.gz||g")
	# create a tmp copy
	cp "$HOME/$BASE_DIR/$LOCAL_FILE_DB" "$HOME/$BASE_DIR/$LOCAL_FILE_TMP"
	# Compress Db file
	tar -cvzf $DATA_SCAN_PATH.tar.gz -C "$HOME/$BASE_DIR" "$LOCAL_FILE_TMP"
	# delete tmp copy
	rm "$HOME/$BASE_DIR/$LOCAL_FILE_TMP"

	DBG "done write"

}

# create a diff from external db
DIFF_DATABASE () {

	DBG "start diff"

	# Check if path entered
	DBG "scanpath=$DATA_SCAN_PATH"
	if [ -z "$DATA_SCAN_PATH" ] ; then
		# No path
		echo "missing filename"
		exit 1
	fi
	if [ -r "$DATA_SCAN_PATH" ] ; then
		DBG "file found"
	else
		echo "missing file $DATA_SCAN_PATH"
		exit 1
	fi

	# Remove .tar.gz if entered
	DATA_SCAN_PATH=$(echo $DATA_SCAN_PATH | sed "s|.tar.gz||g")
	# unpack file
	tar -xvzf $DATA_SCAN_PATH.tar.gz -C "$HOME/$BASE_DIR" "$LOCAL_FILE_TMP"

#	# Create missing file
#	grep -vxFf "$HOME/$BASE_DIR/$LOCAL_FILE_TMP" "$HOME/$BASE_DIR/$LOCAL_FILE_DB" >> "$HOME/$BASE_DIR/$DATA_MISS_FILE"

	# Create exporting file
	grep -vxFf "$HOME/$BASE_DIR/$LOCAL_FILE_DB" "$HOME/$BASE_DIR/$LOCAL_FILE_TMP" >> "$HOME/$BASE_DIR/$DATA_EXPORT_FILE"

	# cleanup
	rm "$HOME/$BASE_DIR/$LOCAL_FILE_TMP"

	echo "diff done. now run export"

	DBG "done diff"

}

# create file export
DATA_EXPORT () {

	DBG "start export"

	# check if diff was done
#	if [ -r "$HOME/$BASE_DIR/$DATA_MISS_FILE" ] ; then
#		DBG "diff done"
#	else
#		DBG "diff mising"
#		echo "run diff first"
#		exit 1
#	fi
	if [ -r "$HOME/$BASE_DIR/$DATA_EXPORT_FILE" ] ; then
		DBG "diff done"
	else
		DBG "diff missing"
		echo "run diff first"
		exit 1
	fi

	# create export file
	CORU=cvf
	CORUDONE=0
	while read p ; do

		# check all path
		while read pp ; do

			DBG $pp$p
			#check if exist
			if [ -r "$pp$p" ] ; then

				# Add to Arch
				tar -$CORU "$HOME/$BASE_DIR/$MEDIA_EXPORT_FILE" -C "$pp" "$p"
				CORU=uvf
				CORUDONE=1
			fi

		done < "$HOME/$BASE_DIR/$DATA_SCAN_FILE"

	done < "$HOME/$BASE_DIR/$DATA_EXPORT_FILE"

#	if [ $CORUDONE -eq 1 ] ; then
#
#		#compress file
#		tar -czf "$HOME/$BASE_DIR/$MEDIA_EXPORT_FILE.gz" -C "$HOME/$BASE_DIR" "$MEDIA_EXPORT_FILE"
#
#	fi

	# remove tmp file
	rm "$HOME/$BASE_DIR/$DATA_EXPORT_FILE"

	if [ -r "$HOME/$BASE_DIR/$MEDIA_EXPORT_FILE" ] ; then
		echo "created $HOME/$BASE_DIR/$MEDIA_EXPORT_FILE"
	else
		echo "no files to export"
	fi

	DBG "done export"

}

# write Playlist
WRITE_PLAYLIST () {

	DBG "start m3u playlist"

	# Check if path entered
	DBG "scanpath=$DATA_SCAN_PATH"
	if [ -z "$DATA_SCAN_PATH" ] ; then
		# No path
		echo "missing filename"
		exit 1
	fi

	# remove m3u from filename
	DATA_SCAN_PATH=$(echo $DATA_SCAN_PATH | sed "s|.m3u||g")

	# check if file exist
	if [ -r "$DATA_SCAN_PATH.m3u" ] ; then
		DBG "overwrite file $DATA_SCAN_PATH.m3u"
		read -p "Delete existing $DATA_SCAN_PATH.m3u? [Y/N]" yn
		case $yn in
			[Yy]* )
			DBG "delete $DATA_SCAN_PATH.m3u"
			rm "$DATA_SCAN_PATH.m3u"
			break
			;;
			[Nn]* )
			DBG "done m3u playlist"
			DBG "medialist - end"
			exit 1
			;;
		esac
	fi

	# crate m3u file
	touch "$DATA_SCAN_PATH.m3u"

	while read p ; do

		# Remove LOCAL_FILE_TMP if exist
		if [ -f "$HOME/$BASE_DIR/$LOCAL_FILE_TMP" ] ; then
			DBG "delete $HOME/$BASE_DIR/$LOCAL_FILE_TMP"
			rm "$HOME/$BASE_DIR/$LOCAL_FILE_TMP"
		fi

		# Scan to $HOME/$BASE_DIR/$LOCAL_FILE_TMP
		find $p -type f -print >> "$HOME/$BASE_DIR/$LOCAL_FILE_TMP"

		# diff against $DATA_SCAN_PATH.m3u
		grep -vxFf "$DATA_SCAN_PATH.m3u" "$HOME/$BASE_DIR/$LOCAL_FILE_TMP" >> "$DATA_SCAN_PATH.m3u"

		# sort file
		sort "$DATA_SCAN_PATH.m3u" -o "$DATA_SCAN_PATH.m3u"

	done < "$HOME/$BASE_DIR/$DATA_SCAN_FILE"

	# Clean up tmp file
	# Remove LOCAL_FILE_TMP if exist
	if [ -f "$HOME/$BASE_DIR/$LOCAL_FILE_TMP" ] ; then
		DBG "delete $HOME/$BASE_DIR/$LOCAL_FILE_TMP"
		rm "$HOME/$BASE_DIR/$LOCAL_FILE_TMP"
	fi

	DBG "done m3u playlist"

}

# --------------------
# - MAIN             -
# --------------------
DBG "medialist - start"

#	IS_ROOT

# Have arg?
if [ $# -eq 0 ] ; then
	SHOW_HELP
fi
# Check arg
while getopts "h?i:a:w:d:m:ue" opt ; do
	DBG "opt=$opt"
	case "$opt" in
		h|\?)
		SHOW_HELP
		;;
		i)
		DATA_SCAN_PATH=${OPTARG}
		INIT_DATABASE
		;;
		a)
		DATA_SCAN_PATH=${OPTARG}
		UPDATE_DATABASE
		;;
		u)
		UPDATE_DATABASE
		;;
		e)
		DATA_EXPORT
		;;
		d)
		DATA_SCAN_PATH=${OPTARG}
		DIFF_DATABASE
		;;
		w)
		DATA_SCAN_PATH=${OPTARG}
		WRITE_DATABASE
		;;
		m)
		DATA_SCAN_PATH=${OPTARG}
		WRITE_PLAYLIST
		;;
		*)
		SHOW_HELP
		;;
	esac
done

DBG "medialist - end"
