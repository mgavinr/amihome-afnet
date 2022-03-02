#!/bin/bash
export AFHOME=`dirname $0`; until ls ${AFHOME}/etc/afnet.conf > /dev/null 2>&1; do cd ${AFHOME}/..; export AFHOME=`pwd`; done; echo "Home Directory: `pwd`"; source ${AFHOME}/etc/afnet.conf
#
sudo cp ${AFHOME}/_service/*user.service /etc/systemd/user
systemctl --user daemon-reload
systemctl --user start afnet-user.service
systemctl --user status afnet-user.service
