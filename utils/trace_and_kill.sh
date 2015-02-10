#!/bin/bash
#
# Script to strace and kill misbehaving mongod.
# strace and lsof must be installed.

PID=`pgrep mongod`
DATE=`date +"%Y%d%m"`
OUT_DIR=trace-logs.$DATE.PID$PID

if [ -z "$PID" ]; then
  echo "No mongod processes found"
  exit 1
fi

echo "mongod PID is $PID"

mkdir -p $OUT_DIR

lsof -p $PID > $OUT_DIR/lsof.$DATE.PID$PID
tail -n1000 /var/log/messages > $OUT_DIR/messages.$DATE.PID$PID
dmesg | tail -n500 > $OUT_DIR/dmesg.$DATE.PID$PID

echo "stracing for 30 seconds..."
strace -tt -s 2000 -fp $PID -o $OUT_DIR/strace.out.$DATE.PID$PID &
sleep 30

echo "Killing PID $PID..."
kill $PID
sleep 5
[ -d /proc/$PID ] && kill -9 $PID

tar -jc --remove-files -f $OUT_DIR.tar.bz $OUT_DIR/
