#!/bin/bash
##################################################################################################
# Snap Check
# This script will:
#   1) read in a file that contains a list of snaps and stores the values in an array
#   2) iterate through a folder containing slp files and identify the pipelines that contain each snap
#   3) output the results to a file (yyyy-mm-dd_snapname_results.htm)
#	4) output a summary html file that will list the number of snaps for a project
#
#	Prerequsites
#		This script uses a maven java structure however, feel free to change the directories to what you need them to be ./target for all your results
#		-required a text file that contains the snaps being upgraded (snapchecks.txt)
#		-header.txt and footer.txt (both are used to form the HTML display, they also reference bootstrap by CDN)
#		-there is no windows version currently
# by Den Fong/Trevor Keppel-Jones Jan 30-2015
##################################################################################################
#variables
rootdir=./target/snapresults
sourcefiles=./src/main/config/source/slp
results=./target/snapresults
logfile=./target/snapresults/snapcheck.html
#required for list of snaps being checked
snaplist=./src/main/config/snapchecklist.txt
#files for html file
header=./src/main/resources/header.txt
footer=./src/main/resources/footer.txt
number=0

if [ ! -d $rootdir ] ; then 
	mkdir -p $rootdir
fi

if [ ! -e $snaplist ] ; then 
    
		echo -e "no snaps to check ensure snaplist isn't empty" $snaplist
		exit
fi

if [ ! -e $sourcefiles ] ; then 
	echo -e "no snaps to check ensure snaplist isn't empty" $sourcefiles

fi

if [ ! -e $logfile ] ; then 
        touch $logfile
	else
	rm $results/*.*
fi

mkdir -p $results
timestamp=$(date +%Y-%m-%d_%H:%M:%S)
dateprefix=$(date +%Y-%m-%d)
#mkdir -p $results/$dateprefix

echo -e "--------------------------------------------------</br>" >> $logfile
echo -e "$timestamp - Starting snapcheck</br>" >> $logfile
echo -e "$timestamp - Results will be stored in $results/$dateprefix</br>" >> $logfile
echo -e "$timestamp - Results will be stored in $results/$dateprefix" >> "$dateprefix"_summary-snapcounts.txt

##################################################################################################
# Read in the list of snaps from the snaplist file
# writes snap html files for easier reading

OIFS=$IFS
IFS=$'\n'
snaparray=($(<$snaplist))
IFS=$OIFS

for snap in "${snaparray[@]}";
do
    timestamp=$(date +%Y-%m-%d_%H:%M:%S)
	number=0
	echo -e "$timestamp - Checking $snap</br>" >> $logfile
	grep -l -r $snap $sourcefiles >> $results/"$dateprefix"_"$snap".txt
	if [ ! -s $results/"$dateprefix"_"$snap".txt ]
	then
		rm $results/"$dateprefix"_"$snap".txt
	else 
		number=$(wc -l $results/"$dateprefix"_"$snap".txt)
		echo $number >> $results/"$dateprefix"_summary-snapcounts.htm
		sed -i 's/.*src\/main\/config\/source\/slp\//<tr><td>Pipeline - /' $results/"$dateprefix"_"$snap".txt
		sed -i 's/slp/slp<\/td><\/tr>/' $results/"$dateprefix"_"$snap".txt
		echo $snap "checked</td></tr>" >> $results/"$dateprefix"_"$snap".text
		cat $header $results/"$dateprefix"_"$snap".text $results/"$dateprefix"_"$snap".txt $footer > $results/"$dateprefix"_"$snap".htm   
		rm $results/"$dateprefix"_"$snap".txt
		rm $results/"$dateprefix"_"$snap".text
	fi
	echo "checking" $snap
done

#gets summary info for a summary page
sed -i 's/^[ \t]*/<tr><td>/' $results/"$dateprefix"_summary-snapcounts.htm
sed -i 's/.txt/<\/a><\/tr><\/td>/' $results/"$dateprefix"_summary-snapcounts.htm
cat $header $results/"$dateprefix"_summary-snapcounts.htm $footer > $results/"$dateprefix"_summary-snapcounts.html
rm $results/"$dateprefix"_summary-snapcounts.htm
sed -i 's/.\/target\/snapresults\//<\/td><td> /' $results/"$dateprefix"_summary-snapcounts.html
