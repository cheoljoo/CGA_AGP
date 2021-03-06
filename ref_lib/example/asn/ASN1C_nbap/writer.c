/**
 * This file was generated by the Objective Systems ASN1C Compiler
 * (http://www.obj-sys.com).  Version: 5.83, Date: 19-Mar-2007.
 */
#include "NBAP-PDU-Discriptions.h"

#include <stdio.h>
#include <stdlib.h>

int main (int argc, char** argv)
{
   NBAP_PDU* pdata;
   ASN1CTXT     ctxt;
   OSOCTET    *msgptr;
   OSBOOL     aligned = 1;
   OSBOOL     trace = TRUE;
   FILE*        fp;
   char*        filename = "message.dat";
   int          i, len, stat;

   /* Process Command line arguments */
   if (argc > 1) {
      for (i = 1; i < argc; i++) {
         if (!strcmp (argv[i], "-a")) aligned = 1;
         else if (!strcmp (argv[i], "-u")) aligned = 0;
         else if (!strcmp (argv[i], "-v")) rtSetDiag (1);
         else if (!strcmp (argv[i], "-o")) filename = argv[++i];
         else if (!strcmp (argv[i], "-notrace")) trace = FALSE;
         else {
            printf ("usage: writer -a | -u [ -v ] [ -o <filename>\n");
            printf ("   -a  use PER aligned encoding\n");
            printf ("   -u  use PER unaligned encoding\n");
            printf ("   -v  verbose mode: print trace info\n");
            printf ("   -o <filename>  write encoded msg to <filename>\n");
            printf ("   -notrace  do not display trace info\n");
            return 0;
         }
      }
   }

   /* Create a new context structure */
   if (rtInitContext (&ctxt) != 0) return -1;
   pu_setBuffer (&ctxt, 0, 0, aligned);
   pu_setTrace (&ctxt, trace);

   pdata = asn1Test_NBAP_PDU(&ctxt);

   if (trace) {
      printf ("The following record will be encoded:\n");
      asn1Print_NBAP_PDU ("data", pdata);
      printf ("\n");
   }

   /* Encode */
   if ((stat = asn1PE_NBAP_PDU (&ctxt, pdata))== 0) {
      if (trace) {
         printf ("Encoding was successful\n");
         printf ("Hex dump of encoded record:\n");
         pu_hexdump (&ctxt);
         printf ("Binary dump:\n");
         pu_bindump (&ctxt, "data");
      }
   }
   else {
      printf ("Encoding failed\n");
      rtErrPrint (&ctxt.errInfo);
      rtFreeContext (&ctxt);
      return -1;
   }
   msgptr = pe_GetMsgPtr (&ctxt, &len);
   /* Write the encoded message out to the output file */
   if (fp = fopen (filename, "wb")) {
      fwrite (msgptr, 1, len, fp);
      fclose (fp);
   }
   else {
      printf ("Error opening %s for write access\n", filename);
      rtFreeContext (&ctxt);
      return -1;
   }

   rtFreeContext (&ctxt);
   return 0;
}
