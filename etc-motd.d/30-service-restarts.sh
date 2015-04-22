#!/bin/sh

if [[ -e /tmp/.motd-service-restarts ]]; then
  cat /tmp/.motd-service-restarts
  exit 0
fi

trap "rm -f /tmp/.motd-service-restarts ; exit 1" 2
for i in 1 ; do
  #SERVICES="$(restart_services -c -u -l 2>/dev/null | grep -v -- "^..........->" | egrep -v "Found 0 (services|inittab)" | grep -v "^No known services need to be restarted.\$" | sed '/./,$!d' | wc -l)"
  SERVICES="$(lib_users -i *hugetlbfs* | wc -l)"
  if [[ $SERVICES -gt 0 ]]; then
    echo -e " \033[1;33m* ${SERVICES}\033[0m processes need to be restarted, run '\033[1mrestart_services -c -u -l\033[0m' to get a list"
    #restart_services -c -u -l | grep -v -- "^..........->" | egrep -v "Found 0 (services|inittab)" | grep -v "^No known services need to be restarted.\$" | sed '/./,$!d' | cut -c 1-150
  fi
done &> /tmp/.motd-service-restarts
cat /tmp/.motd-service-restarts
