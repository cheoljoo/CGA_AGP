#
#	$Id: Makefile,v 1.3 2007/02/09 10:51:01 yhshin Exp $
#

#--------------------- Makefile which have no SubDir ---------------------
SHELL  		= /bin/sh
SRCDIR 		= .
DSTDIR 		= ../../lib

CC = gcc

TARGET		= all

SUBDIRS		= 

MAKEDEPEND 	= makedepend

STD_INCDIR 	= 
STD_LIBDIR	=

# include directories
LOC_INCDIR	= ../../include 
LOC_LIBDIR	=

GBL_INCDIR	=
GBL_LIBDIR	=

INC_DIRS	= -I. -I$(LOC_INCDIR)  -I$(RTSRCDIR) -I$(PERSRCDIR) 
LIB_DIRS	=

#-------------------- Source & Objects & Libraries------------------------
PROGRAMS 	= libDlinkUtil.a
LIBS 		= 

DEFINES 	= -DDEBUG -g3 -Wall

CFLAGS 		= $(DEFINES) $(INC_DIRS)
CPPFLAGS	= 
LDOPTIONS	=

LIBRARIES	=

DEPLIBS1	= 

SRCS1		= dlink.c param_node.c protocol_node.c proot.c proot_print.c
OBJS1		= $(SRCS1:.c=.o)
HDRS1		= 


DEPLIBS2	= 
SRCS2		= 
OBJS2		=
HDRS2		=

#-------------------------------------------------------------------------

all:: $(PROGRAMS) 

$(PROGRAMS): $(OBJS1) $(HDRS1)
	ar rcu $@ $(OBJS1)
	cp *.a ../
	cp *.h ../

clean::
	rm -f $(PROGRAMS) $(OBJS1) $(OBJS2)

install:: $(PROGRAMS) 
	@for i in $(PROGRAMS); do \
		echo Installing $$i in $(DSTDIR); \
		cp $$i $(DSTDIR); \
	done

#
#	$Log: Makefile,v $
#	Revision 1.3  2007/02/09 10:51:01  yhshin
#	cp Ãß°¡
#	
#	Revision 1.2  2007/02/09 00:19:03  yhshin
#	*** empty log message ***
#	
#	Revision 1.1  2007/02/06 23:20:00  yhshin
#	dlink util
#	
#	Revision 1.1  2006/11/09 01:30:33  tjryu
#	RANAP decoding utility added
#	
#
