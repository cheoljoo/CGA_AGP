/**
 * This file was generated by the Objective Systems ASN1C Compiler
 * (http://www.obj-sys.com).  Version: 5.83, Date: 19-Mar-2007.
 */
#include "asn1intl.h"
#include "NBAP-Containers.h"

/**************************************************************/
/*                                                            */
/*  ProtocolIE_Field                                          */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_ProtocolIE_Field (ASN1CTXT* pctxt, ProtocolIE_Field* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolIE_Field: start\n");

   /* encode id */

   PU_PUSHNAME (pctxt, "id");

   stat = asn1PE_ProtocolIE_ID (pctxt, pvalue->id);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PE_Criticality (pctxt, pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode value */

   PU_PUSHNAME (pctxt, "value");

   stat = pe_OpenType (pctxt, pvalue->value.numocts, pvalue->value.data);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolIE_Field: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  ProtocolIE_Single_Container                               */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_ProtocolIE_Single_Container (ASN1CTXT* pctxt, ProtocolIE_Single_Container* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolIE_Single_Container: start\n");

   stat = asn1PE_ProtocolIE_Field (pctxt, pvalue);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolIE_Single_Container: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  ProtocolIE_Container                                      */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_ProtocolIE_Container (ASN1CTXT* pctxt, ProtocolIE_Container* pvalue)
{
   static Asn1SizeCnst lsize1 = { 0, OSUINTCONST(0), OSUINTCONST(65535), 0 };
   int stat = 0;
   Asn1RTDListNode* pnode;
   OSUINT32 xx1;

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolIE_Container: start\n");

   /* encode length determinant */

   PU_PUSHNAME (pctxt, "count");

   stat = pu_addSizeConstraint (pctxt, &lsize1);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   stat = pe_Length (pctxt, pvalue->count);
   if (stat < 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* encode elements */
   pnode = pvalue->head;

   for (xx1 = 0; xx1 < pvalue->count; xx1++) {
      PU_PUSHELEMNAME (pctxt, xx1);

      stat = asn1PE_ProtocolIE_Field (pctxt, ((ProtocolIE_Field*)pnode->data));
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
      pnode = pnode->next;
      PU_POPNAME (pctxt);
   }

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolIE_Container: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  ProtocolExtensionField                                    */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_ProtocolExtensionField (ASN1CTXT* pctxt, ProtocolExtensionField* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolExtensionField: start\n");

   /* encode id */

   PU_PUSHNAME (pctxt, "id");

   stat = asn1PE_ProtocolIE_ID (pctxt, pvalue->id);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PE_Criticality (pctxt, pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode extensionValue */

   PU_PUSHNAME (pctxt, "extensionValue");

   stat = pe_OpenType (pctxt, pvalue->extensionValue.numocts, pvalue->extensionValue.data);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolExtensionField: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  ProtocolExtensionContainer                                */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_ProtocolExtensionContainer (ASN1CTXT* pctxt, ProtocolExtensionContainer* pvalue)
{
   static Asn1SizeCnst lsize1 = { 0, OSUINTCONST(1), OSUINTCONST(65535), 0 };
   int stat = 0;
   Asn1RTDListNode* pnode;
   OSUINT32 xx1;

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolExtensionContainer: start\n");

   /* encode length determinant */

   PU_PUSHNAME (pctxt, "count");

   stat = pu_addSizeConstraint (pctxt, &lsize1);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   stat = pe_Length (pctxt, pvalue->count);
   if (stat < 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* encode elements */
   pnode = pvalue->head;

   for (xx1 = 0; xx1 < pvalue->count; xx1++) {
      PU_PUSHELEMNAME (pctxt, xx1);

      stat = asn1PE_ProtocolExtensionField (pctxt, ((ProtocolExtensionField*)pnode->data));
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
      pnode = pnode->next;
      PU_POPNAME (pctxt);
   }

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolExtensionContainer: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  PrivateIE_Field                                           */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_PrivateIE_Field (ASN1CTXT* pctxt, PrivateIE_Field* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt, "asn1PE_PrivateIE_Field: start\n");

   /* encode id */

   PU_PUSHNAME (pctxt, "id");

   stat = asn1PE_PrivateIE_ID (pctxt, &pvalue->id);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode criticality */

   PU_PUSHNAME (pctxt, "criticality");

   stat = asn1PE_Criticality (pctxt, pvalue->criticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode value */

   PU_PUSHNAME (pctxt, "value");

   stat = pe_OpenType (pctxt, pvalue->value.numocts, pvalue->value.data);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt, "asn1PE_PrivateIE_Field: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  PrivateIE_Container                                       */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_PrivateIE_Container (ASN1CTXT* pctxt, PrivateIE_Container* pvalue)
{
   static Asn1SizeCnst lsize1 = { 0, OSUINTCONST(1), OSUINTCONST(65535), 0 };
   int stat = 0;
   Asn1RTDListNode* pnode;
   OSUINT32 xx1;

   RTDIAGSTRM2 (pctxt, "asn1PE_PrivateIE_Container: start\n");

   /* encode length determinant */

   PU_PUSHNAME (pctxt, "count");

   stat = pu_addSizeConstraint (pctxt, &lsize1);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   stat = pe_Length (pctxt, pvalue->count);
   if (stat < 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* encode elements */
   pnode = pvalue->head;

   for (xx1 = 0; xx1 < pvalue->count; xx1++) {
      PU_PUSHELEMNAME (pctxt, xx1);

      stat = asn1PE_PrivateIE_Field (pctxt, ((PrivateIE_Field*)pnode->data));
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
      pnode = pnode->next;
      PU_POPNAME (pctxt);
   }

   RTDIAGSTRM2 (pctxt, "asn1PE_PrivateIE_Container: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  ProtocolIE_FieldPair                                      */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_ProtocolIE_FieldPair (ASN1CTXT* pctxt, ProtocolIE_FieldPair* pvalue)
{
   int stat = 0;

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolIE_FieldPair: start\n");

   /* encode id */

   PU_PUSHNAME (pctxt, "id");

   stat = asn1PE_ProtocolIE_ID (pctxt, pvalue->id);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode firstCriticality */

   PU_PUSHNAME (pctxt, "firstCriticality");

   stat = asn1PE_Criticality (pctxt, pvalue->firstCriticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode firstValue */

   PU_PUSHNAME (pctxt, "firstValue");

   stat = pe_OpenType (pctxt, pvalue->firstValue.numocts, pvalue->firstValue.data);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode secondCriticality */

   PU_PUSHNAME (pctxt, "secondCriticality");

   stat = asn1PE_Criticality (pctxt, pvalue->secondCriticality);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   /* encode secondValue */

   PU_PUSHNAME (pctxt, "secondValue");

   stat = pe_OpenType (pctxt, pvalue->secondValue.numocts, pvalue->secondValue.data);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
   PU_POPNAME (pctxt);

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolIE_FieldPair: end\n");

   return (stat);
}

/**************************************************************/
/*                                                            */
/*  ProtocolIE_ContainerPair                                  */
/*                                                            */
/**************************************************************/

EXTERN int asn1PE_ProtocolIE_ContainerPair (ASN1CTXT* pctxt, ProtocolIE_ContainerPair* pvalue)
{
   static Asn1SizeCnst lsize1 = { 0, OSUINTCONST(0), OSUINTCONST(65535), 0 };
   int stat = 0;
   Asn1RTDListNode* pnode;
   OSUINT32 xx1;

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolIE_ContainerPair: start\n");

   /* encode length determinant */

   PU_PUSHNAME (pctxt, "count");

   stat = pu_addSizeConstraint (pctxt, &lsize1);
   if (stat != 0) return LOG_ASN1ERR (pctxt, stat);

   stat = pe_Length (pctxt, pvalue->count);
   if (stat < 0) return LOG_ASN1ERR (pctxt, stat);

   PU_POPNAME (pctxt);

   /* encode elements */
   pnode = pvalue->head;

   for (xx1 = 0; xx1 < pvalue->count; xx1++) {
      PU_PUSHELEMNAME (pctxt, xx1);

      stat = asn1PE_ProtocolIE_FieldPair (pctxt, ((ProtocolIE_FieldPair*)pnode->data));
      if (stat != 0) return LOG_ASN1ERR (pctxt, stat);
      pnode = pnode->next;
      PU_POPNAME (pctxt);
   }

   RTDIAGSTRM2 (pctxt, "asn1PE_ProtocolIE_ContainerPair: end\n");

   return (stat);
}

