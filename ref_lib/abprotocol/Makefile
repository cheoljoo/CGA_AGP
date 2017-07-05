#
# $Id: Makefile,v 1.9 2007/02/09 10:51:58 yhshin Exp $
#

CC		= gcc
AR		= ar
RM		= /bin/rm
MV		= mv
CP		= cp

INC			= -I. -I../dlinkUtil
LIB_PATH	= -L. -L../dlinkUtil

DEBUG	= -g3 -Wall
CFLAGS	= $(INC) $(DEBUG) 
CFLAGS_TEST	= $(INC) $(DEBUG) -DTEST

TARGET	= stg_lib
LIBS	= $(LIB_PATH) -lSTGsb_protocol_stg -lDlinkUtil

OBJS	= proto_print.o
SRCS	= proto_print.c

#
.SUFFIXES: .c .s .o .i .u
.s.o:
	$(CC) $(CFLAGS) -c $<
.c.s:
	$(CC) $(SFLAGS) -S $<
.c.o:
	$(CC) $(CFLAGS) -c $<
.c.u:
	$(CC) $(CFLAGS) -j $<
.c.i:
	$(CC) $(CFLAGS) -P $<


all: $(TARGET) test


$(TARGET) : 
	./configure
	cp *.a ../
	cp *.h ../

test : $(OBJS)
#	./configure
	$(CC) $(CFLAGS_TEST) -o proto_print $(SRCS) $(LIBS) 

clean: 
	/bin/rm -rf *.o proto_print *.a flat_sb_protocol_stg.h sb_protocol_stg.h ./structg

#  
#	$Log: Makefile,v $
#	Revision 1.9  2007/02/09 10:51:58  yhshin
#	*** empty log message ***
#	
#	Revision 1.8  2007/02/08 12:51:06  yhshin
#	*** empty log message ***
#	
#	Revision 1.7  2007/02/08 12:41:02  yhshin
#	test_abana을 proto_print로 바꿈
#	
#	Revision 1.6  2007/02/06 23:09:55  yhshin
#	lDlinkUt add
#	
#	Revision 1.5  2007/01/23 04:53:58  yhshin
#	all 시 test추가
#	
#	Revision 1.4  2007/01/18 01:43:23  yhshin
#	rename 적용
#	
#	Revision 1.3  2007/01/16 11:13:31  yhshin
#	stc 추가
#	
#	Revision 1.2  2006/06/28 04:18:31  yhshin
#	lSTGabprotocol_stg 추가
#	
#	Revision 1.1  2006/08/28 01:32:58  cjlee
#	INIT
#	 
#
