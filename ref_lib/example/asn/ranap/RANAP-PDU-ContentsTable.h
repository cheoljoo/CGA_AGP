/**
 * This file was generated by the Objective Systems ASN1C Compiler
 * (http://www.obj-sys.com).  Version: 5.83, Date: 20-Mar-2007.
 */
#ifndef RANAP_PDU_CONTENTSTABLE_H
#define RANAP_PDU_CONTENTSTABLE_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdlib.h>
#include "rtkey.h"
#include "asn1per.h"
#include "rtTable.h"
#include "RANAP-PDU-Contents.h"
#include "RANAP-ContainersClass.h"
#include "RANAP-Constants.h"

/* Intialization function */
extern void RANAP_PDU_Contents_init(ASN1CTXT *pctxt);

/* Object definitions */

/* ObjectSet definitions */

extern struct RANAP_PROTOCOL_IES Iu_ReleaseCommandIEs[];
extern int Iu_ReleaseCommandIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION Iu_ReleaseCommandExtensions[];
extern int Iu_ReleaseCommandExtensions_Size;
extern struct RANAP_PROTOCOL_IES Iu_ReleaseCompleteIEs[];
extern int Iu_ReleaseCompleteIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_DataVolumeReportItemIEs[];
extern int RAB_DataVolumeReportItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_DataVolumeReportItem_ExtIEs[];
extern int RAB_DataVolumeReportItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_ReleasedItem_IuRelComp_IEs[];
extern int RAB_ReleasedItem_IuRelComp_IEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_ReleasedItem_IuRelComp_ExtIEs[];
extern int RAB_ReleasedItem_IuRelComp_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION Iu_ReleaseCompleteExtensions[];
extern int Iu_ReleaseCompleteExtensions_Size;
extern struct RANAP_PROTOCOL_IES RelocationRequiredIEs[];
extern int RelocationRequiredIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RelocationRequiredExtensions[];
extern int RelocationRequiredExtensions_Size;
extern struct RANAP_PROTOCOL_IES RelocationCommandIEs[];
extern int RelocationCommandIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_RelocationReleaseItemIEs[];
extern int RAB_RelocationReleaseItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_RelocationReleaseItem_ExtIEs[];
extern int RAB_RelocationReleaseItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_DataForwardingItemIEs[];
extern int RAB_DataForwardingItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_DataForwardingItem_ExtIEs[];
extern int RAB_DataForwardingItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RelocationCommandExtensions[];
extern int RelocationCommandExtensions_Size;
extern struct RANAP_PROTOCOL_IES RelocationPreparationFailureIEs[];
extern int RelocationPreparationFailureIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RelocationPreparationFailureExtensions[];
extern int RelocationPreparationFailureExtensions_Size;
extern struct RANAP_PROTOCOL_IES RelocationRequestIEs[];
extern int RelocationRequestIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_SetupItem_RelocReq_IEs[];
extern int RAB_SetupItem_RelocReq_IEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_SetupItem_RelocReq_ExtIEs[];
extern int RAB_SetupItem_RelocReq_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION UserPlaneInformation_ExtIEs[];
extern int UserPlaneInformation_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RelocationRequestExtensions[];
extern int RelocationRequestExtensions_Size;
extern struct RANAP_PROTOCOL_EXTENSION CNMBMSLinkingInformation_ExtIEs[];
extern int CNMBMSLinkingInformation_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION JoinedMBMSBearerService_ExtIEs[];
extern int JoinedMBMSBearerService_ExtIEs_Size;
extern struct RANAP_PROTOCOL_IES RelocationRequestAcknowledgeIEs[];
extern int RelocationRequestAcknowledgeIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_SetupItem_RelocReqAck_IEs[];
extern int RAB_SetupItem_RelocReqAck_IEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_SetupItem_RelocReqAck_ExtIEs[];
extern int RAB_SetupItem_RelocReqAck_ExtIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_FailedItemIEs[];
extern int RAB_FailedItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_FailedItem_ExtIEs[];
extern int RAB_FailedItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RelocationRequestAcknowledgeExtensions[];
extern int RelocationRequestAcknowledgeExtensions_Size;
extern struct RANAP_PROTOCOL_IES RelocationFailureIEs[];
extern int RelocationFailureIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RelocationFailureExtensions[];
extern int RelocationFailureExtensions_Size;
extern struct RANAP_PROTOCOL_IES RelocationCancelIEs[];
extern int RelocationCancelIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RelocationCancelExtensions[];
extern int RelocationCancelExtensions_Size;
extern struct RANAP_PROTOCOL_IES RelocationCancelAcknowledgeIEs[];
extern int RelocationCancelAcknowledgeIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RelocationCancelAcknowledgeExtensions[];
extern int RelocationCancelAcknowledgeExtensions_Size;
extern struct RANAP_PROTOCOL_IES SRNS_ContextRequestIEs[];
extern int SRNS_ContextRequestIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_DataForwardingItem_SRNS_CtxReq_IEs[];
extern int RAB_DataForwardingItem_SRNS_CtxReq_IEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_DataForwardingItem_SRNS_CtxReq_ExtIEs[];
extern int RAB_DataForwardingItem_SRNS_CtxReq_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION SRNS_ContextRequestExtensions[];
extern int SRNS_ContextRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES SRNS_ContextResponseIEs[];
extern int SRNS_ContextResponseIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_ContextItemIEs[];
extern int RAB_ContextItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_ContextItem_ExtIEs[];
extern int RAB_ContextItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_IES RABs_ContextFailedtoTransferItemIEs[];
extern int RABs_ContextFailedtoTransferItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RABs_ContextFailedtoTransferItem_ExtIEs[];
extern int RABs_ContextFailedtoTransferItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION SRNS_ContextResponseExtensions[];
extern int SRNS_ContextResponseExtensions_Size;
extern struct RANAP_PROTOCOL_IES SecurityModeCommandIEs[];
extern int SecurityModeCommandIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION SecurityModeCommandExtensions[];
extern int SecurityModeCommandExtensions_Size;
extern struct RANAP_PROTOCOL_IES SecurityModeCompleteIEs[];
extern int SecurityModeCompleteIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION SecurityModeCompleteExtensions[];
extern int SecurityModeCompleteExtensions_Size;
extern struct RANAP_PROTOCOL_IES SecurityModeRejectIEs[];
extern int SecurityModeRejectIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION SecurityModeRejectExtensions[];
extern int SecurityModeRejectExtensions_Size;
extern struct RANAP_PROTOCOL_IES DataVolumeReportRequestIEs[];
extern int DataVolumeReportRequestIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_DataVolumeReportRequestItemIEs[];
extern int RAB_DataVolumeReportRequestItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_DataVolumeReportRequestItem_ExtIEs[];
extern int RAB_DataVolumeReportRequestItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION DataVolumeReportRequestExtensions[];
extern int DataVolumeReportRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES DataVolumeReportIEs[];
extern int DataVolumeReportIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION DataVolumeReportExtensions[];
extern int DataVolumeReportExtensions_Size;
extern struct RANAP_PROTOCOL_IES RABs_failed_to_reportItemIEs[];
extern int RABs_failed_to_reportItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RABs_failed_to_reportItem_ExtIEs[];
extern int RABs_failed_to_reportItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_IES ResetIEs[];
extern int ResetIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION ResetExtensions[];
extern int ResetExtensions_Size;
extern struct RANAP_PROTOCOL_IES ResetAcknowledgeIEs[];
extern int ResetAcknowledgeIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION ResetAcknowledgeExtensions[];
extern int ResetAcknowledgeExtensions_Size;
extern struct RANAP_PROTOCOL_IES ResetResourceIEs[];
extern int ResetResourceIEs_Size;
extern struct RANAP_PROTOCOL_IES ResetResourceItemIEs[];
extern int ResetResourceItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION ResetResourceItem_ExtIEs[];
extern int ResetResourceItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION ResetResourceExtensions[];
extern int ResetResourceExtensions_Size;
extern struct RANAP_PROTOCOL_IES ResetResourceAcknowledgeIEs[];
extern int ResetResourceAcknowledgeIEs_Size;
extern struct RANAP_PROTOCOL_IES ResetResourceAckItemIEs[];
extern int ResetResourceAckItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION ResetResourceAckItem_ExtIEs[];
extern int ResetResourceAckItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION ResetResourceAcknowledgeExtensions[];
extern int ResetResourceAcknowledgeExtensions_Size;
extern struct RANAP_PROTOCOL_IES RAB_ReleaseRequestIEs[];
extern int RAB_ReleaseRequestIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_ReleaseItemIEs[];
extern int RAB_ReleaseItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_ReleaseItem_ExtIEs[];
extern int RAB_ReleaseItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_ReleaseRequestExtensions[];
extern int RAB_ReleaseRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES Iu_ReleaseRequestIEs[];
extern int Iu_ReleaseRequestIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION Iu_ReleaseRequestExtensions[];
extern int Iu_ReleaseRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES RelocationDetectIEs[];
extern int RelocationDetectIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RelocationDetectExtensions[];
extern int RelocationDetectExtensions_Size;
extern struct RANAP_PROTOCOL_IES RelocationCompleteIEs[];
extern int RelocationCompleteIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RelocationCompleteExtensions[];
extern int RelocationCompleteExtensions_Size;
extern struct RANAP_PROTOCOL_IES PagingIEs[];
extern int PagingIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION PagingExtensions[];
extern int PagingExtensions_Size;
extern struct RANAP_PROTOCOL_IES CommonID_IEs[];
extern int CommonID_IEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION CommonIDExtensions[];
extern int CommonIDExtensions_Size;
extern struct RANAP_PROTOCOL_IES CN_InvokeTraceIEs[];
extern int CN_InvokeTraceIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION CN_InvokeTraceExtensions[];
extern int CN_InvokeTraceExtensions_Size;
extern struct RANAP_PROTOCOL_IES CN_DeactivateTraceIEs[];
extern int CN_DeactivateTraceIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION CN_DeactivateTraceExtensions[];
extern int CN_DeactivateTraceExtensions_Size;
extern struct RANAP_PROTOCOL_IES LocationReportingControlIEs[];
extern int LocationReportingControlIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION LocationReportingControlExtensions[];
extern int LocationReportingControlExtensions_Size;
extern struct RANAP_PROTOCOL_IES LocationReportIEs[];
extern int LocationReportIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION LocationReportExtensions[];
extern int LocationReportExtensions_Size;
extern struct RANAP_PROTOCOL_IES InitialUE_MessageIEs[];
extern int InitialUE_MessageIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION InitialUE_MessageExtensions[];
extern int InitialUE_MessageExtensions_Size;
extern struct RANAP_PROTOCOL_IES DirectTransferIEs[];
extern int DirectTransferIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION DirectTransferExtensions[];
extern int DirectTransferExtensions_Size;
extern struct RANAP_PROTOCOL_IES RedirectionIndication_IEs[];
extern int RedirectionIndication_IEs_Size;
extern struct RANAP_PROTOCOL_IES OverloadIEs[];
extern int OverloadIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION OverloadExtensions[];
extern int OverloadExtensions_Size;
extern struct RANAP_PROTOCOL_IES ErrorIndicationIEs[];
extern int ErrorIndicationIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION ErrorIndicationExtensions[];
extern int ErrorIndicationExtensions_Size;
extern struct RANAP_PROTOCOL_IES SRNS_DataForwardCommandIEs[];
extern int SRNS_DataForwardCommandIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION SRNS_DataForwardCommandExtensions[];
extern int SRNS_DataForwardCommandExtensions_Size;
extern struct RANAP_PROTOCOL_IES ForwardSRNS_ContextIEs[];
extern int ForwardSRNS_ContextIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION ForwardSRNS_ContextExtensions[];
extern int ForwardSRNS_ContextExtensions_Size;
extern struct RANAP_PROTOCOL_IES RAB_AssignmentRequestIEs[];
extern int RAB_AssignmentRequestIEs_Size;
extern struct RANAP_PROTOCOL_IES_PAIR RAB_SetupOrModifyItem_IEs[];
extern int RAB_SetupOrModifyItem_IEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION TransportLayerInformation_ExtIEs[];
extern int TransportLayerInformation_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_SetupOrModifyItemFirst_ExtIEs[];
extern int RAB_SetupOrModifyItemFirst_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_SetupOrModifyItemSecond_ExtIEs[];
extern int RAB_SetupOrModifyItemSecond_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_AssignmentRequestExtensions[];
extern int RAB_AssignmentRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES RAB_AssignmentResponseIEs[];
extern int RAB_AssignmentResponseIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_SetupOrModifiedItemIEs[];
extern int RAB_SetupOrModifiedItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_SetupOrModifiedItem_ExtIEs[];
extern int RAB_SetupOrModifiedItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_ReleasedItemIEs[];
extern int RAB_ReleasedItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_ReleasedItem_ExtIEs[];
extern int RAB_ReleasedItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION DataVolumeList_ExtIEs[];
extern int DataVolumeList_ExtIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_QueuedItemIEs[];
extern int RAB_QueuedItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_QueuedItem_ExtIEs[];
extern int RAB_QueuedItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_AssignmentResponseExtensions[];
extern int RAB_AssignmentResponseExtensions_Size;
extern struct RANAP_PROTOCOL_IES GERAN_Iumode_RAB_Failed_RABAssgntResponse_ItemIEs[];
extern int GERAN_Iumode_RAB_Failed_RABAssgntResponse_ItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION GERAN_Iumode_RAB_Failed_RABAssgntResponse_Item_ExtIEs[];
extern int GERAN_Iumode_RAB_Failed_RABAssgntResponse_Item_ExtIEs_Size;
extern struct RANAP_PRIVATE_IES PrivateMessage_IEs[];
extern int PrivateMessage_IEs_Size;
extern struct RANAP_PROTOCOL_IES RANAP_RelocationInformationIEs[];
extern int RANAP_RelocationInformationIEs_Size;
extern struct RANAP_PROTOCOL_IES DirectTransferInformationItemIEs_RANAP_RelocInf[];
extern int DirectTransferInformationItemIEs_RANAP_RelocInf_Size;
extern struct RANAP_PROTOCOL_EXTENSION RANAP_DirectTransferInformationItem_ExtIEs_RANAP_RelocInf[];
extern int RANAP_DirectTransferInformationItem_ExtIEs_RANAP_RelocInf_Size;
extern struct RANAP_PROTOCOL_IES RAB_ContextItemIEs_RANAP_RelocInf[];
extern int RAB_ContextItemIEs_RANAP_RelocInf_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_ContextItem_ExtIEs_RANAP_RelocInf[];
extern int RAB_ContextItem_ExtIEs_RANAP_RelocInf_Size;
extern struct RANAP_PROTOCOL_EXTENSION RANAP_RelocationInformationExtensions[];
extern int RANAP_RelocationInformationExtensions_Size;
extern struct RANAP_PROTOCOL_IES RAB_ModifyRequestIEs[];
extern int RAB_ModifyRequestIEs_Size;
extern struct RANAP_PROTOCOL_IES RAB_ModifyItemIEs[];
extern int RAB_ModifyItemIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_ModifyItem_ExtIEs[];
extern int RAB_ModifyItem_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION RAB_ModifyRequestExtensions[];
extern int RAB_ModifyRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES LocationRelatedDataRequestIEs[];
extern int LocationRelatedDataRequestIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION LocationRelatedDataRequestExtensions[];
extern int LocationRelatedDataRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES LocationRelatedDataResponseIEs[];
extern int LocationRelatedDataResponseIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION LocationRelatedDataResponseExtensions[];
extern int LocationRelatedDataResponseExtensions_Size;
extern struct RANAP_PROTOCOL_IES LocationRelatedDataFailureIEs[];
extern int LocationRelatedDataFailureIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION LocationRelatedDataFailureExtensions[];
extern int LocationRelatedDataFailureExtensions_Size;
extern struct RANAP_PROTOCOL_IES InformationTransferIndicationIEs[];
extern int InformationTransferIndicationIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION InformationTransferIndicationExtensions[];
extern int InformationTransferIndicationExtensions_Size;
extern struct RANAP_PROTOCOL_IES InformationTransferConfirmationIEs[];
extern int InformationTransferConfirmationIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION InformationTransferConfirmationExtensions[];
extern int InformationTransferConfirmationExtensions_Size;
extern struct RANAP_PROTOCOL_IES InformationTransferFailureIEs[];
extern int InformationTransferFailureIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION InformationTransferFailureExtensions[];
extern int InformationTransferFailureExtensions_Size;
extern struct RANAP_PROTOCOL_IES UESpecificInformationIndicationIEs[];
extern int UESpecificInformationIndicationIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION UESpecificInformationIndicationExtensions[];
extern int UESpecificInformationIndicationExtensions_Size;
extern struct RANAP_PROTOCOL_IES DirectInformationTransferIEs[];
extern int DirectInformationTransferIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION DirectInformationTransferExtensions[];
extern int DirectInformationTransferExtensions_Size;
extern struct RANAP_PROTOCOL_IES UplinkInformationExchangeRequestIEs[];
extern int UplinkInformationExchangeRequestIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION UplinkInformationExchangeRequestExtensions[];
extern int UplinkInformationExchangeRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES UplinkInformationExchangeResponseIEs[];
extern int UplinkInformationExchangeResponseIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION UplinkInformationExchangeResponseExtensions[];
extern int UplinkInformationExchangeResponseExtensions_Size;
extern struct RANAP_PROTOCOL_IES UplinkInformationExchangeFailureIEs[];
extern int UplinkInformationExchangeFailureIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION UplinkInformationExchangeFailureExtensions[];
extern int UplinkInformationExchangeFailureExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSSessionStartIEs[];
extern int MBMSSessionStartIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSSessionStartExtensions[];
extern int MBMSSessionStartExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSSessionStartResponseIEs[];
extern int MBMSSessionStartResponseIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSSessionStartResponseExtensions[];
extern int MBMSSessionStartResponseExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSSessionStartFailureIEs[];
extern int MBMSSessionStartFailureIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSSessionStartFailureExtensions[];
extern int MBMSSessionStartFailureExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSSessionUpdateIEs[];
extern int MBMSSessionUpdateIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSSessionUpdateExtensions[];
extern int MBMSSessionUpdateExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSSessionUpdateResponseIEs[];
extern int MBMSSessionUpdateResponseIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSSessionUpdateResponseExtensions[];
extern int MBMSSessionUpdateResponseExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSSessionUpdateFailureIEs[];
extern int MBMSSessionUpdateFailureIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSSessionUpdateFailureExtensions[];
extern int MBMSSessionUpdateFailureExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSSessionStopIEs[];
extern int MBMSSessionStopIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSSessionStopExtensions[];
extern int MBMSSessionStopExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSSessionStopResponseIEs[];
extern int MBMSSessionStopResponseIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSSessionStopResponseExtensions[];
extern int MBMSSessionStopResponseExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSUELinkingRequestIEs[];
extern int MBMSUELinkingRequestIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION LeftMBMSBearerService_ExtIEs[];
extern int LeftMBMSBearerService_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSUELinkingRequestExtensions[];
extern int MBMSUELinkingRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSUELinkingResponseIEs[];
extern int MBMSUELinkingResponseIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION UnsuccessfulLinking_ExtIEs[];
extern int UnsuccessfulLinking_ExtIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSUELinkingResponseExtensions[];
extern int MBMSUELinkingResponseExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSRegistrationRequestIEs[];
extern int MBMSRegistrationRequestIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSRegistrationRequestExtensions[];
extern int MBMSRegistrationRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSRegistrationResponseIEs[];
extern int MBMSRegistrationResponseIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSRegistrationResponseExtensions[];
extern int MBMSRegistrationResponseExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSRegistrationFailureIEs[];
extern int MBMSRegistrationFailureIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSRegistrationFailureExtensions[];
extern int MBMSRegistrationFailureExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSCNDe_RegistrationRequestIEs[];
extern int MBMSCNDe_RegistrationRequestIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSCNDe_RegistrationRequestExtensions[];
extern int MBMSCNDe_RegistrationRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSCNDe_RegistrationResponseIEs[];
extern int MBMSCNDe_RegistrationResponseIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSCNDe_RegistrationResponseExtensions[];
extern int MBMSCNDe_RegistrationResponseExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSRABEstablishmentIndicationIEs[];
extern int MBMSRABEstablishmentIndicationIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSRABEstablishmentIndicationExtensions[];
extern int MBMSRABEstablishmentIndicationExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSRABReleaseRequestIEs[];
extern int MBMSRABReleaseRequestIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSRABReleaseRequestExtensions[];
extern int MBMSRABReleaseRequestExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSRABReleaseIEs[];
extern int MBMSRABReleaseIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSRABReleaseExtensions[];
extern int MBMSRABReleaseExtensions_Size;
extern struct RANAP_PROTOCOL_IES MBMSRABReleaseFailureIEs[];
extern int MBMSRABReleaseFailureIEs_Size;
extern struct RANAP_PROTOCOL_EXTENSION MBMSRABReleaseFailureExtensions[];
extern int MBMSRABReleaseFailureExtensions_Size;

#ifdef __cplusplus
}
#endif

#endif
