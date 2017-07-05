/**
 * This file was generated by the Objective Systems ASN1C Compiler
 * (http://www.obj-sys.com).  Version: 5.83, Date: 20-Mar-2007.
 */
#include "asn1intl.h"
#include "RANAP-CommonDataTypes.h"

/**************************************************************/
/*                                                            */
/*  PrivateIE_ID                                              */
/*                                                            */
/**************************************************************/

int asn1CmpTC_PrivateIE_ID (PrivateIE_ID* pValue, PrivateIE_ID* pCmpValue)
{
   if(pValue->t != pCmpValue->t)
   {
      return -1;
   }
   switch (pValue->t) {
      case T_PrivateIE_ID_local:
         return rtCmpTCUSINT(&pValue->u.local, &pCmpValue->u.local);
         break;

      case T_PrivateIE_ID_global:
         return rtCmpTCOID(pValue->u.global, pCmpValue->u.global);
         break;

      default:
         return -1;
   }
   return 0;
}
