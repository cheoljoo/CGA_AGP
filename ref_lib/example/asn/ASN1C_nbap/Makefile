# makefile to build generated files

#include platform.mk
#%ASN-E-FILNOTFOU, File 'platform.mk' not found

ASN1C_PATH=/usr/local/asn1c-v583
include $(ASN1C_PATH)/c/platform.mk

# include directories
OSROOTDIR = $(ASN1C_PATH)
LIBDIR  = $(OSROOTDIR)/c/lib
RTSRCDIR = $(OSROOTDIR)/rtsrc
PERSRCDIR = $(OSROOTDIR)/rtpersrc
SRCDIR = .
HFILESDIR = .
HFILES = $(RTSRCDIR)/asn1type.h $(PERSRCDIR)/asn1per.h 
# compiler defs
CFLAGS = -c $(CVARS_) $(CFLAGS_) $(CBLDTYPE_) -D_TRACE
IPATHS = -I$(SRCDIR) -I$(OSROOTDIR) -I$(RTSRCDIR) -I$(PERSRCDIR) $(IPATHS_)
LINKOPT = $(LINKOPT_)

# run-time libraries
LIBS = $(LIBDIR)/libasn1per.a $(LIBDIR)/libasn1rt.a
LLIBS = -lasn1per -lasn1rt
LPATHS = $(LPPFX)$(LIBDIR) $(XMLLPATHS)

OBJECTS =  \
NBAP-PDU-Discriptions$(OBJ) \
NBAP-PDU-Contents$(OBJ) \
NBAP-IEs$(OBJ) \
NBAP-CommonDataTypes$(OBJ) \
NBAP-Constants$(OBJ) \
NBAP-Containers$(OBJ)

ENCOBJECTS =  \
NBAP-PDU-DiscriptionsEnc$(OBJ) \
NBAP-PDU-ContentsEnc$(OBJ) \
NBAP-IEsEnc$(OBJ) \
NBAP-CommonDataTypesEnc$(OBJ) \
NBAP-ConstantsEnc$(OBJ) \
NBAP-ContainersEnc$(OBJ)

DECOBJECTS =  \
NBAP-PDU-DiscriptionsDec$(OBJ) \
NBAP-PDU-ContentsDec$(OBJ) \
NBAP-IEsDec$(OBJ) \
NBAP-CommonDataTypesDec$(OBJ) \
NBAP-ConstantsDec$(OBJ) \
NBAP-ContainersDec$(OBJ)

PRTOBJECTS =  \
NBAP-PDU-DiscriptionsPrint$(OBJ) \
NBAP-PDU-ContentsPrint$(OBJ) \
NBAP-IEsPrint$(OBJ) \
NBAP-CommonDataTypesPrint$(OBJ) \
NBAP-ConstantsPrint$(OBJ) \
NBAP-ContainersPrint$(OBJ)

TESTOBJECTS =  \
NBAP-PDU-DiscriptionsTest$(OBJ) \
NBAP-PDU-ContentsTest$(OBJ) \
NBAP-IEsTest$(OBJ) \
NBAP-CommonDataTypesTest$(OBJ) \
NBAP-ConstantsTest$(OBJ) \
NBAP-ContainersTest$(OBJ)


# ----------------------------------------------------------------

OBJS = $(OBJECTS) $(ENCOBJECTS) $(DECOBJECTS) $(TESTOBJECTS) $(PRTOBJECTS)

TARGET = libAsn1c_nbap32.a
all: $(TARGET) $(TESTOBJECTS) writer$(EXE) reader$(EXE)

$(TARGET): $(OBJS) $(LIBS) $(HFILES)
	ar rcs $(TARGET) $(OBJS)

WRITEROBJ = writer$(OBJ) $(OBJECTS) $(ENCOBJECTS) $(TESTOBJECTS) $(PRTOBJECTS)

writer$(EXE) : $(WRITEROBJ) $(LIBS)
	$(LINK) $(WRITEROBJ) $(LINKOPT) $(LPATHS) $(LLIBS)

READEROBJ = reader$(OBJ) $(OBJECTS) $(DECOBJECTS) \
$(PRTOBJECTS)

reader$(EXE) : $(READEROBJ) $(LIBS)
	$(LINK) $(READEROBJ) $(LINKOPT) $(LPATHS) $(LLIBS)

RWHFILES = $(HFILESDIR)/NBAP-PDU-Discriptions.h \
$(HFILESDIR)/NBAP-PDU-Contents.h $(HFILESDIR)/NBAP-IEs.h $(HFILESDIR)/NBAP-CommonDataTypes.h \
$(HFILESDIR)/NBAP-Constants.h $(HFILESDIR)/NBAP-Containers.h $(HFILESDIR)/rtkey.h \
$(HFILES)

writer$(OBJ) : writer.c $(RWHFILES)
reader$(OBJ) : reader.c $(RWHFILES)

# ----------------------------------------------------------------


clean:
	$(RM) *$(OBJ)
	$(RM) *~
