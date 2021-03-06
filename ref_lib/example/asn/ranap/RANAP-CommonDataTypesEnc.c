/**
 * This file was generated by the Objective Systems ASN1C Compiler
 * (http://www.obj-sys.com).  Version: 5.83, Date: 20-Mar-2007.
 */
#include "asn1intl.h"
#include "RANAP-CommonDataTypes.h"

/**************************************************************/
/*                                                            */
/*  ProtocolIE_ID                                             */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_ProtocolIE_ID (ASN1CTXT* pctxt, ProtocolIE_ID value)
{
   int stat = 0;

   stat = pe_ConsUnsigned (pctxt, value, OSUINTCONST(0), OSUINTCONST(65535));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  Criticality                                               */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_Criticality (ASN1CTXT* pctxt, Criticality value)
{
   int stat = 0;
   OSUINT32 ui;

   switch (value) {
      case reject: ui = 0; break;
      case ignore: ui = 1; break;
      case notify: ui = 2; break;
      default: rtErrAddIntParm (&pctxt->errInfo, value);
      return LOG_ASN1ERR (pctxt, ASN_E_INVENUM);
   }

   stat = pe_ConsUnsigned (pctxt, ui, 0, OSUINTCONST(2));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  Presence                                                  */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_Presence (ASN1CTXT* pctxt, Presence value)
{
   int stat = 0;
   OSUINT32 ui;

   switch (value) {
      case optional: ui = 0; break;
      case conditional: ui = 1; break;
      case mandatory: ui = 2; break;
      default: rtErrAddIntParm (&pctxt->errInfo, value);
      return LOG_ASN1ERR (pctxt, ASN_E_INVENUM);
   }

   stat = pe_ConsUnsigned (pctxt, ui, 0, OSUINTCONST(2));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  ProtocolExtensionID                                       */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_ProtocolExtensionID (ASN1CTXT* pctxt, ProtocolExtensionID value)
{
   int stat = 0;

   stat = pe_ConsUnsigned (pctxt, value, OSUINTCONST(0), OSUINTCONST(65535));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  ProcedureCode                                             */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_ProcedureCode (ASN1CTXT* pctxt, ProcedureCode value)
{
   int stat = 0;

   stat = pe_ConsUnsigned (pctxt, value, OSUINTCONST(0), OSUINTCONST(255));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  TriggeringMessage                                         */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_TriggeringMessage (ASN1CTXT* pctxt, TriggeringMessage value)
{
   int stat = 0;
   OSUINT32 ui;

   switch (value) {
      case initiating_message: ui = 0; break;
      case successful_outcome: ui = 1; break;
      case unsuccessfull_outcome: ui = 2; break;
      case outcome: ui = 3; break;
      default: rtErrAddIntParm (&pctxt->errInfo, value);
      return LOG_ASN1ERR (pctxt, ASN_E_INVENUM);
   }

   stat = pe_ConsUnsigned (pctxt, ui, 0, OSUINTCONST(3));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  PrivateIE_ID                                              */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_PrivateIE_ID (ASN1CTXT* pctxt, PrivateIE_ID* pvalue)
{
   int stat = 0;

   /* Encode choice index value */

   stat = pe_ConsUnsigned (pctxt, pvalue->t - 1, 0, 1);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   /* Encode root element data value */

   switch (pvalue->t)
   {
      /* local */
      case 1:
         stat = pe_ConsUnsigned (pctxt, pvalue->u.local, OSUINTCONST(0), OSUINTCONST(65535));
         if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

         break;

      /* global */
      case 2:
         stat = pe_ObjectIdentifier (pctxt, pvalue->u.global);
         if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
         break;

      default:
         return LOG_ASN1ERR (pctxt, ASN_E_INVOPT);
   }

   return (stat);
}

