/**
 * This file was generated by the Objective Systems ASN1C Compiler
 * (http://www.obj-sys.com).  Version: 5.83, Date: 19-Mar-2007.
 */
#include "asn1intl.h"
#include "NBAP-CommonDataTypes.h"

/**************************************************************/
/*                                                            */
/*  Presence                                                  */
/*                                                            */
/**************************************************************/

Presence* asn1Test_Presence
   (ASN1CTXT* pctxt)
{
   Presence* pvalue = (Presence*)rtMemAllocZ (pctxt, sizeof(Presence));
   memset((void*)pvalue, 0, sizeof(Presence));

   /* Populate the Enumerated type */
   *pvalue = optional;
   return (pvalue);
}

