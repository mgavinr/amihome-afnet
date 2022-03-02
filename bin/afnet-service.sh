#!/bin/bash
function showhelp() {
cat << HELP
NAME
        bin/afnet-service.sh - systemd style entry point of project 

SYNOPSIS
        bin/afnet-service.sh

DESCRIPTION
        This parses the txt files and run expect scripts on their contents
        Calls one of the following expect scripts with the contents of the txt files 
		    AF_BIN_START=bin/afnet-expect-start.sh
		    AF_BIN_STOP=bin/afnet-expect-stop.sh

SEE ALSO
        Those expect scripts use bin/afnet-script.sh (the main code) which takes a single request as args 
HELP
}
# ----------------------------------------------------- #
# Settings
# ----------------------------------------------------- #
export AFHOME=`dirname $0`; until ls ${AFHOME}/etc/afnet.conf > /dev/null 2>&1; do cd ${AFHOME}/..; export AFHOME=`pwd`; done; echo "Home Directory: `pwd`"; source ${AFHOME}/etc/afnet.conf
#
set -a
IFS=$'\n'

# ----------------------------------------------------- #
# functions
# ----------------------------------------------------- #
# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
  echo "** Trapped CTRL-C"
  for i in {1..5}
  do
    eval "$AFHOME/$AF_BIN_STOP"
  done
  exit 1
}

function check_sleep() {
  # retry failed connections after a minute
  sleep 1
  touch /tmp/.check_sleep`id -u`
  for i in {0..60}
  do
    echo "Sleep $i/60 .."
    sleep 1
    [ "$AFHOME/etc/$AF_TEXT_RUNNING" -nt /tmp/.check_sleep`id -u` ] && break
    [ "$AFHOME/etc/$AF_TEXT_START" -nt /tmp/.check_sleep`id -u` ] && break
    [ "$AFHOME/etc/$AF_TEXT_STOP" -nt /tmp/.check_sleep`id -u` ] && break
    if [ -f $AFHOME/etc/$AF_TEXT_SHUTDOWN ]; then
      break
    fi
  done
}

# ----------------------------------------------------- #
# main
# ----------------------------------------------------- #
running="1"
rm -f $AFHOME/etc/$AF_TEXT_SHUTDOWN
rm -f $AFHOME/etc/$AF_TEXT_RUNNING
rm -f $AFHOME/etc/$AF_TEXT_ERRORS
touch $AFHOME/etc/$AF_TEXT_RUNNING
echo "$0 starting loop"
attempt=0
while [ $running -eq 1 ]
do
  # STOP
  # --------------------------------
  lineno=0
  for line in `cat $AFHOME/etc/$AF_TEXT_STOP | grep -v '#'`
  do
    lineno=$((lineno+1))
    grep "^${line}$" $AFHOME/etc/$AF_TEXT_RUNNING > /dev/null 2>&1
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
      echo " "
      echo "___________________________________________ SERVICE LOOP STOP FILE LINE $lineno"
      echo "Stopping no spawn so spawn yourself to death losers FTP $line"
      eval "$AFHOME/$AF_BIN_STOP $line"
      RESULT=$?
      if [ $RESULT -eq 0 ]; then
        echo "___________________________________________ SERVICE LOOP STOP FILE LINE $lineno=SUCCESS"
        sed -i "/${line}/d" $AFHOME/etc/$AF_TEXT_RUNNING
      fi
    fi
  done

  # START
  # --------------------------------
  lineno=0
  for line in `diff -b -B $AFHOME/etc/$AF_TEXT_START $AFHOME/etc/$AF_TEXT_RUNNING | grep -v '#' | grep '^<' | sed 's/^. //g'`
  do
    lineno=$((lineno+1))
    grep "^${line}$" $AFHOME/etc/$AF_TEXT_STOP > /dev/null 2>&1
    RESULT=$?
    if [ $RESULT -eq 1 ]; then
      attempt=$((attempt+1))
      echo " "
      echo "___________________________________________ SERVICE LOOP START FILE LINE $lineno attempt $attempt"
      echo "Starting FTP $line"
      eval "$AFHOME/$AF_BIN_START $line"
      RESULT=$?
      if [ $RESULT -eq 0 ]; then
        echo "___________________________________________ SERVICE LOOP START FILE LINE $lineno attempt $attempt=RUNNING"
        echo $line >> $AFHOME/etc/$AF_TEXT_RUNNING
      else
        echo "___________________________________________ SERVICE LOOP START FILE LINE $lineno attempt $attempt=FAILED"
      fi
      if [ -f $AFHOME/etc/$AF_TEXT_SHUTDOWN ]; then
        break
      fi
    fi
  done

  # end of loop
  check_sleep
  if [ -f $AFHOME/etc/$AF_TEXT_SHUTDOWN ]; then
    running=0
  fi
done

echo " "
echo "___________________________________________ SERVICE LOOP"
echo "$0 stopping normally"
for line in `cat $AFHOME/etc/$AF_TEXT_START`
do
  eval "$AFHOME/$AF_BIN_STOP"
done
echo " "
echo "___________________________________________ SERVICE LOOP"
echo "$0 stopping"
