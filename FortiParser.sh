#!/bin/bash
# FortiParser
# Simple CSV log parser for analyzing traffic on FortiGate

# grep
grep="/usr/bin/grep"

# read from input parameters
fgt_service_type=$1
fgt_what=$2
if [ "$3" == "" ]; then
	fgt_log="example.log" # path to log
else
	fgt_log="$3"
fi

if [ "$fgt_service_type" != "" ]; then
		if [ "$fgt_service_type" = topip ]; then
			if [ "$2" == "" ]; then
				exit 0
			else
				fgt_what="$2"
			fi
			echo "TOP IP address in SRC for service $fgt_what in $fgt_log:"
			cat $fgt_log | grep -i "service=\"$fgt_what" | $grep -o "src=[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | $grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | sort -n | uniq -c | sort -n

		elif [ "$fgt_service_type" = showip ]; then
			echo "IP address $fgt_what statistics "
			echo -ne "Send MegaBytes (MB): \t\t"
			cat $fgt_log | grep -i "src=$fgt_what" | grep -o -P '(?<=sent=).*(?=,rcvd=)' |  awk '{ SUM += $1} END { print SUM/1024/1024 }'
			echo -ne "Recivied MegaBytes (MB): \t "
			cat $fgt_log | grep -i "src=$fgt_what" | grep -o -P '(?<=rcvd=).*(?=,sent_pkt=)' |  awk '{ SUM += $1} END { print SUM/1024/1024 }'
			echo ""
#	 		while read LINE
#			do
#				count=grep -o -P "(?<=sent=).*(?=,rcvd=)"
#			    let count=count
#			done < $fgt_log
		else
			exit 0
		fi

    else
    	echo "-----------------------"
    	echo " Foti Traffic analyzer "
    	echo "-----------------------"
    	echo "Usage:"
    	echo "./FortiParser.sh topip [mail | http | ...] [log]"
    	echo "./FortiParser.sh showip 192.168.1.1 [log]"
    	echo "If path to LOG file is not specified, then will be used example.log"
    	exit 0
fi
