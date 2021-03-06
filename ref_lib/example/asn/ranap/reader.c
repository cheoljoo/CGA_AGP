/**
 * This file was generated by the Objective Systems ASN1C Compiler
 * (http://www.obj-sys.com).  Version: 5.83, Date: 20-Mar-2007.
 */
#include "RANAP-PDU-DescriptionsTable.h"
#include "RANAP-PDU-ContentsTable.h"
#include "RANAP-IEsTable.h"

#include <stdio.h>
#include <stdlib.h>

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#define MAXREADLEN 1024

int main (int argc, char** argv)
{
   RANAP_PDU data;
   ASN1CTXT   ctxt;
   OSOCTET    *pMsgBuf;
   OSBOOL     aligned = 1;
   OSBOOL     trace = TRUE;
   char*      filename = "message.dat";
   int        i, stat;
   size_t     len;

    int             fd;
    int             size, llen;
    char            buf[8192];
    int             result;

   /* Process Command line arguments */
#if 1
   if (argc > 1) {
      for (i = 1; i < argc; i++) {
         if (!strcmp (argv[i], "-a")) aligned = 1;
         else if (!strcmp (argv[i], "-u")) aligned = 0;
         else if (!strcmp (argv[i], "-v")) rtSetDiag (1);
         else if (!strcmp (argv[i], "-i")) filename = argv[++i];
         else if (!strcmp (argv[i], "-notrace")) trace = FALSE;
         else {
            printf ("usage: reader -a | -u [ -v ] [ -i <filename>\n");
            printf ("   -a  use PER aligned encoding\n");
            printf ("   -u  use PER unaligned encoding\n");
            printf ("   -v  verbose mode: print trace info\n");
            printf ("   -i <filename>  read encoded msg from <filename>\n");
            printf ("   -notrace  do not display trace info\n");
            return 0;
         }
      }
   }
#endif

   /* Create a new context structure */
   if (rtInitContext (&ctxt) != 0) return -1;

   RANAP_PDU_Descriptions_init (&ctxt);
   RANAP_PDU_Contents_init (&ctxt);
   RANAP_IEs_init (&ctxt);

   /* Read input file into a memory buffer */
   if (0 != rtFileReadBinary (&ctxt, filename, &pMsgBuf, &len)) {
      printf ("Error opening %s for read access\n", filename);
      return -1;
   }

pMsgBuf = pMsgBuf + 16;
len = len -16;

   pu_setBuffer (&ctxt, pMsgBuf, len, aligned);
   pu_setTrace (&ctxt, trace);

   /* Call compiler generated decode function */
   stat = asn1PD_RANAP_PDU (&ctxt, &data);
   if (stat != 0) {
      printf ("decode of data failed\n");
      rtErrPrint (&ctxt.errInfo);
      rtFreeContext (&ctxt);
      return -1;
   }

   if (trace) {
      printf ("Dump of decoded bit fields:\n");
      pu_bindump (&ctxt, "data");
      printf ("\n");
      printf("decode of data was successful\n");
      asn1Print_RANAP_PDU ("Data", &data);
   }

   rtFreeContext (&ctxt);
   return 0;
}
