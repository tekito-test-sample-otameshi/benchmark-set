#!/bin/bash -u

## -- FUNCTION ---
IP_ADDR () {
	IP_AD=`ip a | grep inet | grep $pfx | cut -d ' ' -f 6`
	
	if [ -n "$IP_AD" ]
	then
		ip_addr=${IP_AD%/*}
	fi
}

INF_LOG () {
	DATE=`date '+%Y/%m/%d %T'`
	echo ""$DATE" [INFO]: "$msg"" >> $log_file
	}

ERR_LOG () {
	DATE=`date '+%Y/%m/%d %T'`
	echo ""$DATE" [ERROR]: "$msg"" >> $log_file
	}

BEG_DAY () {
	echo "Enter the beggining of term you want to get results."
	read -p "Year (format XXXX) -->  " beg_year_ans
	read -p "Month (format XX, enter 2 characters as padding "0" left of the number when you enter (1~9)) -->  " beg_mon_ans
	read -p "Day   -->  " beg_day_ans

	echo "You entered ${beg_year_ans}/${beg_mon_ans}/${beg_day_ans}."
	read -p "Is this correct? (yes/n) -->  " rep
}


END_DAY () {
	echo "Enter the end of term you want to get results."
	read -p "Year  -->  " end_year_ans
	read -p "Month -->  " end_mon_ans
	read -p "Day   -->  " end_day_ans

	echo "You entered ${end_year_ans}/${end_mon_ans}/${end_day_ans}."
	read -p "Is this correct? (yes/n) -->  " rep
}

MEM_FUN () {
	val=`grep "$t" $line | awk -F " " '{print $3}'`
	
	if [ -z $val ]
	then
		msg="Cannot get the "$t" value of $line"
		ERR_LOG
	fi
}

## -- MAIN --

log_file="/home/benchmark/arr_log/arrange_`date +%Y%m%d`.log"
log_dir=${log_file%/*}

if [ ! -d "$log_dir" ]
then
	mkdir -p $log_dir
fi


# for sakura machine
pfx="/24"
IP_ADDR

# for AWS machine
if [ -z "$ip_addr" ]
then
	pfx="/20"
	IP_ADDR
fi

case $ip_addr in
	"163.43.247.229" ) hostname="sakura-1co1gb-tky" ;;
	"163.43.247.228" ) hostname="sakura-1co2gb-tky" ;;
	"153.120.83.62"  ) hostname="sakura-1co1gb-isk" ;;
	"153.120.83.67"  ) hostname="sakura-1co2gb-isk" ;;
	"172.31.34.103"  ) hostname="aws-t2small-tky" ;;
	"172.31.45.71"   ) hostname="aws-t2micro-tky" ;;
	"172.31.21.57"   ) hostname="aws-a1medium-va" ;;
	*                ) ;;
esac

echo "Now, choose the term you want to get the ssd benchmark result with the form of XXXX/XX/XX ~ YYYY/YY/YY"

BEG_DAY

while [ "$rep" = "no" ] || [ "$rep" = "n" ]
do
	echo "You answered with 'no'."
	BEG_DAY
done

END_DAY

while [ "$rep" = "no" ] || [ "$rep" = "n" ]
do
	echo "You answered with 'no'."
	END_DAY
done

echo -n "Getting the ssd results from ${beg_year_ans}/${beg_mon_ans}/${beg_day_ans} to 
${end_year_ans}/${end_mon_ans}/${end_day_ans}" | tee $log_file

#ssd
ssd_dir="/home/benchmark/fio/results"

cd $ssd_dir 2>> $log_file
ret=`echo $?`

ssd_file="${ssd_dir}/sum_res/sum_res_`date '+%Y%m%d%H%M'`.txt"

if [ ! -d ${ssd_file%/*} ]
then
	mkdir ${ssd_file%/*}
fi

echo "date,time,Seq-Read-1m,Seq-Write-1m,Rand-Read-4k-32qd,Rand-Write-4k-32qd" > $ssd_file

startdate="${beg_year_ans}${beg_mon_ans}${beg_day_ans}"
enddate="${end_year_ans}${end_mon_ans}${end_day_ans}"

tmpdate="$startdate"
while [ 1 ]
do
	target=`find *${tmpdate}*`
	
	# anticipates that $target has equal or more than 2 files.
	echo "$target" | while read line
	do
		stdi=`grep "iops" $line `
		one=`echo "$stdi" | head -n 1 | awk -F "," '{print $3}' | sed "s/ avg=//g"`
		two=`echo "$stdi" | head -n 2 | tail -n 1 | awk -F "," '{print $3}' | sed "s/ avg=//g"`
		three=`echo "$stdi" | head -n 3 | tail -n 1 | awk -F "," '{print $3}' | sed "s/ avg=//g"`
		four=`echo "$stdi" | tail -n 1 | awk -F "," '{print $3}' | sed "s/ avg=//g"`
		
		ssd_time=`date '+%Y-%m-%d %H:%M' -r "$line"`

		echo "${ssd_time},${one},${two},${three},${four}" >> $ssd_file
	done
	
	if [ "$tmpdate" = "$enddate" ]
	then
		break
	fi

	tmpdate=`date -d "$tmpdate 1day" "+%Y%m%d"`
done

echo "Getting the memory result done." | tee $log_file
