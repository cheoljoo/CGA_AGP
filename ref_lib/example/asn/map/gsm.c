#include <inc.h>
#include <GSMMAP.h>
extern NO7_PACKET_t		no7_packet;
extern	GSM_MAP_t		gsm_map;
//GSM_MAP_R4_t			gsm_map_r4;
extern	int				map_cnt;
extern 	char			camel_flag;

/* component length 가 무정의 형 check */
int chk_para_len_indef(TCAP_PACKET_t *pkt, int idx);
/* tcap length 가 무정의 형 check */
int chk_tcap_len_indef(TCAP_PACKET_t *pkt, int idx);
/* Dialogue Portion 에서 gsm Version을 얻어오는 함수 */
int get_gsm_version(TCAP_PACKET_t	*tc);
void make_asn_1_data(int i,int *gsm_dec_pos,char *data);

void dec_gsm(char *data, ushort caplen, int *dec_pos)
{
	int				rtn ;
	int				i;
	int				gsm_dec_pos = 0;
	int				gsm_version = 0;
#ifdef DYNAMIC_DB_SUPPORT
    USER_PARA_t     u_para[MAX_USER_SET_PARA];
    char        	user_para[sizeof(USER_PARA_t)*MAX_USER_SET_PARA+1];
#elif defined(NEW_DB)
	Para_t			user_para;
#endif

	gsm_version = get_gsm_version(&no7_packet.tcap_packet);
//	memset(&gsm_map_r4, 0x00, sizeof(GSM_MAP_R4_t));
	/* GSM Map Decoding 은 기본적으로 Parameter Tag + Parameter Length 를 
		포한 시켜줘야 한다. */

	for(i=0;i<map_cnt;i++)
	{
		printf("%d> map_len = %d \n", i,no7_packet.tcap_packet.map_len[i]);
		memset( &gsm_map, 0x00, sizeof(GSM_MAP_t));
		gsm_dec_pos = no7_packet.tcap_packet.map_pos[i];

		gsm_map.op_code = no7_packet.tcap_packet.op_code[i];
		gsm_map.rr = no7_packet.tcap_packet.rr[i];
		gsm_map.map_len = no7_packet.tcap_packet.map_len[i];

		if( no7_packet.tcap_packet.map_len[i] == 0 ) continue;


		make_asn_1_data(i,&gsm_dec_pos,data);

DumpLog(&data[gsm_dec_pos], "gsm", 30);
		
		if(camel_flag)
		{
			rtn = camel_dec(data,caplen,gsm_dec_pos,(char *)&gsm_map);
		//	(*dec_pos) += (int)gsm_map.map_len;
			continue;
		}
		else
		{
			switch(gsm_version)
			{
			case 3:
#ifdef DYNAMIC_DB_SUPPORT
				rtn = GSM_MAP_DECODE(data, (int)caplen, gsm_dec_pos, &gsm_map, user_para);
#elif defined(NEW_DB)
				rtn = GSM_MAP_DECODE(data, (int)caplen, gsm_dec_pos, &gsm_map, &user_para);
#endif
				break;
			case 2:
				rtn = gsm_dec_R4(data,caplen,gsm_dec_pos,(char *)&gsm_map);
				break;

			case 1:
				rtn = gsm_dec_R99(data,caplen,gsm_dec_pos,(char *)&gsm_map);
				break;
			}
		}

		if( gsm_version != 3 ) continue;
#ifdef DYNAMIC_DB_SUPPORT
/////////
// Dynamic DB Test
        memcpy(u_para, (USER_PARA_t *)user_para, sizeof(USER_PARA_t)*MAX_USER_SET_PARA);
		printf(" =========== Defined Parameter ------------------ \n");
        for(i=0;i<MAX_USER_SET_PARA;i++)
        {
            if( u_para[i].decode_ok)
            {
                printf(" USER PARA] parameter = %d , db_idx = %d\n",u_para[i].para_id,u_para[i].db_idx);
                printf("            ");prt_data(u_para[i].data,u_para[i].para_len);
            }
        }
#elif defined(NEW_DB)
		printf(" =========== WCDMA MAP DECODE \n");
		printf("TAG]   LENGTH]    DATA] \n");
		for(i=0;i<user_para.dec_total_cnt;i++)
		{
		printf("%05d     %03d     ",user_para.Tag[i],user_para.Length[i]);
		prt_data(user_para.data[i],user_para.Length[i]);
		}
		printf("=============================== \n");
#endif

		if( rtn != 0 )
		{
			printf(" %d) GSMMAP DECODE fail(%d) code(%x) rr(%d)\n",i,rtn,gsm_map.op_code,gsm_map.rr);
			continue;
		}
		if( gsm_map.rr == 0 )
		{
			switch( gsm_map.op_code )
			{
			case 2:		// updateLocation
#ifdef GSM_PRT
				asn1Print_R5__updateLocation_ArgumentType("updateLocation", (void *)&gsm_map.OP.updateLocation);
#endif
				break; 	
			case 3:		// cancelLocation
#ifdef GSM_PRT
				asn1Print_R5__cancelLocation_ArgumentType("cancelLocation", (void *)&gsm_map.OP.cancelLocation);
#endif
				break;
			case 67:	// purgeMS
#ifdef GSM_PRT
				asn1Print_R5__purgeMS_ArgumentType("purgeMS", (void *)&gsm_map.OP.purgeMS);
#endif			
				break;

			case 55:	// sendIdentification
#ifdef GSM_PRT
				asn1Print_R5__sendIdentification_ArgumentType("sendIdentification",(void *)&gsm_map.OP.sendIdentification);
#endif
				break;

			case 23:	// updateGprsLocation
#ifdef GSM_PRT
				asn1Print_R5__updateGprsLocation_ArgumentType("updateGprsLocation",(void *)&gsm_map.OP.updateGprsLocation);
#endif
				break;

			case 70:	// provideSubscriberInfo
#ifdef GSM_PRT
				asn1Print_R5__provideSubscriberInfo_ArgumentType("provideSubscriberInfo",(void *)&gsm_map.OP.provideSubscriberInfo);
#endif
				break;
			case 71:	// anyTimeInterrogation
#ifdef GSM_PRT
				asn1Print_R5__anyTimeInterrogation_ArgumentType("anyTimeInterrogation", (void *)&gsm_map.OP.anyTimeInterrogation);
#endif
				break;
			case 62:	// anyTimeModification
#ifdef GSM_PRT
				asn1Print_R5__anyTimeModification_ArgumentType("anyTimeModification", (void *)&gsm_map.OP.anyTimeModification);
#endif
				break;

			case 5:		// noteSubscriberDataModified
#ifdef GSM_PRT
				asn1Print_R5__noteSubscriberDataModified_ArgumentType("noteSubscriberDataModified", (void *)&gsm_map.OP.noteSubscriberDataModified);
#endif
				break;

			case 68:
#ifdef GSM_PRT
				asn1Print_R5__prepareHandover_ArgumentType("prepareHandover", (void *)&gsm_map.OP.prepareHandover);
#endif
				break;

			case 29:	// sendEndSignal
#ifdef GSM_PRT
				asn1Print_R5__sendEndSignal_ArgumentType("sendEndSignal", (void *)&gsm_map.OP.sendEndSignal);
#endif
				break;

			case 33:	// processAccessSignalling
#ifdef GSM_PRT
				asn1Print_R5__processAccessSignalling_ArgumentType("processAccessSignalling", (void *)&gsm_map.OP.processAccessSignalling);
#endif
				break;

			case 34:	// forwardAccessSignalling
#ifdef GSM_PRT
				asn1Print_R5__forwardAccessSignalling_ArgumentType("forwardAccessSignalling", (void *)&gsm_map.OP.forwardAccessSignalling);
#endif
				break;

			case 69:	// prepareSubsequentHandover
#ifdef GSM_PRT
				asn1Print_R5__prepareSubsequentHandover_ArgumentType("prepareSubsequentHandover", (void *)&gsm_map.OP.prepareSubsequentHandover);
#endif
				break;

			case 56:	// sendAuthenticationInfo
#ifdef GSM_PRT
				asn1Print_R5__sendAuthenticationInfo_ArgumentType("sendAuthenticationInfo", (void *)&gsm_map.OP.sendAuthenticationInfo);
#endif
				break;

			case 15:	// authenticationFailureReport
#ifdef GSM_PRT
				asn1Print_R5__authenticationFailureReport_ArgumentType("authenticationFailureReport", (void *)&gsm_map.OP.authenticationFailureReport);
#endif
				break;

			case 43:	// checkIMEI
#ifdef GSM_PRT
				asn1Print_R5__checkIMEI_ArgumentType("checkIMEI",(void *)&gsm_map.OP.checkIMEI);
#endif
				break;

			case 7:		// insertSubscriberData
#ifdef GSM_PRT
				asn1Print_R5__insertSubscriberData_ArgumentType("insertSubscriberData",(void *)&gsm_map.OP.insertSubscriberData);
#endif
				break;

			case 8:		// deleteSubscriberData
#ifdef GSM_PRT
				asn1Print_R5__deleteSubscriberData_ArgumentType("deleteSubscriberData",(void *)&gsm_map.OP.deleteSubscriberData);
#endif
				break;

			case 37:	// reset
#ifdef GSM_PRT
				asn1Print_R5__reset_ArgumentType("reset",(void *)&gsm_map.OP.reset);
#endif
				break;

			case 57:	// restoreData
#ifdef GSM_PRT
				asn1Print_R5__restoreData_ArgumentType("restoreData",(void *)&gsm_map.OP.restoreData);
#endif
				break;

			case 24:	// sendRoutingInfoForGprs
#ifdef GSM_PRT
				asn1Print_R5__sendRoutingInfoForGprs_ArgumentType("sendRoutingInfoForGprs",(void *)&gsm_map.OP.sendRoutingInfoForGprs);
#endif
				break;

			case 25:	// failureReport
#ifdef GSM_PRT
				asn1Print_R5__failureReport_ArgumentType("failureReport",(void *)&gsm_map.OP.failureReport);
#endif
				break;

			case 26:	// noteMsPresentForGprs
#ifdef GSM_PRT
				asn1Print_R5__noteMsPresentForGprs_ArgumentType("noteMsPresentForGprs",(void *)&gsm_map.OP.noteMsPresentForGprs);
#endif
				break;

			case 89:	// noteMM_Event
#ifdef GSM_PRT
				asn1Print_R5__noteMM_Event_ArgumentType("noteMM_Event",(void *)&gsm_map.OP.noteMM_Event);
#endif
				break;

			case 50:	// activateTraceMode
#ifdef GSM_MAP
				asn1Print_R5__activateTraceMode_ArgumentType("activateTraceMode",(void *)&gsm_map.OP.activateTraceMode);
#endif
				break;

			case 51:	// deactivateTraceMode
#ifdef GSM_MAP
				asn1Print_R5__deactivateTraceMode_ArgumentType("deactivateTraceMode",(void *)&gsm_map.OP.deactivateTraceMode);
#endif
				break;
			
			case 58:	// sendIMSI
#ifdef GSM_MAP
				asn1Print_R5__sendIMSI_ArgumentType("sendIMSI",(void *)&gsm_map.OP.sendIMSI);
#endif
				DumpLog((char *)gsm_map.OP.sendIMSI.data, "sendIMSI", gsm_map.OP.sendIMSI.numocts);
				break;

			case 22:	// sendRoutingInfo
#ifdef GSM_MAP
				asn1Print_R5__sendRoutingInfo_ArgumentType("sendRoutingInfo",(void *)&gsm_map.OP.sendRoutingInfo);
#endif
				break;

			case 4:		// provideRoamingNumber
#ifdef GSM_MAP
				asn1Print_R5__provideRoamingNumber_ArgumentType("provideRoamingNumber",(void *)&gsm_map.OP.provideRoamingNumber);
#endif
				break;

			case 6:		// resumeCallHandling
#ifdef GSM_MAP
				asn1Print_R5__resumeCallHandling_ArgumentType("resumeCallHandling",(void *)&gsm_map.OP.resumeCallHandling);
#endif
				break;

			case 31:	// provideSIWFSNumber
#ifdef GSM_MAP
				asn1Print_R5__provideSIWFSNumber_ArgumentType("provideSIWFSNumber",(void *)&gsm_map.OP.provideSIWFSNumber);
#endif
				break;

			case 32:	// siwfs_SignallingModify
#ifdef GSM_MAP
				asn1Print_R5__siwfs_SignallingModify_ArgumentType("siwfs_SignallingModify",(void *)&gsm_map.OP.siwfs_SignallingModify);
#endif
				break;

			case 73:	// setReportingState
#ifdef GSM_MAP
				asn1Print_R5__setReportingState_ArgumentType("setReportingState",(void *)&gsm_map.OP.setReportingState);
#endif
				break;

			case 74:	// statusReport
#ifdef GSM_MAP
				asn1Print_R5__statusReport_ArgumentType("statusReport", (void *)&gsm_map.OP.statusReport);
#endif
				break;

			case 75:	// remoteUserFree
#ifdef GSM_PRT
				asn1Print_R5__remoteUserFree_ArgumentType("remoteUserFree",(void *)&gsm_map.OP.remoteUserFree);
#endif
				break;

			case 87:	// ist_Alert
#ifdef GSM_PRT
				asn1Print_R5__ist_Alert_ArgumentType("ist_Alert",(void *)&gsm_map.OP.ist_Alert);
#endif
				break;

			case 88:	// ist_Command
#ifdef GSM_PRT
				asn1Print_R5__ist_Command_ArgumentType("ist_Command",(void *)&gsm_map.OP.ist_Command);
#endif
				break;

			case 10:	// registerSS
#ifdef GSM_PRT
				asn1Print_R5__registerSS_ArgumentType("registerSS",(void *)&gsm_map.OP.registerSS);
#endif
				break;

			case 11:	// eraseSS
#ifdef GSM_PRT
				asn1Print_R5__eraseSS_ArgumentType("eraseSS",(void *)&gsm_map.OP.eraseSS);
#endif
				break;

			case 12:	// activateSS
#ifdef GSM_PRT
				asn1Print_R5__activateSS_ArgumentType("activateSS",(void *)&gsm_map.OP.activateSS);
#endif
				break;

			case 13:	// deactivateSS
#ifdef GSM_PRT
				asn1Print_R5__deactivateSS_ArgumentType("deactivateSS",(void *)&gsm_map.OP.deactivateSS);
#endif
				break;

			case 14:	// interrogateSS
#ifdef GSM_PRT
				asn1Print_R5__interrogateSS_ArgumentType("interrogateSS", (void *)&gsm_map.OP.interrogateSS);
#endif
				break;

			case 59:	// processUnstructuredSS_Request
#ifdef GSM_PRT
				asn1Print_R5__processUnstructuredSS_Request_ArgumentType("processUnstructuredSS_Request",(void *)&gsm_map.OP.processUnstructuredSS_Request);
#endif
				break;

			case 60:	// unstructuredSS_Request
#ifdef GSM_PRT
				asn1Print_R5__unstructuredSS_Request_ArgumentType("unstructuredSS_Request",(void *)&gsm_map.OP.unstructuredSS_Request);
#endif
				break;

			case 61:	// unstructuredSS_Notify
#ifdef GSM_PRT
				asn1Print_R5__unstructuredSS_Notify_ArgumentType("unstructuredSS_Notify",(void *)&gsm_map.OP.unstructuredSS_Notify);
#endif
				break;

			case 17: // registerPassword
#ifdef GSM_PRT
				asn1Print_R5__registerPassword_ArgumentType("registerPassword",(void *)&gsm_map.OP.registerPassword);
#endif
				break;

			case 18:	// getPassword
#ifdef GSM_PRT
				asn1Print_R5__getPassword_ArgumentType("getPassword",(void *)&gsm_map.OP.getPassword);
#endif
				break;

			case 72:	// ss_InvocationNotification
#ifdef GSM_PRT
				asn1Print_R5__ss_InvocationNotification_ArgumentType("ss_InvocationNotification",(void *)&gsm_map.OP.ss_InvocationNotification);
#endif
				break;

			case 76:	// registerCC_Entry
#ifdef GSM_PRT
				asn1Print_R5__registerCC_Entry_ArgumentType("registerCC_Entry",(void *)&gsm_map.OP.registerCC_Entry);
#endif
				break;

			case 77:	// eraseCC_Entry
#ifdef GSM_PRT
				asn1Print_R5__eraseCC_Entry_ArgumentType("eraseCC_Entry",(void *)&gsm_map.OP.eraseCC_Entry);
#endif
				break;

			case 45:	// sendRoutingInfoForSM
#ifdef GSM_PRT
				asn1Print_R5__sendRoutingInfoForSM_ArgumentType("sendRoutingInfoForSM", (void *)&gsm_map.OP.sendRoutingInfoForSM);				
#endif
				break;

			case 44:	// mt_ForwardSM
#ifdef GSM_PRT
				asn1Print_R5__mt_ForwardSM_ArgumentType("mt_ForwardSM",(void *)&gsm_map.OP.mt_ForwardSM);
#endif
				break;

			case 47:	// reportSM_DeliveryStatus
#ifdef GSM_PRT
				asn1Print_R5__reportSM_DeliveryStatus_ArgumentType("reportSM_DeliveryStatus",(void *)&gsm_map.OP.reportSM_DeliveryStatus);
#endif
				break;

			case 64:	// alertServiceCentre
#ifdef GSM_PRT
				asn1Print_R5__alertServiceCentre_ArgumentType("alertServiceCentre",(void *)&gsm_map.OP.alertServiceCentre);
#endif
				break;
			case 63:	// informServiceCentre
#ifdef GSM_PRT
				asn1Print_R5__informServiceCentre_ArgumentType("informServiceCentre",(void *)&gsm_map.OP.informServiceCentre);
#endif
				break;

			case 66:	// readyForSM
#ifdef GSM_PRT
				asn1Print_R5__readyForSM_ArgumentType("readyForSM",(void *)&gsm_map.OP.readyForSM);
#endif
				break;

			case 39:	// prepareGroupCall
#ifdef GSM_PRT
				asn1Print_R5__prepareGroupCall_ArgumentType("prepareGroupCall",(void *)&gsm_map.OP.prepareGroupCall);
#endif
				break;

			case 40:	// sendGroupCallEndSignal
#ifdef GSM_PRT
				asn1Print_R5__sendGroupCallEndSignal_ArgumentType("sendGroupCallEndSignal",(void *)&gsm_map.OP.sendGroupCallEndSignal);
#endif
				break;

			case 41:	// processGroupCallSignalling
#ifdef GSM_PRT
				asn1Print_R5__processGroupCallSignalling_ArgumentType("processGroupCallSignalling",(void *)&gsm_map.OP.processGroupCallSignalling);
#endif
				break;

			case 42:	// forwardGroupCallSignalling
#ifdef GSM_PRT
				asn1Print_R5__forwardGroupCallSignalling_ArgumentType("forwardGroupCallSignalling",(void *)&gsm_map.OP.forwardGroupCallSignalling);
#endif
				break;

			case 85:	// sendRoutingInfoForLCS
#ifdef GSM_PRT
				asn1Print_R5__sendRoutingInfoForLCS_ArgumentType("sendRoutingInfoForLCS", (void *)&gsm_map.OP.sendRoutingInfoForLCS);
#endif
				break;

			case 83:	// provideSubscriberLocation
#ifdef GSM_PRT
				asn1Print_R5__provideSubscriberLocation_ArgumentType("provideSubscriberLocation",(void *)&gsm_map.OP.provideSubscriberLocation);
#endif
				break;

			case 78:	// secureTransportClass1
#ifdef GSM_PRT
				asn1Print_R5__secureTransportClass1_ArgumentType("secureTransportClass1",(void *)&gsm_map.OP.secureTransportClass1);
#endif
				break;

			case 79:	// secureTransportClass2
#ifdef GSM_PRT
				asn1Print_R5__secureTransportClass2_ArgumentType("secureTransportClass2",(void *)&gsm_map.OP.secureTransportClass2);
#endif
				break;

			case 80:	// secureTransportClass3
#ifdef GSM_PRT
				asn1Print_R5__secureTransportClass3_ArgumentType("secureTransportClass3",(void *)&gsm_map.OP.secureTransportClass3);
#endif
				break;

			case 81:	// secureTransportClass4
#ifdef GSM_PRT
				asn1Print_R5__secureTransportClass4_ArgumentType("secureTransportClass4",(void *)&gsm_map.OP.secureTransportClass4);
#endif
				break;

			case 46:	// OP.mo_ForwardSM
#ifdef GSM_PRT
				asn1Print_R5__mo_ForwardSM_ArgumentType("OP.mo_ForwardSM",(void *)&gsm_map.OP.mo_ForwardSM);
#endif
				break;

			default:
				printf(" GSM Unknown Op code (%x) \n", gsm_map.op_code);

				break;
			}
		}
		else if ( gsm_map.rr == 1 )		// Return Result
		{
			switch( gsm_map.op_code )
			{
			case 2:		// updateLocation
#ifdef GSM_PRT
				asn1Print_R5__updateLocation_ResultType("updateLocation_rr",(void *)&gsm_map.RR.updateLocation);
#endif
				break;
		
			case 3:		// cancelLocation
#ifdef GSM_PRT
				asn1Print_R5__cancelLocation_ResultType("cancelLocation_rr",(void *)&gsm_map.RR.cancelLocation);
#endif
				break;	

			case 67:	// purgeMS
#ifdef GSM_PRT
				asn1Print_R5__purgeMS_ResultType("purgeMS_rr",(void *)&gsm_map.RR.purgeMS);
#endif
				break;

			case 55:	// sendIdentification
#ifdef GSM_PRT
				asn1Print_R5__sendIdentification_ResultType("sendIdentification_rr",(void *)&gsm_map.RR.sendIdentification);
#endif
				break;

			case 23:	// updateGprsLocation
#ifdef GSM_PRT
				asn1Print_R5__updateGprsLocation_ResultType("updateGprsLocation_rr",(void *)&gsm_map.RR.updateGprsLocation);
#endif
				break;

			case 70:	// provideSubscriberInfo
#ifdef GSM_PRT
				asn1Print_R5__provideSubscriberInfo_ResultType("provideSubscriberInfo_rr",(void *)&gsm_map.RR.provideSubscriberInfo);
#endif
				break;

			case 71:	// anyTimeInterrogation
#ifdef GSM_PRT
				asn1Print_R5__anyTimeModification_ResultType("anyTimeInterrogation_rr",(void *)&gsm_map.RR.anyTimeInterrogation);
#endif
				break;

			case 62:	// anyTimeSubscriptionInterrogation
#ifdef GSM_PRT
				asn1Print_R5__anyTimeSubscriptionInterrogation_ResultType("anyTimeSubscriptionInterrogation_rr",(void *)&gsm_map.RR.anyTimeSubscriptionInterrogation);
#endif
				break;

			case 65:	// anyTimeModification
#ifdef GSM_PRT
				asn1Print_R5__anyTimeModification_ResultType("anyTimeModification_rr",(void *)&gsm_map.RR.anyTimeModification);
#endif
				break;

			case 5:		// noteSubscriberDataModified
#ifdef GSM_PRT
				asn1Print_R5__noteSubscriberDataModified_ResultType("noteSubscriberDataModified_rr",(void *)&gsm_map.RR.noteSubscriberDataModified);
#endif
				break;

			case 68:	// prepareHandover
#ifdef GSM_PRT
				asn1Print_R5__prepareHandover_ResultType("prepareHandover_rr",(void *)&gsm_map.RR.prepareHandover);
#endif
				break;

			case 29:	// sendEndSignal
#ifdef GSM_PRT
				asn1Print_R5__sendEndSignal_ResultType("sendEndSignal_rr",(void *)&gsm_map.RR.sendEndSignal);
#endif
				break;

			case 69:	// prepareSubsequentHandover
#ifdef GSM_PRT
				asn1Print_R5__prepareSubsequentHandover_ResultType("prepareSubsequentHandover_rr",(void *)&gsm_map.RR.prepareSubsequentHandover);
#endif
				break;

			case 56:	// sendAuthenticationInfo
#ifdef GSM_PRT
				asn1Print_R5__sendAuthenticationInfo_ResultType("sendAuthenticationInfo_rr",(void *)&gsm_map.RR.sendAuthenticationInfo);
#endif
printf(" print ok \n");
				break;

			case 15:	// authenticationFailureReport
#ifdef GSM_PRT
				asn1Print_R5__authenticationFailureReport_ResultType("authenticationFailureReport_rr",(void *)&gsm_map.RR.authenticationFailureReport);
#endif
				break;

			case 43:	// checkIMEI
#ifdef GSM_PRT
				asn1Print_R5__checkIMEI_ResultType("checkIMEI_rr",(void *)&gsm_map.RR.checkIMEI);
#endif
				break;

			case 7:		// insertSubscriberData
#ifdef GSM_PRT
				asn1Print_R5__insertSubscriberData_ResultType("insertSubscriberData_rr",(void *)&gsm_map.RR.insertSubscriberData);
#endif
				break;

			case 8:		// deleteSubscriberData
#ifdef GSM_PRT
				asn1Print_R5__deleteSubscriberData_ResultType("deleteSubscriberData_rr",(void *)&gsm_map.RR.deleteSubscriberData);
#endif
				break;

			case 57:	// restoreData
#ifdef GSM_PRT
				asn1Print_R5__restoreData_ResultType("restoreData_rr",(void *)&gsm_map.RR.restoreData);
#endif
				break;

			case 24:	// sendRoutingInfoForGprs
#ifdef GSM_PRT
				asn1Print_R5__sendRoutingInfoForGprs_ResultType("sendRoutingInfoForGprs_rr",(void *)&gsm_map.RR.sendRoutingInfoForGprs);
#endif
				break;

			case 25:	// failureReport
#ifdef GSM_PRT
				asn1Print_R5__failureReport_ResultType("failureReport_rr",(void *)&gsm_map.RR.failureReport);
#endif
				break;

			case 26:	// noteMsPresentForGprs
#ifdef GSM_PRT
				asn1Print_R5__noteMsPresentForGprs_ResultType("noteMsPresentForGprs_rr",(void *)&gsm_map.RR.noteMsPresentForGprs);
#endif
				break;

			case 89:	// noteMM_Event
#ifdef GSM_PRT
				asn1Print_R5__noteMM_Event_ResultType("noteMM_Event_rr",(void *)&gsm_map.RR.noteMM_Event);
#endif
				break;

			case 50:	// activateTraceMode
#ifdef GSM_PRT
				asn1Print_R5__activateTraceMode_ResultType("activateTraceMode_rr",(void *)&gsm_map.RR.activateTraceMode);
#endif
				break;

			case 51:	// deactivateTraceMode
#ifdef GSM_PRT
				asn1Print_R5__deactivateTraceMode_ResultType("deactivateTraceMode_rr",(void *)&gsm_map.RR.deactivateTraceMode);
#endif
				break;

			case 58:	// sendIMSI
#ifdef GSM_PRT
				asn1Print_R5__sendIMSI_ResultType("sendIMSI_rr",(void *)&gsm_map.RR.sendIMSI);
#endif
				break;

			case 22:	// sendRoutingInfo
#ifdef GSM_PRT
				asn1Print_R5__sendRoutingInfo_ResultType("sendRoutingInfo_rr",(void *)&gsm_map.RR.sendRoutingInfo);
#endif
				break;

			case 4:		// provideRoamingNumber
#ifdef GSM_PRT
				asn1Print_R5__provideRoamingNumber_ResultType("provideRoamingNumber_rr",(void *)&gsm_map.RR.provideRoamingNumber);
#endif
				break;

			case 6:		// resumeCallHandling
#ifdef GSM_PRT
				asn1Print_R5__resumeCallHandling_ResultType("resumeCallHandling_rr",(void *)&gsm_map.RR.resumeCallHandling);
#endif
				break;

			case 31:	// provideSIWFSNumber
#ifdef GSM_PRT
				asn1Print_R5__provideSIWFSNumber_ResultType("provideSIWFSNumber_rr",(void *)&gsm_map.RR.provideSIWFSNumber);
#endif
				break;

			case 32:	// siwfs_SignallingModify
#ifdef GSM_PRT
				asn1Print_R5__siwfs_SignallingModify_ResultType("siwfs_SignallingModify_rr",(void *)&gsm_map.RR.siwfs_SignallingModify);
#endif
				break;

			case 73:	// setReportingState
#ifdef GSM_PRT
				asn1Print_R5__setReportingState_ResultType("setReportingState_rr",(void *)&gsm_map.RR.setReportingState);
#endif
				break;

			case 74:	// statusReport
#ifdef GSM_PRT
				asn1Print_R5__statusReport_ResultType("statusReport_rr",(void *)&gsm_map.RR.statusReport);
#endif
				break;

			case 75:	// remoteUserFree

#ifdef GSM_PRT
				asn1Print_R5__remoteUserFree_ResultType("remoteUserFree_rr",(void *)&gsm_map.RR.remoteUserFree);
#endif
				break;

			case 87:	// ist_Alert
#ifdef GSM_PRT
				asn1Print_R5__ist_Alert_ResultType("ist_Alert_rr",(void *)&gsm_map.RR.ist_Alert);
#endif
				break;

			case 88:	// ist_Command
#ifdef GSM_PRT
				asn1Print_R5__ist_Command_ResultType("ist_Command_rr",(void *)&gsm_map.RR.ist_Command);
#endif
				break;

			case 10:	// registerSS
#ifdef GSM_PRT
				asn1Print_R5__registerSS_ResultType("registerSS_rr",(void *)&gsm_map.RR.registerSS);
#endif
				break;

			case 11:	// eraseSS
#ifdef GSM_PRT
				asn1Print_R5__eraseSS_ResultType("eraseSS_rr",(void *)&gsm_map.RR.eraseSS);
#endif
				break;
			
			case 12:	// activateSS
#ifdef GSM_PRT
				asn1Print_R5__activateSS_ResultType("activateSS_rr",(void *)&gsm_map.RR.activateSS);
#endif
				break;

			case 13:	// deactivateSS
#ifdef GSM_PRT
				asn1Print_R5__deactivateSS_ResultType("deactivateSS_rr",(void *)&gsm_map.RR.deactivateSS);
#endif
				break;

			case 14:	// interrogateSS
#ifdef GSM_PRT
				asn1Print_R5__interrogateSS_ResultType("interrogateSS_rr",(void *)&gsm_map.RR.interrogateSS);
#endif
				break;

			case 59:	// processUnstructuredSS_Request
#ifdef GSM_PRT
				asn1Print_R5__processUnstructuredSS_Request_ResultType("processUnstructuredSS_Request_rr",(void *)&gsm_map.RR.processUnstructuredSS_Request);
#endif
				break;

			case 60:	// unstructuredSS_Request
#ifdef GSM_PRT
				asn1Print_R5__unstructuredSS_Request_ResultType("unstructuredSS_Request_rr",(void *)&gsm_map.RR.unstructuredSS_Request);
#endif
				break;

			case 17:	// registerPassword
#ifdef GSM_PRT
				asn1Print_R5__registerPassword_ResultType("registerPassword_rr",(void *)&gsm_map.RR.registerPassword);
#endif
				break;

			case 18:	// getPassword
#ifdef GSM_PRT
				asn1Print_R5__getPassword_ResultType("getPassword_rr",(void *)&gsm_map.RR.getPassword);
#endif
				break;

			case 72:	// ss_InvocationNotification
#ifdef GSM_PRT
				asn1Print_R5__ss_InvocationNotification_ResultType("ss_InvocationNotification_rr",(void *)&gsm_map.RR.ss_InvocationNotification);
#endif
				break;

			case 76:	// registerCC_Entry
#ifdef GSM_PRT
				asn1Print_R5__registerCC_Entry_ResultType("registerCC_Entry_rr",(void *)&gsm_map.RR.registerCC_Entry);
#endif
				break;

			case 77:	// eraseCC_Entry
#ifdef GSM_PRT
				asn1Print_R5__eraseCC_Entry_ResultType("eraseCC_Entry_rr",(void *)&gsm_map.RR.eraseCC_Entry);
#endif
				break;

			case 45:	// sendRoutingInfoForSM
#ifdef GSM_PRT
				asn1Print_R5__sendRoutingInfoForSM_ResultType("sendRoutingInfoForSM_rr",(void *)&gsm_map.RR.sendRoutingInfoForSM);
#endif
				break;

			case 46:	// mo_ForwardSM
#ifdef GSM_PRT
				asn1Print_R5__mo_ForwardSM_ResultType("mo_ForwardSM_rr",(void *)&gsm_map.RR.mo_ForwardSM);
#endif
				break;

			case 44:	// mt_ForwardSM
#ifdef GSM_PRT
				asn1Print_R5__mt_ForwardSM_ResultType("mt_ForwardSM_rr",(void *)&gsm_map.RR.mt_ForwardSM);
#endif
				break;

			case 47:	// reportSM_DeliveryStatus
#ifdef GSM_PRT
				asn1Print_R5__reportSM_DeliveryStatus_ResultType("reportSM_DeliveryStatus_rr",(void *)&gsm_map.RR.reportSM_DeliveryStatus);
#endif
				break;

			case 66:	// readyForSM
#ifdef GSM_PRT
				asn1Print_R5__readyForSM_ResultType("readyForSM_rr",(void *)&gsm_map.RR.readyForSM);
#endif
				break;

			case 39:	// prepareGroupCall
#ifdef GSM_PRT
				asn1Print_R5__prepareGroupCall_ResultType("prepareGroupCall_rr",(void *)&gsm_map.RR.prepareGroupCall);
#endif
				break;

			case 40:	// sendGroupCallEndSignal
#ifdef GSM_PRT
				asn1Print_R5__sendGroupCallEndSignal_ResultType("sendGroupCallEndSignal_rr",(void *)&gsm_map.RR.sendGroupCallEndSignal);
#endif
				break;

			case 85:	// sendRoutingInfoForLCS
#ifdef GSM_PRT
				asn1Print_R5__sendRoutingInfoForLCS_ResultType("sendRoutingInfoForLCS_rr",(void *)&gsm_map.RR.sendRoutingInfoForLCS);
#endif
				break;

			case 83:	// provideSubscriberLocation
#ifdef GSM_PRT
				asn1Print_R5__provideSubscriberLocation_ResultType("provideSubscriberLocation_rr",(void *)&gsm_map.RR.provideSubscriberLocation);
#endif
				break;

			case 78:	// secureTransportClass1
#ifdef GSM_PRT
				asn1Print_R5__secureTransportClass1_ResultType("secureTransportClass1_rr",(void *)&gsm_map.RR.secureTransportClass1);
#endif
				break;

			case 80:	// secureTransportClass3
#ifdef GSM_PRT
				asn1Print_R5__secureTransportClass3_ResultType("secureTransportClass3_rr",(void *)&gsm_map.RR.secureTransportClass3);
#endif
				break;

			default:

				break;
			}
		}
		else if ( gsm_map.rr == 2 )
		{
			switch( gsm_map.op_code )
			{
			case 6:	// absentSubscriberSM
#ifdef GSM_PRT
				asn1Print_R5__absentSubscriber_ParameterType("absentSubscriberSM",(void *)&gsm_map.RE.absentSubscriberSM);
#endif
				break;

			case 0x20:
#ifdef GSM_PRT
				asn1Print_R5__sm_DeliveryFailure_ParameterType("SM",(void *)&gsm_map.RE.sm_DeliveryFailure);
#endif
				break;
			default:
				break;
			}
				
		}
		usleep(1000);
//		DumpLog(data,"GSM",caplen);
	} 
	if( map_cnt >= 1 )
	{
		*dec_pos += (int)gsm_map.map_len;
		printf(" *dec_pos = %d \n",*dec_pos);
	}
}

void make_asn_1_data(int i, int *gsm_dec_pos,char *data)
{

	if( gsm_map.op_code == 56 && gsm_map.rr == 0 ) // sendAuthenticationInfo invoke
	{
		if( chk_para_len_indef(&no7_packet.tcap_packet,i) ||
			chk_tcap_len_indef(&no7_packet.tcap_packet,i) )
		{
			(*gsm_dec_pos) -= 2;
			data[(*gsm_dec_pos)] = 0x30;
			data[(*gsm_dec_pos)+1] = 0x80;
		}
		else if(no7_packet.tcap_packet.map_len[i] < 128 )
		{
			(*gsm_dec_pos) -= 2;
			data[(*gsm_dec_pos)] = 0x30;
			data[(*gsm_dec_pos)+1] = (uchar)no7_packet.tcap_packet.map_len[i];
		}
		else if (no7_packet.tcap_packet.map_len[i] >= 128 )	
		{
			(*gsm_dec_pos) -= 3;
			data[(*gsm_dec_pos)+1] = 0x30;
			data[(*gsm_dec_pos)+2] = (uchar)no7_packet.tcap_packet.map_len[i];
		}	

	}
	else if ((gsm_map.op_code == 56 && gsm_map.rr == 1) ||  // sendAuthenticationInfo return
			(gsm_map.op_code == 0x0B && gsm_map.rr == 1 ) )
	{
		if( chk_para_len_indef(&no7_packet.tcap_packet,i) )
		{
			(*gsm_dec_pos) -= 2;
			data[(*gsm_dec_pos)] = 0xA3;
			data[(*gsm_dec_pos)+1] = 0x80;
		}
		else if(no7_packet.tcap_packet.map_len[i] < 128 )
		{
			(*gsm_dec_pos) -= 2;
			data[(*gsm_dec_pos)] = 0xA3;
			data[(*gsm_dec_pos)+1] = (uchar)no7_packet.tcap_packet.map_len[i];
		}
		else if (no7_packet.tcap_packet.map_len[i] >= 128 )	
		{
			(*gsm_dec_pos) -= 3;
			data[(*gsm_dec_pos)] = 0xA3;
			data[(*gsm_dec_pos)+1] = 0x81;
			data[(*gsm_dec_pos)+2] = (uchar)no7_packet.tcap_packet.map_len[i];
		}	

	}
	else if ( (gsm_map.op_code == 58 && gsm_map.rr == 0 ) || 
			  //(gsm_map.op_code == 43 && gsm_map.rr == 0 )) // sendIMSI invoke
			  (gsm_map.op_code == 18 )|| // getPassword
			  (gsm_map.op_code == 17 ) || // registerPassword
			  //(uchar)data[(*gsm_dec_pos)] == (uchar)0xA0 ||
			  (uchar)data[(*gsm_dec_pos)] == (uchar)0xA1 ||
			  (gsm_map.op_code == 43 )) // sendIMSI invoke
	{
		;
	} 

#if 1
// Test purgeMS
	else if ( gsm_map.op_code == 67 && gsm_map.rr == 0 )
	{
		if( chk_para_len_indef(&no7_packet.tcap_packet,i) )
		{
			(*gsm_dec_pos) -= 2;
			data[(*gsm_dec_pos)] = 0xA3;
			data[(*gsm_dec_pos)+1] = 0x80;
		}
		else if(no7_packet.tcap_packet.map_len[i] < 128 )
		{
			(*gsm_dec_pos) -= 2;
			data[(*gsm_dec_pos)] = 0xA3;
			data[(*gsm_dec_pos)+1] = (uchar)no7_packet.tcap_packet.map_len[i];
		}
		else if (no7_packet.tcap_packet.map_len[i] >= 128 )	
		{
			(*gsm_dec_pos) -= 3;
			data[(*gsm_dec_pos)] = 0xA3;
			data[(*gsm_dec_pos)+1] = 0x81;
			data[(*gsm_dec_pos)+2] = (uchar)no7_packet.tcap_packet.map_len[i];
		}	
	}
#endif

	else if ( gsm_map.op_code == 14 && gsm_map.rr == 1 ) // interrogateSS return 
	{
		(*gsm_dec_pos) -= 2;
		data[(*gsm_dec_pos)] = 0xA3;
		data[(*gsm_dec_pos)+1] = (uchar)no7_packet.tcap_packet.map_len[i]; 		
	} 

	else if ( gsm_map.op_code == 3 && gsm_map.rr == 0 ) // cancelLocation
	{
		if( chk_para_len_indef(&no7_packet.tcap_packet,i) ||
			chk_tcap_len_indef(&no7_packet.tcap_packet,i) )
		{
			(*gsm_dec_pos) -= 2;
			data[(*gsm_dec_pos)] = 0xA3;
			data[(*gsm_dec_pos)+1] = 0x80;
		}
		else
		{
			(*gsm_dec_pos) -= 2;	
			data[(*gsm_dec_pos)] = 0xA3;;
			data[(*gsm_dec_pos)+1] = (uchar)no7_packet.tcap_packet.map_len[i]; 		
		}
	}

	else if ( (uchar)data[(*gsm_dec_pos)-2] == 0xA3 ||
		(uchar)data[(*gsm_dec_pos)-3] == 0xA3 )
	{

		if( no7_packet.tcap_packet.map_len[i] <= 128 )
			((*gsm_dec_pos)) -= 2;
		else if ( no7_packet.tcap_packet.map_len[i] > 128 && no7_packet.tcap_packet.map_len[i] < 256 )
			((*gsm_dec_pos)) -= 3;
	}	
	else if( no7_packet.tcap_packet.map_len[i] >= 128 && no7_packet.tcap_packet.map_len[i] < 256 &&
			 !chk_para_len_indef(&no7_packet.tcap_packet,i) )
	{
		/* 확장 1형 0x81xx */
		(*gsm_dec_pos) -= 3;
		data[(*gsm_dec_pos)] = 0x30;
		data[(*gsm_dec_pos)+1] = 0x81;
		data[(*gsm_dec_pos)+2] = (uchar)(no7_packet.tcap_packet.map_len[i]);
	}
	else if ( no7_packet.tcap_packet.map_len[i] > 256 && no7_packet.tcap_packet.map_len[i] < 65535 && 
			  !chk_para_len_indef(&no7_packet.tcap_packet,i))
	{
		/* 확장 2형 0x82aabb */
		((*gsm_dec_pos)) -= -4;
		data[(*gsm_dec_pos)] = 0x30;
		data[(*gsm_dec_pos)+1] = 0x82;
		data[(*gsm_dec_pos)+2] = no7_packet.tcap_packet.map_len[i] / 256;
		data[(*gsm_dec_pos)+3] = no7_packet.tcap_packet.map_len[i] % 256;
	}
	/* tcap length 가 무 정의 형 */
	else if ( chk_para_len_indef(&no7_packet.tcap_packet,i) )
	{
		((*gsm_dec_pos)) -= 2;
#if 0
		data[(*gsm_dec_pos)] = 0x30;
		data[(*gsm_dec_pos)+1] = 0x80;
#endif
	}
	else
	{
		if( gsm_map.op_code == 3 && gsm_map.rr == 0 && (uchar)data[(*gsm_dec_pos)-2] == (uchar)0xA3 ) 
		{
			(*gsm_dec_pos) -= 2;
		}
		else if ( gsm_map.op_code == 3 && gsm_map.rr == 0 && (uchar)data[(*gsm_dec_pos)-2] != (uchar)0xA3)
		{
			(*gsm_dec_pos) -= 2;
			data[(*gsm_dec_pos)] = 0xA3;
			if( chk_para_len_indef(&no7_packet.tcap_packet,i) )
				data[(*gsm_dec_pos)+1] = 0x80;
			else
			{
				if( chk_tcap_len_indef(&no7_packet.tcap_packet,i) )
					data[(*gsm_dec_pos)+1] = (uchar)no7_packet.tcap_packet.map_len[i]-2;
				else
					data[(*gsm_dec_pos)+1] = (uchar)no7_packet.tcap_packet.map_len[i];
			}
		}
		else
		{
			((*gsm_dec_pos)) -= 2;
			data[(*gsm_dec_pos)] = 0x30;
			if( chk_para_len_indef(&no7_packet.tcap_packet,i) || 
				chk_tcap_len_indef(&no7_packet.tcap_packet,i))
				data[(*gsm_dec_pos)+1] = 0x80;
			else
				data[(*gsm_dec_pos)+1] = (uchar)no7_packet.tcap_packet.map_len[i];
		}
	}
}

int chk_para_len_indef(TCAP_PACKET_t *pkt, int idx)
{
    switch(pkt->msg_type_tag)
    {
    case TR_BEGIN:
        switch( pkt->TR.tr_begin.begin_comp.com_type_tag[idx] )
        {
        case TC_INVOKE_TAG:
			if(pkt->TR.tr_begin.begin_comp.CT.inv[idx].parameter_length == TC_PARA_LENGTH_INDEFINITE) 
                return 1;
        }
        break;

    case TR_CONTINUE:
        switch( pkt->TR.tr_cont.cont_comp.com_type_tag[idx] )
        {
        case TC_INVOKE_TAG:
			if( pkt->TR.tr_cont.cont_comp.CT.inv[idx].parameter_length == TC_PARA_LENGTH_INDEFINITE )
                return 1;

        case TC_RETURN_RESULT_LAST:
			if( pkt->TR.tr_cont.cont_comp.CT.rtn_last[idx].parameter_length == TC_PARA_LENGTH_INDEFINITE) 
                return 1;
        }

    case TR_END:
        switch(pkt->TR.tr_end.end_comp.com_type_tag[idx] )
        {
        case TC_RETURN_RESULT_LAST:
			if(pkt->TR.tr_end.end_comp.CT.rtn_last[idx].parameter_length == TC_PARA_LENGTH_INDEFINITE )
                return 1;
        }
    }
    return 0;
}

int chk_tcap_len_indef(TCAP_PACKET_t *pkt, int idx)
{
    switch(pkt->msg_type_tag)
    {
    case TR_BEGIN:
        switch( pkt->TR.tr_begin.begin_comp.com_type_tag[idx] )
        {
        case TC_INVOKE_TAG:
            if( pkt->total_msg_len == TC_PARA_LENGTH_INDEFINITE ||
				pkt->TR.tr_begin.begin_comp.comp_length == TC_PARA_LENGTH_INDEFINITE ||
				pkt->TR.tr_begin.dialogue.dlg_len == 0x80 )
                return 1;
        }
        break;

    case TR_CONTINUE:
        switch( pkt->TR.tr_cont.cont_comp.com_type_tag[idx] )
        {
        case TC_INVOKE_TAG:
            if( pkt->total_msg_len == TC_PARA_LENGTH_INDEFINITE || 
				pkt->TR.tr_cont.cont_comp.comp_length == TC_PARA_LENGTH_INDEFINITE ||
				pkt->TR.tr_cont.dialogue.dlg_len == 0x80 )
                return 1;

        case TC_RETURN_RESULT_LAST:
            if( pkt->total_msg_len == TC_PARA_LENGTH_INDEFINITE || 
				pkt->TR.tr_cont.cont_comp.comp_length == TC_PARA_LENGTH_INDEFINITE ||
				pkt->TR.tr_cont.dialogue.dlg_len == 0x80 )
                return 1;
        }

    case TR_END:
        switch(pkt->TR.tr_end.end_comp.com_type_tag[idx] )
        {
        case TC_RETURN_RESULT_LAST:
            if( pkt->total_msg_len == TC_PARA_LENGTH_INDEFINITE || 
				pkt->TR.tr_end.end_comp.comp_length == TC_PARA_LENGTH_INDEFINITE ||
				pkt->TR.tr_end.dialogue.dlg_len == 0x80 )
                return 1;
        }
    }
    return 0;
}

/*
	return value :
	3 --> WCDMA Version R5
	2 --> WCDMA Version R4
	1 --> WCDMA Version R99

	structured Dialogue 만 구현. 
*/
int get_gsm_version(TCAP_PACKET_t	*tc)
{
	switch(tc->msg_type_tag)
	{
	case TR_UNI:
		return 3;

	case TR_BEGIN:
		switch(tc->TR.tr_begin.dialogue.SU.st.dlg_type)
		{
		case TC_DLG_REQ_TAG:
			if(tc->TR.tr_begin.dialogue.SU.st.DT.dlg_aarq.dlg_as_is_val.version != 0)
				return tc->TR.tr_begin.dialogue.SU.st.DT.dlg_aarq.dlg_as_is_val.version;
			else
				return 3;
			break;
		case TC_DLG_RSP_TAG:
			if(tc->TR.tr_begin.dialogue.SU.st.DT.dlg_aare.dlg_as_is_val.version != 0)
				return tc->TR.tr_begin.dialogue.SU.st.DT.dlg_aare.dlg_as_is_val.version;
			else
				return 3;
			break;
		default:
			return 3;
		}
				
		break;

	case TR_END:
		switch(tc->TR.tr_end.dialogue.SU.st.dlg_type)
		{
		case TC_DLG_REQ_TAG:
			if(tc->TR.tr_end.dialogue.SU.st.DT.dlg_aarq.dlg_as_is_val.version != 0)
				return tc->TR.tr_end.dialogue.SU.st.DT.dlg_aarq.dlg_as_is_val.version;
			else
				return 3;
			break;
		case TC_DLG_RSP_TAG:
			if(tc->TR.tr_end.dialogue.SU.st.DT.dlg_aare.dlg_as_is_val.version != 0)
				return tc->TR.tr_end.dialogue.SU.st.DT.dlg_aare.dlg_as_is_val.version;
			else
				return 3;
			break;
		default:
			return 3;
		}
				
		break;

	case TR_CONTINUE:
		switch(tc->TR.tr_cont.dialogue.SU.st.dlg_type)
		{
		case TC_DLG_REQ_TAG:
			if(tc->TR.tr_cont.dialogue.SU.st.DT.dlg_aarq.dlg_as_is_val.version != 0)
				return tc->TR.tr_cont.dialogue.SU.st.DT.dlg_aarq.dlg_as_is_val.version;
			else
				return 3;
			break;
		case TC_DLG_RSP_TAG:
			if(tc->TR.tr_cont.dialogue.SU.st.DT.dlg_aare.dlg_as_is_val.version != 0)
				return tc->TR.tr_cont.dialogue.SU.st.DT.dlg_aare.dlg_as_is_val.version;
			else
				return 3;
			break;
		default:
			return 3;
		}
				
		break;
	
	default:
		return 3;
	}

	return 3;
}
	
