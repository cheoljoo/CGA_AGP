#ifndef _WMAP_PARA_H_
#define _WMAP_PARA_H_

#define WMAP_PARA_BASE 	12000000	

/*
**	GSMMP 의 파라메타는 따로 정의 하여 사용 한다.
*/

///////////////////////////////////////////////
// COMMON Parameters	1000 ~

#define WMAP_IMSI								1000 + WMAP_PARA_BASE
#define WMAP_TMSI								2000	 + WMAP_PARA_BASE
#define WMAP_IMEI								2001 + WMAP_PARA_BASE
#define WMAP_IMEISV								2002 + WMAP_PARA_BASE
#define WMAP_Previous_location_area_Id			2003 + WMAP_PARA_BASE
#define WMAP_Stored_location_area_Id			2004 + WMAP_PARA_BASE
#define WMAP_Current_location_area_Id			2005 + WMAP_PARA_BASE
#define WMAP_Target_location_area_Id			2006 + WMAP_PARA_BASE
#define WMAP_Target_cell_Id						2007 + WMAP_PARA_BASE
#define WMAP_Target_RNC_Id						2008 + WMAP_PARA_BASE
#define WMAP_Originating_entity_number			2009 + WMAP_PARA_BASE
#define WMAP_MSC_number							2010 + WMAP_PARA_BASE
#define WMAP_Target_MSC_number					2011 + WMAP_PARA_BASE
#define WMAP_HLR_number							2012 + WMAP_PARA_BASE
#define WMAP_VLR_number							2013 + WMAP_PARA_BASE
#define WMAP_HLR_Id								2014 + WMAP_PARA_BASE
#define WMAP_LMSI								2015 + WMAP_PARA_BASE
#define WMAP_MS_ISDN							2016 + WMAP_PARA_BASE
#define WMAP_OMC_Id								2017 + WMAP_PARA_BASE
#define WMAP_Roaming_number						2018 + WMAP_PARA_BASE
#define WMAP_Relocation_Number_List				2019 + WMAP_PARA_BASE
#define WMAP_Handover_number					2020 + WMAP_PARA_BASE
#define WMAP_Forwarded_to_number				2021 + WMAP_PARA_BASE
#define WMAP_Long_forwarded_to_number			2022 + WMAP_PARA_BASE
#define WMAP_Long_FTN_Supported					2023 + WMAP_PARA_BASE
#define WMAP_Forwarded_to_subaddress			2024 + WMAP_PARA_BASE
#define WMAP_Called_number						2025 + WMAP_PARA_BASE
#define WMAP_Calling_number						2026 + WMAP_PARA_BASE
#define WMAP_Originally_dialled_number			2027 + WMAP_PARA_BASE
#define WMAP_Service_centre_address				2028 + WMAP_PARA_BASE
#define WMAP_Zone_Code							2029 + WMAP_PARA_BASE
#define WMAP_MSIsdn_Alert						2030 + WMAP_PARA_BASE
#define WMAP_Location_Information				2031 + WMAP_PARA_BASE
#define WMAP_Location_Information_for_GPRS		2032 + WMAP_PARA_BASE
#define WMAP_GMSC_Address						2033 + WMAP_PARA_BASE
#define WMAP_VMSC_Address						2034	 + WMAP_PARA_BASE
#define WMAP_Group_Id							2035 + WMAP_PARA_BASE
#define WMAP_North_American_Equal_Access_preferred_Carrier_Id	2036	 + WMAP_PARA_BASE
#define WMAP_Serving_cell_Id					2037 + WMAP_PARA_BASE
#define WMAP_SGSN_number						2038 + WMAP_PARA_BASE
#define WMAP_SGSN_address						2039 + WMAP_PARA_BASE
#define WMAP_GGSN_address						2040 + WMAP_PARA_BASE
#define WMAP_GGSN_number						2041 + WMAP_PARA_BASE
#define WMAP_APN								2042 + WMAP_PARA_BASE
#define WMAP_Network_Node_number				2043 + WMAP_PARA_BASE
#define WMAP_PDP_Type							2044 + WMAP_PARA_BASE
#define WMAP_PDP_Address						2045 + WMAP_PARA_BASE
#define WMAP_Additional_number					2046 + WMAP_PARA_BASE
#define WMAP_P_TMSI								2047 + WMAP_PARA_BASE
#define WMAP_B_subscriber_number				2048 + WMAP_PARA_BASE
#define WMAP_B_subscriber_subaddress			2049 + WMAP_PARA_BASE
#define WMAP_LMU_Number							2050 + WMAP_PARA_BASE
#define WMAP_MLC_Number							2051 + WMAP_PARA_BASE
#define WMAP_Multicall_Bearer_Information		2052 + WMAP_PARA_BASE
#define WMAP_Multiple_Bearer_Requested			2053 + WMAP_PARA_BASE
#define WMAP_Multiple_Bearer_Not_Supported		2054 + WMAP_PARA_BASE
#define WMAP_PDP_Charging_Characteristics		2055 + WMAP_PARA_BASE
#define WMAP_Selected_RAB_ID					2056 + WMAP_PARA_BASE
#define WMAP_RAB_ID								2057 + WMAP_PARA_BASE
#define WMAP_gsmSCF_Address						2058 + WMAP_PARA_BASE
#define WMAP_V_GMLC_Address						2059 + WMAP_PARA_BASE
#define WMAP_H_GMLC_Address						2060 + WMAP_PARA_BASE
#define WMAP_PPR_Address						2061 + WMAP_PARA_BASE
#define WMAP_Routeing_Number					2062 + WMAP_PARA_BASE
#define WMAP_Additional_V_GMLC_Address			2063 + WMAP_PARA_BASE


///////////////////////////////////////////////
// Subscriber Management Parameter	2000 ~

#define WMAP_Category							3000 + WMAP_PARA_BASE
#define WMAP_Equipment_status					3001 + WMAP_PARA_BASE
#define WMAP_BMUEF								3002 + WMAP_PARA_BASE
#define WMAP_Extensible_Bearer_service			3003 + WMAP_PARA_BASE
#define WMAP_Extensible_Teleservice				3004 + WMAP_PARA_BASE
#define WMAP_Extensible_Basic_Service_Group		3005 + WMAP_PARA_BASE
#define WMAP_GSM_bearer_capability				3006 + WMAP_PARA_BASE
#define WMAP_Subscriber_Status					3007 + WMAP_PARA_BASE
#define WMAP_CUG_Outgoing_Access_indicator		3008 + WMAP_PARA_BASE
#define WMAP_Operator_Determined_Barring_General_Data	3009	 + WMAP_PARA_BASE
#define WMAP_ODB_HPLMN_Specific_Data			3010 + WMAP_PARA_BASE
#define WMAP_Regional_Subscription_Data			3011 + WMAP_PARA_BASE
#define WMAP_Regional_Subscription_Response		3012 + WMAP_PARA_BASE
#define WMAP_Roaming_Restriction_Due_To_Unsupported_Feature		3013 + WMAP_PARA_BASE
#define WMAP_Extensible_SS_Info					3014 + WMAP_PARA_BASE
#define WMAP_Extensible_forwarding_information	3015 + WMAP_PARA_BASE
#define WMAP_Extensible_forwarding_feature		3016 + WMAP_PARA_BASE
#define WMAP_Extensible_SS_Status				3017 + WMAP_PARA_BASE
#define WMAP_Extensible_Forwarding_Options		3018 + WMAP_PARA_BASE
#define WMAP_Extensible_No_reply_condition_timer	3019 + WMAP_PARA_BASE
#define WMAP_Extensible_Call_barring_information	3020 + WMAP_PARA_BASE
#define WMAP_Extensible_Call_barring_feature		3021 + WMAP_PARA_BASE
#define WMAP_CUG_info								3022 + WMAP_PARA_BASE
#define WMAP_CUG_subscription						3023 + WMAP_PARA_BASE
#define WMAP_CUG_interlock							3024 + WMAP_PARA_BASE
#define WMAP_CUG_index								3025 + WMAP_PARA_BASE
#define WMAP_CUG_feature							3026 + WMAP_PARA_BASE
#define WMAP_Inter_CUG_options						3027 + WMAP_PARA_BASE
#define WMAP_Intra_CUG_restrictions					3028 + WMAP_PARA_BASE
#define WMAP_Extensible_SS_Data						3029 + WMAP_PARA_BASE
#define WMAP_Subscriber_State						3030 + WMAP_PARA_BASE
#define WMAP_equested_Info							3031 + WMAP_PARA_BASE
#define WMAP_Requested_Domain						3032 + WMAP_PARA_BASE
#define WMAP_Suppression_of_Announcement			3033 + WMAP_PARA_BASE
#define WMAP_Suppress_T_CSI							3034 + WMAP_PARA_BASE
#define WMAP_GMSC_CAMEL_Subscription_Info			3035 + WMAP_PARA_BASE
#define WMAP_VLR_CAMEL_Subscription_Info			3036 + WMAP_PARA_BASE
#define WMAP_Supported_CAMEL_Phases_in_the_VLR		3037 + WMAP_PARA_BASE
#define WMAP_Supported_CAMEL_Phases_in_the_SGSN		3038 + WMAP_PARA_BASE
#define WMAP_Offered_CAMEL_CSIs_in_the_VLR			3039 + WMAP_PARA_BASE
#define WMAP_Offered_CAMEL_CSIs_in_the_SGSN			3040 + WMAP_PARA_BASE
#define WMAP_Offered_CAMEL_CSIs						3041 + WMAP_PARA_BASE
#define WMAP_Offered_CAMEL_CSIs_in_interrogating_node	3042	 + WMAP_PARA_BASE
#define WMAP_Offered_CAMEL_CSIs_in_VMSC				3043 + WMAP_PARA_BASE
#define WMAP_Offered_CAMEL__Functionalities			3044 + WMAP_PARA_BASE
#define WMAP_Supported_CAMEL_Phases					3045 + WMAP_PARA_BASE
#define WMAP_Supported_CAMEL_Phases_in_interrogating_node	3046 + WMAP_PARA_BASE
#define WMAP_CUG_Subscription_Flag					3047 + WMAP_PARA_BASE
#define WMAP_CAMEL_Subscription_Info_Withdraw		3048 + WMAP_PARA_BASE
#define WMAP_Voice_Group_Call_Service_(VGCS)_Data	3049 + WMAP_PARA_BASE
#define WMAP_Voice_Broadcast_Service_(VBS)_Data		3050 + WMAP_PARA_BASE
#define WMAP_ISDN_bearer_capability					3051 + WMAP_PARA_BASE
#define WMAP_Lower_layer_Compatibility				3052 + WMAP_PARA_BASE
#define WMAP_High_Layer_Compatibility				3053 + WMAP_PARA_BASE
#define WMAP_Alerting_Pattern						3054 + WMAP_PARA_BASE
#define WMAP_GPRS_Subscription_Data_Withdraw		3055 + WMAP_PARA_BASE
#define WMAP_GPRS_Subscription_Data					3056 + WMAP_PARA_BASE
#define WMAP_QoS_Subscribed							3057 + WMAP_PARA_BASE
#define WMAP_VPLMN_address_allowed					3058 + WMAP_PARA_BASE
#define WMAP_Roaming_Restricted_In_SGSN_Due_To_Unsupported_Feature	3059	 + WMAP_PARA_BASE
#define WMAP_Network_Access_Mode					3060 + WMAP_PARA_BASE
#define WMAP_Mobile_Not_Reachable_Reason			3061 + WMAP_PARA_BASE
#define WMAP_Cancellation_Type						3062 + WMAP_PARA_BASE
#define WMAP_All_GPRS_Data							3063 + WMAP_PARA_BASE
#define WMAP_Complete_Data_List_Included			3064 + WMAP_PARA_BASE
#define WMAP_PDP_Context_Identifier					3065 + WMAP_PARA_BASE
#define WMAP_LSA_Information						3066 + WMAP_PARA_BASE
#define WMAP_SoLSA_support_indicator				3067 + WMAP_PARA_BASE
#define WMAP_LSA_Information_Withdraw				3068 + WMAP_PARA_BASE
#define WMAP_LMU_Indicator							3069 + WMAP_PARA_BASE
#define WMAP_LCS_Information						3070 + WMAP_PARA_BASE
#define WMAP_GMLC_List								3071 + WMAP_PARA_BASE
#define WMAP_LCS_Privacy_Exception_List				3072 + WMAP_PARA_BASE
#define WMAP_Additional_LCS_Privacy_Exception_List	3073 + WMAP_PARA_BASE
#define WMAP_LCS_Privacy_Exception_Parameters		3074 + WMAP_PARA_BASE
#define WMAP_External_Client_List					3075 + WMAP_PARA_BASE
#define WMAP_Internal_Client_List					3076 + WMAP_PARA_BASE
#define WMAP_MO_LR_List								3077 + WMAP_PARA_BASE
#define WMAP_Privacy_Notification_to_MS_User		3078 + WMAP_PARA_BASE
#define WMAP_GMLC_List_Withdraw						3079 + WMAP_PARA_BASE
#define WMAP_Service_Type_List						3080 + WMAP_PARA_BASE
#define WMAP_IST_Alert_Timer						3081 + WMAP_PARA_BASE
#define WMAP_Call_Termination_Indicator				3082 + WMAP_PARA_BASE
#define WMAP_IST_Information_Withdraw				3083 + WMAP_PARA_BASE
#define WMAP_IST_Support_Indicator					3084 + WMAP_PARA_BASE
#define WMAP_Super_Charger_Supported_In_HLR			3085 + WMAP_PARA_BASE
#define WMAP_Super_Charger_Supported_In_Serving_Network_Entity	3086 + WMAP_PARA_BASE
#define WMAP_Age_Indicator							3087 + WMAP_PARA_BASE
#define WMAP_GPRS_enhancements_support_indicator	3088 + WMAP_PARA_BASE
#define WMAP_Extension_QoS_Subscribed				3089 + WMAP_PARA_BASE
#define WMAP_SGSN_CAMEL_Subscription_Info			3090 + WMAP_PARA_BASE
#define WMAP_Extension__QoS_Subscribed				3091 + WMAP_PARA_BASE
#define WMAP_MO_SMS_CSI								3092 + WMAP_PARA_BASE
#define WMAP_MT_SMS_CSI								3093 + WMAP_PARA_BASE
#define WMAP_GPRS_CSI								3094 + WMAP_PARA_BASE
#define WMAP_CAMEL_subscription_info				3095 + WMAP_PARA_BASE
#define WMAP_Call_Barring_Data						3096 + WMAP_PARA_BASE
#define WMAP_Call_Forwarding_Data					3097 + WMAP_PARA_BASE
#define WMAP_ODB_Data								3098 + WMAP_PARA_BASE
#define WMAP_Requested_Subscription_Info			3099 + WMAP_PARA_BASE
#define WMAP_CS_Allocation_Retention_priority		3100 + WMAP_PARA_BASE
#define WMAP_ODB_Info								3101 + WMAP_PARA_BASE
#define WMAP_Suppress_VT_CSI						3102 + WMAP_PARA_BASE
#define WMAP_Suppress_Incoming_Call_Barring			3103 + WMAP_PARA_BASE
#define WMAP_gsmSCF_Initiated_Call					3104 + WMAP_PARA_BASE
#define WMAP_SuppressMTSS							3105 + WMAP_PARA_BASE
#define WMAP_Call_barring_support_indicator			3106 + WMAP_PARA_BASE
#define WMAP_MNP_Info_Result						3107 + WMAP_PARA_BASE
#define WMAP_Allowed_Services						3108 + WMAP_PARA_BASE
#define WMAP_Unavailability_Cause					3109 + WMAP_PARA_BASE
#define WMAP_MNP_Requested_Info						3110 + WMAP_PARA_BASE
#define WMAP_Access_Restriction_Data				3111 + WMAP_PARA_BASE
#define WMAP_Supported_RAT_types_indicator			3112 + WMAP_PARA_BASE


///////////////////////////////////////////////
// Subscriber Management Parameter	4000 ~

#define WMAP_SS_Code								4001 + WMAP_PARA_BASE
#define WMAP_SS_Code2								4002 + WMAP_PARA_BASE
#define WMAP_SS_Status								4003 + WMAP_PARA_BASE
#define WMAP_SS_Data								4004 + WMAP_PARA_BASE
#define WMAP_Override_Category						4005 + WMAP_PARA_BASE
#define WMAP_CLI_Restriction_Option					4006 + WMAP_PARA_BASE
#define WMAP_Forwarding_Options						4007 + WMAP_PARA_BASE
#define WMAP_No_reply_condition_timer				4008 + WMAP_PARA_BASE
#define WMAP_Forwarding_information					4009 + WMAP_PARA_BASE
#define WMAP_Forwarding_feature						4010 + WMAP_PARA_BASE
#define WMAP_Call_barring_information				4011	 + WMAP_PARA_BASE
#define WMAP_Call_barring_feature					4012 + WMAP_PARA_BASE
#define WMAP_New_password							4013 + WMAP_PARA_BASE
#define WMAP_Current_password						4014 + WMAP_PARA_BASE
#define WMAP_Guidance_information					4015 + WMAP_PARA_BASE
#define WMAP_SS_Info								4016 + WMAP_PARA_BASE
#define WMAP_USSD_Data_Coding_Scheme				4017 + WMAP_PARA_BASE
#define WMAP_USSD_String							4018 + WMAP_PARA_BASE
#define WMAP_Bearer_service							4019 + WMAP_PARA_BASE
#define WMAP_Bearer_Service2						4020 + WMAP_PARA_BASE
#define WMAP_Teleservice							4021 + WMAP_PARA_BASE
#define WMAP_Teleservice2							4022 + WMAP_PARA_BASE
#define WMAP_Basic_Service_Group					4023 + WMAP_PARA_BASE
#define WMAP_eMLPP_information						4024 + WMAP_PARA_BASE
#define WMAP_SS_event								4025 + WMAP_PARA_BASE
#define WMAP_SS_event_data							4026 + WMAP_PARA_BASE
#define WMAP_LCS_Privacy_Exceptions					4027 + WMAP_PARA_BASE
#define WMAP_Mobile_Originating_Location_Request_(MO_LR)	4028	 + WMAP_PARA_BASE
#define WMAP_NbrUser								4029 + WMAP_PARA_BASE
#define WMAP_MC_Subscription_Data					4030 + WMAP_PARA_BASE
#define WMAP_MC_Information							4041 + WMAP_PARA_BASE
#define WMAP_CCBS_Request_State						4042 + WMAP_PARA_BASE
#define WMAP_Basic_Service_Group2					4043 + WMAP_PARA_BASE

#define WMAP_Teleservice_List						4100 + WMAP_PARA_BASE
#define WMAP_Bearerservice_List						4101 + WMAP_PARA_BASE


///////////////////////////////////////////////
// Call Parameter	5000 ~

#define WMAP_Call_reference_number					5000 + WMAP_PARA_BASE
#define WMAP_Interrogation_type						5001 + WMAP_PARA_BASE
#define WMAP_OR_interrogation						5003 + WMAP_PARA_BASE
#define WMAP_OR_capability							5004 + WMAP_PARA_BASE
#define WMAP_Forwarding_reason						5005 + WMAP_PARA_BASE
#define WMAP_Forwarding_interrogation_required		5006 + WMAP_PARA_BASE
#define WMAP_O_CSI									5007 + WMAP_PARA_BASE
#define WMAP_D_CSI									5008 + WMAP_PARA_BASE
#define WMAP_T_CSI									5009 + WMAP_PARA_BASE
#define WMAP_VT_CSI									5010 + WMAP_PARA_BASE
#define WMAP_O_IM_CSI								5011 + WMAP_PARA_BASE
#define WMAP_D_IM_CSI								5012 + WMAP_PARA_BASE
#define WMAP_VT_IM_CSI								5013 + WMAP_PARA_BASE
#define WMAP_CCBS_Feature							5014 + WMAP_PARA_BASE
#define WMAP_UU_Data								5015 + WMAP_PARA_BASE
#define WMAP_Number_Portability_Status				5016 + WMAP_PARA_BASE
#define WMAP_Pre_paging_supported					5017 + WMAP_PARA_BASE

///////////////////////////////////////////////
// Radio Parameter	6000 ~

#define WMAP_GERAN_Classmark						6000 + WMAP_PARA_BASE	
#define WMAP_BSSMAP_Service_Handover				6001 + WMAP_PARA_BASE
#define WMAP_BSSMAP_Service_Handover_List			6002 + WMAP_PARA_BASE
#define WMAP_RANAP_Service_Handover					6003 + WMAP_PARA_BASE
#define WMAP_O_Number_Not_Required					6004 + WMAP_PARA_BASE
#define WMAP_integrity_Protection_Information		6005 + WMAP_PARA_BASE
#define WMAP_encryption_Information					6006 + WMAP_PARA_BASE
#define WMAP_Radio_Resource_Information				6007 + WMAP_PARA_BASE
#define WMAP_Radio_Resource_List					6008 + WMAP_PARA_BASE
#define WMAP_Chosen_Radio_Resource_Information		6009 + WMAP_PARA_BASE
#define WMAP_Key_Status								6010 + WMAP_PARA_BASE
#define WMAP_Selected_UMTS_Algorithms				6011 + WMAP_PARA_BASE
#define WMAP_Allowed_GSM_Algorithms					6012 + WMAP_PARA_BASE
#define WMAP_Allowed_UMTS_Algorithms				6013 + WMAP_PARA_BASE
#define WMAP_Selected_GSM_Algorithm					6014 + WMAP_PARA_BASE
#define WMAP_Iu_Currently_Used_Codec				6015 + WMAP_PARA_BASE
#define WMAP_Iu_Supported_Codecs_List				6016 + WMAP_PARA_BASE
#define WMAP_Iu_Available_Codecs_List				6017 + WMAP_PARA_BASE
#define WMAP_Iu_Selected_Codec						6018 + WMAP_PARA_BASE
#define WMAP_RAB_Configuration_Indicator			6019 + WMAP_PARA_BASE
#define WMAP_UESBI_Iu								6020 + WMAP_PARA_BASE
#define WMAP_Alternative_Channel_Type				6021 + WMAP_PARA_BASE


///////////////////////////////////////////////
// Authentication Parameter	7000 ~

#define WMAP_Authentication_set_list				7000 + WMAP_PARA_BASE
#define WMAP_Rand									7001 + WMAP_PARA_BASE
#define WMAP_Sres									7002 + WMAP_PARA_BASE
#define WMAP_Kc										7003 + WMAP_PARA_BASE
#define WMAP_Xres									7004 + WMAP_PARA_BASE
#define WMAP_Ck										7005 + WMAP_PARA_BASE
#define WMAP_Ik										7006 + WMAP_PARA_BASE
#define WMAP_Autn									7007 + WMAP_PARA_BASE
#define WMAP_Cksn									7008 + WMAP_PARA_BASE
#define WMAP_Ksi									7009 + WMAP_PARA_BASE
#define WMAP_Auts									7010 + WMAP_PARA_BASE
#define WMAP_Ciphering_mode							7011 + WMAP_PARA_BASE
#define WMAP_Current_Security_Context				7012 + WMAP_PARA_BASE
#define WMAP_Failure_cause							7013 + WMAP_PARA_BASE
#define WMAP_Re_attempt								7014 + WMAP_PARA_BASE
#define WMAP_Access_Type							7015 + WMAP_PARA_BASE


///////////////////////////////////////////////
// Short Message Parameter	8000 ~

#define WMAP_SM_RP_DA								8000 + WMAP_PARA_BASE
#define WMAP_SM_RP_OA								8001 + WMAP_PARA_BASE
#define WMAP_MWD_status								8002 + WMAP_PARA_BASE
#define WMAP_SM_RP_UI								8003 + WMAP_PARA_BASE
#define WMAP_SM_RP_PRI								8004 + WMAP_PARA_BASE
#define WMAP_SM_Delivery_Outcome					8005 + WMAP_PARA_BASE
#define WMAP_More_Messages_To_Send					8006 + WMAP_PARA_BASE
#define WMAP_Alert_Reason							8007 + WMAP_PARA_BASE
#define WMAP_Absent_Subscriber_Diagnostic_SM		8008 + WMAP_PARA_BASE
#define WMAP_Alert_Reason_Indicator					8009 + WMAP_PARA_BASE
#define WMAP_Additional_SM_Delivery_Outcome			8010 + WMAP_PARA_BASE
#define WMAP_Additional_Absent_Subscriber_Diagnostic_SM		8011 + WMAP_PARA_BASE
#define WMAP_Delivery_Outcome_Indicator				8012 + WMAP_PARA_BASE
#define WMAP_GPRS_Node_Indicator					8013 + WMAP_PARA_BASE
#define WMAP_GPRS_Support_Indicator					8014 + WMAP_PARA_BASE
#define WMAP_SM_RP_MTI								8015 + WMAP_PARA_BASE
#define WMAP_SM_RP_SMEA								8016 + WMAP_PARA_BASE

///////////////////////////////////////////////
//_access_and_signalling_system_related_parameter	9000_~

#define WMAP_AN_apdu								9001 + WMAP_PARA_BASE
#define WMAP_CM_service_type						9002 + WMAP_PARA_BASE
#define WMAP_Access_connection_status				9003 + WMAP_PARA_BASE
#define WMAP_External_Signal_Information			9004 + WMAP_PARA_BASE
#define WMAP_Access_signalling_information			9005 + WMAP_PARA_BASE
#define WMAP_Location_update_type					9006 + WMAP_PARA_BASE
#define WMAP_Protocol_ID							9007 + WMAP_PARA_BASE
#define WMAP_Network_signal_information				9008 + WMAP_PARA_BASE
#define WMAP_Network_signal_information2			9009 + WMAP_PARA_BASE
#define WMAP_Call_Info								9010 + WMAP_PARA_BASE
#define WMAP_Additional_signal_info					9011 + WMAP_PARA_BASE


///////////////////////////////////////////////
// System Operation parameter	10000_~

#define WMAP_Network_resources						10000 + WMAP_PARA_BASE
#define WMAP_Trace_reference						10001 + WMAP_PARA_BASE
#define WMAP_Trace_reference2						10002 + WMAP_PARA_BASE
#define WMAP_Trace_type								10003 + WMAP_PARA_BASE
#define WMAP_Additional_network_resources			10004 + WMAP_PARA_BASE
#define WMAP_Trace_depth_list						10005 + WMAP_PARA_BASE
#define WMAP_Trace_NE_type_list						10006 + WMAP_PARA_BASE
#define WMAP_Trace_interface_list					10007 + WMAP_PARA_BASE
#define WMAP_Trace_event_list						10008 + WMAP_PARA_BASE
#define WMAP_Trace_support_indicator				10009 + WMAP_PARA_BASE
#define WMAP_Trace_Propagation_List					10010 + WMAP_PARA_BASE

///////////////////////////////////////////////
// Location Service  parameter	11000_~


#define WMAP_Age_of_Location_Estimate				11000 + WMAP_PARA_BASE
#define WMAP_Deferred_MT_LR_Response_Indicator		11001 + WMAP_PARA_BASE
#define WMAP_Deferred_MT_LR_Data					11002 + WMAP_PARA_BASE
#define WMAP_LCS_Client_ID							11003 + WMAP_PARA_BASE
#define WMAP_LCS_Event								11004 + WMAP_PARA_BASE
#define WMAP_LCS_Priority							11005 + WMAP_PARA_BASE
#define WMAP_LCS_QoS								11006 + WMAP_PARA_BASE
#define WMAP_CS_LCS_Not_Supported_by_UE				11007 + WMAP_PARA_BASE
#define WMAP_PS_LCS_Not_Supported_by_UE				11008 + WMAP_PARA_BASE
#define WMAP_Location_Estimate						11009 + WMAP_PARA_BASE
#define WMAP_GERAN_Positioning_Data					11010 + WMAP_PARA_BASE
#define WMAP_UTRAN_Positioning_Data					11011 + WMAP_PARA_BASE
#define WMAP_Location_Type							11012 + WMAP_PARA_BASE
#define WMAP_NA_ESRD								11013 + WMAP_PARA_BASE
#define WMAP_NA_ESRK								11014 + WMAP_PARA_BASE
#define WMAP_LCS_Service_Type_Id					11015 + WMAP_PARA_BASE
#define WMAP_Privacy_Override						11016 + WMAP_PARA_BASE
#define WMAP_Supported_LCS_Capability_Sets			11017 + WMAP_PARA_BASE
#define WMAP_LCS_Codeword							11018 + WMAP_PARA_BASE
#define WMAP_NA_ESRK_Request						11019 + WMAP_PARA_BASE
#define WMAP_Supported_GAD_Shapes					11020 + WMAP_PARA_BASE
#define WMAP_Additional_Location_Estimate			11021 + WMAP_PARA_BASE
#define WMAP_Cell_Id_Or_SAI							11022 + WMAP_PARA_BASE
#define WMAP_LCS_Reference_Number					11023 + WMAP_PARA_BASE
#define WMAP_LCS_Privacy_Check						11024 + WMAP_PARA_BASE
#define WMAP_Additional_LCS_Capability_Sets			11025 + WMAP_PARA_BASE
#define WMAP_Area_Event_Info						11026 + WMAP_PARA_BASE
#define WMAP_Velocity_Estimate						11027 + WMAP_PARA_BASE
#define WMAP_Accuracy_Fulfilment_Indicator			11028 + WMAP_PARA_BASE
#define WMAP_MO_LR_Short_Circuit_Indicator			11029 + WMAP_PARA_BASE
#define WMAP_Reporting_PLMN_List					11030 + WMAP_PARA_BASE
#define WMAP_Periodic_LDR_information				11031 + WMAP_PARA_BASE
#define WMAP_Sequence_Number						11032 + WMAP_PARA_BASE

//////////////////////////////////////
//	Cause & Diagnostic			12000 ~

#define	WMAP_Failure_Cause							12000 + WMAP_PARA_BASE
#define WMAP_Error_Status							12001 + WMAP_PARA_BASE
#define WMAP_Network_Resource						12002 + WMAP_PARA_BASE
#define WMAP_Unknown_Subscriber_Diagnostic			12003 + WMAP_PARA_BASE
#define WMAP_Roaming_Not_Allowed_Cause				12004 + WMAP_PARA_BASE
#define WMAP_Absent_Subscriber_Reason				12005 + WMAP_PARA_BASE
#define WMAP_Call_Bearring_Cause					12006 + WMAP_PARA_BASE
#define WMAP_CUG_Reject_Cause						12007 + WMAP_PARA_BASE
#define WMAP_Enumerate_Delivery_Failure_Cause		12008 + WMAP_PARA_BASE
#define WMAP_Diagnostic_Info						12009 + WMAP_PARA_BASE
#define WMAP_Unauthorized_LCS_Client_Diagnostic		12010 + WMAP_PARA_BASE
#define WMAP_Position_Method_Failure_Diagnostic		12011 + WMAP_PARA_BASE
#define WMAP_Security_Parameter_Index				12012 + WMAP_PARA_BASE
#define WMAP_Initialization_Vector					12013 + WMAP_PARA_BASE






#endif
