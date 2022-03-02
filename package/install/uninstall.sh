#!/bin/bash
export AFHOME=`dirname $0`; until ls ${AFHOME}/etc/afnet.conf > /dev/null 2>&1; do cd ${AFHOME}/..; export AFHOME=`pwd`; done; echo "Home Directory: `pwd`"; source ${AFHOME}/etc/afnet.conf
#
systemctl --user stop afnet-user.service
systemctl --user status afnet-user.service
for file in `ls ${AFHOME}/_service/*.service`
do
  echo "Uninstalling $file"
  sudo bash -c "rm -f /etc/systemd/user/`basename $file` > /dev/null 2>&1"
  sudo bash -c "rm -f /etc/systemd/system/`basename $file` > /dev/null 2>&1"
done
systemctl --user daemon-reload
