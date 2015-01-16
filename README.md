Expense report helper
=====================

This tool provides basic PDF helper
for GD expenses report.

DEPENDENCIES:
=============
* qpdf
* pdftk
* pdftotext (MAC - brew install poppler)


USAGE:
======
* -a automated walkthrough
* -e edit online document
* -c create directory structure for current month
* -h list help
* -s send expense report
* no param -> help

HOW TO:
=======
* write your **login** to creds file, ex. michal.weiser
* run ./expense.sh -a
* follow instructions

TODO:
=====
* add GDocs API fro automatic document updates
* enable mail sending
