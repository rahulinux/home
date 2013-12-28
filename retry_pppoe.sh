#!/bin/bash

# Retry pppoe until get connected

interval=2
n=0
pppstats && { echo "Internet is working"; exit 1; }
while true
do
	poff -a ||
	pon dsl-provider
	sleep $interval	
	plog | grep -Eq "failed|terminated" || break
	((n++))
done

echo "Dialer Connected after total retry: $n"
