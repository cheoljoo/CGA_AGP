# makefile to build generated files

include /usr/local/asn1c-v583/c/platform.mk

# include directories
OSROOTDIR = /usr/local/asn1c-v583
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
RANAP-PDU-Descriptions$(OBJ) \
RANAP-PDU-DescriptionsTable$(OBJ) \
RANAP-PDU-Contents$(OBJ) \
RANAP-PDU-ContentsTable$(OBJ) \
RANAP-IEs$(OBJ) \
RANAP-IEsTable$(OBJ) \
RANAP-CommonDataTypes$(OBJ) \
RANAP-Constants$(OBJ) \
RANAP-Containers$(OBJ)

ENCOBJECTS =  \
RANAP-PDU-DescriptionsEnc$(OBJ) \
RANAP-PDU-ContentsEnc$(OBJ) \
RANAP-IEsEnc$(OBJ) \
RANAP-CommonDataTypesEnc$(OBJ) \
RANAP-ConstantsEnc$(OBJ) \
RANAP-ContainersEnc$(OBJ)

DECOBJECTS =  \
RANAP-PDU-DescriptionsDec$(OBJ) \
RANAP-PDU-ContentsDec$(OBJ) \
RANAP-IEsDec$(OBJ) \
RANAP-CommonDataTypesDec$(OBJ) \
RANAP-ConstantsDec$(OBJ) \
RANAP-ContainersDec$(OBJ)

PRTOBJECTS =  \
ranap_prt$(OBJ)

TESTOBJECTS =  \
RANAP-PDU-DescriptionsTest$(OBJ) \
RANAP-PDU-ContentsTest$(OBJ) \
RANAP-IEsTest$(OBJ) \
RANAP-CommonDataTypesTest$(OBJ) \
RANAP-ConstantsTest$(OBJ) \
RANAP-ContainersTest$(OBJ)

all : $(OBJECTS) $(ENCOBJECTS) $(DECOBJECTS) $(PRTOBJECTS) \
$(TESTOBJECTS) writer$(EXE) reader$(EXE)

WRITEROBJ = writer$(OBJ) $(OBJECTS) $(ENCOBJECTS) $(TESTOBJECTS) $(PRTOBJECTS) \
 $(DECOBJECTS)

writer$(EXE) : $(WRITEROBJ) $(LIBS)
	$(LINK) $(WRITEROBJ) $(LINKOPT) $(LPATHS) $(LLIBS)

READEROBJ = reader$(OBJ) $(OBJECTS) $(DECOBJECTS)  $(ENCOBJECTS)\
$(PRTOBJECTS)

reader$(EXE) : $(READEROBJ) $(LIBS)
	$(LINK) $(READEROBJ) $(LINKOPT) $(LPATHS) $(LLIBS)

RWHFILES = $(HFILESDIR)/RANAP-PDU-Descriptions.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsClass.h $(HFILESDIR)/RANAP-PDU-DescriptionsTable.h \
$(HFILESDIR)/RANAP-PDU-Contents.h $(HFILESDIR)/RANAP-PDU-ContentsTable.h \
$(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/RANAP-Constants.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/rtkey.h \
$(HFILES)

writer$(OBJ) : writer.c $(RWHFILES)
reader$(OBJ) : reader.c $(RWHFILES)

# .c -> .obj rules
# common file rules
RANAP-PDU-Descriptions$(OBJ) : $(SRCDIR)/RANAP-PDU-Descriptions.c \
$(HFILESDIR)/RANAP-PDU-Descriptions.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsClass.h $(HFILESDIR)/RANAP-PDU-DescriptionsTable.h \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-PDU-Descriptions.c

RANAP-PDU-DescriptionsTable$(OBJ) : $(SRCDIR)/RANAP-PDU-DescriptionsTable.c \
$(HFILESDIR)/RANAP-PDU-Descriptions.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsClass.h $(HFILESDIR)/RANAP-PDU-DescriptionsTable.h \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-PDU-DescriptionsTable.c

# decode file rules
RANAP-PDU-DescriptionsDec$(OBJ) : $(SRCDIR)/RANAP-PDU-DescriptionsDec.c \
$(HFILESDIR)/RANAP-PDU-Descriptions.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsClass.h $(HFILESDIR)/RANAP-PDU-DescriptionsTable.h \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-PDU-DescriptionsDec.c

# encode file rules
RANAP-PDU-DescriptionsEnc$(OBJ) : $(SRCDIR)/RANAP-PDU-DescriptionsEnc.c \
$(HFILESDIR)/RANAP-PDU-Descriptions.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsClass.h $(HFILESDIR)/RANAP-PDU-DescriptionsTable.h \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-PDU-DescriptionsEnc.c

# print file rules
ranap_prt$(OBJ) : $(SRCDIR)/ranap_prt.c \
$(HFILESDIR)/RANAP-PDU-Descriptions.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsClass.h $(HFILESDIR)/RANAP-PDU-DescriptionsTable.h \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/ranap_prt.c

# test file rules
RANAP-PDU-DescriptionsTest$(OBJ) : $(SRCDIR)/RANAP-PDU-DescriptionsTest.c \
$(HFILESDIR)/RANAP-PDU-Descriptions.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsClass.h $(HFILESDIR)/RANAP-PDU-DescriptionsTable.h \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-PDU-DescriptionsTest.c

# reader file rules
reader$(OBJ) : $(SRCDIR)/reader.c \
$(HFILESDIR)/RANAP-PDU-Descriptions.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsClass.h $(HFILESDIR)/RANAP-PDU-DescriptionsTable.h \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)

# writer file rules
writer$(OBJ) : $(SRCDIR)/writer.c \
$(HFILESDIR)/RANAP-PDU-Descriptions.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsClass.h $(HFILESDIR)/RANAP-PDU-DescriptionsTable.h \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)

# common file rules
RANAP-PDU-Contents$(OBJ) : $(SRCDIR)/RANAP-PDU-Contents.c \
$(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-PDU-Contents.c

RANAP-PDU-ContentsTable$(OBJ) : $(SRCDIR)/RANAP-PDU-ContentsTable.c \
$(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-PDU-ContentsTable.c

# decode file rules
RANAP-PDU-ContentsDec$(OBJ) : $(SRCDIR)/RANAP-PDU-ContentsDec.c \
$(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-PDU-ContentsDec.c

# encode file rules
RANAP-PDU-ContentsEnc$(OBJ) : $(SRCDIR)/RANAP-PDU-ContentsEnc.c \
$(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-PDU-ContentsEnc.c

# test file rules
RANAP-PDU-ContentsTest$(OBJ) : $(SRCDIR)/RANAP-PDU-ContentsTest.c \
$(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-PDU-ContentsTest.c

# reader file rules
reader$(OBJ) : $(SRCDIR)/reader.c \
$(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)

# writer file rules
writer$(OBJ) : $(SRCDIR)/writer.c \
$(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h $(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)

# common file rules
RANAP-IEs$(OBJ) : $(SRCDIR)/RANAP-IEs.c \
$(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-IEs.c

RANAP-IEsTable$(OBJ) : $(SRCDIR)/RANAP-IEsTable.c \
$(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-IEsTable.c

# decode file rules
RANAP-IEsDec$(OBJ) : $(SRCDIR)/RANAP-IEsDec.c \
$(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-IEsDec.c

# encode file rules
RANAP-IEsEnc$(OBJ) : $(SRCDIR)/RANAP-IEsEnc.c \
$(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-IEsEnc.c

# test file rules
RANAP-IEsTest$(OBJ) : $(SRCDIR)/RANAP-IEsTest.c \
$(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-IEsTest.c

# reader file rules
reader$(OBJ) : $(SRCDIR)/reader.c \
$(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/rtkey.h \
$(HFILES)

# writer file rules
writer$(OBJ) : $(SRCDIR)/writer.c \
$(HFILESDIR)/RANAP-IEs.h $(HFILESDIR)/RANAP-IEsTable.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Containers.h $(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/rtkey.h \
$(HFILES)

# common file rules
RANAP-CommonDataTypes$(OBJ) : $(SRCDIR)/RANAP-CommonDataTypes.c \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-CommonDataTypes.c

# decode file rules
RANAP-CommonDataTypesDec$(OBJ) : $(SRCDIR)/RANAP-CommonDataTypesDec.c \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-CommonDataTypesDec.c

# encode file rules
RANAP-CommonDataTypesEnc$(OBJ) : $(SRCDIR)/RANAP-CommonDataTypesEnc.c \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-CommonDataTypesEnc.c

# test file rules
RANAP-CommonDataTypesTest$(OBJ) : $(SRCDIR)/RANAP-CommonDataTypesTest.c \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-CommonDataTypesTest.c

# reader file rules
reader$(OBJ) : $(SRCDIR)/reader.c \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)

# writer file rules
writer$(OBJ) : $(SRCDIR)/writer.c \
$(HFILESDIR)/RANAP-CommonDataTypes.h $(HFILESDIR)/rtkey.h \
$(HFILES)

# common file rules
RANAP-Constants$(OBJ) : $(SRCDIR)/RANAP-Constants.c \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-Constants.c

# decode file rules
RANAP-ConstantsDec$(OBJ) : $(SRCDIR)/RANAP-ConstantsDec.c \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-ConstantsDec.c

# encode file rules
RANAP-ConstantsEnc$(OBJ) : $(SRCDIR)/RANAP-ConstantsEnc.c \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-ConstantsEnc.c

# test file rules
RANAP-ConstantsTest$(OBJ) : $(SRCDIR)/RANAP-ConstantsTest.c \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-ConstantsTest.c

# reader file rules
reader$(OBJ) : $(SRCDIR)/reader.c \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)

# writer file rules
writer$(OBJ) : $(SRCDIR)/writer.c \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h \
$(HFILES)

# common file rules
RANAP-Containers$(OBJ) : $(SRCDIR)/RANAP-Containers.c \
$(HFILESDIR)/RANAP-Containers.h \
$(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h $(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-Containers.c

# decode file rules
RANAP-ContainersDec$(OBJ) : $(SRCDIR)/RANAP-ContainersDec.c \
$(HFILESDIR)/RANAP-Containers.h \
$(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h $(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-ContainersDec.c

# encode file rules
RANAP-ContainersEnc$(OBJ) : $(SRCDIR)/RANAP-ContainersEnc.c \
$(HFILESDIR)/RANAP-Containers.h \
$(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h $(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-ContainersEnc.c

# test file rules
RANAP-ContainersTest$(OBJ) : $(SRCDIR)/RANAP-ContainersTest.c \
$(HFILESDIR)/RANAP-Containers.h \
$(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h $(HFILES)
	$(CC) $(CFLAGS) -c $(IPATHS) $(SRCDIR)/RANAP-ContainersTest.c

# reader file rules
reader$(OBJ) : $(SRCDIR)/reader.c \
$(HFILESDIR)/RANAP-Containers.h \
$(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h $(HFILES)

# writer file rules
writer$(OBJ) : $(SRCDIR)/writer.c \
$(HFILESDIR)/RANAP-Containers.h \
$(HFILESDIR)/RANAP-ContainersClass.h $(HFILESDIR)/RANAP-CommonDataTypes.h \
$(HFILESDIR)/RANAP-Constants.h $(HFILESDIR)/rtkey.h $(HFILES)

# .asn -> .c .h rules
$(SRCDIR)/RANAP-PDU-DescriptionsEnc.c \
$(SRCDIR)/RANAP-PDU-DescriptionsDec.c \
$(SRCDIR)/RANAP-PDU-Descriptions.c \
$(SRCDIR)/RANAP-PDU-DescriptionsTable.c \
$(SRCDIR)/ranap_prt.c \
$(SRCDIR)/RANAP-PDU-DescriptionsTest.c \
$(HFILESDIR)/RANAP-PDU-Descriptions.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsClass.h \
$(HFILESDIR)/RANAP-PDU-DescriptionsTable.h \
$(SRCDIR)/RANAP-PDU-ContentsEnc.c \
$(SRCDIR)/RANAP-PDU-ContentsDec.c \
$(SRCDIR)/RANAP-PDU-Contents.c \
$(SRCDIR)/RANAP-PDU-ContentsTable.c \
$(SRCDIR)/RANAP-PDU-ContentsTest.c \
$(HFILESDIR)/RANAP-PDU-Contents.h \
$(HFILESDIR)/RANAP-PDU-ContentsTable.h \
$(SRCDIR)/RANAP-IEsEnc.c \
$(SRCDIR)/RANAP-IEsDec.c \
$(SRCDIR)/RANAP-IEs.c \
$(SRCDIR)/RANAP-IEsTable.c \
$(SRCDIR)/RANAP-IEsTest.c \
$(HFILESDIR)/RANAP-IEs.h \
$(HFILESDIR)/RANAP-IEsTable.h \
$(SRCDIR)/RANAP-CommonDataTypesEnc.c \
$(SRCDIR)/RANAP-CommonDataTypesDec.c \
$(SRCDIR)/RANAP-CommonDataTypes.c \
$(SRCDIR)/RANAP-CommonDataTypesTest.c \
$(HFILESDIR)/RANAP-CommonDataTypes.h \
$(SRCDIR)/RANAP-ConstantsEnc.c \
$(SRCDIR)/RANAP-ConstantsDec.c \
$(SRCDIR)/RANAP-Constants.c \
$(SRCDIR)/RANAP-ConstantsTest.c \
$(HFILESDIR)/RANAP-Constants.h \
$(SRCDIR)/RANAP-ContainersEnc.c \
$(SRCDIR)/RANAP-ContainersDec.c \
$(SRCDIR)/RANAP-Containers.c \
$(SRCDIR)/RANAP-ContainersTest.c \
$(HFILESDIR)/RANAP-Containers.h \
$(HFILESDIR)/RANAP-ContainersClass.h \
$(HFILESDIR)/rtkey.h \
: ./ranapSample.asn $(OSROOTDIR)/bin/asn1c$(EXE)
	/usr/local/asn1c-v583/bin/asn1c ./ranapSample.asn -c -per -print ranap_prt -prtfmt details -reader -tables -test -writer

clean:
	$(RM) RANAP-PDU-DescriptionsEnc.c
	$(RM) RANAP-PDU-DescriptionsDec.c
	$(RM) RANAP-PDU-Descriptions.c
	$(RM) RANAP-PDU-DescriptionsTable.c
	$(RM) ranap_prt.c
	$(RM) RANAP-PDU-DescriptionsTest.c
	$(RM) $(HFILESDIR)/RANAP-PDU-Descriptions.h 
	$(RM) $(HFILESDIR)/RANAP-PDU-DescriptionsClass.h 
	$(RM) $(HFILESDIR)/RANAP-PDU-DescriptionsTable.h 
	$(RM) RANAP-PDU-ContentsEnc.c
	$(RM) RANAP-PDU-ContentsDec.c
	$(RM) RANAP-PDU-Contents.c
	$(RM) RANAP-PDU-ContentsTable.c
	$(RM) RANAP-PDU-ContentsTest.c
	$(RM) $(HFILESDIR)/RANAP-PDU-Contents.h 
	$(RM) $(HFILESDIR)/RANAP-PDU-ContentsTable.h 
	$(RM) RANAP-IEsEnc.c
	$(RM) RANAP-IEsDec.c
	$(RM) RANAP-IEs.c
	$(RM) RANAP-IEsTable.c
	$(RM) RANAP-IEsTest.c
	$(RM) $(HFILESDIR)/RANAP-IEs.h 
	$(RM) $(HFILESDIR)/RANAP-IEsTable.h 
	$(RM) RANAP-CommonDataTypesEnc.c
	$(RM) RANAP-CommonDataTypesDec.c
	$(RM) RANAP-CommonDataTypes.c
	$(RM) RANAP-CommonDataTypesTest.c
	$(RM) $(HFILESDIR)/RANAP-CommonDataTypes.h 
	$(RM) RANAP-ConstantsEnc.c
	$(RM) RANAP-ConstantsDec.c
	$(RM) RANAP-Constants.c
	$(RM) RANAP-ConstantsTest.c
	$(RM) $(HFILESDIR)/RANAP-Constants.h 
	$(RM) RANAP-ContainersEnc.c
	$(RM) RANAP-ContainersDec.c
	$(RM) RANAP-Containers.c
	$(RM) RANAP-ContainersTest.c
	$(RM) $(HFILESDIR)/RANAP-Containers.h 
	$(RM) $(HFILESDIR)/RANAP-ContainersClass.h 
	$(RM) $(HFILESDIR)/rtkey.h 
	$(RM) *$(OBJ)
	$(RM) *~
