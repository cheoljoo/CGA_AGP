/**
 * This file was generated by the Objective Systems ASN1C Compiler
 * (http://www.obj-sys.com).  Version: 5.83, Date: 19-Mar-2007.
 */
#ifndef NBAP_PDU_DISCRIPTIONS_H
#define NBAP_PDU_DISCRIPTIONS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdlib.h>
#include "rtkey.h"
#include "asn1per.h"
#include "NBAP-CommonDataTypes.h"

/**************************************************************/
/*                                                            */
/*  InitiatingMessage                                         */
/*                                                            */
/**************************************************************/

typedef struct EXTERN InitiatingMessage {
   ProcedureID procedureID;
   Criticality criticality;
   MessageDiscriminator messageDiscriminator;
   TransactionID transactionID;
   ASN1OpenType value;
} InitiatingMessage;

EXTERN int asn1PE_InitiatingMessage (ASN1CTXT* pctxt, InitiatingMessage* pvalue);

EXTERN int asn1PD_InitiatingMessage (ASN1CTXT* pctxt, InitiatingMessage* pvalue);

EXTERN void asn1Print_InitiatingMessage
   (const char* name, InitiatingMessage* pvalue);

EXTERN InitiatingMessage* asn1Test_InitiatingMessage
   (ASN1CTXT* pctxt);

/**************************************************************/
/*                                                            */
/*  SuccessfulOutcome                                         */
/*                                                            */
/**************************************************************/

typedef struct EXTERN SuccessfulOutcome {
   ProcedureID procedureID;
   Criticality criticality;
   MessageDiscriminator messageDiscriminator;
   TransactionID transactionID;
   ASN1OpenType value;
} SuccessfulOutcome;

EXTERN int asn1PE_SuccessfulOutcome (ASN1CTXT* pctxt, SuccessfulOutcome* pvalue);

EXTERN int asn1PD_SuccessfulOutcome (ASN1CTXT* pctxt, SuccessfulOutcome* pvalue);

EXTERN void asn1Print_SuccessfulOutcome
   (const char* name, SuccessfulOutcome* pvalue);

EXTERN SuccessfulOutcome* asn1Test_SuccessfulOutcome
   (ASN1CTXT* pctxt);

/**************************************************************/
/*                                                            */
/*  UnsuccessfulOutcome                                       */
/*                                                            */
/**************************************************************/

typedef struct EXTERN UnsuccessfulOutcome {
   ProcedureID procedureID;
   Criticality criticality;
   MessageDiscriminator messageDiscriminator;
   TransactionID transactionID;
   ASN1OpenType value;
} UnsuccessfulOutcome;

EXTERN int asn1PE_UnsuccessfulOutcome (ASN1CTXT* pctxt, UnsuccessfulOutcome* pvalue);

EXTERN int asn1PD_UnsuccessfulOutcome (ASN1CTXT* pctxt, UnsuccessfulOutcome* pvalue);

EXTERN void asn1Print_UnsuccessfulOutcome
   (const char* name, UnsuccessfulOutcome* pvalue);

EXTERN UnsuccessfulOutcome* asn1Test_UnsuccessfulOutcome
   (ASN1CTXT* pctxt);

/**************************************************************/
/*                                                            */
/*  Outcome                                                   */
/*                                                            */
/**************************************************************/

typedef struct EXTERN Outcome {
   ProcedureID procedureID;
   Criticality criticality;
   MessageDiscriminator messageDiscriminator;
   TransactionID transactionID;
   ASN1OpenType value;
} Outcome;

EXTERN int asn1PE_Outcome (ASN1CTXT* pctxt, Outcome* pvalue);

EXTERN int asn1PD_Outcome (ASN1CTXT* pctxt, Outcome* pvalue);

EXTERN void asn1Print_Outcome
   (const char* name, Outcome* pvalue);

EXTERN Outcome* asn1Test_Outcome
   (ASN1CTXT* pctxt);

/**************************************************************/
/*                                                            */
/*  NBAP_PDU                                                  */
/*                                                            */
/**************************************************************/

/* Choice tag constants */

#define T_NBAP_PDU_initiatingMessage    1
#define T_NBAP_PDU_succesfulOutcome     2
#define T_NBAP_PDU_unsuccesfulOutcome   3
#define T_NBAP_PDU_outcome              4
#define T_NBAP_PDU_extElem1             5

typedef struct EXTERN NBAP_PDU {
   int t;
   union {
      /* t = 1 */
      InitiatingMessage *initiatingMessage;
      /* t = 2 */
      SuccessfulOutcome *succesfulOutcome;
      /* t = 3 */
      UnsuccessfulOutcome *unsuccesfulOutcome;
      /* t = 4 */
      Outcome *outcome;
      /* t = 5 */
      ASN1OpenType *extElem1;
   } u;
} NBAP_PDU;

EXTERN int asn1PE_NBAP_PDU (ASN1CTXT* pctxt, NBAP_PDU* pvalue);

EXTERN int asn1PD_NBAP_PDU (ASN1CTXT* pctxt, NBAP_PDU* pvalue);

EXTERN void asn1Print_NBAP_PDU
   (const char* name, NBAP_PDU* pvalue);

EXTERN NBAP_PDU* asn1Test_NBAP_PDU
   (ASN1CTXT* pctxt);

#ifdef __cplusplus
}
#endif

#endif