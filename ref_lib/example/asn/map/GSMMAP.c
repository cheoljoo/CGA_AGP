#include <inc.h>
#include <GSMMAP.h>

#ifdef DYNAMIC_DB_SUPPORT
USER_PARA_t         user_para[MAX_USER_SET_PARA];
USER_SET_PARA_t     user_set_para[MAX_USER_SET_PARA];
#elif defined(NEW_DB)
Para_t				user_para;
#endif

#ifdef DYNAMIC_DB_SUPPORT
int GSM_MAP_DECODE( char *pdata, int length, int start_position, GSM_MAP_t *result_data ,char *u_data)
#elif defined(NEW_DB)
int GSM_MAP_DECODE( char *pdata, int length, int start_position, GSM_MAP_t *result_data ,Para_t *u_data)
#else
int GSM_MAP_DECODE( char *pdata, int length, int start_position, GSM_MAP_t *result_data)
#endif
{
	ASN1CTXT ctxt;
	int stats;

	if( length < start_position )
		return INVALID_LENGTH;
	
#ifdef DYNAMIC_DB_SUPPORT
	memset(user_para, 0, sizeof(USER_PARA_t)*MAX_USER_SET_PARA);
#elif defined(NEW_DB)
	memset(&user_para, 0, sizeof(Para_t));
#endif
	//stats = rtInitContextBuffer( &ctxt, (OSOCTET*)pdata, length );
	stats = rtInitContext( &ctxt );
	
	if( stats != ASN_OK ) 
		return INIT_CONTEXT_FAILED;

	xd_setp( &ctxt, pdata + start_position, length - start_position, 0, 0 );
#ifdef SS7_DEBUG
	printf(" GSM rr = %d \n", result_data->rr );
	printf(" GSM op code = %x \n", result_data->op_code);
#endif
	
	if( result_data->rr == 0 ) //Invoke
	{
		switch( result_data->op_code )
		{
		case 2:// updateLocation
			stats = asn1D_R5__updateLocation_ArgumentType( &ctxt, &result_data->OP.updateLocation, ASN1EXPL, 0 );
			break;
		case 3:// cancelLocation
			stats = asn1D_R5__cancelLocation_ArgumentType( &ctxt, &result_data->OP.cancelLocation, ASN1EXPL, 0 );
			//stats = asn1D_R5__cancelLocation_ArgumentType( &ctxt, &result_data->OP.cancelLocation, ASN1EXPL, 0 ,result_data->map_len);
			break;
			
		case 67:// purgeMS
			stats = asn1D_R5__purgeMS_ArgumentType( &ctxt, &result_data->OP.purgeMS, ASN1EXPL, 0 );
			break;
			
		case 55:// sendIdentification
			stats = asn1D_R5__sendIdentification_ArgumentType( &ctxt, &result_data->OP.sendIdentification, ASN1EXPL, 0 );
			break;
			
		case 23:// updateGprsLocation
			stats = asn1D_R5__updateGprsLocation_ArgumentType( &ctxt, &result_data->OP.updateGprsLocation, ASN1EXPL, 0 );
			break;
			
		case 70:// provideSubscriberInfo
			stats = asn1D_R5__provideSubscriberInfo_ArgumentType( &ctxt, &result_data->OP.provideSubscriberInfo, ASN1EXPL, 0 );
			break;
			
		case 71:// anyTimeInterrogation
			stats = asn1D_R5__anyTimeInterrogation_ArgumentType( &ctxt, &result_data->OP.anyTimeInterrogation, ASN1EXPL, 0 );
			break;
			
		case 62:// anyTimeSubscriptionInterrogation
			stats = asn1D_R5__anyTimeSubscriptionInterrogation_ArgumentType( &ctxt, &result_data->OP.anyTimeSubscriptionInterrogation, ASN1EXPL, 0 );
			break;
			
		case 65:// anyTimeModification
			stats = asn1D_R5__anyTimeModification_ArgumentType( &ctxt, &result_data->OP.anyTimeModification, ASN1EXPL, 0 );
			break;
			
		case 5:// noteSubscriberDataModified
			stats = asn1D_R5__noteSubscriberDataModified_ArgumentType( &ctxt, &result_data->OP.noteSubscriberDataModified, ASN1EXPL, 0 );
			break;
			
		case 68:// prepareHandover
			stats = asn1D_R5__prepareHandover_ArgumentType( &ctxt, &result_data->OP.prepareHandover, ASN1EXPL, 0 );
			break;
			
		case 29:// sendEndSignal
			stats = asn1D_R5__sendEndSignal_ArgumentType( &ctxt, &result_data->OP.sendEndSignal, ASN1EXPL, 0 );
			break;
			
		case 33:// processAccessSignalling
			stats = asn1D_R5__processAccessSignalling_ArgumentType( &ctxt, &result_data->OP.processAccessSignalling, ASN1EXPL, 0 );
			break;
			
		case 34:// forwardAccessSignalling
			stats = asn1D_R5__forwardAccessSignalling_ArgumentType( &ctxt, &result_data->OP.forwardAccessSignalling, ASN1EXPL, 0 );
			break;
			
		case 69:// prepareSubsequentHandover
			stats = asn1D_R5__prepareSubsequentHandover_ArgumentType( &ctxt, &result_data->OP.prepareSubsequentHandover, ASN1EXPL, 0 );
			break;
			
		case 56:// sendAuthenticationInfo
			stats = asn1D_R5__sendAuthenticationInfo_ArgumentType( &ctxt, &result_data->OP.sendAuthenticationInfo, ASN1EXPL, 0 );
			break;
			
		case 15:// authenticationFailureReport
			stats = asn1D_R5__authenticationFailureReport_ArgumentType( &ctxt, &result_data->OP.authenticationFailureReport, ASN1EXPL, 0 );
			break;
			
		case 43:// checkIMEI
			stats = asn1D_R5__checkIMEI_ArgumentType( &ctxt, &result_data->OP.checkIMEI, ASN1EXPL, 0 );
			break;
			
		case 7:// insertSubscriberData
			stats = asn1D_R5__insertSubscriberData_ArgumentType( &ctxt, &result_data->OP.insertSubscriberData, ASN1EXPL, 0 );
			break;
			
		case 8:// deleteSubscriberData
			stats = asn1D_R5__deleteSubscriberData_ArgumentType( &ctxt, &result_data->OP.deleteSubscriberData, ASN1EXPL, 0 );
			break;
			
		case 37:// reset
			stats = asn1D_R5__reset_ArgumentType( &ctxt, &result_data->OP.reset, ASN1EXPL, 0 );
			break;
			
			//_forwardCheckSS_Indication_ArgumentType forwardCheckSS_Indication; //38
		case 57:// restoreData
			stats = asn1D_R5__restoreData_ArgumentType( &ctxt, &result_data->OP.restoreData, ASN1EXPL, 0 );
			break;
			
		case 24:// sendRoutingInfoForGprs
			stats = asn1D_R5__sendRoutingInfoForGprs_ArgumentType( &ctxt, &result_data->OP.sendRoutingInfoForGprs, ASN1EXPL, 0 );
			break;
			
		case 25:// failureReport
			stats = asn1D_R5__failureReport_ArgumentType( &ctxt, &result_data->OP.failureReport, ASN1EXPL, 0 );
			break;
			
		case 26:// noteMsPresentForGprs
			stats = asn1D_R5__noteMsPresentForGprs_ArgumentType( &ctxt, &result_data->OP.noteMsPresentForGprs, ASN1EXPL, 0 );
			break;
			
		case 89:// noteMM_Event
			stats = asn1D_R5__noteMM_Event_ArgumentType( &ctxt, &result_data->OP.noteMM_Event, ASN1EXPL, 0 );
			break;
			
		case 50:// activateTraceMode
			stats = asn1D_R5__activateTraceMode_ArgumentType( &ctxt, &result_data->OP.activateTraceMode, ASN1EXPL, 0 );
			break;
			
		case 51:// deactivateTraceMode
			stats = asn1D_R5__deactivateTraceMode_ArgumentType( &ctxt, &result_data->OP.deactivateTraceMode, ASN1EXPL, 0 );
			break;
			
		case 58:// sendIMSI
			stats = asn1D_R5__sendIMSI_ArgumentType( &ctxt, &result_data->OP.sendIMSI, ASN1EXPL, 0 );
			break;
			
		case 22:// sendRoutingInfo
			stats = asn1D_R5__sendRoutingInfo_ArgumentType( &ctxt, &result_data->OP.sendRoutingInfo, ASN1EXPL, 0 );
			break;
			
		case 4:// provideRoamingNumber
			stats = asn1D_R5__provideRoamingNumber_ArgumentType( &ctxt, &result_data->OP.provideRoamingNumber, ASN1EXPL, 0 );
			break;
			
		case 6:// resumeCallHandling
			stats = asn1D_R5__resumeCallHandling_ArgumentType( &ctxt, &result_data->OP.resumeCallHandling, ASN1EXPL, 0 );
			break;
			
		case 31:// provideSIWFSNumber
			stats = asn1D_R5__provideSIWFSNumber_ArgumentType( &ctxt, &result_data->OP.provideSIWFSNumber, ASN1EXPL, 0 );
			break;
			
		case 32:// siwfs_SignallingModify
			stats = asn1D_R5__siwfs_SignallingModify_ArgumentType( &ctxt, &result_data->OP.siwfs_SignallingModify, ASN1EXPL, 0 );
			break;
			
		case 73:// setReportingState
			stats = asn1D_R5__setReportingState_ArgumentType( &ctxt, &result_data->OP.setReportingState, ASN1EXPL, 0 );
			break;
			
		case 74:// statusReport
			stats = asn1D_R5__statusReport_ArgumentType( &ctxt, &result_data->OP.statusReport, ASN1EXPL, 0 );
			break;
			
		case 75:// remoteUserFree
			stats = asn1D_R5__remoteUserFree_ArgumentType( &ctxt, &result_data->OP.remoteUserFree, ASN1EXPL, 0 );
			break;
			
		case 87:// ist_Alert
			stats = asn1D_R5__ist_Alert_ArgumentType( &ctxt, &result_data->OP.ist_Alert, ASN1EXPL, 0 );
			break;
			
		case 88:// ist_Command
			stats = asn1D_R5__ist_Command_ArgumentType( &ctxt, &result_data->OP.ist_Command, ASN1EXPL, 0 );
			break;
			
		case 10:// registerSS
			stats = asn1D_R5__registerSS_ArgumentType( &ctxt, &result_data->OP.registerSS, ASN1EXPL, 0 );
			break;
			
		case 11:// eraseSS
			stats = asn1D_R5__eraseSS_ArgumentType( &ctxt, &result_data->OP.eraseSS, ASN1EXPL, 0 );
			break;
			
		case 12:// activateSS
			stats = asn1D_R5__activateSS_ArgumentType( &ctxt, &result_data->OP.activateSS, ASN1EXPL, 0 );
			break;
			
		case 13:// deactivateSS
			stats = asn1D_R5__deactivateSS_ArgumentType( &ctxt, &result_data->OP.deactivateSS, ASN1EXPL, 0 );
			break;
			
		case 14:// interrogateSS
			stats = asn1D_R5__interrogateSS_ArgumentType( &ctxt, &result_data->OP.interrogateSS, ASN1EXPL, 0 );
			break;
			
		case 59:// processUnstructuredSS_Request
			stats = asn1D_R5__processUnstructuredSS_Request_ArgumentType( &ctxt, &result_data->OP.processUnstructuredSS_Request, ASN1EXPL, 0 );
			break;
			
		case 60:// unstructuredSS_Request
			stats = asn1D_R5__unstructuredSS_Request_ArgumentType( &ctxt, &result_data->OP.unstructuredSS_Request, ASN1EXPL, 0 );
			break;
			
		case 61:// unstructuredSS_Notify
			stats = asn1D_R5__unstructuredSS_Notify_ArgumentType( &ctxt, &result_data->OP.unstructuredSS_Notify, ASN1EXPL, 0 );
			break;
			
		case 17:// registerPassword
			stats = asn1D_R5__registerPassword_ArgumentType( &ctxt, &result_data->OP.registerPassword, ASN1EXPL, 0 );
			break;
			
		case 18:// getPassword
			stats = asn1D_R5__getPassword_ArgumentType( &ctxt, &result_data->OP.getPassword, ASN1EXPL, 0 );
			break;
			
		case 72:// ss_InvocationNotification
			stats = asn1D_R5__ss_InvocationNotification_ArgumentType( &ctxt, &result_data->OP.ss_InvocationNotification, ASN1EXPL, 0 );
			break;
			
		case 76:// registerCC_Entry
			stats = asn1D_R5__registerCC_Entry_ArgumentType( &ctxt, &result_data->OP.registerCC_Entry, ASN1EXPL, 0 );
			break;
			
		case 77:// eraseCC_Entry
			stats = asn1D_R5__eraseCC_Entry_ArgumentType( &ctxt, &result_data->OP.eraseCC_Entry, ASN1EXPL, 0 );
			break;
			
		case 45:// sendRoutingInfoForSM
			stats = asn1D_R5__sendRoutingInfoForSM_ArgumentType( &ctxt, &result_data->OP.sendRoutingInfoForSM, ASN1EXPL, 0 );
			break;
			
		case 46:// mo_ForwardSM
			stats = asn1D_R5__mo_ForwardSM_ArgumentType( &ctxt, &result_data->OP.mo_ForwardSM, ASN1EXPL, 0 );
			break;
			
		case 44:// mt_ForwardSM
			stats = asn1D_R5__mt_ForwardSM_ArgumentType( &ctxt, &result_data->OP.mt_ForwardSM, ASN1EXPL, 0 );
			break;
			
		case 47:// reportSM_DeliveryStatus
			stats = asn1D_R5__reportSM_DeliveryStatus_ArgumentType( &ctxt, &result_data->OP.reportSM_DeliveryStatus, ASN1EXPL, 0 );
			break;
			
		case 64:// alertServiceCentre
			stats = asn1D_R5__alertServiceCentre_ArgumentType( &ctxt, &result_data->OP.alertServiceCentre, ASN1EXPL, 0 );
			break;
			
		case 63:// informServiceCentre
			stats = asn1D_R5__informServiceCentre_ArgumentType( &ctxt, &result_data->OP.informServiceCentre, ASN1EXPL, 0 );
			break;
			
		case 66:// readyForSM
			stats = asn1D_R5__readyForSM_ArgumentType( &ctxt, &result_data->OP.readyForSM, ASN1EXPL, 0 );
			break;
			
		case 39:// prepareGroupCall
			stats = asn1D_R5__prepareGroupCall_ArgumentType( &ctxt, &result_data->OP.prepareGroupCall, ASN1EXPL, 0 );
			break;
			
		case 40:// sendGroupCallEndSignal
			stats = asn1D_R5__sendGroupCallEndSignal_ArgumentType( &ctxt, &result_data->OP.sendGroupCallEndSignal, ASN1EXPL, 0 );
			break;
			
		case 41:// processGroupCallSignalling
			stats = asn1D_R5__processGroupCallSignalling_ArgumentType( &ctxt, &result_data->OP.processGroupCallSignalling, ASN1EXPL, 0 );
			break;
			
		case 42:// forwardGroupCallSignalling
			stats = asn1D_R5__forwardGroupCallSignalling_ArgumentType( &ctxt, &result_data->OP.forwardGroupCallSignalling, ASN1EXPL, 0 );
			break;
			
		case 85:// sendRoutingInfoForLCS
			stats = asn1D_R5__sendRoutingInfoForLCS_ArgumentType( &ctxt, &result_data->OP.sendRoutingInfoForLCS, ASN1EXPL, 0 );
			break;
			
		case 83:// provideSubscriberLocation
			stats = asn1D_R5__provideSubscriberLocation_ArgumentType( &ctxt, &result_data->OP.provideSubscriberLocation, ASN1EXPL, 0 );
			break;
			
			//_subscriberLocationReport_ArgumentType subscriberLocationReport; //86
		case 78:// secureTransportClass1
			stats = asn1D_R5__secureTransportClass1_ArgumentType( &ctxt, &result_data->OP.secureTransportClass1, ASN1EXPL, 0 );
			break;
			
		case 79:// secureTransportClass2
			stats = asn1D_R5__secureTransportClass2_ArgumentType( &ctxt, &result_data->OP.secureTransportClass2, ASN1EXPL, 0 );
			break;
			
		case 80:// secureTransportClass3
			stats = asn1D_R5__secureTransportClass3_ArgumentType( &ctxt, &result_data->OP.secureTransportClass3, ASN1EXPL, 0 );
			break;
			
		case 81:// secureTransportClass4
			stats = asn1D_R5__secureTransportClass4_ArgumentType( &ctxt, &result_data->OP.secureTransportClass4, ASN1EXPL, 0 );
			break;

		default: //TODO: implement this!!
			break;
		}
	}
	else if( result_data->rr == 1 ) //Return-Result
	{
		switch( result_data->op_code )
		{
		case 2:// updateLocation
			stats = asn1D_R5__updateLocation_ResultType( &ctxt, &result_data->RR.updateLocation, ASN1EXPL, 0 );
			break;

		case 3:// cancelLocation
			stats = asn1D_R5__cancelLocation_ResultType( &ctxt, &result_data->RR.cancelLocation, ASN1EXPL, 0 );
			break;

		case 67:// purgeMS
			stats = asn1D_R5__purgeMS_ResultType( &ctxt, &result_data->RR.purgeMS, ASN1EXPL, 0 );
			break;

		case 55:// sendIdentification
			stats = asn1D_R5__sendIdentification_ResultType( &ctxt, &result_data->RR.sendIdentification, ASN1EXPL, 0 );
			break;

		case 23:// updateGprsLocation
			stats = asn1D_R5__updateGprsLocation_ResultType( &ctxt, &result_data->RR.updateGprsLocation, ASN1EXPL, 0 );
			break;

		case 70:// provideSubscriberInfo
			stats = asn1D_R5__provideSubscriberInfo_ResultType( &ctxt, &result_data->RR.provideSubscriberInfo, ASN1EXPL, 0 );
			break;

		case 71:// anyTimeInterrogation
			stats = asn1D_R5__anyTimeInterrogation_ResultType( &ctxt, &result_data->RR.anyTimeInterrogation, ASN1EXPL, 0 );
			break;

		case 62:// anyTimeSubscriptionInterrogation
			stats = asn1D_R5__anyTimeSubscriptionInterrogation_ResultType( &ctxt, &result_data->RR.anyTimeSubscriptionInterrogation, ASN1EXPL, 0 );
			break;

		case 65:// anyTimeModification
			stats = asn1D_R5__anyTimeModification_ResultType( &ctxt, &result_data->RR.anyTimeModification, ASN1EXPL, 0 );
			break;

		case 5:// noteSubscriberDataModified
			stats = asn1D_R5__noteSubscriberDataModified_ResultType( &ctxt, &result_data->RR.noteSubscriberDataModified, ASN1EXPL, 0 );
			break;

		case 68:// prepareHandover
			stats = asn1D_R5__prepareHandover_ResultType( &ctxt, &result_data->RR.prepareHandover, ASN1EXPL, 0 );
			break;

		case 29:// sendEndSignal
			stats = asn1D_R5__sendEndSignal_ResultType( &ctxt, &result_data->RR.sendEndSignal, ASN1EXPL, 0 );
			break;

		//_processAccessSignalling_ResultType processAccessSignalling; //33
		//_forwardAccessSignalling_ResultType forwardAccessSignalling; //34
		case 69:// prepareSubsequentHandover
			stats = asn1D_R5__prepareSubsequentHandover_ResultType( &ctxt, &result_data->RR.prepareSubsequentHandover, ASN1EXPL, 0 );
			break;

		case 56:// sendAuthenticationInfo
			stats = asn1D_R5__sendAuthenticationInfo_ResultType( &ctxt, &result_data->RR.sendAuthenticationInfo, ASN1EXPL, 0 );
			//stats = asn1D_R5__sendAuthenticationInfo_ResultType( &ctxt, &result_data->RR.sendAuthenticationInfo, ASN1EXPL, 0 ,result_data->map_len);
			break;

		case 15:// authenticationFailureReport
			stats = asn1D_R5__authenticationFailureReport_ResultType( &ctxt, &result_data->RR.authenticationFailureReport, ASN1EXPL, 0 );
			break;

		case 43:// checkIMEI
			stats = asn1D_R5__checkIMEI_ResultType( &ctxt, &result_data->RR.checkIMEI, ASN1EXPL, 0 );
			break;

		case 7:// insertSubscriberData
			stats = asn1D_R5__insertSubscriberData_ResultType( &ctxt, &result_data->RR.insertSubscriberData, ASN1EXPL, 0 );
			break;

		case 8:// deleteSubscriberData
			stats = asn1D_R5__deleteSubscriberData_ResultType( &ctxt, &result_data->RR.deleteSubscriberData, ASN1EXPL, 0 );
			break;

		//_reset_ResultType reset; //37
		//_forwardCheckSS_Indication_ResultType forwardCheckSS_Indication; //38
		case 57:// restoreData
			stats = asn1D_R5__restoreData_ResultType( &ctxt, &result_data->RR.restoreData, ASN1EXPL, 0 );
			break;

		case 24:// sendRoutingInfoForGprs
			stats = asn1D_R5__sendRoutingInfoForGprs_ResultType( &ctxt, &result_data->RR.sendRoutingInfoForGprs, ASN1EXPL, 0 );
			break;

		case 25:// failureReport
			stats = asn1D_R5__failureReport_ResultType( &ctxt, &result_data->RR.failureReport, ASN1EXPL, 0 );
			break;

		case 26:// noteMsPresentForGprs
			stats = asn1D_R5__noteMsPresentForGprs_ResultType( &ctxt, &result_data->RR.noteMsPresentForGprs, ASN1EXPL, 0 );
			break;

		case 89:// noteMM_Event
			stats = asn1D_R5__noteMM_Event_ResultType( &ctxt, &result_data->RR.noteMM_Event, ASN1EXPL, 0 );
			break;

		case 50:// activateTraceMode
			stats = asn1D_R5__activateTraceMode_ResultType( &ctxt, &result_data->RR.activateTraceMode, ASN1EXPL, 0 );
			break;

		case 51:// deactivateTraceMode
			stats = asn1D_R5__deactivateTraceMode_ResultType( &ctxt, &result_data->RR.deactivateTraceMode, ASN1EXPL, 0 );
			break;

		case 58:// sendIMSI
			stats = asn1D_R5__sendIMSI_ResultType( &ctxt, &result_data->RR.sendIMSI, ASN1EXPL, 0 );
			break;

		case 22:// sendRoutingInfo
			stats = asn1D_R5__sendRoutingInfo_ResultType( &ctxt, &result_data->RR.sendRoutingInfo, ASN1EXPL, 0 );
			break;

		case 4:// provideRoamingNumber
			stats = asn1D_R5__provideRoamingNumber_ResultType( &ctxt, &result_data->RR.provideRoamingNumber, ASN1EXPL, 0 );
			break;

		case 6:// resumeCallHandling
			stats = asn1D_R5__resumeCallHandling_ResultType( &ctxt, &result_data->RR.resumeCallHandling, ASN1EXPL, 0 );
			break;

		case 31:// provideSIWFSNumber
			stats = asn1D_R5__provideSIWFSNumber_ResultType( &ctxt, &result_data->RR.provideSIWFSNumber, ASN1EXPL, 0 );
			break;

		case 32:// siwfs_SignallingModify
			stats = asn1D_R5__siwfs_SignallingModify_ResultType( &ctxt, &result_data->RR.siwfs_SignallingModify, ASN1EXPL, 0 );
			break;

		case 73:// setReportingState
			stats = asn1D_R5__setReportingState_ResultType( &ctxt, &result_data->RR.setReportingState, ASN1EXPL, 0 );
			break;

		case 74:// statusReport
			stats = asn1D_R5__statusReport_ResultType( &ctxt, &result_data->RR.statusReport, ASN1EXPL, 0 );
			break;

		case 75:// remoteUserFree
			stats = asn1D_R5__remoteUserFree_ResultType( &ctxt, &result_data->RR.remoteUserFree, ASN1EXPL, 0 );
			break;

		case 87:// ist_Alert
			stats = asn1D_R5__ist_Alert_ResultType( &ctxt, &result_data->RR.ist_Alert, ASN1EXPL, 0 );
			break;

		case 88:// ist_Command
			stats = asn1D_R5__ist_Command_ResultType( &ctxt, &result_data->RR.ist_Command, ASN1EXPL, 0 );
			break;

		case 10:// registerSS
			stats = asn1D_R5__registerSS_ResultType( &ctxt, &result_data->RR.registerSS, ASN1EXPL, 0 );
			break;

		case 11:// eraseSS
			stats = asn1D_R5__eraseSS_ResultType( &ctxt, &result_data->RR.eraseSS, ASN1EXPL, 0 );
			break;

		case 12:// activateSS
			stats = asn1D_R5__activateSS_ResultType( &ctxt, &result_data->RR.activateSS, ASN1EXPL, 0 );
			break;

		case 13:// deactivateSS
			stats = asn1D_R5__deactivateSS_ResultType( &ctxt, &result_data->RR.deactivateSS, ASN1EXPL, 0 );
			break;

		case 14:// interrogateSS
			stats = asn1D_R5__interrogateSS_ResultType( &ctxt, &result_data->RR.interrogateSS, ASN1EXPL, 0 );
			break;

		case 59:// processUnstructuredSS_Request
			stats = asn1D_R5__processUnstructuredSS_Request_ResultType( &ctxt, &result_data->RR.processUnstructuredSS_Request, ASN1EXPL, 0 );
			break;

		case 60:// unstructuredSS_Request
			stats = asn1D_R5__unstructuredSS_Request_ResultType( &ctxt, &result_data->RR.unstructuredSS_Request, ASN1EXPL, 0 );
			break;

		//_unstructuredSS_Notify_ResultType unstructuredSS_Notify; //61
		case 17:// registerPassword
			stats = asn1D_R5__registerPassword_ResultType( &ctxt, &result_data->RR.registerPassword, ASN1EXPL, 0 );
			break;

		case 18:// getPassword
			stats = asn1D_R5__getPassword_ResultType( &ctxt, &result_data->RR.getPassword, ASN1EXPL, 0 );
			break;

		case 72:// ss_InvocationNotification
			stats = asn1D_R5__ss_InvocationNotification_ResultType( &ctxt, &result_data->RR.ss_InvocationNotification, ASN1EXPL, 0 );
			break;

		case 76:// registerCC_Entry
			stats = asn1D_R5__registerCC_Entry_ResultType( &ctxt, &result_data->RR.registerCC_Entry, ASN1EXPL, 0 );
			break;

		case 77:// eraseCC_Entry
			stats = asn1D_R5__eraseCC_Entry_ResultType( &ctxt, &result_data->RR.eraseCC_Entry, ASN1EXPL, 0 );
			break;

		case 45:// sendRoutingInfoForSM
			stats = asn1D_R5__sendRoutingInfoForSM_ResultType( &ctxt, &result_data->RR.sendRoutingInfoForSM, ASN1EXPL, 0 );
			break;

		case 46:// mo_ForwardSM
			stats = asn1D_R5__mo_ForwardSM_ResultType( &ctxt, &result_data->RR.mo_ForwardSM, ASN1EXPL, 0 );
			break;

		case 44:// mt_ForwardSM
			stats = asn1D_R5__mt_ForwardSM_ResultType( &ctxt, &result_data->RR.mt_ForwardSM, ASN1EXPL, 0 );
			break;

		case 47:// reportSM_DeliveryStatus
			stats = asn1D_R5__reportSM_DeliveryStatus_ResultType( &ctxt, &result_data->RR.reportSM_DeliveryStatus, ASN1EXPL, 0 );
			break;

		//_alertServiceCentre_ResultType alertServiceCentre; //64
		//_informServiceCentre_ResultType informServiceCentre; //63
		case 66:// readyForSM
			stats = asn1D_R5__readyForSM_ResultType( &ctxt, &result_data->RR.readyForSM, ASN1EXPL, 0 );
			break;

		case 39:// prepareGroupCall
			stats = asn1D_R5__prepareGroupCall_ResultType( &ctxt, &result_data->RR.prepareGroupCall, ASN1EXPL, 0 );
			break;

		case 40:// sendGroupCallEndSignal
			stats = asn1D_R5__sendGroupCallEndSignal_ResultType( &ctxt, &result_data->RR.sendGroupCallEndSignal, ASN1EXPL, 0 );
			break;

		//_processGroupCallSignalling_ResultType processGroupCallSignalling; //41
		//_forwardGroupCallSignalling_ResultType forwardGroupCallSignalling; //42
		case 85:// sendRoutingInfoForLCS
			stats = asn1D_R5__sendRoutingInfoForLCS_ResultType( &ctxt, &result_data->RR.sendRoutingInfoForLCS, ASN1EXPL, 0 );
			break;

		case 83:// provideSubscriberLocation
			stats = asn1D_R5__provideSubscriberLocation_ResultType( &ctxt, &result_data->RR.provideSubscriberLocation, ASN1EXPL, 0 );
			break;

		//_subscriberLocationReport_ResultType subscriberLocationReport; //86
		case 78:// secureTransportClass1
			stats = asn1D_R5__secureTransportClass1_ResultType( &ctxt, &result_data->RR.secureTransportClass1, ASN1EXPL, 0 );
			break;

		//_secureTransportClass2_ResultType secureTransportClass2; //79
		case 80:// secureTransportClass3
			stats = asn1D_R5__secureTransportClass3_ResultType( &ctxt, &result_data->RR.secureTransportClass3, ASN1EXPL, 0 );
			break;

		//_secureTransportClass4_ResultType secureTransportClass4; //81

		default: //TODO: implement this!!
			break;
		}
	}
	else if( result_data->rr == 2 ) //Return-Error
	{
		switch( result_data->op_code )
		{
		case 34://systemFailure
			stats = asn1D_R5__systemFailure_ParameterType( &ctxt, &result_data->RE.systemFailure, ASN1EXPL, 0 );
			break;

		case 35://dataMissing
			stats = asn1D_R5__dataMissing_ParameterType( &ctxt, &result_data->RE.dataMissing, ASN1EXPL, 0 );
			break;

		case 36://unexpectedDataValue
			stats = asn1D_R5__unexpectedDataValue_ParameterType( &ctxt, &result_data->RE.unexpectedDataValue, ASN1EXPL, 0 );
			break;

		case 21://facilityNotSupported
			stats = asn1D_R5__facilityNotSupported_ParameterType( &ctxt, &result_data->RE.facilityNotSupported, ASN1EXPL, 0 );
			break;

		case 28://incompatibleTerminal
			stats = asn1D_R5__incompatibleTerminal_ParameterType( &ctxt, &result_data->RE.incompatibleTerminal, ASN1EXPL, 0 );
			break;

		case 51://resourceLimitation
			stats = asn1D_R5__resourceLimitation_ParameterType( &ctxt, &result_data->RE.resourceLimitation, ASN1EXPL, 0 );
			break;

		case 1://unknownSubscriber
			stats = asn1D_R5__unknownSubscriber_ParameterType( &ctxt, &result_data->RE.unknownSubscriber, ASN1EXPL, 0 );
			break;

		case 44://numberChanged
			stats = asn1D_R5__numberChanged_ParameterType( &ctxt, &result_data->RE.numberChanged, ASN1EXPL, 0 );
			break;

		//_unknownMSC_ParameterType Data; //3
		case 5://unidentifiedSubscriber
			stats = asn1D_R5__unidentifiedSubscriber_ParameterType( &ctxt, &result_data->RE.unidentifiedSubscriber, ASN1EXPL, 0 );
			break;

		//_unknownEquipment_ParameterType Data; //7
		case 8://roamingNotAllowed
			stats = asn1D_R5__roamingNotAllowed_ParameterType( &ctxt, &result_data->RE.roamingNotAllowed, ASN1EXPL, 0 );
			break;

		case 9://illegalSubscriber
			stats = asn1D_R5__illegalSubscriber_ParameterType( &ctxt, &result_data->RE.illegalSubscriber, ASN1EXPL, 0 );
			break;

		case 12://illegalEquipment
			stats = asn1D_R5__illegalEquipment_ParameterType( &ctxt, &result_data->RE.illegalEquipment, ASN1EXPL, 0 );
			break;

		case 10://bearerServiceNotProvisioned
			stats = asn1D_R5__bearerServiceNotProvisioned_ParameterType( &ctxt, &result_data->RE.bearerServiceNotProvisioned, ASN1EXPL, 0 );
			break;

		case 11://teleserviceNotProvisioned
			stats = asn1D_R5__teleserviceNotProvisioned_ParameterType( &ctxt, &result_data->RE.teleserviceNotProvisioned, ASN1EXPL, 0 );
			break;

		//_noHandoverNumberAvailable_ParameterType Data; //25
		//_subsequentHandoverFailure_ParameterType Data; //26
		case 42://targetCellOutsideGroupCallArea
			stats = asn1D_R5__targetCellOutsideGroupCallArea_ParameterType( &ctxt, &result_data->RE.targetCellOutsideGroupCallArea, ASN1EXPL, 0 );
			break;

		case 40://tracingBufferFull
			stats = asn1D_R5__tracingBufferFull_ParameterType( &ctxt, &result_data->RE.tracingBufferFull, ASN1EXPL, 0 );
			break;

		case 39://noRoamingNumberAvailable
			stats = asn1D_R5__noRoamingNumberAvailable_ParameterType( &ctxt, &result_data->RE.noRoamingNumberAvailable, ASN1EXPL, 0 );
			break;

		case 27://absentSubscriber
			stats = asn1D_R5__absentSubscriber_ParameterType( &ctxt, &result_data->RE.absentSubscriber, ASN1EXPL, 0 );
			break;

		case 45://busySubscriber
			stats = asn1D_R5__busySubscriber_ParameterType( &ctxt, &result_data->RE.busySubscriber, ASN1EXPL, 0 );
			break;

		case 46://noSubscriberReply
			stats = asn1D_R5__noSubscriberReply_ParameterType( &ctxt, &result_data->RE.noSubscriberReply, ASN1EXPL, 0 );
			break;

		case 13://callBarred
			stats = asn1D_R5__callBarred_ParameterType( &ctxt, &result_data->RE.callBarred, ASN1EXPL, 0 );
			break;

		case 14://forwardingViolation
			stats = asn1D_R5__forwardingViolation_ParameterType( &ctxt, &result_data->RE.forwardingViolation, ASN1EXPL, 0 );
			break;

		case 47://forwardingFailed
			stats = asn1D_R5__forwardingFailed_ParameterType( &ctxt, &result_data->RE.forwardingFailed, ASN1EXPL, 0 );
			break;

		case 15://cug_Reject
			stats = asn1D_R5__cug_Reject_ParameterType( &ctxt, &result_data->RE.cug_Reject, ASN1EXPL, 0 );
			break;

		case 48://or_NotAllowed
			stats = asn1D_R5__or_NotAllowed_ParameterType( &ctxt, &result_data->RE.or_NotAllowed, ASN1EXPL, 0 );
			break;

		case 49://ati_NotAllowed
			stats = asn1D_R5__ati_NotAllowed_ParameterType( &ctxt, &result_data->RE.ati_NotAllowed, ASN1EXPL, 0 );
			break;

		case 60://atsi_NotAllowed
			stats = asn1D_R5__atsi_NotAllowed_ParameterType( &ctxt, &result_data->RE.atsi_NotAllowed, ASN1EXPL, 0 );
			break;

		case 61://atm_NotAllowed
			stats = asn1D_R5__atm_NotAllowed_ParameterType( &ctxt, &result_data->RE.atm_NotAllowed, ASN1EXPL, 0 );
			break;

		case 62://informationNotAvailable
			stats = asn1D_R5__informationNotAvailable_ParameterType( &ctxt, &result_data->RE.informationNotAvailable, ASN1EXPL, 0 );
			break;

		case 16://illegalSS_Operation
			stats = asn1D_R5__illegalSS_Operation_ParameterType( &ctxt, &result_data->RE.illegalSS_Operation, ASN1EXPL, 0 );
			break;

		case 17://ss_ErrorStatus
			stats = asn1D_R5__ss_ErrorStatus_ParameterType( &ctxt, &result_data->RE.ss_ErrorStatus, ASN1EXPL, 0 );
			break;

		case 18://ss_NotAvailable
			stats = asn1D_R5__ss_NotAvailable_ParameterType( &ctxt, &result_data->RE.ss_NotAvailable, ASN1EXPL, 0 );
			break;

		case 19://ss_SubscriptionViolation
			stats = asn1D_R5__ss_SubscriptionViolation_ParameterType( &ctxt, &result_data->RE.ss_SubscriptionViolation, ASN1EXPL, 0 );
			break;

		case 20://ss_Incompatibility
			stats = asn1D_R5__ss_Incompatibility_ParameterType( &ctxt, &result_data->RE.ss_Incompatibility, ASN1EXPL, 0 );
			break;

		//_unknownAlphabet_ParameterType Data; //71
		//_ussd_Busy_ParameterType Data; //72
		case 37://pw_RegistrationFailure
			stats = asn1D_R5__pw_RegistrationFailure_ParameterType( &ctxt, &result_data->RE.pw_RegistrationFailure, ASN1EXPL, 0 );
			break;

		//_negativePW_Check_ParameterType Data; //38
		//_numberOfPW_AttemptsViolation_ParameterType Data; //43
		case 29://shortTermDenial
			stats = asn1D_R5__shortTermDenial_ParameterType( &ctxt, &result_data->RE.shortTermDenial, ASN1EXPL, 0 );
			break;

		case 30://longTermDenial
			stats = asn1D_R5__longTermDenial_ParameterType( &ctxt, &result_data->RE.longTermDenial, ASN1EXPL, 0 );
			break;

		case 31://subscriberBusyForMT_SMS
			stats = asn1D_R5__subscriberBusyForMT_SMS_ParameterType( &ctxt, &result_data->RE.subscriberBusyForMT_SMS, ASN1EXPL, 0 );
			break;

		case 32://sm_DeliveryFailure
			stats = asn1D_R5__sm_DeliveryFailure_ParameterType( &ctxt, &result_data->RE.sm_DeliveryFailure, ASN1EXPL, 0 );
			break;

		case 33://messageWaitingListFull
			stats = asn1D_R5__messageWaitingListFull_ParameterType( &ctxt, &result_data->RE.messageWaitingListFull, ASN1EXPL, 0 );
			break;

		case 6://absentSubscriberSM
			stats = asn1D_R5__absentSubscriberSM_ParameterType( &ctxt, &result_data->RE.absentSubscriberSM, ASN1EXPL, 0 );
			break;

		case 50://noGroupCallNumberAvailable
			stats = asn1D_R5__noGroupCallNumberAvailable_ParameterType( &ctxt, &result_data->RE.noGroupCallNumberAvailable, ASN1EXPL, 0 );
			break;

		case 52://unauthorizedRequestingNetwork
			stats = asn1D_R5__unauthorizedRequestingNetwork_ParameterType( &ctxt, &result_data->RE.unauthorizedRequestingNetwork, ASN1EXPL, 0 );
			break;

		case 53://unauthorizedLCSClient
			stats = asn1D_R5__unauthorizedLCSClient_ParameterType( &ctxt, &result_data->RE.unauthorizedLCSClient, ASN1EXPL, 0 );
			break;

		case 54://positionMethodFailure
			stats = asn1D_R5__positionMethodFailure_ParameterType( &ctxt, &result_data->RE.positionMethodFailure, ASN1EXPL, 0 );
			break;

		case 58://unknownOrUnreachableLCSClient
			stats = asn1D_R5__unknownOrUnreachableLCSClient_ParameterType( &ctxt, &result_data->RE.unknownOrUnreachableLCSClient, ASN1EXPL, 0 );
			break;

		case 59://mm_EventNotSupported
			stats = asn1D_R5__mm_EventNotSupported_ParameterType( &ctxt, &result_data->RE.mm_EventNotSupported, ASN1EXPL, 0 );
			break;

		case 4://secureTransportError
			stats = asn1D_R5__secureTransportError_ParameterType( &ctxt, &result_data->RE.secureTransportError, ASN1EXPL, 0 );
			break;

		default: //TODO: implement this!!
			break;
		}
	}
	else
		return INVALID_OP_CODE_TYPE;

	if( stats != 0 )
		return DECODING_FAILED;

	rtFreeContext( &ctxt );

#ifdef DYNAMIC_DB_SUPPORT
    memcpy(u_data, (char *)&user_para[0],sizeof(USER_PARA_t)*MAX_USER_SET_PARA);
#elif defined(NEW_DB)
	memcpy(u_data, &user_para, sizeof(Para_t));
#endif	

	return 0;
}

void DYNAMIC_DB_CP(int	w_code, int len, char *data)
{
	int					i,j;

#ifdef DYNAMIC_DB_SUPPORT
	for(i=0;i<MAX_USER_SET_PARA;i++)
	{
		if( user_set_para[i].used_flag && 
			user_set_para[i].protocol == DYNAMIC_DB_PROTO_WCDMA_MAP ) 
		{
			if( w_code == user_set_para[i].parameter )
			{
				for(j=0;j<MAX_USER_SET_PARA;j++)
				{
					if( !user_para[j].decode_ok )
					{
						user_para[j].para_id = user_set_para[i].parameter;
						user_para[j].db_idx = user_set_para[i].db_idx;
						user_para[j].para_len = len;
						user_para[j].decode_ok = 1;
						memcpy(user_para[j].data, data, len);
				
						break;
					}
				}
			}
		}
	}
#elif defined(NEW_DB)
	
	if(user_para.dec_total_cnt >= (MAX_USER_SET_PARA-1) || len > 128 )
	{
		printf("=== LIB] Parameter cnt over(%d) or length over(%d) \n",user_para.dec_total_cnt,len);
		return;
	}
	user_para.Tag[user_para.dec_total_cnt] = w_code;
	user_para.Length[user_para.dec_total_cnt] = len;
	memcpy(user_para.data[user_para.dec_total_cnt], data, len);
	user_para.dec_total_cnt++;
#endif
}
