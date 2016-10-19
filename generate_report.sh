#!/bin/bash

NOT_FOUND="\[CRITICAL\] page not found (404)"
NOT_PAGE_CONTENT="\[CRITICAL\] unable to retrieve page content"
NO_ERROR="all tested parameters appear to be not injectable"
NOT_AUTHORIZE="\[CRITICAL\] not authorized"
SSL="\[CRITICAL\] can't establish SSL connection"

TMP_FILE="res.tmp"

WS_FILE="ws-urls.txt"

TEMPLATE="./report/scan_report_remplate.html"
RESULT="./report/scan_results.html"

rm $RESULT

grep -rL -e "$NOT_FOUND" -e "$NO_ERROR" -e "$NOT_PAGE_CONTENT" -e "$NOT_AUTHORIZE" -e "$SSL" scan/scan_out_*.txt > $TMP_FILE
nb_err=0
while read file; do
	error[$nb_err]=$(echo $file | sed "s/.*scan_out_//" | sed "s/\.txt//")
	nb_err=$((nb_err+1))
done < $TMP_FILE

i=1
TABLE="<table class=\"table table-striped\">"
TABLE+="<tbody>"
STATUS_GENERAL="a"
while read line; do
	status="<span class='label label-success'>Success</span>"
	for ((j=0; j<$nb_err; j++)); do
		if [ $i -eq ${error[$j]} ]
		then
			status="<span class='label label-danger'>Vulnerability Found !</span>"
			STATUS_GENERAL="e"
			break
		fi
	done
	truncatedLine=$(echo $line | cut -c 1-128)
	row=$(echo "<tr><td>$i</td><td>" $truncatedLine "</td><td>" $status "</td></tr>")
	TABLE+=$row
	i=$((i+1))
done < $WS_FILE
TABLE+="</tbody>"
TABLE+="</table>"

while read line; do
	case $line in 
		*SQLMAP_STATUS*)
			echo "./rating_$STATUS_GENERAL.png" >> $RESULT
			;;
		*TABLE_RESULTS*)
			echo $TABLE >> $RESULT
			;;
		*)
			echo $line >> $RESULT
			;;	
	esac		
done < $TEMPLATE
