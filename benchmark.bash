#!/bin/bash -xu

dir=$(cd $(dirname $0); pwd)
cpu_dir=${dir}/unixbench
mem_dir=${dir}/STREAM
st_dir=${dir}/fio
db_dir=${dir}/sysbench

# --- CPU section ---
${cpu_dir}/Run

# --- MEMORY section ---
mem_log="${mem_dir}/results/stream_`date +%Y%m%d%H%M`.log"
${mem_dir}/stream > ${mem_log}

# --- STORAGE section ---
fio_file="${st_dir}/bench.ini"
fio_log="${st_dir}/results/fio_`date +%Y%m%d%H%M`.log"
fio ${fio_file} > ${fio_log}

# --- DB section ---
${db_dir}/run.sh

