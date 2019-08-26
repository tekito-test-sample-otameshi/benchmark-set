#!/bin/sh
LUA=/usr/share/sysbench/oltp_read_write.lua
SIZE=1000000
usage()
{
  echo "Usage: ./sysbench.sh <prepare|run|cleanup> <num of threads>"
  exit "${1}"
}
#chack argumets
if [ "${1}" = "" -o $# -gt 3 ]; then
  usage 1
elif [ "${2}" = "" ]; then
  THREADS=1
else
  THREADS=${2}
fi
sysbench ${LUA} --db-driver=mysql --table-size=${SIZE} --mysql-host=localhost --mysql-password=sbtest --time=60 --db-ps-mode=disable --threads=${THREADS} ${1}
