#!/bin/bash
export AFHOME=`dirname $0`; until ls ${AFHOME}/etc/afnet.conf > /dev/null 2>&1; do cd ${AFHOME}/..; export AFHOME=`pwd`; done; echo "Home Directory: `pwd`"; source ${AFHOME}/etc/afnet.conf
#
sudo systemctl stop afnet-root.service
sudo systemctl status afnet-root.service
for file in `ls ${AFHOME}/package/service/*.service`
do
  echo "Uninstalling $file"
  sudo bash -c "rm -f /etc/systemd/user/`basename $file` > /dev/null 2>&1"
  sudo bash -c "rm -f /etc/systemd/system/`basename $file` > /dev/null 2>&1"
done
sudo systemctl daemon-reload
sudo systemctl status afnet-root.service
