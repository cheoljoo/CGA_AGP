#!/bin/sh

rm -rf tags
echo 'find . -name "*.[ch]" > aa'
echo 'ctags -L cout'
find . -name "*.[chl]" > cout
find . -name "*.stc" >> cout
find . -name "*.stcI" >> cout
find . -name "*.stg" >> cout
find . -name "*.stgL" >> cout
find . -name "*.pstg" >> cout
find . -name "*.pl" >> cout
find . -name "*.upr" >> cout
cat cout | grep -v "CVS" > cout2
ctags -L cout2
#cscope -i cout2 -p 4
