
#include "L7.h"



SHELL 	= /bin/sh

CC 		= gcc
AR 		= ar 
RM 		= /bin/rm
MV 		= /bin/mv
DEPEND	= makedepend
LINT 	= lint
INSTALL = install

TOP_BIN = 

INCLUDES=  -I./ -I../ -I../../ -L../../
DEFINES = 
OPTIMIZE= -O

ifeq ($(STG_DEBUG),)
DEBUG   = -g3  -lSTGBit
#DEBUG   = -g3  -lSTGflow -lSTGBit
else
DEBUG   = -g3 -DDEBUG
endif

CFLAGS 	= $(OPTIMIZE) $(INCLUDES) $(DEFINES) $(DEBUG) 
SFLAGS 	= $(INCLUDES) $(DEFINES) $(DEBUG)
DEPOPTS = $(INCLUDES) $(DEFINES) 

HDRS 	=  flat_flow.h flow.h

SRCS 	=  LOG_member_Get_func.c Set_Stat_Accumulate.c Set_Stat_Once.c

TARGET 	= libSTGflow.a

OBJS 	= $(SRCS:.c=.o)

#
#-----------------------------------------------------------
#

#
.SUFFIXES: .c .s s.o c.o p.o q.o .i .u .H
.s.o:
	$(CC) -c $< $(CLAGS)
.c.s:
	$(CC) $(SFLAGS) -S $<
.c.u:
	$(CC) $(CFLAGS) -j $<
.c.i:
	$(CC) $(CFLAGS) -P $<

all: $(TARGET) $(HADS)

$(TARGET): $(SRCS) $(HDRS) $(OBJS) 
	$(RM) -f $@
	$(AR) clq $@ $(OBJS)
	$(AR) ts $@ 
	$(MV) $@ ../../
	$(MV) *.h ../../


clean:
	$(RM) -f *.s *.u *.o *.i core* $(TARGET) bit conf flow resp4 get4 body lbody lex.*

depend: $(SRCS)
	$(DEPEND) -o.o -f Makefile -- $(DEPOPTS) -- $(SRCS)

lint:
	$(LINT) $(INCLUDES) -h -v -a -u -x -m $(SRCS)

flow:
	$(CC) $(CFLAGS) flow.c -o flow -lSTGflow


bit : bit.c ../../libSTGBit.a
	cc -O -I./ -I../ -I../../ -L../../  -g3  bit.c -o bit -lSTGBit 

conf : conf.c ../../libSTGconf.a
	cc -O -I./ -I../ -I../../ -L../../  -g3  conf.c -o conf -lSTGconf 

resp4 : resp4.c ../../libSTGaqua.a
	cc -O -I./ -I../ -I../../ -L../../  -g3  resp4.c -o resp4 -lSTGaqua 

get4 : get4.c ../../libSTGaqua.a
	cc -O -I./ -I../ -I../../ -L../../  -g3  get4.c -o get4 -lSTGaqua 
	
body1 : body1.c ../../libSTGaqua.a 
	cc -O -I./ -I../ -I../../ -L../../  -g3  body1.c -o body1 -lSTGaqua 

body : body.c ../../libSTGaqua.a 
	cc -O -I./ -I../ -I../../ -L../../  -g3  body.c -o body -lSTGaqua 

lbody : lbody.c ../../libSTGaqua.a bodyURL.l httpURL.l
	flex -PbodyURL bodyURL.l
	flex -PhttpURL httpURL.l
	cc -O -c lex.bodyURL.c  -I./ -I../ -I../../
	cc -O -c lex.httpURL.c  -I./ -I../ -I../../
	cc -O -I./ -I../ -I../../ -L../../    lbody.c -o lbody -lSTGaqua lex.bodyURL.o lex.httpURL.o

BODY : BODY.l
	flex -PBODY  BODY.l
	cc -c lex.BODY.c  -I./ -I../ -I../../
	cc -o BODY lex.BODY.o -lfl -lSTGaqua -L../../

LogKunReqHdr :
	flex -PLogKunReqHdr  LOG_KUN_REQ_HDR.l
	cc -c lex.LogKunReqHdr.c -DTEST
	cc -o LogKunReqHdr lex.LogKunReqHdr.o -lfl -lSTGL7 -L../../../



LogMERespHdr :
	flex -PLogMERespHdr  LOG_ME_RESP_HDR.l
	cc -c lex.LogMERespHdr.c -DTEST
	cc -o LogMERespHdr lex.LogMERespHdr.o -lfl -lSTGL7 -L../../../



LogKunRespHdr :
	flex -PLogKunRespHdr  LOG_KUN_RESP_HDR.l
	cc -c lex.LogKunRespHdr.c -DTEST
	cc -o LogKunRespHdr lex.LogKunRespHdr.o -lfl -lSTGL7 -L../../../



echo:

	echo "make LogMEReqHdr"  

	echo "make LogKunReqHdr"  

	echo "make LogMERespHdr"  

	echo "make LogKunRespHdr"  
	


# DO NOT DELETE THIS LINE -- make depend depends on it.


#
# $Log: Makefile,v $
# Revision 1.13  2006/10/23 08:27:07  cjlee
# *** empty log message ***
#
# Revision 1.12  2006/10/19 06:43:14  cjlee
# *** empty log message ***
#
# Revision 1.11  2006/10/11 09:24:56  cjlee
# *** empty log message ***
#
# Revision 1.10  2006/10/11 05:08:34  cjlee
# *** empty log message ***
#
# Revision 1.9  2006/10/11 05:06:17  cjlee
# *** empty log message ***
#
# Revision 1.8  2006/10/11 05:05:35  cjlee
# lbody 추가
#
# Revision 1.7  2006/10/09 01:35:59  cjlee
# *** empty log message ***
#
# Revision 1.6  2006/10/09 01:17:05  cjlee
# *** empty log message ***
#
# Revision 1.5  2006/09/20 07:34:07  cjlee
# BrowserInfo 분할 추가 : ACTION함수 추가
#
# Revision 1.4  2006/09/19 03:41:35  cjlee
# WIPI추가
#
# Revision 1.3  2006/09/08 05:28:07  cjlee
# Configuration File 처리
#
# Revision 1.2  2006/09/08 00:01:05  cjlee
# no message
#
# Revision 1.1  2006/08/29 04:06:30  cjlee
# BIT 처리 완료 : compile 완료
#
# Revision 1.2  2006/03/19 01:06:28  yhshin
# pc용과 일반용으로 구분
#
# Revision 1.1  2006/03/19 00:13:28  yhshin
# structg lib add
#
#
