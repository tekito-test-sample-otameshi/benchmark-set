#!/bin/bash -xu

dir=$(cd $(dirname $0); pwd)
cpu_dir=${dir}/unixbench
mem_dir=${dir}/STREAM
st_dir=${dir}/fio
db_dir=${dir}/sysbench

# --- CPU section ---
cd ${cpu_dir}
./Run

# --- MEMORY section ---
mem_log="${mem_dir}/results/stream_`date +%Y%m%d%H%M`.log"
cd ${mem_dir}
./stream > ${mem_log}

# --- STORAGE section ---
cd ${st_dir}
fio_file="bench.ini"
fio_log="results/fio_`date +%Y%m%d%H%M`.log"
fio ${fio_file} > ${fio_log}

# --- DB section ---
cd ${db_dir}
./run.sh

