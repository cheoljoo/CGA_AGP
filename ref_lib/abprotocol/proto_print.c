/*
 * 	$Id: proto_print.c,v 1.25 2007/06/20 05:02:23 jsyoon Exp $
 */


#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "sb_protocol_stg.h"
#include "proot_print.h"
#include "proot.h"
#include "protocol_node.h"
#include "param_node.h"

int		verbose;

#define	MAX_TREE_DEPTH			10
#define MAX_TREE_STRING			256
unsigned char 		tree_prefix [MAX_TREE_DEPTH][MAX_TREE_STRING];

#define WIDTH   16          
#define	CREATE_PDP_CXT_REQ	16
#define	CREATE_PDP_CXT_RES	17	
#define	DELETE_PDP_CXT_REQ	20
#define	DELETE_PDP_CXT_RES	21
int                                         
dump(char *s,int len)                
{
    char buf[BUFSIZ],lbuf[BUFSIZ],rbuf[BUFSIZ];
    unsigned char *p;
    int line,i;

    p =(unsigned char *) s;
    for(line = 1; len > 0; len -= WIDTH,line++) {
        memset(lbuf,0,BUFSIZ);
        memset(rbuf,0,BUFSIZ);

        for(i = 0; i < WIDTH && len > i; i++,p++) {
            sprintf(buf,"%02x ",(unsigned char) *p);
            strcat(lbuf,buf);
            sprintf(buf,"%c",(!iscntrl(*p) && *p <= 0x7f) ? *p : '.');
            strcat(rbuf,buf);
        }
        printf("%04x: %-*s    %s\n",line - 1,WIDTH * 3,lbuf,rbuf);
    }
    /*if(!(len%16)) dAppLog(LOG_INFO, "\n"); */
    return line;
}

int
read_data_file (unsigned char *pData, unsigned char *pathname)
{
    FILE                *pOpenF;
    int                 red, idx;

    pOpenF = fopen (pathname, "r");
    if (pOpenF == NULL) {
        printf ("Read file Open Fail !! %s \n", pathname);
        return -1;
    }

    idx = 0;
    while (1) {
        red = fread (pData + idx, 1, 1, pOpenF);
        if (red <= 0)   
            break;      
        idx++;
    }
        
	if (verbose == 1) 
    	printf ("Read Data %d\n", idx);

    fclose (pOpenF);
    return idx;
}

void
usage_print ()
{
	printf ("usage: proto_print <filename> -p prototype [ -s (skipbytes) ] -v\n");
	printf (" -p  prototype [RTP | IP | TCP]\n");
	printf (" -s  skip bytes \n");
	printf (" -v  verbose (dump)\n");
	printf (" -c  continue \n");
}

void
do_gtp_messages(unsigned char *ucBuf, int iread, int *dec_pos, unsigned char ucMessageType, int *tree_pos, dlink_t *node)
{
	GTP_CrtPDPCxtReq_sb				*pGTP_CPCReqMsg;
	GTP_CrtPDPCxtResp_sb			*pGTP_CPCRespMsg;
	GTP_DelPDPCxtReq_sb				*pGTP_DPCReqMsg;
	GTP_DelPDPCxtResp_sb			*pGTP_DPCRespMsg;
	GTP_SendRoutInfoGPRSReq_sb		*pGTP_SRIReqMsg;
	GTP_SendRoutInfoGPRSResp_sb		*pGTP_SRIRespMsg;
	GTP_NoteMSGPRSPresentReq_sb		*pGTP_NMGPReqMsg;
	GTP_NoteMSGPRSPresentResp_sb	*pGTP_NMGPRespMsg;

	printf ("dec_pos: %d tree_pos: %d.. do_gtp_msg\n", *dec_pos, *tree_pos);
	switch(ucMessageType)
	{
		case 32:
			decode_addr_GTP_SendRoutInfoGPRSReq_sb (ucBuf, iread, dec_pos, &pGTP_SRIReqMsg);

			GTP_SendRoutInfoGPRSReq_sb_Prt ("pGTP_SRIReqMsg", pGTP_SRIReqMsg);

			printf("GTP Msg IE IMSI: [%s]\n", pGTP_SRIReqMsg->stIMSI.IMSI);
			
			break;
		case 33:
			decode_addr_GTP_SendRoutInfoGPRSResp_sb (ucBuf, iread, dec_pos, &pGTP_SRIRespMsg);

			GTP_SendRoutInfoGPRSResp_sb_Prt ("pGTP_SRIRespMsg", pGTP_SRIRespMsg);
			
			break;
		case 36:
			decode_addr_GTP_NoteMSGPRSPresentReq_sb (ucBuf, iread, dec_pos, &pGTP_NMGPReqMsg);

			GTP_NoteMSGPRSPresentReq_sb_Prt ("pGTP_NMGPReqMsg", pGTP_NMGPReqMsg);

			break;
		case 37:
			decode_addr_GTP_NoteMSGPRSPresentResp_sb (ucBuf, iread, dec_pos, &pGTP_NMGPRespMsg);

			GTP_NoteMSGPRSPresentResp_sb_Prt ("pGTP_NMGPRespMsg", pGTP_NMGPRespMsg);

			break;
		case 16:
			decode_addr_GTP_CrtPDPCxtReq_sb (ucBuf, iread, dec_pos, &pGTP_CPCReqMsg);

			GTP_CrtPDPCxtReq_sb_Prt ("CPCReqMsg", pGTP_CPCReqMsg);

			break;

		case 17:
			decode_addr_GTP_CrtPDPCxtResp_sb (ucBuf, iread, dec_pos, &pGTP_CPCRespMsg);

			GTP_CrtPDPCxtResp_sb_Prt ("CPCRespMsg", pGTP_CPCRespMsg);

			break;
		case 20:
			decode_addr_GTP_DelPDPCxtReq_sb (ucBuf, iread, dec_pos, &pGTP_DPCReqMsg);

			GTP_DelPDPCxtReq_sb_Prt ("DPCReqMsg", pGTP_DPCReqMsg);

			break;
		case 21:
			decode_addr_GTP_DelPDPCxtResp_sb (ucBuf, iread, dec_pos, &pGTP_DPCRespMsg);

			GTP_DelPDPCxtResp_sb_Prt ("DPCRespMsg", pGTP_DPCRespMsg);

			break;

		default:
			printf("Unknown GTP Messages\n");
			break;
	}
}


int
main (int argc, char *argv[])
{
	int					i, skip_byte =0;
	int					iread;
	unsigned char 		ucBuf [2046*4], protocol[24], gtp_msgtype, pstring [256];
//	unsigned char 		utreebuf [2046*4];
	int					dec_pos, tree_pos, b_continue, str_pos, temp_pos;
	int					struct_size, struct_type, line;

	int					ResultCode;

	proot_t             mRoot;

	/**< interate.. */
	RTP_Header_sb			*pRTPHdr;
	RTCP_Header_sb			*pRTCPHdr;
	IP_Header_sb			*pIPHdr;
	TCP_Header_sb			*pTCPHdr;
	RTCP_SR_sb				*pRTCP_SR;
	UDP_Header_sb			*pUDPHdr;
	GTP_Header_sb			*pGTPHdr;
	GTP_CrtPDPCxtReq_sb		*pGTP_CPCReqMsg;
	GTP_CrtPDPCxtResp_sb	*pGTP_CPCRespMsg;
	GTP_DelPDPCxtReq_sb		*pGTP_DPCReqMsg;
	GTP_DelPDPCxtResp_sb	*pGTP_DPCRespMsg;

	DIAMETER_Header_sb			*pDIAMETERHdr;

	Location_Info_Req_sb		*pAVPLIReqMsg;
	Location_Info_Resp_sb		*pAVPLIRespMsg;
	Device_Watchdog_Req_sb		*pAVPDWReqMsg;
	Device_Watchdog_Resp_sb		*pAVPDWRespMsg;
	User_Authorization_Req_sb	*pAVPUAReqMsg;
	User_Authorization_Resp_sb	*pAVPUARespMsg;
	Server_Assignment_Req_sb	*pAVPSAReqMsg;
	Server_Assignment_Resp_sb	*pAVPSARespMsg;
	Multimedia_Auth_Req_sb		*pAVPMAReqMsg;
	Multimedia_Auth_Resp_sb		*pAVPMARespMsg;

	GTP_P_Header_sb         *pGTP_PHdr;
	GTP_P_CDRTransReq_sb    *pGTP_PCDRTransReq;
	GTP_P_CDRTransResp_sb   *pGTP_PCDRTransResp;
	GTP_P_NodeAliveReq_sb	*pGTP_PNodeAliveReq;
	GTP_P_NodeAliveResp_sb	*pGTP_PNodeAliveResp;

	str_pos = b_continue = verbose = 0;
	proot_node_init (&mRoot);

	if (argc > 1) {
		for (i = 2; i < argc; i++) {
			if      (!strcmp (argv[i], "-s")) skip_byte = atoi(argv [++i]);
			else if (!strcmp (argv[i], "-v")) verbose = 1;
			else if (!strcmp (argv[i], "-p")) strcpy (protocol, argv [++i]);
			else if (!strcmp (argv[i], "-c")) b_continue = 1;
			else {
				usage_print();
				return 0;
			}
		}
	} else {
		usage_print();
		return 0;
	}


	if ((iread = read_data_file (ucBuf, argv[1])) < 0) {
		printf ("file open error!! :%s\n", argv[1]);
		return 0;
	}
		
	if (verbose == 1) {
		dump (ucBuf+skip_byte, iread-skip_byte);
	}


	line = 0;
	tree_pos = dec_pos = 0;
	do {
		if ((iread - skip_byte) <= dec_pos)
			break;

		if (!strncmp (protocol, "NULL", 4)) {
			break;
		/**< interate.. **/

		} else if (!strncmp (protocol, "RTP", 3)) {
			decode_addr_RTP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pRTPHdr);
			RTP_Header_sb_Prt ("RTP Header", pRTPHdr);
			make_tree_addr_RTP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, (void *)&pRTPHdr, &mRoot.child);

			strcpy (protocol, "NULL");
		} else if (!strncmp (protocol, "IP", 2)) {
			temp_pos = dec_pos;
			decode_addr_IP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &temp_pos, &pIPHdr);
			IP_Header_sb_Prt ("IP Header", pIPHdr);
			temp_pos = dec_pos;

			str_pos = 0;
			IP_Header_sb_list (ucBuf+skip_byte, iread-skip_byte, (void *)&pIPHdr, &temp_pos, &struct_size, &struct_type, pstring + str_pos, &str_pos);
			dec_pos = temp_pos;

			printf ("IP Header: %d", pIPHdr->ucProtocol);
			switch (pIPHdr->ucProtocol) {
			case 6: 	/**< TCP header */
				strcpy (protocol, "TCP");
				break;
			case 0x11:
				strcpy (protocol, "UDP");
				break;
			default:
				strcpy (protocol, "NULL");
				break;
			}

			str_pos = 0;
			IP_Header_sb_tree (ucBuf + skip_byte, iread -skip_byte, (void *)&pIPHdr, &tree_pos, &struct_size, &struct_type, pstring +str_pos, &str_pos, &line);
			printf ("..\n%s..\n", pstring);
//			make_tree_addr_IP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, (void *)&pIPHdr, &mRoot.child);
		} else if (!strncmp (protocol, "TCP", 3)) {
			temp_pos = dec_pos;
			decode_addr_TCP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &temp_pos, &pTCPHdr);
			TCP_Header_sb_Prt ("TCP Header", pTCPHdr);

			str_pos = 0;
			TCP_Header_sb_tree (ucBuf + skip_byte, iread -skip_byte, (void *)&pTCPHdr, &tree_pos, &struct_size, &struct_type, pstring +str_pos, &str_pos, &line);
			printf ("..\n%s..\n", pstring);
//			make_tree_addr_TCP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, &pTCPHdr, &mRoot.child);

			temp_pos = dec_pos;
			str_pos = 0;
			TCP_Header_sb_list (ucBuf+skip_byte, iread-skip_byte, (void *)&pTCPHdr, &temp_pos, &struct_size, &struct_type, pstring + str_pos, &str_pos);
			dec_pos = temp_pos;
			printf ("String Print: %s, size:%d, type:%d", pstring, struct_size, struct_type);

			strcpy (protocol, "NULL");

		} else if (!strncmp (protocol, "RTCP_SR", 7)) {
			decode_addr_RTCP_SR_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pRTCP_SR);
			RTCP_SR_sb_Prt ("RTCP SR Msg", pRTCP_SR);
			make_tree_addr_RTCP_SR_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, (void *)&pRTCP_SR, &mRoot.child);

			strcpy (protocol, "NULL");
		} else if (!strncmp (protocol, "RTCP", 4)) {
			decode_addr_RTCP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pRTCPHdr);
			RTCP_Header_sb_Prt ("RTCP Header", pRTCPHdr);
			make_tree_addr_RTCP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, (void *)&pRTCPHdr, &mRoot.child);

			strcpy (protocol, "NULL");
		} else if (!strncmp (protocol, "UDP", 3)) { 
			decode_addr_UDP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pUDPHdr);
			UDP_Header_sb_Prt ("UDP Header", pUDPHdr);

			printf ("UDP Header: %d", pUDPHdr->usDstPort);
			switch (pUDPHdr->usDstPort) {
			case 2123:
				strcpy (protocol, "GTP");
				break;
			default:	
				strcpy (protocol, "NULL");
				break;
			}

			make_tree_addr_UDP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, (void *)&pUDPHdr, &mRoot.child);

		} else if (!strncmp (protocol, "GTP_P", 5)) {
			printf ("	GTP_P Header\n");
			decode_addr_GTP_P_Header_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pGTP_PHdr);
			GTP_P_Header_sb_Prt ("GTP_P Header", pGTP_PHdr);

			switch (pGTP_PHdr->ucMessageType)
			{
				case 240:
					decode_addr_GTP_P_CDRTransReq_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pGTP_PCDRTransReq);
					GTP_P_CDRTransReq_sb_Prt ("CDReqMsg ", pGTP_PCDRTransReq);
					printf( "Number of data records: %d\n"
							"Data record format: %d\n"
							"Data record format version: %d\n"
							, 
							(U8)pGTP_PCDRTransReq->stCDRPKT.CDRPacket[0],
							(U8)pGTP_PCDRTransReq->stCDRPKT.CDRPacket[1],
							ntohs(*((U16 *)(&pGTP_PCDRTransReq->stCDRPKT.CDRPacket[2])))
						  );
					break;
				case 241:
					decode_addr_GTP_P_CDRTransResp_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pGTP_PCDRTransResp);
					GTP_P_CDRTransResp_sb_Prt ("CDRespMsg ", pGTP_PCDRTransResp);
					break;
				case 4:
					decode_addr_GTP_P_NodeAliveReq_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pGTP_PNodeAliveReq);
					GTP_P_NodeAliveReq_sb_Prt ("NodeAliveReqMsg ", pGTP_PNodeAliveReq);
					break;
				case 5:
					decode_addr_GTP_P_NodeAliveResp_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pGTP_PNodeAliveResp);
					GTP_P_NodeAliveResp_sb_Prt ("NodeAliveRespMsg ", pGTP_PNodeAliveResp);
					break;
				case 1:
					printf ("ECHO REQUEST\n");
					break;
				case 2:
					printf ("ECHO RESPONSE\n");
					break;
				default:
					break;
			}

			strcpy (protocol, "NULL");

		} else if (!strncmp (protocol, "GTP", 3)) {
			printf ("GTP Header\n");
			decode_addr_GTP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pGTPHdr);
			GTP_Header_sb_Prt ("GTP Header", pGTPHdr);
	
			/**<  GTP Messages Decoding  **/	
			gtp_msgtype = pGTPHdr->ucMessageType;
			printf ("GTP Messages: %d, dec_pos:%d \n", pGTPHdr->ucMessageType, dec_pos);
			do_gtp_messages(ucBuf + skip_byte, iread -skip_byte, &dec_pos, pGTPHdr->ucMessageType, &tree_pos, &mRoot.child);

			make_tree_addr_GTP_Header_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, (void *)&pGTPHdr, &mRoot.child);

			printf ("GTP Messages: %d, dec_pos:%d \n", pGTPHdr->ucMessageType, dec_pos);
			switch(gtp_msgtype)
			{
				case 16:
					make_tree_addr_GTP_CrtPDPCxtReq_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, (void *)&pGTP_CPCReqMsg, &mRoot.child);
					break;
				case 17:
					make_tree_addr_GTP_CrtPDPCxtResp_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, (void *)&pGTP_CPCRespMsg, &mRoot.child);
					break;
				case 20:
					make_tree_addr_GTP_DelPDPCxtReq_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, (void *)&pGTP_DPCReqMsg, &mRoot.child);
					break;
				case 21:
					make_tree_addr_GTP_DelPDPCxtResp_sb (ucBuf + skip_byte, iread -skip_byte, &tree_pos, (void *)&pGTP_DPCRespMsg, &mRoot.child);
					break;
				default:
					break;
			}

			strcpy (protocol, "NULL");
			break;
		} else if (!strncmp (protocol, "DIAMETER", 8)) {
			printf ("	DIAMETER Header\n");
			decode_addr_DIAMETER_Header_sb (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pDIAMETERHdr);
			DIAMETER_Header_sb_Prt ("DIAMETER Header", pDIAMETERHdr);
/*
DIAMETER_Header_sb			*pDIAMETERHdr;
Location_Info_Req_sb		*pAVPLIReqMsg;
Location_Info_Resp_sb		*pAVPLIRespMsg;
Device_Watchdog_Req_sb		*pAVPDWReqMsg;
Device_Watchdog_Resp_sb		*pAVPDWRespMsg;
User_Authorization_Req_sb	*pAVPUAReqMsg;
User_Authorization_Resp_sb	*pAVPUARespMsg;
Server_Assignment_Req_sb	*pAVPSAReqMsg;
Server_Assignment_Resp_sb	*pAVPSARespMsg;
Multimedia_Auth_Req_sb		*pAVPMAReqMsg;
Multimedia_Auth_Resp_sb		*pAVPMARespMsg;

*/
			switch(pDIAMETERHdr->uiCommandCode)
			{
				case 280:
					if ( pDIAMETERHdr->DiaH1.B.bRequest == 1 )
					{
						decode_addr_Device_Watchdog_Req_sb  (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pAVPDWReqMsg);
						Device_Watchdog_Req_sb_Prt ("pAVPDWReqMsg ", pAVPDWReqMsg);
					}
					else
					{
						decode_addr_Device_Watchdog_Resp_sb  (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pAVPDWRespMsg);
						Device_Watchdog_Resp_sb_Prt ("pAVPDWRespMsg ", pAVPDWRespMsg);
					}
					break;
				case 300:
					if ( pDIAMETERHdr->DiaH1.B.bRequest == 1 )
					{
						decode_addr_User_Authorization_Req_sb  (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pAVPUAReqMsg);
						User_Authorization_Req_sb_Prt ("pAVPUAReqMsg ", pAVPUAReqMsg);
					}
					else
					{
						decode_addr_User_Authorization_Resp_sb  (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pAVPUARespMsg);
						User_Authorization_Resp_sb_Prt ("pAVPUARespMsg ", pAVPUARespMsg);

						if ( pAVPUARespMsg->stRESULTCODE.AVPLength == 0 )
						{
							/*
							memcpy ( ResultData, pAVPUARespMsg->stEXPRESULT.AVPData, pAVPUARespMsg->stEXPRESULT.AVPLength);
							printf(" AVPLength: %d, ResultData: [%02x]\n", pAVPUARespMsg->stEXPRESULT.AVPLength, ResultData[20]);
							ResultCode = ntohl(*((int *)(&ResultData[20])));
							*/
							ResultCode = ntohl(*((int *)(&pAVPUARespMsg->stEXPRESULT.AVPData[20])));

							printf(" --> EXP RESULT CODE: %d\n", ResultCode);
						}
						else
						{
							printf(" --> RESULT CODE: %d\n", pAVPUARespMsg->stRESULTCODE.AVPData);
						}
					}
					break;
				case 301:
					if ( pDIAMETERHdr->DiaH1.B.bRequest == 1 )
					{
						decode_addr_Server_Assignment_Req_sb  (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pAVPSAReqMsg);
						Server_Assignment_Req_sb_Prt ("pAVPSAReqMsg ", pAVPSAReqMsg);
					}
					else
					{
						decode_addr_Server_Assignment_Resp_sb  (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pAVPSARespMsg);
						Server_Assignment_Resp_sb_Prt ("pAVPSARespMsg ", pAVPSARespMsg);
					}
					break;
				case 302:
					if ( pDIAMETERHdr->DiaH1.B.bRequest == 1 )
					{
						decode_addr_Location_Info_Req_sb  (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pAVPLIReqMsg);
						Location_Info_Req_sb_Prt ("pAVPLIReqMsg ", pAVPLIReqMsg);
					}
					else
					{
						decode_addr_Location_Info_Resp_sb  (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pAVPLIRespMsg);
						Location_Info_Resp_sb_Prt ("pAVPLIRespMsg ", pAVPLIRespMsg);
					}
					break;
				case 303:
					if ( pDIAMETERHdr->DiaH1.B.bRequest == 1 )
					{
						decode_addr_Multimedia_Auth_Req_sb  (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pAVPMAReqMsg);
						Multimedia_Auth_Req_sb_Prt ("pAVPMAReqMsg ", pAVPMAReqMsg);
					}
					else
					{
						decode_addr_Multimedia_Auth_Resp_sb  (ucBuf + skip_byte, iread -skip_byte, &dec_pos, &pAVPMARespMsg);
						Multimedia_Auth_Resp_sb_Prt ("pAVPMARespMsg ", pAVPMARespMsg);
					}
					break;

				default:
					printf("UNDEF: CommandCode [%d]\n", pDIAMETERHdr->uiCommandCode);
					break;
			}

			strcpy (protocol, "NULL");
		}
		else {
			printf ("Not defined Protocol type: %s, dec_pos:%d, tree_pos:%d\n", protocol, dec_pos, tree_pos);
			break;
		}

	} while (b_continue);

	root_print (&mRoot);

//	print_packet_view_tree (&mRoot, utreebuf, &line);
//	printf (".utreebuf: \n%s\n", utreebuf);

	proot_node_free (&mRoot);

	exit(0);
}

/**  
 *  $Log: proto_print.c,v $
 *  Revision 1.25  2007/06/20 05:02:23  jsyoon
 *  NOTE MS GPRS PRESENT REQUEST 메세지 테스트
 *
 *  Revision 1.24  2007/06/19 07:31:45  jsyoon
 *  GTP_MAP 메세지 테스트
 *
 *  Revision 1.23  2007/06/12 12:25:49  jsyoon
 *  *** empty log message ***
 *
 *  Revision 1.22  2007/06/12 08:54:14  jsyoon
 *  ADD Command Code: Multimedia-Auth-Answer (303)
 *
 *  Revision 1.21  2007/06/11 10:57:45  jsyoon
 *  ADD Device-Watchdog-Request/Response
 *
 *  Revision 1.20  2007/05/27 09:04:05  jsyoon
 *  MODIFY GTP_P PROTOCOL
 *
 *  Revision 1.19  2007/05/27 08:01:34  jsyoon
 *  MODIFY GTP_P PROTOCOL
 *
 *  Revision 1.18  2007/05/08 11:29:56  jsyoon
 *  ADD Location-Info-Request/Answer
 *
 *  Revision 1.17  2007/05/08 06:33:04  jsyoon
 *  Modify AVPs Structures
 *
 *  Revision 1.16  2007/05/08 05:53:36  jsyoon
 *  ADD AVPs Structures
 *
 *  Revision 1.15  2007/04/24 06:36:32  jsyoon
 *  Add Message Definition
 *
 *  Revision 1.14  2007/03/16 01:04:39  yhshin
 *  test 수정
 *
 *  Revision 1.13  2007/03/15 04:05:29  jsyoon
 *  구조체 이름 변경
 *
 *  Revision 1.12  2007/03/15 02:40:33  yhshin
 *  pos, len 추가
 *
 *  Revision 1.11  2007/03/14 07:54:23  yhshin
 *  *** empty log message ***
 *
 *  Revision 1.10  2007/03/14 05:29:48  yhshin
 *  TCP_Header_list 추가
 *
 *  Revision 1.9  2007/03/12 08:29:13  jsyoon
 *  proto_print.c 스트럭쳐 변경
 *
 *  Revision 1.8  2007/02/23 07:56:11  jsyoon
 *  GTP 메세지 처리 추가
 *
 *  Revision 1.7  2007/02/21 11:45:54  jsyoon
 *  GTP 값 테스트
 *
 *  Revision 1.6  2007/02/20 05:07:27  jsyoon
 *  *** empty log message ***
 *
 *  Revision 1.5  2007/02/16 08:43:10  jsyoon
 *  Test decode_addr_GTP_CrtPDPCxtReq_sb
 *
 *  Revision 1.4  2007/02/15 09:53:12  yhshin
 *  rtcp 추가
 *
 *  Revision 1.3  2007/02/15 06:23:08  jsyoon
 *  Add UDP, GTP Testing Code
 *
 *  Revision 1.2  2007/02/15 06:12:55  yhshin
 *  *** empty log message ***
 *
 *  Revision 1.1  2007/02/08 12:44:54  yhshin
 *  test program
 *
 *  Revision 1.6  2007/02/08 01:21:46  yhshin
 *  *** empty log message ***
 *
 *  Revision 1.5  2007/02/06 23:12:41  yhshin
 *  tree test
 *
 *  Revision 1.4  2007/01/26 04:25:13  yhshin
 *  test
 *
 *  Revision 1.3  2007/01/24 04:51:43  yhshin
 *  decode_addr_GMM_ServiceReq 사용
 *
 *  Revision 1.2  2007/01/23 04:52:45  yhshin
 *  test
 *
 *  Revision 1.1  2007/01/18 01:46:03  yhshin
 *  rename test_tcphdr.c
 *
 *  Revision 1.1  2007/01/16 11:12:58  yhshin
 *  TCP header test
 *
 **/

