# makefile to build generated files

ASN1C_PATH = /usr/local
include $(ASN1C_PATH)/asn1c-v583/c/platform.mk

# include directories
OSROOTDIR = $(ASN1C_PATH)/asn1c-v583
LIBDIR  = $(OSROOTDIR)/c/lib
RTSRCDIR = $(OSROOTDIR)/rtsrc
PERSRCDIR = $(OSROOTDIR)/rtpersrc
HFILESDIR = .
HFILES = $(RTSRCDIR)/asn1type.h $(PERSRCDIR)/asn1per.h 
# compiler defs
CFLAGS = -c $(CVARS_) $(CFLAGS_) $(CBLDTYPE_) -D_TRACE
IPATHS = -I. -I$(OSROOTDIR) -I$(RTSRCDIR) -I$(PERSRCDIR) $(IPATHS_) -I../../INC
LINKOPT = $(LINKOPT_)

# run-time libraries
LIBS = $(LIBDIR)/libasn1per.a $(LIBDIR)/libasn1rt.a
LLIBS = -lranap -lasn1per -lasn1rt -lasn1lib -lSTGcommon_stg -lhashg -lSTGhashg -lLogUtil
LPATHS = $(LPPFX)$(LIBDIR) $(XMLLPATHS)

OBJECTS =  \
ranap$(OBJ)

# ------------------------------------------------------
COM_LIB	= ../../../LIB
OBJS = $(OBJECTS) 

TARGET	= libranap.a

all : $(TARGET) test
$(TARGET): $(OBJS) $(LIBS) $(HFILES)
	ar rcs $(TARGET) $(OBJS)
	cp $(TARGET) $(COM_LIB)
# ------------------------------------------------------

# .c -> .obj rules
# common file rules
ranap$(OBJ) : ranap.c 
	$(CC) $(CFLAGS) -c $(IPATHS) ranap.c

test: test_ranap.o test_tree.o
	$(CC) $(IPATHS) -DDEBUG -g3 -Wall -static -L. -L$(LIBDIR) -L../../../LIB -o test_ranap test_ranap.o $(LLIBS)
	$(CC) $(IPATHS) -DDEBUG -g3 -Wall -static -L. -L$(LIBDIR) -L../../../LIB -o test_tree test_tree.o $(LLIBS)

clean:
	$(RM) *$(OBJ)
	$(RM) $(TARGET)
	$(RM) *~
	$(RM) test_ranap.o test_ranap
