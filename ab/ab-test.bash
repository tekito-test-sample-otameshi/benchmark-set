#!/bin/bash -u

DATE=`date '+%Y%m%d'`
dir_path=$(dirname $(readlink -f $0))
res_dir="${dir_path}/results/${DATE}"

mkdir -p $res_dir

for i in 0 1 2
do
	ab -n 10000 -c 100 http://localhost/ >> $res_dir/ab_res.log
done
