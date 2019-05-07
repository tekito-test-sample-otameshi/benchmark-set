#!/bin/sh
DATE=`date '+%Y%m%d%H%M'`
mkdir $DATE
for thread in 1 2 4 8 16 64 256
do
  ./sysbench.sh run ${thread} >> ${DATE}/sysbench_read_write_${thread}.log
  echo "read-write ${thread} threads" >> ${DATE}/result.txt
  grep transactions ${DATE}/sysbench_read_write_${thread}.log >> ${DATE}/result.txt
done
