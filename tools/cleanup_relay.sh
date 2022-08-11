#!/bin/bash

# Clean up synced_and_verified files over ## days old
CLEANUP_DAYS_OLD=30
# LOG_FILE
CLEANUP_LOG="/data/cleanup_logs/cleanup_relay.log"
# ARCHIVE_LOCATION
ARCHIVE_LOC="/data/xnat/archive"

HOST="localhost"

CLEANUP_DIR=`echo "$CLEANUP_LOG" | sed -e "s/\/[^\/]*$//"`
if [ ! -d $CLEANUP_DIR ] ; then
	mkdir -p $CLEANUP_DIR
fi

echo "Running cleanup_relay job - starting `date`" >> $CLEANUP_LOG

JSESSIONID=`curl -s -k -n https://$HOST/data/JSESSIONID`

#echo "JSESSIONID=$JSESSIONID"

XSYNC_HISTORY=`curl -s -k --cookie JSESSIONID=$JSESSIONID https://$HOST/xapi/xsync/history`

TEMP_FILE=`mktemp --suffix=cleanup`

CURRENT_TIME=`date +%s`
#echo "CURRENT_TIME=$CURRENT_TIME"

for SYNC_RECORD in `echo "$XSYNC_HISTORY" | jq -r '.[] | @base64'`; do
	OLDIFS="$IFS"
	IFS=$'\n'
	for ASSNMT in `echo "${SYNC_RECORD}" | base64 --decode | jq -r 'to_entries|map("\(.key)=xxxxxx\(.value|tostring)xxxxxx")|.[]'`; do
		ASSNMTMOD=`echo "set $ASSNMT" | sed -e "s/'/\&/g" -e "s/xxxxxx/'/g"`
		eval export $ASSNMTMOD
	done
	IFS="$OLDIFS"
	#echo "experimentHistories=$experimentHistories"
	for EXP_RECORD in `echo "$experimentHistories" | jq -r '.[] | @base64'`; do
		OLDIFS="$IFS"
		IFS=$'\n'
		for EXPMT in `echo "${EXP_RECORD}" | base64 --decode | jq -r 'to_entries|map("\(.key)=xxxxxx\(.value|tostring)xxxxxx")|.[]'`; do
	   		EXPTMTMOD=`echo "set $EXPMT" | sed -e "s/'/\&/g" -e "s/xxxxxx/'/g"`
			eval export $EXPTMTMOD
		done
		#echo "startDate=$startDate"
		#echo "completeDate=$completeDate"
		#echo "remoteHost=$remoteHost"
		#echo "remoteProject=$remoteProject"
		#echo "localProject=$localProject"
		#echo "timestamp=$timestamp"
		#echo "localLabel=$localLabel"
		#echo "syncStatus=$syncStatus"
		IFS="$OLDIFS"
		echo "\"$localProject\",\"$remoteProject\",\"$remoteHost\",\"$localLabel\",\"$timestamp\",\"$syncStatus\"" >> $TEMP_FILE
	done
	
done       

#echo "Print: $TEMP_FILE"
#cat $TEMP_FILE

for EXP_INFO in `curl -s -k --cookie JSESSIONID=$JSESSIONID https://$HOST/data/experiments?format=csv\&columns=ID,project,label,subject_ID,subject_label,URI | cut -d',' -f3,5,6,8 | tail -n +2 | sort`; do
	SUBJ_LBL=`echo "$EXP_INFO" | cut -d',' -f1`
	EXP_PROJ=`echo "$EXP_INFO" | cut -d',' -f2`
	EXP_LBL=`echo "$EXP_INFO" | cut -d',' -f3`
	SUBJ_URI=`echo "$EXP_INFO" | cut -d',' -f4`
	SYNC_INFO=`cat $TEMP_FILE | grep "^\"${EXP_PROJ}\"" | grep ",\"${EXP_LBL}\"," | sort | tail -n 1` 
	#echo "$SYNC_INFO"
	SYNC_REMOTEPROJ=`echo "${SYNC_INFO}" | cut -d',' -f2 | sed -e "s/\"//g"`
	SYNC_REMOTEHOST=`echo "{$SYNC_INFO}" | cut -d',' -f3 | sed -e "s/\"//g"`
	SYNC_TIME=`echo "${SYNC_INFO}" | cut -d',' -f5 | sed -e "s/\"//g"`
	SYNC_STATUS=`echo "${SYNC_INFO}" | cut -d',' -f6 | sed -e "s/\"//g"`
	#echo "$EXP_PROJ - $EXP_LBL - $SYNC_TIME - $SYNC_STATUS"
	DAYS="$(( ( $CURRENT_TIME - ($SYNC_TIME/1000) ) / (60*60*24) ))"
	if [ "$SYNC_STATUS" == "SYNCED_AND_VERIFIED" ] && [ $DAYS -gt $CLEANUP_DAYS_OLD ] ; then
		if [ -d /data/xnat/archive/$EXP_PROJ/arc001/$EXP_LBL  ] ; then
			echo "Removing SYNCED_AND_VERIFIED session:  $EXP_PROJ - $SUBJ_LBL - $EXP_LBL - DAYS_OLD=$DAYS - `date`" >> $CLEANUP_LOG
			curl -s -k --cookie JSESSIONID=$JSESSIONID https://$HOST/data/projects/$EXP_PROJ/subjects/$SUBJ_LBL/experiments/$EXP_LBL?removeFiles=false -X DELETE
			rm -rf $ARCHIVE_LOC/$EXP_PROJ/arc001/$EXP_LBL
		fi
	fi
done

rm $TEMP_FILE



