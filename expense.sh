#!/bin/bash

#author: Michal Weiser
#mail: michal.weiser@gmail.com
#licese: CC

MONTH=`date "+%Y-%m"`
SOURCES=`echo $MONTH/sources`
DECRYPTED=`echo $SOURCES/decrypted`
REPORTNAME="expense-report"
USER=`cat creds`
REPORT=`echo $MONTH/$USER-$REPORTNAME-$MONTH.pdf`
PDFS_NUMBER=`ls $SOURCES | egrep ".pdf$" | wc -l`

echo "EXPENSE REPORT TOOL"
echo ""

if `test ! -d $MONTH`
then
	echo "Creating directory for this month..."
	mkdir $MONTH
	mkdir $SOURCES
	echo "Done"
	echo ""
	echo "Please add all your PDF reports to $SOURCES"
	exit 1
fi

echo "Creating" $USER "expenses report for" $MONTH

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

echo "Done"

