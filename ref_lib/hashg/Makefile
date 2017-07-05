
SHELL	= /bin/sh
CC		= gcc
AR		= ar
RM		= /bin/rm
MV		= mv
DEPEND	= makedepend
LINT	= lint

TOP_BIN	= ../../BIN
TAF_BIN	= /tafapp/BIN
TOP_LIB	= ../../LIB
LIBRARY = -L./

INCLUDES= -I.
DEFINES = -DPRINT

# GI_INTERFACE
DEBUG   = -g3 -Wall -DTEST #-DDEBUG
TARGET	= hashg

# for S4000
M_FLAG	= 
CFLAGS	= $(OPTIMIZE) $(INCLUDES) $(DEFINES) $(DEBUG) $(M_FLAG)
SRCS	= hash.c

OBJS	= $(SRCS:.c=.o)

LIBS    = $(LIBRARY) -lSTGhashg

MAKEFILE= Makefile

#
#-----------------------------------------------------------
#

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


all: $(TARGET)

#$(SRCS):
#	$(GET) -s $@

$(TARGET): $(OBJS)
	cd ../..
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LIBS) $(LIBRARY) $(LDFLAGS)
	#cp $(TARGET) $(TOP_BIN)

lint:
	lint $(INCLUDES) $(CFLAGS) -h -v -a -u -x -m $(SRCS)

depend: $(SRCS)
	$(DEPEND) -o.o -f $(MAKEFILE) -- $(INCLUDES) -- $(SRCS)

install:
	cp $(TARGET) $(TAF_BIN)

doc:
	doxygen

clean:
	/bin/rm -rf *.o $(TARGET) $(TARGET2) core* TEST_RESULT*.TXT HASHG

# DO NOT DELETE THIS LINE -- make depend depends on it.
