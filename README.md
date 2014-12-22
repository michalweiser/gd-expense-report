Expense report helper
=====================

This tool provides basic PDF helper
for GD expenses report.

DEPENDENCIES:
=============
qpdf
pdftk

HOW TO:
=======
* write your login to creds file, ex. mwe
* run ./expense.sh
* it will create directory structure for current monthi, ex. 2014-12
* script will print directory path where you should copy all your expense PDFs, ex. 2014-12/sources
* run ./expense.sh again
* check your month directory, month expense report will be placed here, ex. 2014-12/mwe-expense-report-2014-12.pdf
