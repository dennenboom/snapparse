#! /bin/bash
##################################################################################################
# Snap Parse Jan 2015
# This script will:
#   1) export the _Production project and breaks out to slp/tasks/files
#   2) stores the files into each folder
#   3) Create a summary of total of the # of objects.
#
#	Prerequsites
#		This script uses a maven java structure however, feel free to change the directories to what you need them to be ./target for all your results
#		-Password and ID to access the project from snaplogic
#		-header.txt and footer.txt (both are used to form the HTML display, they also reference bootstrap by CDN)
#		-there is no windows version currently
# 		-dependency jq http://stedolan.github.io/jq/ for json parsing
# 		<replace Curl Command with username and password, project, company, guid
#		-Has only been tested on linux
#
# by Den Fong/Trevor Keppel-Jones Jan 30-2015
# 
##################################################################################################
#Variables for script to use directories
jq=./src/main/scripts/jq
sourcef=./src/main/config/source
SLP=./src/main/config/source/slp
file=./src/main/config/source/files
Act=./src/main/config/source/accounts
task=./src/main/config/source/task
logfile=./target/site/projectparse.html
snapversion=./target/site/snapversion.txt
summary=./target/site/snapsummary.htm
count=$($jq ".entries | length" $sourcef/export.json)
header=./src/main/resources/header.txt
footer=./src/main/resources/footer.txt

#retrieve export of project, unzip and cleans up files, uncomment commands curl and unzip command once you have values in there.
#curl -u <username@xxxx.com:password> -o ./src/main/config/source/export.gz https://elastic.snaplogic.com/api/2/<company guid>/rest/project/export/<company>/projects/<project name>
#unzip $sourcef/export.gz -d $sourcef/export
#mv $sourcef/export/export.json $sourcef/export.json
#rm -r $sourcef/export
#rm $sourcef/export.gz

cat /dev/null > $summary

#counters for spliting of files
counter=0
pipelines=0
accounts=0
tasks=0
files=0
timestamp=$(date +%Y-%m-%d_%H:%M:%S)
dateprefix=$(date +%Y-%m-%d)
br="</br>"

#check directories
if [ ! -d $SLP ] ; then 
	mkdir -p $SLP
fi

if [ ! -d $file ] ; then 
	mkdir -p $file
fi

if [ ! -d $task ] ; then 
	mkdir -p $task
fi

if [ ! -e $logfile ] ; then 
        touch $logfile
	else rm -r $logfile
fi

echo -e "$timestamp - Starting Project Parser $br" >> $logfile
echo -e "$timestamp - Reading $sourcef/export.json $br" >> $logfile


#loop through snapfile
while [[ $counter -lt $count ]]
do
	type=$($jq ".entries[$counter].class_id" $sourcef/export.json | tr -d '\"')
	slp=".entries[$counter].property_map.info.label[]"
	text=".entries[$counter]"
	tsk=".entries[$counter].job_name"
	snapv=".entries[$counter].snap_map[].class_fqid"
	pipename=".entries[$counter].property_map.info.label.value"
	pipeauthor=".entries[$counter].property_map.info.author.value"
	

#write pipeline
if [ "$type" == "com-snaplogic-pipeline" ]; then 
	((pipelines++))
	x=$($jq $slp $sourcef/export.json | tr ' ' '_' | tr -d '\"')
	echo -e "<tr><td>" >> $snapversion
	echo -e "<li>Pipename: " $($jq -c -M $pipename $sourcef/export.json) >> $snapversion
	echo -e "<li>Author: " $($jq -c -M $pipeauthor $sourcef/export.json) >> $snapversion
	echo -e "<li>Snaps Used: " $($jq -c -M $snapv $sourcef/export.json) >> $snapversion
	echo -e "</td></tr>" >> $snapversion

#write files
elif [[ $type == "com-snaplogic-file" ]]; then
	((files++))
	x=$($jq -c -M $text.file_name $sourcef/export.json | tr ' ' '_' | tr -d '\"')
	$jq -c -M $text $sourcef/export.json > $file/$x

#write tasks
else
	((tasks++))
	x=$($jq $tsk $sourcef/export.json | tr ' ' '_' | tr -d '\"')
	$jq -c -M $text $sourcef/export.json > $task/$x.tsk
fi
echo processing $counter $x object
((counter++))

done

#Create summary report
echo -e "<tr><td>Tasks $tasks </td><tr><td> Files $files </td></tr><tr><td> Pipelines $pipelines </td></tr><tr><td> Total $counter </td></tr>" >> $logfile
cat $header $logfile $snapversion $footer >> $summary
rm $logfile
rm $snapversion