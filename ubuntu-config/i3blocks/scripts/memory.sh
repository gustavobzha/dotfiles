#!/bin/bash

FREE_COMMAND=$(free -h --giga | head -n 2 | tail -n 1)
TOTAL_MEM=$(echo $FREE_COMMAND | awk '{ printf $2 }' | sed -E 's/G//')
USED_MEM=$(echo $FREE_COMMAND | awk '{ printf $3 }' | sed -E 's/G//')
PERCENTAGE_USED=$(echo "scale=2; ($USED_MEM * 100) / $TOTAL_MEM" | bc)

echo "${USED_MEM}G (${PERCENTAGE_USED}%)"
