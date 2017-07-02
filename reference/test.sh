#!/bin/sh
#
# $Id: test.sh,v 1.6 2006/11/10 06:01:38 cjlee Exp $
#

export LANG=C
rm -rf TEST
mkdir TEST
cd TEST

cvs co memg
cd memg
cp -f ../../* .
../../structg.pl ./memg.stg OUTPUT
echo $?
cd OUTPUT
make
if(test $? != 0)
then
	echo "ERROR memg"
	exit
fi
cd ../..

cvs co hashg/hashg.stg
cd hashg
cp -f ../../* .
../../structg.pl ./hashg.stg  OUTPUT
echo $?
cd OUTPUT
make
if(test $? != 0)
then
	echo "ERROR hashg"
	exit
fi
cd ../..


cvs co hasho/hasho.stg
cd hasho
cp -f ../../* .
../../structg.pl ./hasho.stg OUTPUT
echo $?
cd OUTPUT
make
if(test $? != 0)
then
	echo "ERROR hasho"
	exit
fi
cd ../..

cvs co timerN/timerN.stg
cd timerN
cp -f ../../* .
../../structg.pl ./timerN.stg  OUTPUT
echo $?
cd OUTPUT
make
if(test $? != 0)
then
	echo "ERROR timerN"
	exit
fi
cd ../..
  
cvs co mems/mems.stg
cd timerN
cp -f ../../* .
../../structg.pl ./mems.stg  OUTPUT
echo $?
cd OUTPUT
make
if(test $? != 0)
then
	echo "ERROR timerN"
	exit
fi
cd ../..
  
cvs co nifo/nifo.stg
cd timerN
cp -f ../../* .
../../structg.pl ./nifo.stg  OUTPUT
echo $?
cd OUTPUT
make
if(test $? != 0)
then
	echo "ERROR timerN"
	exit
fi
cd ../..
  
  
echo "SUCCESS ALL"

#   
# $Log: test.sh,v $
# Revision 1.6  2006/11/10 06:01:38  cjlee
# clex.stc
#
# Revision 1.5  2006/05/29 05:15:22  cjlee
# *** empty log message ***
#
# Revision 1.4  2006/05/25 06:30:35  cjlee
# logtest
#
# Revision 1.3  2006/05/25 06:29:41  cjlee
# *** empty log message ***
#
#
