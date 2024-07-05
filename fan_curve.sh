#!/bin/bash

# Query Nvidia-SMI (nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)
# If number value, apply fan curve
# else continue
#
declare -A fan_curve
declare -a indexes
# CONFIG
update_interval=3
fan_curve=([30]="0x30" [40]="0x30" [50]="0x35" [60]="0x41" [70]="0x47" [80]="0x50" )
indexes=( 30 40 50 60 70 80 )
while true
do
	nvidia_smi_output=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)
	if [[ "$nvidia_smi_output" != *"failed"* ]]
	then
		for index in "${indexes[@]}"
		do
			if [[ $nvidia_smi_output -ge $index ]]
			then
				fan_value=${fan_curve[$index]}
			fi
		done
		#echo "Temp: $nvidia_smi_output"
		#echo $fan_value
		ipmitool raw 0x30 0x70 0x66 0x01 0x00 $fan_value
	else
		echo "nvidia-smi failed to get temperature information"
	fi
	sleep $update_interval
done
