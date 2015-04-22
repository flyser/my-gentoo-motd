#!/bin/sh

if [[ -e /tmp/.motd-system-updates ]]; then
  cat /tmp/.motd-system-updates
  exit 0
fi

trap "rm -f /tmp/.motd-system-updates ; exit 1" 2
for i in 1 ; do
  SYS=$(emerge -uDNpq world | grep ebuild | wc -l)
  SEC=$(glsa-check -l affected 2> /dev/null | grep \\[ | wc -l)
  NEWS=$(eselect news count new)
  ETCUPDATE=$(find /etc $CONFIG_PROTECT -name ._cfg[0-9][0-9][0-9][0-9]_* | wc -l)

  KVER=$(readlink /usr/src/linux | cut -f 2 -d -)
  UNAMER=$(uname -r)

  SYSC="\033[1;32m"
  SECC=$SYSC

  if [[ $SYS -gt 0 ]] ; then
      SYSC="\033[1;33m"
  fi

  if [[ $SEC -gt 0 ]] ; then
      SECC="\033[1;31m"
  fi

  echo -e "\nPortage and GLSA status:"
  if [[ "x$KVER" != "x$UNAMER" ]]; then
      echo -e " \033[1;33m*\033[0m An update to kernel version \033[1;33m${KVER}\033[0m is available."
  fi
  echo -e " ${SYSC}* ${SYS}\033[0m packages have updates available."

  if [[ $SEC -gt 0 ]]; then
    echo -e " ${SECC}* ${SEC}\033[0m security advisories affect this server, see '\033[1mglsa-check -d affected\033[0m'"
  fi

  if [[ $ETCUPDATE -gt 0 ]] ; then
      echo -e " \033[1;33m* ${ETCUPDATE}\033[0m config file(s) need to be updated."
  fi
  if [[ $NEWS -gt 0 ]] ; then
      echo -e " \033[1;33m* Important:\033[0m There are \033[1m${NEWS}\033[0m unread news items."
  fi
done &> /tmp/.motd-system-updates
cat /tmp/.motd-system-updates
