#!/bin/bash
export AFHOME=`dirname $0`; until ls ${AFHOME}/etc/afnet.conf > /dev/null 2>&1; do cd ${AFHOME}/..; export AFHOME=`pwd`; done; echo "Home Directory: `pwd`"; source ${AFHOME}/etc/afnet.conf
#
sudo mkdir -p /etc/afnet/
sudo rsync -avz ${AFHOME}/ /etc/afnet
sudo cp ${AFHOME}/package/service/*root.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start afnet-root.service
sudo systemctl status afnet-root.service
sudo journalctl -u afnet-root -f
