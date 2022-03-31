#!/bin/bash

# missing iterations (or too many args)
if [[ $# -ne 1 ]]; then
	echo "Usage: multi-mass.sh <iterations>"
	exit 1
fi

# read domain list and do captures for each domain
jq -r .pcaps[] ./config.json | while IFS= read -r domain; do

	# number of captures per domain supplied by arg 1
	for i in $(eval echo {1..$1}); do
		echo "[$i][$(date)] Capturing..."

		# capture traffic in background
		./capture.sh $domain lynx &

		# start lynx in xterm and timeout after 20 sec
		timeout 20 xterm -e lynx -accept_all_cookies https://$domain/

		# kill tcpdump
		tcpdump_pid=$(pidof tcpdump)
		if [[ ! -z $tcpdump_pid ]]; then
			echo "Killing $tcpdump_pid"
			kill -15 $tcpdump_pid
		fi
	done
done
