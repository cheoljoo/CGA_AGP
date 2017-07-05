/**
 * This file was generated by the Objective Systems ASN1C Compiler
 * (http://www.obj-sys.com).  Version: 5.83, Date: 19-Mar-2007.
 */
#include "asn1intl.h"
#include "NBAP-PDU-Discriptions.h"

/**************************************************************/
/*                                                            */
/*  InitiatingMessage                                         */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_InitiatingMessage (ASN1CTXT* pctxt, InitiatingMessage* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt,"asn1PD_InitiatingMessage: start\n");

   /* decode procedureID */

   PU_PUSHNAME (pctxt, "procedureID");

   stat = asn1PD_ProcedureID (pctxt, &pvalue->procedureID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PD_Criticality (pctxt, &pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode messageDiscriminator */

   PU_PUSHNAME (pctxt, "messageDiscriminator");

   stat = asn1PD_MessageDiscriminator (pctxt, &pvalue->messageDiscriminator);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode transactionID */

   PU_PUSHNAME (pctxt, "transactionID");

   stat = asn1PD_TransactionID (pctxt, &pvalue->transactionID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode value */

   PU_PUSHNAME (pctxt, "value");

   stat = pd_OpenType (pctxt, &pvalue->value.data, &pvalue->value.numocts);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt,"asn1PD_InitiatingMessage: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  SuccessfulOutcome                                         */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_SuccessfulOutcome (ASN1CTXT* pctxt, SuccessfulOutcome* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt,"asn1PD_SuccessfulOutcome: start\n");

   /* decode procedureID */

   PU_PUSHNAME (pctxt, "procedureID");

   stat = asn1PD_ProcedureID (pctxt, &pvalue->procedureID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PD_Criticality (pctxt, &pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode messageDiscriminator */

   PU_PUSHNAME (pctxt, "messageDiscriminator");

   stat = asn1PD_MessageDiscriminator (pctxt, &pvalue->messageDiscriminator);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode transactionID */

   PU_PUSHNAME (pctxt, "transactionID");

   stat = asn1PD_TransactionID (pctxt, &pvalue->transactionID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode value */

   PU_PUSHNAME (pctxt, "value");

   stat = pd_OpenType (pctxt, &pvalue->value.data, &pvalue->value.numocts);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt,"asn1PD_SuccessfulOutcome: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  UnsuccessfulOutcome                                       */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_UnsuccessfulOutcome (ASN1CTXT* pctxt, UnsuccessfulOutcome* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt,"asn1PD_UnsuccessfulOutcome: start\n");

   /* decode procedureID */

   PU_PUSHNAME (pctxt, "procedureID");

   stat = asn1PD_ProcedureID (pctxt, &pvalue->procedureID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PD_Criticality (pctxt, &pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode messageDiscriminator */

   PU_PUSHNAME (pctxt, "messageDiscriminator");

   stat = asn1PD_MessageDiscriminator (pctxt, &pvalue->messageDiscriminator);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode transactionID */

   PU_PUSHNAME (pctxt, "transactionID");

   stat = asn1PD_TransactionID (pctxt, &pvalue->transactionID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode value */

   PU_PUSHNAME (pctxt, "value");

   stat = pd_OpenType (pctxt, &pvalue->value.data, &pvalue->value.numocts);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt,"asn1PD_UnsuccessfulOutcome: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  Outcome                                                   */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_Outcome (ASN1CTXT* pctxt, Outcome* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt,"asn1PD_Outcome: start\n");

   /* decode procedureID */

   PU_PUSHNAME (pctxt, "procedureID");

   stat = asn1PD_ProcedureID (pctxt, &pvalue->procedureID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PD_Criticality (pctxt, &pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode messageDiscriminator */

   PU_PUSHNAME (pctxt, "messageDiscriminator");

   stat = asn1PD_MessageDiscriminator (pctxt, &pvalue->messageDiscriminator);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode transactionID */

   PU_PUSHNAME (pctxt, "transactionID");

   stat = asn1PD_TransactionID (pctxt, &pvalue->transactionID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* decode value */

   PU_PUSHNAME (pctxt, "value");

   stat = pd_OpenType (pctxt, &pvalue->value.data, &pvalue->value.numocts);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt,"asn1PD_Outcome: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  NBAP_PDU                                                  */
/*                                                            */
/**************************************************************/

EXTERN int asn1PD_NBAP_PDU (ASN1CTXT* pctxt, NBAP_PDU* pvalue)
{
   int stat = 0;
   OSUINT32 ui;
   ASN1OpenType openType;
   OSBOOL extbit;

   RTDIAGSTRM2 (pctxt,"asn1PD_NBAP_PDU: start\n");

   /* extension bit */

   PU_NEWFIELD (pctxt, "extension marker");

   stat = PD_BIT (pctxt, &extbit);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_SETBITCOUNT (pctxt);

   if (!extbit) {
      PU_PUSHNAME (pctxt, "t");

      stat = pd_ConsUnsigned (pctxt, &ui, 0, OSUINTCONST(3));
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
      else pvalue->t = ui + 1;

      PU_POPNAME (pctxt);

      switch (ui) {
         /* initiatingMessage */
         case 0:
            PU_PUSHNAME (pctxt, "u.initiatingMessage");

            pvalue->u.initiatingMessage = rtMemAllocTypeZ (pctxt, InitiatingMessage);
            if (pvalue->u.initiatingMessage == NULL)
               return LOG_ASN1ERR (pctxt, ASN_E_NOMEM);

            stat = asn1PD_InitiatingMessage (pctxt, pvalue->u.initiatingMessage);
            if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

            PU_POPNAME (pctxt);

            break;

         /* succesfulOutcome */
         case 1:
            PU_PUSHNAME (pctxt, "u.succesfulOutcome");

            pvalue->u.succesfulOutcome = rtMemAllocTypeZ (pctxt, SuccessfulOutcome);
            if (pvalue->u.succesfulOutcome == NULL)
               return LOG_ASN1ERR (pctxt, ASN_E_NOMEM);

            stat = asn1PD_SuccessfulOutcome (pctxt, pvalue->u.succesfulOutcome);
            if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

            PU_POPNAME (pctxt);

            break;

         /* unsuccesfulOutcome */
         case 2:
            PU_PUSHNAME (pctxt, "u.unsuccesfulOutcome");

            pvalue->u.unsuccesfulOutcome = rtMemAllocTypeZ (pctxt, UnsuccessfulOutcome);
            if (pvalue->u.unsuccesfulOutcome == NULL)
               return LOG_ASN1ERR (pctxt, ASN_E_NOMEM);

            stat = asn1PD_UnsuccessfulOutcome (pctxt, pvalue->u.unsuccesfulOutcome);
            if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

            PU_POPNAME (pctxt);

            break;

         /* outcome */
         case 3:
            PU_PUSHNAME (pctxt, "u.outcome");

            pvalue->u.outcome = rtMemAllocTypeZ (pctxt, Outcome);
            if (pvalue->u.outcome == NULL)
               return LOG_ASN1ERR (pctxt, ASN_E_NOMEM);

            stat = asn1PD_Outcome (pctxt, pvalue->u.outcome);
            if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

            PU_POPNAME (pctxt);

            break;

         default:
            return LOG_ASN1ERR (pctxt, ASN_E_INVOPT);
      }
   }
   else {
      PU_NEWFIELD (pctxt, "choice index");

      stat = pd_SmallNonNegWholeNumber (pctxt, &ui);
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
      else pvalue->t = ui + 5;

      PU_SETBITCOUNT (pctxt);

      stat = PD_BYTE_ALIGN (pctxt);
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

      PU_PUSHNAME (pctxt, "choice extension");

      stat = pd_OpenType (pctxt, &openType.data, &openType.numocts);
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

      PU_POPNAME (pctxt);

      PU_PUSHNAME (pctxt, "extension");

      pvalue->u.extElem1 = rtMemAllocType (pctxt, ASN1OpenType);
      if (pvalue->u.extElem1 == NULL)
         return LOG_ASN1ERR (pctxt, ASN_E_NOMEM);

      pvalue->u.extElem1->data = openType.data;
      pvalue->u.extElem1->numocts = openType.numocts;

      PU_POPNAME (pctxt);

   }

   RTDIAGSTRM2 (pctxt,"asn1PD_NBAP_PDU: end\n");

   return (stat);
}

