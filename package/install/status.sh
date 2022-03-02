#!/bin/bash
export AFHOME=`dirname $0`; until ls ${AFHOME}/etc/afnet.conf > /dev/null 2>&1; do cd ${AFHOME}/..; export AFHOME=`pwd`; done; echo "Home Directory: `pwd`"; source ${AFHOME}/etc/afnet.conf
#
systemctl --user status afnet.service
journalctl -f --since 09:00 --user -u afnet.service
