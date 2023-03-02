#!/bin/bash

# Clear the contents of qdisc_stats.txt
echo "" > qdisc_stats.txt

# Run the tc command every 0.2 seconds and append the output to qdisc_stats.txt
while true; do
    echo -n "$(date +%s.%N) " >> qdisc_stats.txt
    tc -s -d qdisc show dev $(ip route get 10.14.1.2 | grep -oP "(?<= dev )[^ ]+") >> qdisc_stats.txt
    sleep 0.2
done

