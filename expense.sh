#!/bin/bash

#author: Michal Weiser @michal_weiser
#mail: michal.weiser@gmail.com, michal.weiser@gooddata.com
#licese: CC

NAME="GD Expense report"
VERSION="0.01 (alpha)"

MONTH=`date "+%Y-%m"`
SOURCES=`echo $MONTH/sources`
DECRYPTED=`echo $SOURCES/decrypted`
REPORTNAME="expense-report"
USER=`cat creds | sed -n '1 p'`
DOCKEY=`cat creds | sed -n '2 p'`
REPORT=`echo $MONTH/$USER-$REPORTNAME-$MONTH.pdf`

function createMonth {
	if `test ! -d $MONTH`
	then
		echo "Creating directory for current month..."
		mkdir $MONTH
		mkdir $SOURCES
		echo "Done"
		echo ""
		echo "Now, please add all your PDF reports to $SOURCES"
		exit 1
	else
		echo "Current month directory already exists"
		echo "Please add all your PDF reports to $SOURCES"
	fi
}

function processDocuments {
	echo "Creating" $USER "expenses report PDF file for" $MONTH

	PDFS_NUMBER=`ls $SOURCES | egrep ".pdf$" | wc -l`

	if [[ $PDFS_NUMBER -gt 0 ]];
		then
		echo "Decrypting PDF files"

		if `test -d $DECRYPTED`
			then
			rm -r $DECRYPTED
		fi

		mkdir $DECRYPTED

		for FILE in `ls $SOURCES | egrep ".pdf$"`
		do
			qpdf --decrypt $SOURCES/$FILE $DECRYPTED/$FILE
			pdftotext $SOURCES/$FILE
			filename=`expr ${#FILE} - 4`
			textfile="${FILE:0:$filename}.txt"
			parse $SOURCES/$textfile
		done

		echo "Merging files"
		pdftk $DECRYPTED/*.pdf cat output $REPORT

		rm -r $DECRYPTED

		echo ""
		echo "Report file:" $REPORT
		echo ""
	else
		echo "No files to process"
	fi
}

function sendviamail {
	subject="Expense report - $MONTH"
	from="$USER@gooddata.com"
	recipients="expenses-cz@gooddata.com"
	mail="subject:$subject\nfrom:$from\nExpense report $MONTH for $USER"
	echo -e $mail #| sendmail "$recipients"
}

function editdocument {
	echo "Redirecting to Google Docs"
	URL="https://docs.google.com/a/gooddata.com/spreadsheet/ccc?key=$DOCKEY"
	open $URL
}

function automated {
	headmessage
	createMonth
	read -p "and press any key to continue... " -n1 -s
	processDocuments
	echo "Done"
}

## PARSERS ##

function parseDPMB {
	echo "parsing $1"
	filename=$1
	date=`head -n 1 $filename | sed "s/\([0-9]\{2\}\)\/\([0-9]\{2\}\)\/\([0-9]\{4\}\)/\2.\1.\3/g"`
	value=`egrep -A 2 Uhrazeno $filename | tail -n 1 | sed 's/ Kč//g'`
	printf "%s\tDPMB\t%d\n" "$date" $value
}

function parseDPP {
	echo "parsing $1"
	filename=$1
	date=`head -n 1 $filename | sed "s/\([0-9]\{2\}\)\/\([0-9]\{2\}\)\/\([0-9]\{4\}\)/\2.\1.\3/g"`
	value=`egrep -A 2 Uhrazeno $filename | tail -n 1 | sed 's/ Kč//g'`
	printf "%s\tDPP\t%d\n" "$date" $value
}

function parseCD {
	echo "parsing $1"
	filename=$1
	date=`grep "Datum vystavení/datum platby:" $filename | sed "s/Datum vystavení\/datum platby: \([0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{4\}\).*/\1/g"`
	value=`egrep -A 1 Celkem $filename | tail -n 1 | sed "s/ Kč//g"`
	printf "%s\tCD\t%d\n" "$date" $value
}

function parse {
	filename=$1
	isDPMB=`egrep -c "^DPMB, a\.s\.$" $filename`
	isDPP=`egrep -c "^DP hl\. m\. Prahy, a\.s\.$" $filename`
	isCD=`egrep -c "^Prodejce\: České dráhy, a\.s\..*$" $filename`

	if [[ $isCD -gt 0 ]];
		then
		parseCD $filename
	elif [[ $isDPMB -gt 0 ]];
		then
		parseDPMB $filename
	elif [[ $isDPP -gt 0 ]];
		then
		parseDPP $filename
	fi
}

## PARSERS ##

function headmessage {
	echo "$NAME v.$VERSION"
	echo ""
}

function helpmessage {
	echo "help"
}

while getopts ":acehst" opt; do
 	case $opt in
		a)
			headmessage
			automated
			exit;;
		c)
			headmessage
			createMonth
			exit;;
		e)
			headmessage
			editdocument
			exit;;
		h)
			headmessage
			helpmessage
			exit;;
		s)
			headmessage
			sendviamail
			exit;;
		\?) echo "Invalid option: -$OPTARG" >&2;;
 	esac
done

headmessage
helpmessage
exit

