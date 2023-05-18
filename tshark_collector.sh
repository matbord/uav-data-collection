#!/bin/bash
if [[ $# -eq 0 ]]; then
    DATETIME=`date +"%Y_%m_%d_%H_%M_%S"`
    FILENAME=tshark_log_$DATETIME.pcapng
elif [[ $# -eq 1 ]]; then
    FILENAME=tshark_log_$1.pcapng
fi

echo "Add IP route to Gnb"
tmux split-window "bash execCommands.sh"

tshark -i srs_spgw_sgi -a duration:1800 --color -P -w $FILENAME
# tshark -i tun_srsue -a duration:2750 --color -P -w $FILENAME
# tshark -i srs_spgw_sgi -a duration:2750 --color -P -w $FILENAME


#To export files
#lxc file pull BaseStation/root/uav-data-collection/tshark_log_2023_03_21_19_46_19.pcapng .