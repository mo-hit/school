#!/bin/bash

ips=()
while read line
do
  ips=("${ips[@]}" $line)
done < $1

echo ${ips[@]}

i=0
while [ $i -lt 25 ]; do
  index=$(( RANDOM % ${#ips[@]} ))
  curl --request POST "${ips[$index]}:63104" --data "comment=$i"
  i=$(( i + 1 ))
done
