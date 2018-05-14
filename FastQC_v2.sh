#!/bin/bash

#Checking whether the raw files have been placed in the correct directory

mkdir -v output

#Running FastQC initial check

echo "Please place your raw data into your home's input directory. I.e., ~/input/"
echo ""
echo "Have you placed them into the input directory yet? (y/n)"
echo ""
read yno

case "$yno" in
[yY]|[yY][eE][sS])echo "FastQC will commence";
for a in $(ls input/*.fq.gz)
do
fastqc ${a} --threads 20 --outdir ./output/
done
	;;
[nN]|[nN][oO]) echo "Please make sure files are in proper directory prior executing script";
exit 1
	;;
*) echo "You have keyed in an invalid input, please try again"
exit 1
;;
esac

echo ""
echo "Quality check reports have been generated. Please view them in the output directory"
echo ""
