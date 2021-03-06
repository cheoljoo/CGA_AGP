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

EXTERN int asn1PD_ProtocolIE_ID (ASN1CTXT* pctxt, ProtocolIE_ID* pvalue)
{
   int stat = 0;

   stat = pd_ConsUInt16 (pctxt, pvalue, OSUINTCONST(0), OSUINTCONST(65535));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  Criticality                                               */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_Criticality (ASN1CTXT* pctxt, Criticality* pvalue)
{
   int stat = 0;
   OSUINT32 ui;

   stat = pd_ConsUnsigned (pctxt, &ui, 0, OSUINTCONST(2));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   switch (ui) {
      case 0: *pvalue = reject; break;
      case 1: *pvalue = ignore; break;
      case 2: *pvalue = notify; break;
      default: return LOG_ASN1ERR (pctxt, ASN_E_INVENUM);
   }

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  Presence                                                  */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_Presence (ASN1CTXT* pctxt, Presence* pvalue)
{
   int stat = 0;
   OSUINT32 ui;

   stat = pd_ConsUnsigned (pctxt, &ui, 0, OSUINTCONST(2));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   switch (ui) {
      case 0: *pvalue = optional; break;
      case 1: *pvalue = conditional; break;
      case 2: *pvalue = mandatory; break;
      default: return LOG_ASN1ERR (pctxt, ASN_E_INVENUM);
   }

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  ProtocolExtensionID                                       */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_ProtocolExtensionID (ASN1CTXT* pctxt, ProtocolExtensionID* pvalue)
{
   int stat = 0;

   stat = pd_ConsUInt16 (pctxt, pvalue, OSUINTCONST(0), OSUINTCONST(65535));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  ProcedureCode                                             */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_ProcedureCode (ASN1CTXT* pctxt, ProcedureCode* pvalue)
{
   int stat = 0;

   stat = pd_ConsUInt8 (pctxt, pvalue, OSUINTCONST(0), OSUINTCONST(255));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  TriggeringMessage                                         */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_TriggeringMessage (ASN1CTXT* pctxt, TriggeringMessage* pvalue)
{
   int stat = 0;
   OSUINT32 ui;

   stat = pd_ConsUnsigned (pctxt, &ui, 0, OSUINTCONST(3));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   switch (ui) {
      case 0: *pvalue = initiating_message; break;
      case 1: *pvalue = successful_outcome; break;
      case 2: *pvalue = unsuccessfull_outcome; break;
      case 3: *pvalue = outcome; break;
      default: return LOG_ASN1ERR (pctxt, ASN_E_INVENUM);
   }

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  PrivateIE_ID                                              */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_PrivateIE_ID (ASN1CTXT* pctxt, PrivateIE_ID* pvalue)
{
   int stat = 0;
   OSUINT32 ui;

   stat = pd_ConsUnsigned (pctxt, &ui, 0, OSUINTCONST(1));
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   else pvalue->t = ui + 1;

   switch (ui) {
      /* local */
      case 0:
         stat = pd_ConsUInt16 (pctxt, &pvalue->u.local, OSUINTCONST(0), OSUINTCONST(65535));
         if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

         break;

      /* global */
      case 1:
         pvalue->u.global = rtMemAllocTypeZ (pctxt, ASN1OBJID);
         if (pvalue->u.global == NULL)
            return LOG_ASN1ERR (pctxt, ASN_E_NOMEM);

         stat = pd_ObjectIdentifier (pctxt, pvalue->u.global);
         if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

         break;

      default:
         return LOG_ASN1ERR (pctxt, ASN_E_INVOPT);
   }

   return (stat);
}

