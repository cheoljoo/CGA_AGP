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

EXTERN int asn1PE_InitiatingMessage (ASN1CTXT* pctxt, InitiatingMessage* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt, "asn1PE_InitiatingMessage: start\n");

   /* encode procedureID */

   PU_PUSHNAME (pctxt, "procedureID");

   stat = asn1PE_ProcedureID (pctxt, &pvalue->procedureID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PE_Criticality (pctxt, pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode messageDiscriminator */

   PU_PUSHNAME (pctxt, "messageDiscriminator");

   stat = asn1PE_MessageDiscriminator (pctxt, pvalue->messageDiscriminator);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode transactionID */

   PU_PUSHNAME (pctxt, "transactionID");

   stat = asn1PE_TransactionID (pctxt, &pvalue->transactionID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode value */

   PU_PUSHNAME (pctxt, "value");

   stat = pe_OpenType (pctxt, pvalue->value.numocts, pvalue->value.data);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt, "asn1PE_InitiatingMessage: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  SuccessfulOutcome                                         */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_SuccessfulOutcome (ASN1CTXT* pctxt, SuccessfulOutcome* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt, "asn1PE_SuccessfulOutcome: start\n");

   /* encode procedureID */

   PU_PUSHNAME (pctxt, "procedureID");

   stat = asn1PE_ProcedureID (pctxt, &pvalue->procedureID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PE_Criticality (pctxt, pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode messageDiscriminator */

   PU_PUSHNAME (pctxt, "messageDiscriminator");

   stat = asn1PE_MessageDiscriminator (pctxt, pvalue->messageDiscriminator);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode transactionID */

   PU_PUSHNAME (pctxt, "transactionID");

   stat = asn1PE_TransactionID (pctxt, &pvalue->transactionID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode value */

   PU_PUSHNAME (pctxt, "value");

   stat = pe_OpenType (pctxt, pvalue->value.numocts, pvalue->value.data);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt, "asn1PE_SuccessfulOutcome: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  UnsuccessfulOutcome                                       */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_UnsuccessfulOutcome (ASN1CTXT* pctxt, UnsuccessfulOutcome* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt, "asn1PE_UnsuccessfulOutcome: start\n");

   /* encode procedureID */

   PU_PUSHNAME (pctxt, "procedureID");

   stat = asn1PE_ProcedureID (pctxt, &pvalue->procedureID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PE_Criticality (pctxt, pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode messageDiscriminator */

   PU_PUSHNAME (pctxt, "messageDiscriminator");

   stat = asn1PE_MessageDiscriminator (pctxt, pvalue->messageDiscriminator);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode transactionID */

   PU_PUSHNAME (pctxt, "transactionID");

   stat = asn1PE_TransactionID (pctxt, &pvalue->transactionID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode value */

   PU_PUSHNAME (pctxt, "value");

   stat = pe_OpenType (pctxt, pvalue->value.numocts, pvalue->value.data);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt, "asn1PE_UnsuccessfulOutcome: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  Outcome                                                   */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_Outcome (ASN1CTXT* pctxt, Outcome* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt, "asn1PE_Outcome: start\n");

   /* encode procedureID */

   PU_PUSHNAME (pctxt, "procedureID");

   stat = asn1PE_ProcedureID (pctxt, &pvalue->procedureID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PE_Criticality (pctxt, pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode messageDiscriminator */

   PU_PUSHNAME (pctxt, "messageDiscriminator");

   stat = asn1PE_MessageDiscriminator (pctxt, pvalue->messageDiscriminator);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode transactionID */

   PU_PUSHNAME (pctxt, "transactionID");

   stat = asn1PE_TransactionID (pctxt, &pvalue->transactionID);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode value */

   PU_PUSHNAME (pctxt, "value");

   stat = pe_OpenType (pctxt, pvalue->value.numocts, pvalue->value.data);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt, "asn1PE_Outcome: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  NBAP_PDU                                                  */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_NBAP_PDU (ASN1CTXT* pctxt, NBAP_PDU* pvalue)
{
   int stat = 0;
   OSBOOL extbit;

   RTDIAGSTRM2 (pctxt, "asn1PE_NBAP_PDU: start\n");

   /* extension bit */

   PU_NEWFIELD (pctxt, "extension marker");

   extbit = (OSBOOL)(pvalue->t > 4);

   stat = pe_bit (pctxt, extbit);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   PU_SETBITCOUNT (pctxt);

   if (!extbit) {

      /* Encode choice index value */

      PU_PUSHNAME (pctxt, "t");

      stat = pe_ConsUnsigned (pctxt, pvalue->t - 1, 0, 3);
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

      PU_POPNAME (pctxt);

      /* Encode root element data value */

      switch (pvalue->t)
      {
         /* initiatingMessage */
         case 1:
            PU_PUSHNAME (pctxt, "u.initiatingMessage");

            stat = asn1PE_InitiatingMessage (pctxt, pvalue->u.initiatingMessage);
            if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
            PU_POPNAME (pctxt);

            break;

         /* succesfulOutcome */
         case 2:
            PU_PUSHNAME (pctxt, "u.succesfulOutcome");

            stat = asn1PE_SuccessfulOutcome (pctxt, pvalue->u.succesfulOutcome);
            if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
            PU_POPNAME (pctxt);

            break;

         /* unsuccesfulOutcome */
         case 3:
            PU_PUSHNAME (pctxt, "u.unsuccesfulOutcome");

            stat = asn1PE_UnsuccessfulOutcome (pctxt, pvalue->u.unsuccesfulOutcome);
            if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
            PU_POPNAME (pctxt);

            break;

         /* outcome */
         case 4:
            PU_PUSHNAME (pctxt, "u.outcome");

            stat = asn1PE_Outcome (pctxt, pvalue->u.outcome);
            if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
            PU_POPNAME (pctxt);

            break;

         default:
            return LOG_ASN1ERR (pctxt, ASN_E_INVOPT);
      }
   }
   else {
      /* Encode extension choice index value */

      PU_NEWFIELD (pctxt, "choice index");

      stat = pe_SmallNonNegWholeNumber (pctxt, pvalue->t - 5);
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

      PU_SETBITCOUNT (pctxt);

      /* Encode extension element data value */

      PU_PUSHNAME (pctxt, "extension");

      stat = pe_OpenType (pctxt, pvalue->u.extElem1->numocts, pvalue->u.extElem1->data);
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

      PU_POPNAME (pctxt);
   }

   RTDIAGSTRM2 (pctxt, "asn1PE_NBAP_PDU: end\n");

   return (stat);
}

