#!/bin/sh

MOUNTPOINTS="/ /boot /mnt/virtual-machines"

echo -en " \033[1;32m*\033[0m "
uname -nr
echo -en " \033[1;32m*\033[0m "
uptime -p

## Load Average ##

CPUS=$(grep -c ^processor /proc/cpuinfo)
LOAD=$(cut -d '.' -f 1 /proc/loadavg)

if [[ $LOAD -gt $(($CPUS * 4 - 1)) ]]; then
  echo -en " \033[1;31m*\033[0m"
elif [[ $LOAD -gt $CPUS ]]; then
  echo -en " \033[1;33m*\033[0m"
else
  echo -en " \033[1;32m*\033[0m"
fi

echo " Load average: $(sed "s_ _, _"g /proc/loadavg | cut -f -3 -d ,)"

## Memory Usage ##

MEM="$(free | awk '/buffers\/cache/{printf("%.1f\n"), $3/($3+$4)*100}')"
SWAP="$(free | awk '/Swap/{printf("%.1f\n"), $3/$2*100}')"

if [[ ${MEM%??} -ge 85 ]]; then
  echo -en " \033[1;31m*"
elif [[ ${MEM%??} -ge 65 ]]; then
  echo -en " \033[1;33m*"
else
  echo -en " \033[1;32m*\033[0m"
fi
echo -e " Memory Usage: \033[1m${MEM}%\033[0m (Swap Usage: ${SWAP}%)"

## Hard drive usage ##

echo
for MOUNTPOINT in $MOUNTPOINTS ; do 
  PCT="$(df -a --output=size,avail "${MOUNTPOINT}" | awk 'NR==2{printf("%.1f\n"), ($1-$2)/$1*100}')"
  if [[ ${PCT%??} -ge 95 ]]; then
    echo -en " \033[1;31m*"
  elif [[ ${PCT%??} -ge 80 ]]; then
    echo -en " \033[1;33m*"
  else
    echo -en " \033[1;32m*\033[0m"
  fi
  echo -e " Disk Usage of ${MOUNTPOINT}: ${PCT}%\033[0m"

done
