/** @file nifo.c
 * 	Interface Library file.
 *
 *	$Id: nifo.c,v 1.97 2007/06/07 03:54:38 dark264sh Exp $
 *
 *	Copyright (c) 2006~ by Upresto Inc, Korea
 *	All rights reserved.
 * 
 *	@Author      $Author: dark264sh $
 *	@version     $Revision: 1.97 $
 *	@date        $Date: 2007/06/07 03:54:38 $
 *	@ref         nifo.h
 *	@warning     nothing
 *	@todo        nothing
 *
 *	@section     Intro(소개)
 *		- Interface library 파일  (shared memory, message queue, offset linked list 개념으로 작성)
 *		- hasho_init으로 초기롸를 한후에 기본저인 primitives 를 이용하게 함
 *		- primitives
 *			@li nifo_init, nifo_msgq_init
 *			@li nifo_node_alloc
 *			@li nifo_node_link_cont_prev, nifo_node_link_cont_next, nifo_node_link_nont_prev, nifo_node_link_nont_next
 *			@li	nifo_tlv_alloc
 *			@li nifo_msg_write
 *			@li nifo_msg_read
 *			@li nifo_get_point_all, nifo_get_point_cont, nifo_get_value, nifo_get_tlv, nifo_get_tlv_all nifo_read_tlv_all
 *			@li nifo_node_for_each_start, nifo_node_for_each_end
 *			@li nifo_node_unlink_nont, nifo_node_unlink_cont
 *			@li	nifo_node_free nifo_node_delete
 *			@li	nifo_print_nont nifo_print_cont
 *			@li Supplement: Nothing
 *
 *	@section     Requirement
 *		@li 규칙에 틀린 곳을 찾아주세요.
 *
 **/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <errno.h>

#include "nifo.h"

#define	MAX_NIFO_PROCNAME_LEN	(MEMS_MAX_DEBUG_STR - 1)
#define MAX_NIFO_PROCNAME_SIZE	(MAX_NIFO_PROCNAME_LEN + 1)
U8		procName[MAX_NIFO_PROCNAME_SIZE];
S32		procID;

U64		nifo_create;
U64		nifo_del;

# define iscntrl(c) __isctype((c), _IScntrl)
#define WIDTH   16
int nifo_dump_DebugString(char *debug_str, char *s, int len)
{
	char buf[BUFSIZ],lbuf[BUFSIZ],rbuf[BUFSIZ];
	unsigned char *p;
	int line,i;

	FPRINTF(LOG_LEVEL,"### %s\n",debug_str);
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
		FPRINTF(stdout,"%04x: %-*s    %s\n",line - 1,WIDTH * 3,lbuf,rbuf);
	}
	return line;
}

/** nifo_get_offset_node function. 
 *
 *  해당 Pointer를 가지고 NODE 시작 OFFSET을 찾는 함수 
 *
 * 	@param *pMEMSINFO: 메모리 관리 정보
 *  @param *ptr: NODE 내부의 Pointer
 *
 *  @return     OFFSET	(NODE 시작 OFFSET)
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
OFFSET nifo_get_offset_node(stMEMSINFO *pMEMSINFO, U8 *ptr)
{
	OFFSET base;
	S32	cnt;

	base = nifo_offset(pMEMSINFO, ptr);

	base = base - (stMEMSINFO_SIZE + pMEMSINFO->uiHeadRoomSize);	

	cnt = base / (pMEMSINFO->uiMemNodeHdrSize + pMEMSINFO->uiMemNodeBodySize);

	base = stMEMSINFO_SIZE + pMEMSINFO->uiHeadRoomSize + (pMEMSINFO->uiMemNodeHdrSize + pMEMSINFO->uiMemNodeBodySize) * cnt + pMEMSINFO->uiMemNodeHdrSize;

	return base;
}

/** nifo_node_check function. 
 *
 *  NODE들이 유효한지를 판단하는 함수 
 *
 * 	@param *pMEMSINFO: 메모리 관리 정보
 *  @param offset: OFFSET of HEADER NODE 
 *
 *  @return     S32		SUCC: NODE의 개수, FAIL: less 0 
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
S32 nifo_node_check(stMEMSINFO *pMEMSINFO, OFFSET offset)
{
	S32				nontcnt = 0, contcnt = 0;
	U8				*p;
    clist_head      *pNont, *pCont;
    NIFO            *pNode, *pSNode, *pTmp;
	stMEMSNODEHDR	*pMEMSNODEHDR;
	
	p = nifo_ptr(pMEMSINFO, offset);
    pTmp = (NIFO *)p;

    nifo_node_for_each_start(pMEMSINFO, pNont, &pTmp->nont) {
        pNode = clist_entry(pNont, NIFO, nont);
		nontcnt++;
        nifo_node_for_each_start(pMEMSINFO, pCont, &pNode->cont) {
            pSNode = clist_entry(pCont, NIFO, cont);
			contcnt++;
			pMEMSNODEHDR = (stMEMSNODEHDR *)(((U8 *)pSNode) - stMEMSNODEHDR_SIZE);
			if((MEMS_ID != pMEMSNODEHDR->uiID) || (MEMS_ALLOCED != pMEMSNODEHDR->ucIsFree)) {
				FPRINTF(LOG_BUG, "ALLOC PROCESS[%s] FREE PROCESS[%s] ID[%u][%u]TIME[%u]ISFREE[%d] NONTCNT[%d] CONTCNT[%d]", 
					pMEMSNODEHDR->DebugStr, pMEMSNODEHDR->DelStr, pMEMSNODEHDR->uiID, MEMS_ID,
					pMEMSNODEHDR->TimeSec, pMEMSNODEHDR->ucIsFree, nontcnt, contcnt);
				return -1;
			}

			memcpy(pMEMSNODEHDR->DelStr, procName, MAX_NIFO_PROCNAME_LEN);
			pMEMSNODEHDR->DelStr[MAX_NIFO_PROCNAME_LEN] = 0x00;
			pMEMSNODEHDR->TimeSec = time(NULL);

        } nifo_node_for_each_end(pMEMSINFO, pCont, &pNode->cont)
    } nifo_node_for_each_end(pMEMSINFO, pNont, &pTmp->nont)

	return contcnt;
}

/** nifo_msgq_init function. 
 *
 *  MSGQ 초기화 함수 
 *
 * 	@param uiMsgqKey: Message Queue Key
 *
 *  @return     S32		SUCC: MsgQ ID, FAIL: less 0
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
S32 nifo_msgq_init(U32 uiMsgqKey)
{
	S32		dMsgqID;
	/* MSGQ 생성 */
	if((dMsgqID = msgget(uiMsgqKey, 0666|IPC_CREAT)) < 0) {
		return -errno;
	}

	return dMsgqID;
}

/** nifo_init function. 
 *
 *  초기화 함수 
 *
 * 	@param uiShmKey: Shared Memory Key
 * 	@param uiSemKey: Semaphore Key
 * 	@param *pDbgStr: Process Name (For Debugging)
 * 	@param processID: Process ID (For Debugging)
 *
 *  @return     stMEMSINFO *	(MEM 관리자 Pointer)
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
stMEMSINFO *nifo_init(U32 uiShmKey, U32 uiSemKey, U8 *pDbgStr, S32 processID)
{
	memcpy(procName, pDbgStr, MAX_NIFO_PROCNAME_LEN);
	procID = processID;
	procName[MAX_NIFO_PROCNAME_LEN] = 0x00;
	nifo_create = 0;
	nifo_del = 0;
	/* mems 생성 */
	return mems_init(MEMS_SHARED_MEM, uiShmKey, MEMS_SEMA_ON, uiSemKey, DEF_HEADROOM_SIZE, DEF_MEMNODEBODY_SIZE, DEF_MEMNODETOT_CNT);
}

/** nifo_node_alloc function. 
 *
 *	NODE 할당 함수
 *
 * 	@param *pstMEMSINFO: 메모리 관리 정보
 * 
 *  @return     U8 *	SUCC: Pointer of NODE, FAIL: NULL
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
U8 *nifo_node_alloc(stMEMSINFO *pstMEMSINFO)
{
	U8		*p;

	if((p = mems_alloc(pstMEMSINFO, DEF_MEMNODEBODY_SIZE, procName)) != NULL) {
		nifo_node_head_init(pstMEMSINFO, &(((NIFO *)p)->nont));
		nifo_node_head_init(pstMEMSINFO, &(((NIFO *)p)->cont));
		((NIFO *)p)->from = 0;
		((NIFO *)p)->to = 0;
		((NIFO *)p)->cnt = 0;
		((NIFO *)p)->maxoffset = DEF_MEMNODEBODY_SIZE;
		((NIFO *)p)->lastoffset = NIFO_SIZE;

		nifo_create++;
	}
	return p;
}

/** nifo_node_link_cont function. 
 *
 * 	한개의 NODE로 메시지를 처리 하지 못하는 경우
 * 	NODE를 더 생성하여 cont linked list에 달아서 관리한다. 
 *
 *                                                                      
 *    +-----+                                                          
 *    |  A  |                                                          
 *    +-----+                                                          
 *       |                                                              
 *    +-----+         +-----+                                         
 *    |  B  |========>|  B1 |                                         
 *    +-----+         +-----+                                          
 *       |                                                              
 *    +-----+                                                          
 *    |  C  |                                                          
 *    +-----+                                                          
 *       |                                                              
 *    +-----+                                                          
 *    |  D  |                                                          
 *    +-----+                                                          
 *
 *    Figure. 1.1
 *
 *
 *   ex) B에 B1을 cont로 연결하는 경우 (B1는 새로운 node)
 *                                                                      
 * 	@param *pstMEMSINFO: 메모리 관리 정보
 * 	@param *pHead: cont를 연결할 Node의 헤더 Node (Figure. 1.1 에서 B)
 * 	@param *pNew: 연결 하려는 새로운 Node (Figure. 1.1 에서 B1)
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
void nifo_node_link_cont_prev(stMEMSINFO *pstMEMSINFO, U8 *pHead, U8 *pNew)
{
	clist_add_tail(pstMEMSINFO, &((NIFO *)pNew)->cont, &((NIFO *)pHead)->cont);
}

void nifo_node_link_cont_next(stMEMSINFO *pstMEMSINFO, U8 *pHead, U8 *pNew)
{
	clist_add_head(pstMEMSINFO, &((NIFO *)pNew)->cont, &((NIFO *)pHead)->cont);
}

/** nifo_node_link_next function. 
 *
 * 	한개의 NODE에 다음 메시지 NODE 연결하는 linked list
 *                                                                      
 *    +-----+                                                          
 *    |  A  |                                                          
 *    +-----+                                                          
 *       |                                                              
 *    +-----+         +-----+                                         
 *    |  B  |========>|  B1 |                                         
 *    +-----+         +-----+                                          
 *       |                                                              
 *    +-----+                                                          
 *    |  C  |                                                          
 *    +-----+                                                          
 *       |                                                              
 *    +-----+                                                          
 *    |  D  |                                                          
 *    +-----+                                                          
 *
 *    Figure. 1.2
 *
 *                                                                      
 *   ex) C에 D를 next로 연결하는 경우 (D는 새로운 node)
 *
 * 	@param *pstMEMSINFO: 메모리 관리 정보
 * 	@param *pHead: cont를 연결할 Node의 헤더 Node (Figure. 1.2 에서 A)
 * 	@param *pNew: 연결 하려는 새로운 Node (Figure. 1.2 에서 D)
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
void nifo_node_link_nont_prev(stMEMSINFO *pstMEMSINFO, U8 *pHead, U8 *pNew)
{
	clist_add_tail(pstMEMSINFO, &((NIFO *)pNew)->nont, &((NIFO *)pHead)->nont);
}

void nifo_node_link_nont_next(stMEMSINFO *pstMEMSINFO, U8 *pHead, U8 *pNew)
{
	clist_add_head(pstMEMSINFO, &((NIFO *)pNew)->nont, &((NIFO *)pHead)->nont);
}

/** nifo_tlv_alloc function. 
 *
 * 	NODE의 마지막 OFFSET에서 사이즈만큼의 메모리의 Pointer를 반환하는 함수
 * 
 * 	@param *pMEMSINFO: 메모리 관리 정보
 * 	@param *pNode: Pointer of NODE
 * 	@param type: 사용 하려는 구조체 번호
 * 	@param len: 사용하려는 사이즈
 * 	@param memsetFlag: memset 여부를 결정하는 값 (DEF_MEMSET_ON, DEF_MEMSET_OFF)
 *
 *  @return     U8 *  SUCC: Pointer of NODE, FAIL: NULL
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
U8 *nifo_tlv_alloc(stMEMSINFO *pMEMSINFO, U8 *pNode, U32 type, U32 len, S32 memsetFlag)
{
	U8				*p;
	TLV				*pTLV;
	NIFO			*pNIFO;

	pNIFO = (NIFO *)pNode;

	if(pNIFO->maxoffset < pNIFO->lastoffset + TLV_SIZE + len)
		return NULL;

	pNIFO->cnt++;
	pTLV = (TLV *)nifo_ptr(pMEMSINFO, (nifo_offset(pMEMSINFO, pNode) + pNIFO->lastoffset));
	pTLV->type = type;
	pTLV->len = len;

	p = (U8 *)pTLV;

	pNIFO->lastoffset += (TLV_SIZE + len);	

	if(memsetFlag == DEF_MEMSET_ON)
		memset(p + TLV_SIZE, 0x00, len);

	return (p + TLV_SIZE);
}

/** nifo_msg_free function. 
 *
 * 	구조체 관리 구조체를 초기화 하는 함수
 * 
 * 	@param *pREADVALLIST: 받은 구조체 정보
 * 	@param idx: 지울 IDX (DEF_MSG_ALL이면 모두 삭제)
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
void nifo_msg_free(READ_VAL_LIST *pREADVALLIST, U32 idx)
{
	S32			i;

	if(idx == DEF_MSG_ALL) {
		for(i = 0; i < MAX_READVAL_CNT; i++) {
			if(pREADVALLIST->READVAL[i].memtype == DEF_READ_MALLOC) {
				free(pREADVALLIST->READVAL[i].pVal);
			}
			pREADVALLIST->READVAL[i].memtype = DEF_READ_EMPTY;
			pREADVALLIST->READVAL[i].len = 0;
			pREADVALLIST->READVAL[i].pVal = NULL;
		}
	} else {
		if(pREADVALLIST->READVAL[idx].memtype == DEF_READ_MALLOC) {
			free(pREADVALLIST->READVAL[idx].pVal);
		}
		pREADVALLIST->READVAL[idx].memtype = DEF_READ_EMPTY;
		pREADVALLIST->READVAL[idx].len = 0;
		pREADVALLIST->READVAL[idx].pVal = NULL;
	}
}

/** nifo_get_value function. 
 *
 * 	해당 NODE에 대한 해당 TYPE의 구조체의 Pointer를 찾아서 리턴 해주는 함수
 * 
 * 	@param *pMEMSINFO: 메모리 관리 정보
 * 	@param type: 받을 구조체 TYPE 정보
 * 	@param offset: header list offset 값
 *
 *  @return     U8 *	SUCC: 해당 Pointer, FAIL: NULL
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
U8 *nifo_get_value(stMEMSINFO *pMEMSINFO, U32 type, OFFSET offset)
{
	U8			*pNode;
	NIFO		*pNIFO;
	TLV			*pTLV;
	OFFSET		curoffset;

	pNode = nifo_ptr(pMEMSINFO, offset);
	pNIFO = (NIFO *)pNode;
	curoffset = NIFO_SIZE;

	while(curoffset < pNIFO->lastoffset) {
		pTLV = (TLV *)(pNode + curoffset);
		curoffset += TLV_SIZE;
		if(pTLV->type == type) {
			return (pNode + curoffset);
		}
		curoffset += pTLV->len;
	}

	return NULL;
}

/** nifo_get_tlv function. 
 *
 * 	해당 NODE에 대한 해당 TYPE의 TLV의 Pointer를 찾아서 리턴 해주는 함수
 * 
 * 	@param *pMEMSINFO: 메모리 관리 정보
 * 	@param type: 받을 구조체 TYPE 정보
 * 	@param offset: header list offset 값
 *
 *  @return     U8 *	SUCC: 해당 Pointer, FAIL: NULL
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
U8 *nifo_get_tlv(stMEMSINFO *pMEMSINFO, U32 type, OFFSET offset)
{
	U8			*pNode;
	NIFO		*pNIFO;
	TLV			*pTLV;
	OFFSET		curoffset;

	pNode = nifo_ptr(pMEMSINFO, offset);
	pNIFO = (NIFO *)pNode;
	curoffset = NIFO_SIZE;

	while(curoffset < pNIFO->lastoffset) {
		pTLV = (TLV *)(pNode + curoffset);
		if(pTLV->type == type) {
			return (pNode + curoffset);
		}
		curoffset += (TLV_SIZE + pTLV->len);
	}

	return NULL;
}

/** nifo_get_point_cont function. 
 *
 * 	linked list 에 들어온 모든 구조체 값의 Pointer를 찾아서 리턴 해주는 함수 (cont)
 * 
 * 	@param *pstMEMSINFO: 메모리 관리 정보
 * 	@param *pREADVALLIST: 받은 구조체 정보
 * 	@param offset: header list offset 값
 *
 *  @return     S32
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
S32 nifo_get_point_cont(stMEMSINFO *pstMEMSINFO, READ_VAL_LIST *pREADVALLIST, OFFSET offset)
{
	S32				i;
	U32 			dOffset, dOldLen, dIdx, dLen, dCopySize;
	U8				*pBuf, *pSetNode;
	NIFO 			*pRcv;
	NIFO			*pNode, *pSNode;
	TLV				*pTLV;

	pRcv = (NIFO *)nifo_ptr(pstMEMSINFO, offset);

	pNode = clist_entry(pRcv, NIFO, nont);

	dOffset = NIFO_SIZE;

	pSNode = pNode;
	pSetNode = (U8 *)pSNode;
				
	for(i = 0; i < pSNode->cnt; i++) {
		U8 szBuf[8];
		if(dOffset + TLV_SIZE > DEF_MEMNODEBODY_SIZE) {
			pBuf = szBuf;
			dOldLen = 0;
			dLen = TLV_SIZE;
			while(dOldLen < dLen) {
				if((dOffset + dLen - dOldLen) > DEF_MEMNODEBODY_SIZE) {
					dCopySize = DEF_MEMNODEBODY_SIZE - dOffset;
					memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
					pSNode = clist_entry(nifo_ptr(pstMEMSINFO, (pSNode->cont).offset_next), NIFO, cont); 
					pSetNode = (U8 *)pSNode;
					dOldLen += dCopySize;
					dOffset = (dOffset + dCopySize + NIFO_SIZE) % DEF_MEMNODEBODY_SIZE;
				} else {
					dCopySize = dLen - dOldLen;
					memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
					dOldLen += dCopySize;
					dOffset += dCopySize;
				}
			}
				
			pTLV = (TLV *)szBuf;
		} else {
			pTLV = (TLV *)(pSetNode+dOffset);
			dOffset += TLV_SIZE;
		}

		dIdx = pTLV->type;
		dLen = pTLV->len;
	
		if(dOffset + dLen > DEF_MEMNODEBODY_SIZE) {
			if(pREADVALLIST->READVAL[dIdx].init == DEF_READ_ON) {
				if((pBuf = malloc(dLen + 1)) == NULL) {
					return -errno;
				}
				pREADVALLIST->READVAL[dIdx].pVal = pBuf;
				pREADVALLIST->READVAL[dIdx].memtype = DEF_READ_MALLOC;
				pREADVALLIST->READVAL[dIdx].len = dLen;

				dOldLen = 0;
				while(dOldLen < dLen) {
					if((dOffset + dLen - dOldLen) > DEF_MEMNODEBODY_SIZE) {
						dCopySize = DEF_MEMNODEBODY_SIZE - dOffset;
						memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
						pSNode = clist_entry(nifo_ptr(pstMEMSINFO, (pSNode->cont).offset_next), NIFO, cont); 
						pSetNode = (U8 *)pSNode;
						dOldLen += dCopySize;
						dOffset = (dOffset + dCopySize + NIFO_SIZE) % DEF_MEMNODEBODY_SIZE;
					} else {
						dCopySize = dLen - dOldLen;
						memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
						dOldLen += dCopySize;
						dOffset += dCopySize;
					}

				}
					
			} else {
				dOldLen = 0;
				while(dOldLen < dLen) {
					if((dOffset + dLen - dOldLen) > DEF_MEMNODEBODY_SIZE) {
						dCopySize = DEF_MEMNODEBODY_SIZE - dOffset;
						pSNode = clist_entry(nifo_ptr(pstMEMSINFO, (pSNode->cont).offset_next), NIFO, cont); 
						pSetNode = (U8 *)pSNode;
						dOldLen += dCopySize;
						dOffset = (dOffset + dCopySize + NIFO_SIZE) % DEF_MEMNODEBODY_SIZE;
					} else {
						dCopySize = dLen - dOldLen;
						dOldLen += dCopySize;
						dOffset += dCopySize;
					}

				}
			}
		} else {
			if(pREADVALLIST->READVAL[dIdx].init == DEF_READ_ON) {
				pREADVALLIST->READVAL[dIdx].memtype = DEF_READ_ORIGIN;
				pREADVALLIST->READVAL[dIdx].pVal = pSetNode+dOffset;
				pREADVALLIST->READVAL[dIdx].len = dLen;
			}
			dOffset += dLen;
		}

	}

	return 1;
}

/** nifo_get_point_all function. 
 *
 * 	linked list 에 들어온 모든 구조체 값의 Pointer를 찾아서 리턴 해주는 함수 (nont, cont)
 * 
 * 	@param *pstMEMSINFO: 메모리 관리 정보
 * 	@param *pREADVALLIST: 받은 구조체 정보
 * 	@param offset: header list offset 값
 *
 *  @return     S32
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
S32 nifo_get_point_all(stMEMSINFO *pstMEMSINFO, READ_VAL_LIST *pREADVALLIST, OFFSET offset)
{
	S32				dRet;
	NIFO 			*pRcv;
	clist_head		*pNont;
	NIFO			*pNode;

	pRcv = (NIFO *)nifo_ptr(pstMEMSINFO, offset);

	nifo_node_for_each_start(pstMEMSINFO, pNont, &pRcv->nont) {
		pNode = clist_entry(pNont, NIFO, nont);
		if((dRet = nifo_get_point_cont(pstMEMSINFO, pREADVALLIST, nifo_offset(pstMEMSINFO, pNode))) < 0) {
			return dRet;
		}
	} nifo_node_for_each_end(pstMEMSINFO, pNont, &pRcv->nont)

	return 1;
}

/** nifo_get_tlv_cont function. 
 *
 * 	linked list 에 들어온 모든 구조체 값의 Pointer를 찾아서 리턴 해주는 함수 (cont)
 * 
 * 	@param *pstMEMSINFO: 메모리 관리 정보
 * 	@param offset: header list offset 값
 * 	@param *exec_func: 처리 function pointer
 * 	@param *out: exec_func 내부 처리 이후 결과를 받을 void pointer
 *
 *  @return     S32
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
S32 nifo_get_tlv_cont(stMEMSINFO *pstMEMSINFO, OFFSET offset, S32 (*exec_func)(U32 type, U32 len, U8 *data, S32 memflag, void *out), void *out)
{
	S32				i, dRet;
	U32 			dOffset, dOldLen, dIdx, dLen, dCopySize;
	U8				*pBuf, *pSetNode;
	NIFO 			*pRcv;
	NIFO			*pNode, *pSNode;
	TLV				*pTLV;

	pRcv = (NIFO *)nifo_ptr(pstMEMSINFO, offset);

	pNode = clist_entry(pRcv, NIFO, nont);

	dOffset = NIFO_SIZE;

	pSNode = pNode;
	pSetNode = (U8 *)pSNode;
				
	for(i = 0; i < pSNode->cnt; i++) {
		U8 szBuf[8];
		if(dOffset + TLV_SIZE > DEF_MEMNODEBODY_SIZE) {
			pBuf = szBuf;
			dOldLen = 0;
			dLen = TLV_SIZE;
			while(dOldLen < dLen) {
				if((dOffset + dLen - dOldLen) > DEF_MEMNODEBODY_SIZE) {
					dCopySize = DEF_MEMNODEBODY_SIZE - dOffset;
					memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
					pSNode = clist_entry(nifo_ptr(pstMEMSINFO, (pSNode->cont).offset_next), NIFO, cont); 
					pSetNode = (U8 *)pSNode;
					dOldLen += dCopySize;
					dOffset = (dOffset + dCopySize + NIFO_SIZE) % DEF_MEMNODEBODY_SIZE;
				} else {
					dCopySize = dLen - dOldLen;
					memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
					dOldLen += dCopySize;
					dOffset += dCopySize;
				}
			}
				
			pTLV = (TLV *)szBuf;
		} else {
			pTLV = (TLV *)(pSetNode+dOffset);
			dOffset += TLV_SIZE;
		}

		dIdx = pTLV->type;
		dLen = pTLV->len;
	
		if(dOffset + dLen > DEF_MEMNODEBODY_SIZE) {
			if((pBuf = malloc(dLen + 1)) == NULL) {
				return -errno;
			}

			dOldLen = 0;
			while(dOldLen < dLen) {
				if((dOffset + dLen - dOldLen) > DEF_MEMNODEBODY_SIZE) {
					dCopySize = DEF_MEMNODEBODY_SIZE - dOffset;
					memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
					pSNode = clist_entry(nifo_ptr(pstMEMSINFO, (pSNode->cont).offset_next), NIFO, cont); 
					pSetNode = (U8 *)pSNode;
					dOldLen += dCopySize;
					dOffset = (dOffset + dCopySize + NIFO_SIZE) % DEF_MEMNODEBODY_SIZE;
				} else {
					dCopySize = dLen - dOldLen;
					memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
					dOldLen += dCopySize;
					dOffset += dCopySize;
				}

			}
					

			if((dRet = exec_func(pTLV->type, pTLV->len, pBuf, DEF_READ_MALLOC, out)) < 0) {
				free(pBuf);
				return dRet;
			}
			free(pBuf);

		} else {
			if((dRet = exec_func(pTLV->type, pTLV->len, pSetNode+dOffset, DEF_READ_ORIGIN, out)) < 0)
				return dRet;

			dOffset += dLen;
		}

	}

	return 1;
}

/** nifo_get_tlv_all function. 
 *
 * 	linked list 에 들어온 모든 구조체 값의 Pointer를 찾아서 리턴 해주는 함수 (nont, cont)
 * 
 * 	@param *pstMEMSINFO	: 메모리 관리 정보
 * 	@param offset: header list offset 값
 * 	@param *exec_func: 처리 function pointer
 * 	@param *out: exec_func 내부 처리 이후 결과를 받을 void pointer
 *
 *  @return     S32
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
S32 nifo_get_tlv_all(stMEMSINFO *pstMEMSINFO, OFFSET offset, S32 (*exec_func)(U32 type, U32 len, U8 *data, S32 memflag, void *out), void *out)
{
	S32				dRet;
	NIFO 			*pRcv;
	clist_head		*pNont;
	NIFO			*pNode;

	pRcv = (NIFO *)nifo_ptr(pstMEMSINFO, offset);

	nifo_node_for_each_start(pstMEMSINFO, pNont, &pRcv->nont) {
		pNode = clist_entry(pNont, NIFO, nont);
		if((dRet = nifo_get_tlv_cont(pstMEMSINFO, nifo_offset(pstMEMSINFO, pNode), exec_func, out)) < 0) {
			return dRet;
		}
	} nifo_node_for_each_end(pstMEMSINFO, pNont, &pRcv->nont)

	return 1;
}

/** nifo_read_tlv_cont function. 
 *
 * 	linked list 에 들어온 모든 구조체 값의 Pointer를 찾아서 리턴 해주는 함수 (cont)
 * 
 * 	@param *pMEMSINFO: 메모리 관리 정보
 * 	@param *pHEAD: HEADER NODE
 * 	@param *type: TLV type
 * 	@param *len: TLV length
 * 	@param **value: TLV value
 * 	@param *ismalloc: malloc된 메오리인지 아닌지 판단 (DEF_READ_MALLOC, DEF_READ_ORGIN)
 * 	@param **nexttlv: Next TLV Pointer
 *
 *  @return     S32		SUCC: 1, FAIL: less 0
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
S32 nifo_read_tlv_cont(stMEMSINFO *pMEMSINFO, U8 *pHEAD, U32 *type, U32 *len, U8 **value, S32 *ismalloc, U8 **nexttlv)
{
	U32 			dOffset, dOldLen, dLen, dCopySize;
	U8				*pBuf, *pSetNode;
	NIFO			*pSNode;
	TLV				*pTLV;
	OFFSET			base, gap;

	base = nifo_get_offset_node(pMEMSINFO, *nexttlv);

	if((gap = nifo_offset(pMEMSINFO, *nexttlv) - base) == 0) {
		dOffset = NIFO_SIZE;
	} else {
		dOffset = gap;
	}

	pSNode = (NIFO *)nifo_ptr(pMEMSINFO, base);
	pSetNode = (U8 *)pSNode;
				
	U8 szBuf[8];
	if(dOffset + TLV_SIZE > DEF_MEMNODEBODY_SIZE) {
		pBuf = szBuf;
		dOldLen = 0;
		dLen = TLV_SIZE;
		while(dOldLen < dLen) {
			if((dOffset + dLen - dOldLen) > DEF_MEMNODEBODY_SIZE) {
				dCopySize = DEF_MEMNODEBODY_SIZE - dOffset;
				memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
				pSNode = clist_entry(nifo_ptr(pMEMSINFO, (pSNode->cont).offset_next), NIFO, cont); 
				pSetNode = (U8 *)pSNode;
				dOldLen += dCopySize;
				dOffset = (dOffset + dCopySize + NIFO_SIZE) % DEF_MEMNODEBODY_SIZE;
			} else {
				dCopySize = dLen - dOldLen;
				memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
				dOldLen += dCopySize;
				dOffset += dCopySize;
			}
		}
				
		pTLV = (TLV *)szBuf;
	} else {
		pTLV = (TLV *)(pSetNode+dOffset);
		dOffset += TLV_SIZE;
	}

	*type = pTLV->type;
	*len = pTLV->len;
	dLen = pTLV->len;
	
	if(dOffset + dLen > DEF_MEMNODEBODY_SIZE) {
		if((pBuf = malloc(dLen + 1)) == NULL) {
			return -errno;
		}

		dOldLen = 0;
		while(dOldLen < dLen) {
			if((dOffset + dLen - dOldLen) > DEF_MEMNODEBODY_SIZE) {
				dCopySize = DEF_MEMNODEBODY_SIZE - dOffset;
				memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
				pSNode = clist_entry(nifo_ptr(pMEMSINFO, (pSNode->cont).offset_next), NIFO, cont); 
				pSetNode = (U8 *)pSNode;
				dOldLen += dCopySize;
				dOffset = (dOffset + dCopySize + NIFO_SIZE) % DEF_MEMNODEBODY_SIZE;
			} else {
				dCopySize = dLen - dOldLen;
				memcpy(pBuf+dOldLen, pSetNode+dOffset, dCopySize);
				dOldLen += dCopySize;
				dOffset += dCopySize;
			}
		}
			

		*value = pBuf;
		*ismalloc = DEF_READ_MALLOC;

		if(pSNode->lastoffset <= dOffset) {
			if(pSNode->lastoffset == pSNode->maxoffset) {
				pSetNode = (U8 *)clist_entry(nifo_ptr(pMEMSINFO, (pSNode->cont).offset_next), NIFO, cont); 
				if(pHEAD == pSetNode) {
					*nexttlv = NULL;		
				} else {
					*nexttlv = pSetNode;
				}
			} else {
				*nexttlv = NULL;
			}
		}
		else {
			*nexttlv = nifo_ptr(pMEMSINFO, nifo_offset(pMEMSINFO, pSNode) + dOffset);
		}	

	} else {

		*value = pSetNode+dOffset;
		*ismalloc = DEF_READ_ORIGIN;

		dOffset += dLen;

		if(pSNode->lastoffset <= dOffset) {
			if(pSNode->lastoffset == pSNode->maxoffset) {
				pSetNode = (U8 *)clist_entry(nifo_ptr(pMEMSINFO, (pSNode->cont).offset_next), NIFO, cont); 
				if(pHEAD == pSetNode) {
					*nexttlv = NULL;		
				}
				else {
					*nexttlv = pSetNode;
				}
			} else {
				*nexttlv = NULL;
			}
		}
		else {
			*nexttlv = nifo_ptr(pMEMSINFO, nifo_offset(pMEMSINFO, pSNode) + dOffset);
		}
	}

	return 1;
}

/** nifo_copy_tlv_cont function. 
 *
 * 	TLV로 nifo NODE에 Data를 복사 해주는 함수
 * 
 * 	@param *pMEMSINFO: 메모리 관리 정보
 * 	@param type: TLV type
 * 	@param len: TLV length
 * 	@param *value: TLV value
 * 	@param *node: nifo NODE
 *
 *  @return     S32		SUCC: 0, FAIL: less 0
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       node는 반드시 HEAD NODE 이어야 함.
 **/
S32 nifo_copy_tlv_cont(stMEMSINFO *pMEMSINFO, U32 type, U32 len, U8 *value, U8 *node)
{
	U8				*p, *pNode, *pSubNode;
	TLV				aTLV;
	TLV				*pTLV;
	NIFO			*pNIFO;
	S32				copySize, remainSize, oldLen, copyLen;

	pNIFO = (NIFO *)node;
	pNode = (U8 *)clist_entry(nifo_ptr(pMEMSINFO, (pNIFO->cont).offset_prev), NIFO, cont); 
	pNIFO = (NIFO *)pNode;

	if(pNIFO->maxoffset < pNIFO->lastoffset + TLV_SIZE + len)
	{
		pTLV = &aTLV;
		pTLV->type = type;
		pTLV->len = len;

		if(pNIFO->maxoffset < pNIFO->lastoffset + TLV_SIZE)
		{
			copySize = pNIFO->maxoffset - pNIFO->lastoffset;
			remainSize = TLV_SIZE - copySize;

			p = nifo_ptr(pMEMSINFO, (nifo_offset(pMEMSINFO, pNode) + pNIFO->lastoffset));
			pNIFO->lastoffset += copySize;
			memcpy(p, (U8 *)pTLV, copySize);
			
			if((pSubNode = nifo_node_alloc(pMEMSINFO)) == NULL)
			{
				return -1;
			}

			clist_add_head(pMEMSINFO, &((NIFO *)pSubNode)->cont, &((NIFO *)pNode)->cont);			

			pNode = pSubNode;
			pNIFO = (NIFO *)pNode;

			p = nifo_ptr(pMEMSINFO, (nifo_offset(pMEMSINFO, pNode) + pNIFO->lastoffset));
			pNIFO->lastoffset += remainSize;
			memcpy(p, (U8 *)pTLV + copySize, remainSize);
		}
		else
		{
			p = nifo_ptr(pMEMSINFO, (nifo_offset(pMEMSINFO, pNode) + pNIFO->lastoffset));
			pNIFO->lastoffset += TLV_SIZE;
			memcpy(p, pTLV, TLV_SIZE);
		}

		if(pNIFO->maxoffset < pNIFO->lastoffset + len)
		{
			oldLen = 0;

			while(oldLen < len)
			{
				copyLen = len - oldLen;	

				remainSize = pNIFO->maxoffset - pNIFO->lastoffset;
				copySize = ((copyLen - remainSize) > 0) ? remainSize : copyLen;

				p = nifo_ptr(pMEMSINFO, (nifo_offset(pMEMSINFO, pNode) + pNIFO->lastoffset));
				pNIFO->lastoffset += copySize;
				memcpy(p, (U8 *)value, copySize);
				oldLen += copySize;
			
				if((copyLen - remainSize) > 0)
				{
					if((pSubNode = nifo_node_alloc(pMEMSINFO)) == NULL)
					{
						return -2;
					}

					clist_add_head(pMEMSINFO, &((NIFO *)pSubNode)->cont, &((NIFO *)pNode)->cont);			

					pNode = pSubNode;
					pNIFO = (NIFO *)pNode;
				}
			}
		}
		else
		{
			p = nifo_ptr(pMEMSINFO, (nifo_offset(pMEMSINFO, pNode) + pNIFO->lastoffset));
			pNIFO->lastoffset += len;
			memcpy(p, value, len);
		}
	}
	else
	{
		pTLV = (TLV *)nifo_ptr(pMEMSINFO, (nifo_offset(pMEMSINFO, pNode) + pNIFO->lastoffset));
		pTLV->type = type;
		pTLV->len = len;

		p = (U8 *)pTLV;
		pNIFO->lastoffset += (TLV_SIZE + len);	
		memcpy(p + TLV_SIZE, value, len);
	}

	return 0;
}

/** nifo_msg_write function. 
 *
 * 	NODE의 OFFSET을 전송하는 함수
 * 
 * 	@param *pstMEMSINFO: 메모리 관리 정보
 * 	@param uiMsgqID: MsgQ ID
 * 	@param *pNode: 전송을 원하는 Node
 *
 *  @return     S32		SUCC: 0, FAIL: less 0
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
S32 nifo_msg_write(stMEMSINFO *pstMEMSINFO, U32 uiMsgqID, U8 *pNode)
{
    S32 		dLen;
	S32			dRet = 0;
	OFFSET		offset;
	U8			szBuf[BUFSIZ];
	st_MsgQ		*pstMsgQ;
	st_MsgQSub	*pstMsgQSub;

	pstMsgQ = (st_MsgQ *)szBuf;
	pstMsgQSub = (st_MsgQSub *)(&pstMsgQ->mtype);

	pstMsgQSub->type = DEF_MSGQ_SVC;
	pstMsgQSub->svcid = 0;
	pstMsgQSub->msgid = 0;

	pstMsgQ->msgqid = uiMsgqID;
	pstMsgQ->len = sizeof(OFFSET);
	pstMsgQ->procid = procID;

	offset = nifo_offset(pstMEMSINFO, pNode);

	if((dRet = nifo_node_check(pstMEMSINFO, offset)) < 0) {
		FPRINTF(LOG_BUG, "@@@+++### SEND MSG : CANNOT SEND NON-ALLOCED MEMORY");
//		return -1;
		exit(0);
	}

	memcpy(&szBuf[st_MsgQ_SIZE], &offset, sizeof(OFFSET));

	dLen = st_MsgQ_SIZE + pstMsgQ->len - sizeof(S32);
	if(msgsnd(uiMsgqID, szBuf, dLen, IPC_NOWAIT) < 0)
	{
		FPRINTF(LOG_BUG, "SEND MSG : MSGSND ERROR %s\n", strerror(errno));
		dRet = -errno;
	}

	return dRet;
}

/** nifo_msg_read function. 
 *
 * 	전송된 NODE의 OFFSET을 읽는 함수
 * 
 * 	@param *pstMEMSINFO: 메모리 관리 정보
 * 	@param uiMsgqID: MsgQ ID
 * 	@param *pREADVALLIST: 받은 구조체 정보 (NULL 가능)
 *
 *  @return     OFFSET		SUCC: 전송된 OFFSET 값, FAIL: 0
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       *pREADVALLIST가 NULL인 경우 OFFSET만 return 함.
 **/
OFFSET nifo_msg_read(stMEMSINFO *pstMEMSINFO, U32 uiMsgqID, READ_VAL_LIST *pREADVALLIST)
{
    S32     		dRet;
	U8				szBuf[BUFSIZ];
	OFFSET			*offset;
	st_MsgQ			*pstMsgQ;

	/* READ_VAL_LIST 초기화 */
	if(pREADVALLIST != NULL)
		nifo_msg_free(pREADVALLIST, DEF_MSG_ALL);

    if((dRet = msgrcv(uiMsgqID, szBuf, BUFSIZ - sizeof(S32), 0, IPC_NOWAIT | MSG_NOERROR)) < 0)
    {
        if (errno != EINTR && errno != ENOMSG)
        {
            FPRINTF(LOG_BUG, "[FAIL:%d] MSGRCV MYQ : [%s]", errno, strerror(errno));
            return -errno;
        }

        return 0;
    }

	/* CHECK SIZE */
	pstMsgQ = (st_MsgQ *)szBuf;
	if(dRet != pstMsgQ->len + st_MsgQ_SIZE - sizeof(S32))
	{
		FPRINTF(LOG_BUG, "PROID[%d] MESSAGE SIZE ERROR RCV[%d]BODY[%d]HEAD[%d]MTYPE[%d]",
		pstMsgQ->procid, dRet, pstMsgQ->len, st_MsgQ_SIZE, sizeof(S32));
		return 0;
	}

	offset = (OFFSET *)&szBuf[st_MsgQ_SIZE];

	if((dRet = nifo_node_check(pstMEMSINFO, *offset)) < 0) {
		FPRINTF(LOG_BUG, "@@@+++### RCV MSG : RCV NON-ALLOCED MEMORY | SEND PROCESSID[%d] OFFSET[%u]", pstMsgQ->procid, *offset);
//		return -1;
		exit(0);
	}

	nifo_create += dRet;

	if(pREADVALLIST != NULL) {
		if((dRet = nifo_get_point_all(pstMEMSINFO, pREADVALLIST, *offset)) < 0) {
			return dRet;
		}
	}

    return *offset;
}

/** nifo_node_unlink_nont function. 
 *
 * 	nont의 NODE를 unlink 함.
 *                                                                      
 *    +-----+                                                          
 *    |  A  |                                                          
 *    +-----+                                                          
 *       |                                                              
 *    +-----+         +-----+                                         
 *    |  B  |========>|  B1 |                                         
 *    +-----+         +-----+                                          
 *       |                                                              
 *    +-----+                                                          
 *    |  C  |                                                          
 *    +-----+                                                          
 *       |                                                              
 *    +-----+                                                          
 *    |  D  |                                                          
 *    +-----+                                                          
 *
 *    Figure. 1.3
 *
 *                                                                      
 *   ex) B Node의 nont를 unlink하는 경우 
 * 		 B, B1가 link에서 분리됨
 *
 * 	@param *pstMEMSINFO: 메모리 관리 정보
 * 	@param *pDel: 삭제 하려는 Node (Figure. 1.3 에서 B)
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       prev, next가 offset
 *  			cont Node는 개별적으로 삭제가 불가능 함.
 *  			Header Node (Figure 1.3  A) 값을 삭제하는 경우 헤더로 대치 하여야 한다.
 **/
void nifo_node_unlink_nont(stMEMSINFO *pstMEMSINFO, U8 *pDel)
{
	clist_del_init(pstMEMSINFO, &((NIFO *)pDel)->nont);
}

/** nifo_node_unlink_cont function. 
 *
 * 	nont의 NODE를 unlink 함.
 *                                                                      
 *    +-----+                                                          
 *    |  A  |                                                          
 *    +-----+                                                          
 *       |                                                              
 *    +-----+         +-----+                                         
 *    |  B  |========>|  B1 |                                         
 *    +-----+         +-----+                                          
 *       |                                                              
 *    +-----+                                                          
 *    |  C  |                                                          
 *    +-----+                                                          
 *       |                                                              
 *    +-----+                                                          
 *    |  D  |                                                          
 *    +-----+                                                          
 *
 *    Figure. 1.4
 *
 *                                                                      
 *   ex) B1 Node의 cont를 unlink하는 경우 
 * 		 B에서 B1가 link에서 분리됨
 *
 * 	@param *pMEMSINFO: 메모리 관리 정보
 * 	@param *pDel: 삭제 하려는 Node (Figure. 1.4 에서 B1)
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       prev, next가 offset
 *  			Header Node (Figure 1.4  B) 값을 삭제하는 경우 헤더로 대치 하여야 한다.
 **/
void nifo_node_unlink_cont(stMEMSINFO *pMEMSINFO, U8 *pDel)
{
	clist_del_init(pMEMSINFO, &((NIFO *)pDel)->cont);
}

/** nifo_node_free function. 
 *
 * 	NODE를 free하는 함수 
 * 
 * 	@param *pstMEMSINFO: 메모리 관리 정보
 * 	@param *pFree: Free하려는 Pointer of NODE 
 *
 *  @return     S32		SUCC: 0, FAIL: less 0
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
S32 nifo_node_free(stMEMSINFO *pstMEMSINFO, U8 *pFree)
{
    stMEMSNODEHDR   *pMEMSNODEHDR;

	if(mems_free(pstMEMSINFO, pFree, procName) != 0) {
		/* 메모리가 깨진 상태로 더 이상 진행 하는 것이 무의미함. */

		pMEMSNODEHDR = (stMEMSNODEHDR *)(pFree - stMEMSNODEHDR_SIZE);
		FPRINTF(LOG_BUG, "@@@+++### ERROR: BROKEN MEMORY !!! will be exit | ALLOC PROCESS[%s] FREE PROCESS[%s] ID[%u]TIME[%u]ISFREE[%d]",
			pMEMSNODEHDR->DebugStr, pMEMSNODEHDR->DelStr, pMEMSNODEHDR->uiID,
			pMEMSNODEHDR->TimeSec, pMEMSNODEHDR->ucIsFree);
//		return -1;
		exit(0);
	}

	nifo_del++;

	return 0;
}

/** nifo_cont_delete function. 
 *
 * 	NODE를 unlink, free 하는 함수 (cont) 
 * 
 * 	@param *pMEMSINFO: 메모리 관리 정보
 * 	@param *pDel: Delete하려는 Pointer of NODE 
 *
 *  @return     U8 *		Next NODE
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
U8 *nifo_cont_delete(stMEMSINFO *pMEMSINFO, U8 *pDel)
{
	U8 *pNext;

	pNext = (U8 *)clist_entry(nifo_ptr(pMEMSINFO, ((NIFO *)pDel)->cont.offset_next), NIFO, cont);

	nifo_node_unlink_cont(pMEMSINFO, pDel);

	if(pNext == pDel)
		pNext = NULL;

	nifo_node_free(pMEMSINFO, pDel);

	return pNext;
}

/** nifo_nont_delete function. 
 *
 * 	NODE를 unlink, free 하는 함수 (nont) 
 * 
 * 	@param *pMEMSINFO: 메모리 관리 정보
 * 	@param *pDel: Delete하려는 Pointer of NODE 
 *
 *  @return     U8 *		Next NODE
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
U8 *nifo_nont_delete(stMEMSINFO *pMEMSINFO, U8 *pDel)
{
	U8 *pNext;

	pNext = (U8 *)clist_entry(nifo_ptr(pMEMSINFO, ((NIFO *)pDel)->nont.offset_next), NIFO, nont);

	nifo_node_unlink_nont(pMEMSINFO, pDel);

	if(pNext == pDel)
		pNext = NULL;

	return pNext;
}

/** nifo_node_free function. 
 *
 * 	NODE를 unlink, free 하는 함수 (cont, nont) 
 * 
 * 	@param *pMEMSINFO: 메모리 관리 정보
 * 	@param *pDel: Delete하려는 Pointer of NODE 
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       Nothing
 **/
void nifo_node_delete(stMEMSINFO *pMEMSINFO, U8 *pDel)
{
	U8 *pNode;
	U8 *pNext;

	pNode = pDel;

	do {
		pNext = nifo_nont_delete(pMEMSINFO, pNode);

		while(pNode != NULL) {
			pNode = nifo_cont_delete(pMEMSINFO, pNode);
		}
	} while((pNode = pNext) != NULL);
}

/** nifo_print_info function. 
 *
 * 	INFO print
 * 
 * 	@param *pcPrtPrefixStr: print prefix string
 * 	@param *pstMEMSINFO: 메모리 관리 정보 
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 *  @note       앞에는 prefix string을 넣어줌 (_%s)
 **/
void nifo_print_info(S8 *pcPrtPrefixStr, stMEMSINFO *pstMEMSINFO)
{
	stMEMSINFO_Prt(pcPrtPrefixStr, pstMEMSINFO);
}

/** nifo_print_nont function. 
 *
 * 	nont NODE를 따라 가면서 원하는 print_func을 호출해준다. print_func이 NULL인 경우 기본 정보를 찍는다.
 * 
 * 	@param *pstMEMSINFO: 메모리 관리 정보 
 * 	@param *p: Header Node 
 * 	@param *print_func: print 함수
 * 	@param *PrefixStr: Debug String
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 **/
void nifo_print_nont(stMEMSINFO *pstMEMSINFO, U8 *p, void (*print_func)(stMEMSINFO *pmem, U8 *pnode, U8 *str), U8 *PrefixStr)
{
	clist_head		*pNont;
	NIFO			*pNode, *pTmp;

	pTmp = (NIFO *)p;

	nifo_node_for_each_start(pstMEMSINFO, pNont, &pTmp->nont) {
		pNode = clist_entry(pNont, NIFO, nont);	
		if(print_func == NULL) {
			FPRINTF(LOG_LEVEL, 
				"[%s][%s.%d] [%s]## NONT NODE OFFSET[%u] nont->prev[%u] nont->next[%u] cont->prev[%u] cont->next[%u] FROM[%d] TO[%d] LASTOFFSET[%d] MAXOFFSET[%d]\n",
				__FILE__, __FUNCTION__, __LINE__, PrefixStr,
				nifo_offset(pstMEMSINFO, pNode), 
				(pNode->nont).offset_prev, (pNode->nont).offset_next,
			  	(pNode->cont).offset_prev, (pNode->cont).offset_next,
				pNode->from, pNode->to, pNode->lastoffset, pNode->maxoffset);	
		} else {
			print_func(pstMEMSINFO, (U8 *)pNode, PrefixStr);
		}
	} nifo_node_for_each_end(pstMEMSINFO, pNont, &pTmp->nont)
}

/** nifo_print_cont function. 
 *
 * 	cont NODE를 따라 가면서 원하는 print_func을 호출해준다. print_func이 NULL인 경우 기본 정보를 찍는다.
 * 
 * 	@param *pstMEMSINFO: 메모리 관리 정보 
 * 	@param *p: Header Node 
 * 	@param *print_func: print 함수
 * 	@param *PrefixStr: Debug String
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 **/
void nifo_print_cont(stMEMSINFO *pstMEMSINFO, U8 *p, void (*print_func)(stMEMSINFO *pmem, U8 *pnode, U8 *str), U8 *PrefixStr)
{
	clist_head		*pCont;
	NIFO			*pNode, *pTmp;

	pTmp = (NIFO *)p;

	nifo_node_for_each_start(pstMEMSINFO, pCont, &pTmp->cont) {
		pNode = clist_entry(pCont, NIFO, cont);	
		if(print_func == NULL) {
			FPRINTF(LOG_LEVEL, 
				"[%s][%s.%d] [%s]## CONT NODE OFFSET[%u] nont->prev[%u] nont->next[%u] cont->prev[%u] cont->next[%u] FROM[%d] TO[%d] LASTOFFSET[%d] MAXOFFSET[%d]\n",
				__FILE__, __FUNCTION__, __LINE__, PrefixStr,
				nifo_offset(pstMEMSINFO, pNode), 
				(pNode->nont).offset_prev, (pNode->nont).offset_next,
			  	(pNode->cont).offset_prev, (pNode->cont).offset_next,
				pNode->from, pNode->to, pNode->lastoffset, pNode->maxoffset);	
		} else {
			print_func(pstMEMSINFO, (U8 *)pNode, PrefixStr);
		}
	} nifo_node_for_each_end(pstMEMSINFO, pCont, &pTmp->cont)
}

/** 기본 nifo function : nifo_print_node function. 
 *
 * 	NIFO안의 모든 data를 찍어준다.
 * 
 * 	@param *pstMEMSINFO: 메모리 관리 정보 
 * 	@param *p : Header Node 
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 **/
void nifo_print_node(stMEMSINFO *pstMEMSINFO, U8 *p)
{
	clist_head		*pNont, *pCont;
	NIFO			*pNode, *pSNode, *pTmp;

	pTmp = (NIFO *)p;

	nifo_node_for_each_start(pstMEMSINFO, pNont, &pTmp->nont) {
		pNode = clist_entry(pNont, NIFO, nont);	
		nifo_node_for_each_start(pstMEMSINFO, pCont, &pNode->cont) {
			pSNode = clist_entry(pCont, NIFO, cont);
			FPRINTF(LOG_LEVEL, "## CONT OFFSET[%u] nont->prev[%u] nont->next[%u] cont->prev[%u] cont->next[%u] FROM[%d] TO[%d]\n",
				nifo_offset(pstMEMSINFO, pSNode), 
				(pSNode->nont).offset_prev, (pSNode->nont).offset_next,
			  	(pSNode->cont).offset_prev, (pSNode->cont).offset_next,
				pSNode->from, pSNode->to);	
		} nifo_node_for_each_end(pstMEMSINFO, pCont, &pNode->cont)
	} nifo_node_for_each_end(pstMEMSINFO, pNont, &pTmp->nont)
}

/** nifo_draw_all function. 
 *
 * 	MEM안의 모든 data를 찍어준다.
 * 
 * 	@param *filename:  Write할 filename
 * 	@param *labelname: label명  
 * 	@param *pstMEMSINFO: MEM 관리자 
 *
 *  @return     void
 *  @see        nifo.h nifo.c
 *
 *  @note       개개의 파일로 생성된다. 
 **/
void nifo_draw_all(S8 *filename, S8 *labelname, stMEMSINFO *pstMEMSINFO)
{
	U32	iIndex;
	stMEMSNODEHDR *pstMEMSNODEHDR;
	FILE *fp;
	U8 *pBase,*pIndex;

	pBase = (U8 *) (pstMEMSINFO) ; 
	pBase += pstMEMSINFO->offsetNodeStart;

	fp = fopen(filename,"w");
	FPRINTF(fp,"/** @file %s\n",filename);
	FPRINTF(fp,"uiMemNodeTotCnt = %d\\n\n",pstMEMSINFO->uiMemNodeTotCnt);
	FPRINTF(fp,"uiMemNodeAllocedCnt = %d\\n\n",pstMEMSINFO->uiMemNodeAllocedCnt);
	FPRINTF(fp,"\\dot \n	\
	digraph G{ 	\n\
	fontname=Helvetica; 	\n\
	label=\"Hash Table(%s)\"; 	\n\
	nodesep=.05; 	\n\
	rankdir=LR; 	\n\
	node [fontname=Helvetica,shape=record,width=.1,height=.1]; 	\n\
	node0 [label = \"",labelname);
	for(iIndex=0;iIndex < pstMEMSINFO->uiMemNodeTotCnt;iIndex++){
		pIndex = (U8*) (pBase + iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize)); 
		pstMEMSNODEHDR = (stMEMSNODEHDR *) pIndex;
		if(iIndex == pstMEMSINFO->uiMemNodeTotCnt -1){
			FPRINTF(fp,"<f%d> %d_%d_%s",iIndex,iIndex,pstMEMSNODEHDR->ucIsFree,pstMEMSNODEHDR->DebugStr);
		} else {
			FPRINTF(fp,"<f%d> %d_%d_%s |",iIndex,iIndex,pstMEMSNODEHDR->ucIsFree,pstMEMSNODEHDR->DebugStr);
		}
	}
	FPRINTF(fp,"\",height = 2.5];\n");
	FPRINTF(fp,"node [width=1.5];\n");
	FPRINTF(fp,"\n\n");
	FPRINTF(fp,"}\n\\enddot \n\n");
	FPRINTF(fp,"*/\n");
	fclose(fp);
}

#ifdef TEST
typedef struct _aaa {
	U8 a;
	U8 b;
	U16	d;
	U32 c;
} stKEY;

typedef struct _bbb {
	U8 a;
	U8 b;
	U8 d;
	U8 c;
} stDATA;

#define SHM_KEY_TEST	8000
#define SEM_KEY_TEST	8100
#define MSG_KEY_TEST	8200

/** main function.
 *
 *  Node를 삽입하고 , 삭제하는 과정을 text 및 그림으로 보여준다.  
 *  -DTEST 를 위해서 사용되어지는 것으로 main은 TEST가 정의될때만 수행
 *  이 프로그램은 기본적으로 library임. 
 * 
 *  @return     void
 *  @see        hash.h
 *
 *  @note       그림으로는 개개의 file로 생성되면 file명은 code에서 입력하게 되어져있습니다.
 **/

#if 0
int main(int argc, char *argv[])
{
	U32			uiMsgqID, result;
	U8			*p, *p1;
	NIFO			*pHead;
	stMEMSINFO	*pstMEMSINFO;

	/* NIFO INIT */
	pstMEMSINFO = nifo_init(MSG_KEY_TEST, SHM_KEY_TEST, SEM_KEY_TEST, &uiMsgqID);

	/* 1개의 Node Alloc */
	p = nifo_node_alloc(pstMEMSINFO, DEF_MEMNODEBODY_SIZE, (S8 *)__FUNCTION__);

	/* Node에 값 할당 */
	((NIFO *)p)->from = 1;
	((NIFO *)p)->to = 11;

	pHead = (NIFO *)p;

	/* 새로운 Node Alloc */
	p = nifo_node_alloc(pstMEMSINFO, DEF_MEMNODEBODY_SIZE, (S8 *)__FUNCTION__);

	/* Node에 값 할당 */
	((NIFO *)p)->from = 2;
	((NIFO *)p)->to = 12;

	/* nont에 연결 */
	nifo_node_link_nont(pstMEMSINFO, p, (U8 *)pHead);

	p1 = p;

	/* 새로운 Node Alloc */
	p = nifo_node_alloc(pstMEMSINFO, DEF_MEMNODEBODY_SIZE, (S8 *)__FUNCTION__);

	/* Node에 값 할당 */
	((NIFO *)p)->from = 3;
	((NIFO *)p)->to = 13;


	/* cont에 연결 */
	nifo_node_link_cont(pstMEMSINFO, p, (U8 *)p1);

	/* 새로운 Node Alloc */
	p = nifo_node_alloc(pstMEMSINFO, DEF_MEMNODEBODY_SIZE, (S8 *)__FUNCTION__);

	/* Node에 값 할당 */
	((NIFO *)p)->from = 4;
	((NIFO *)p)->to = 14;

	/* nont에 연결 */
	nifo_node_link_nont(pstMEMSINFO, p, (U8 *)pHead);

	/* 새로운 Node Alloc */
	p = nifo_node_alloc(pstMEMSINFO, DEF_MEMNODEBODY_SIZE, (S8 *)__FUNCTION__);

	/* Node에 값 할당 */
	((NIFO *)p)->from = 5;
	((NIFO *)p)->to = 15;

	/* nont에 연결 */
	nifo_node_link_nont(pstMEMSINFO, p, (U8 *)pHead);

	/**
	 * SEND
	 */

	printf("SEND OFFSET[%u]\n", nifo_offset(pstMEMSINFO, pHead));

	nifo_print_node(pstMEMSINFO, (U8 *)pHead);

	result = nifo_msg_write(pstMEMSINFO, uiMsgqID, 1, (U8 *)pHead);	
	if(result < 0) {
		printf("nifo_msg_write [%d][%s]\n", result, strerror(-result));
		exit(0);
	}


	/**
	 *  READ
	 */

	OFFSET		offset;
	U8			*pRcv;

	offset = nifo_msg_read(pstMEMSINFO, uiMsgqID);

	printf("RECV OFFSET[%u]\n", offset);

	pRcv = (U8 *)nifo_ptr(pstMEMSINFO, offset);

	nifo_print_node(pstMEMSINFO, pRcv);

	return 0;
}
#endif

int main(int argc, char *argv[])
{
	U32			uiMsgqID, result;
	U8			*p, *p1;
	NIFO			*pHead;
	stMEMSINFO	*pstMEMSINFO;
	U8			*pBuf;
	TLV		*pTLV;

	/* NIFO INIT */
	pstMEMSINFO = nifo_init(MSG_KEY_TEST, SHM_KEY_TEST, SEM_KEY_TEST, &uiMsgqID);

	/* 1개의 Node Alloc */
	p = nifo_node_alloc(pstMEMSINFO, DEF_MEMNODEBODY_SIZE, (S8 *)__FUNCTION__);

	/* Node에 값 할당 */
	((NIFO *)p)->from = 1;
	((NIFO *)p)->to = 11;

	pHead = (NIFO *)p;
	pTLV = (TLV *)&p[NIFO_SIZE];
	pBuf = (U8 *)&p[NIFO_SIZE + TLV_SIZE];

	pTLV->type = 1;
	pTLV->usLen = DEF_MEMNODEBODY_SIZE;

	pHead->cnt = 1;

	sprintf(pBuf, "test");


	/* 새로운 Node Alloc */
	p1 = nifo_node_alloc(pstMEMSINFO, DEF_MEMNODEBODY_SIZE, (S8 *)__FUNCTION__);

	/* nont에 연결 */
	nifo_node_link_cont(pstMEMSINFO, p1, (U8 *)pHead);

	

#if 0
	/* 새로운 Node Alloc */
	p = nifo_node_alloc(pstMEMSINFO, DEF_MEMNODEBODY_SIZE, (S8 *)__FUNCTION__);

	/* cont에 연결 */
	nifo_node_link_cont(pstMEMSINFO, p, (U8 *)pHead);
#endif

	/**
	 * SEND
	 */

	printf("SEND OFFSET[%u]\n", nifo_offset(pstMEMSINFO, pHead));

	nifo_print_node(pstMEMSINFO, (U8 *)pHead);

	result = nifo_msg_write(pstMEMSINFO, uiMsgqID, 1, (U8 *)pHead);	
	if(result < 0) {
		printf("nifo_msg_write [%d][%s]\n", result, strerror(-result));
		exit(0);
	}


	/**
	 *  READ
	 */

	S32			j;
	OFFSET		offset;
	U8			*pRcv;
	READ_VAL_LIST	READVALLIST;

for(j = 0; j < MAX_READVAL_CNT; j++) {
	READVALLIST.READVAL[j].init = DEF_READ_ON;
	READVALLIST.READVAL[j].memtype = DEF_READ_EMPTY;
	READVALLIST.READVAL[j].len = 0;
	READVALLIST.READVAL[j].pVal = NULL;
}
	READVALLIST.READVAL[1].init = DEF_READ_ON;

	offset = nifo_msg_read(pstMEMSINFO, uiMsgqID, &READVALLIST);


	printf("RECV OFFSET[%u]\n", offset);
	printf("RESULT [%d][%d][%d][%s]\n", READVALLIST.READVAL[1].init, 
		READVALLIST.READVAL[1].memtype, READVALLIST.READVAL[1].len, READVALLIST.READVAL[1].pVal);

	pRcv = (U8 *)nifo_ptr(pstMEMSINFO, offset);

	nifo_print_node(pstMEMSINFO, pRcv);

	return 0;
}

#endif /* TEST */

/*
 *     $Log: nifo.c,v $
 *     Revision 1.97  2007/06/07 03:54:38  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.96  2007/06/06 15:15:18  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.95  2007/06/01 13:07:19  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.94  2007/06/01 03:13:54  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.93  2007/03/06 05:59:22  yhshin
 *     test version
 *
 *     Revision 1.92  2007/02/15 01:37:19  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.91  2007/02/15 01:21:59  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.90  2006/11/29 08:01:12  dark264sh
 *     doxygen
 *
 *     Revision 1.89  2006/11/21 08:20:56  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.88  2006/11/12 11:58:11  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.87  2006/11/10 09:12:25  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.86  2006/11/08 07:45:37  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.85  2006/11/06 07:27:47  dark264sh
 *     nifo NODE size 4*1024 => 6*1024로 변경하기
 *     nifo_tlv_alloc에서 argument로 memset할지 말지 결정하도록 수정
 *     nifo_node_free에서 semaphore 삭제
 *
 *     Revision 1.84  2006/10/25 09:56:02  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.83  2006/10/20 09:52:21  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.82  2006/10/19 10:43:50  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.81  2006/10/18 12:33:54  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.80  2006/10/18 12:15:53  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.79  2006/10/18 08:54:38  dark264sh
 *     nifo debug 코드 추가
 *
 *     Revision 1.78  2006/10/18 03:07:19  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.77  2006/10/18 02:23:33  dark264sh
 *     free시 alloced 할당된 상태가 아니면 죽도록 처리
 *
 *     Revision 1.76  2006/10/17 03:49:44  dark264sh
 *     nifo_tlv_alloc에 memset 추가
 *
 *     Revision 1.75  2006/10/10 07:00:29  dark264sh
 *     A_CALL에 전송하는 부분 추가
 *     nifo_node_alloc 함수 변경에 따른 변경
 *     A_TCP에서 timerN_update의 리턴으로 timerNID 업데이트 하도록 변경
 *
 *     Revision 1.74  2006/10/04 01:45:42  dark264sh
 *     초기화 문제로 NODE를 재사용하는 경우 발생하는 문제 해결
 *
 *     Revision 1.73  2006/10/02 00:16:10  dark264sh
 *     TLV의 usLen => uiLen으로 변경 (U16 => U32) overflow 발생
 *
 *     Revision 1.72  2006/09/29 09:05:15  dark264sh
 *     type casting 추가
 *
 *     Revision 1.71  2006/09/29 08:53:10  dark264sh
 *     nifo_print_cont, nifo_print_nont 추가
 *
 *     Revision 1.70  2006/09/28 01:10:19  dark264sh
 *     두개의 NODE에 걸쳐서 데이터가 있는 경우 데이터 처리 후 OFFSET 계산이 잘못되는 버그 수정
 *
 *     Revision 1.69  2006/09/27 13:22:43  dark264sh
 *     no message
 *
 *     Revision 1.68  2006/09/27 11:28:00  dark264sh
 *     malloc 하는 경우 뒤의 부분이 처리 되지 않는 부분 수정
 *
 *     Revision 1.67  2006/09/25 09:01:03  dark264sh
 *     nifo_get_struct => nifo_get_value로 변경
 *
 *     Revision 1.66  2006/09/25 01:29:42  dark264sh
 *     no message
 *
 *     Revision 1.65  2006/09/25 01:19:58  dark264sh
 *     no message
 *
 *     Revision 1.64  2006/09/25 00:58:44  dark264sh
 *     no message
 *
 *     Revision 1.63  2006/09/22 09:29:30  dark264sh
 *     no message
 *
 *     Revision 1.62  2006/09/22 09:27:24  dark264sh
 *     no message
 *
 *     Revision 1.61  2006/09/22 08:32:45  dark264sh
 *     nifo_get_offset_node
 *
 *     Revision 1.60  2006/09/22 08:27:58  dark264sh
 *     nifo_get_offset_node, nifo_get_ptr_node 추가
 *
 *     Revision 1.59  2006/09/22 07:03:26  dark264sh
 *     no message
 *
 *     Revision 1.58  2006/09/22 06:59:08  dark264sh
 *     nifo_get_tlv_all 추가
 *
 *     Revision 1.57  2006/09/22 05:40:55  dark264sh
 *     nifo_get_tlv_all 추가
 *
 *     Revision 1.56  2006/09/22 05:19:29  dark264sh
 *     nifo_get_tlv_all 추가
 *
 *     Revision 1.55  2006/09/18 03:12:07  dark264sh
 *     no message
 *
 *     Revision 1.54  2006/09/18 03:03:37  dark264sh
 *     no message
 *
 *     Revision 1.53  2006/09/15 09:28:33  dark264sh
 *     nifo_node_link_nont, nifo_node_link_cont API 변경
 *
 *     Revision 1.52  2006/09/11 08:35:39  dark264sh
 *     nifo_tlv_alloc에서 offset 계산 버그 수정
 *
 *     Revision 1.51  2006/09/08 09:17:21  dark264sh
 *     nifo_get_struct, nifo_get_tlv 함수 추가
 *
 *     Revision 1.50  2006/09/08 08:54:55  dark264sh
 *     no message
 *
 *     Revision 1.49  2006/09/06 10:38:30  dark264sh
 *     nifo_msgq_init
 *     return Type 변경
 *
 *     Revision 1.48  2006/09/06 08:59:19  dark264sh
 *     nifo_init 변경
 *     MSGQ 할당은 개별적으로 하도록 처리
 *
 *     Revision 1.47  2006/08/28 12:13:58  dark264sh
 *     nifo_tlv_alloc 파라미터 변경
 *
 *     Revision 1.46  2006/08/28 01:07:00  dark264sh
 *     오타 수정
 *
 *     Revision 1.45  2006/08/23 03:04:39  dark264sh
 *     nifo_get_point_cont 의 다음 Node로 넘어가는 경우 offset 값 계산 방법 변경
 *
 *     Revision 1.44  2006/08/23 03:01:23  dark264sh
 *     no message
 *
 *     Revision 1.43  2006/08/17 02:51:27  dark264sh
 *     nifo_get_point_cont, nifo_get_point_all 함수 수정
 *
 *     Revision 1.42  2006/08/16 01:17:13  dark264sh
 *     nifo_tlv_alloc 함수 추가
 *
 *     Revision 1.41  2006/08/14 06:32:57  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.40  2006/08/14 05:47:03  dark264sh
 *     no message
 *
 *     Revision 1.39  2006/08/14 05:45:26  dark264sh
 *     no message
 *
 *     Revision 1.38  2006/08/14 05:43:00  dark264sh
 *     no message
 *
 *     Revision 1.37  2006/08/14 05:21:34  dark264sh
 *     no message
 *
 *     Revision 1.36  2006/08/14 05:05:04  dark264sh
 *     no message
 *
 *     Revision 1.35  2006/08/14 05:04:26  dark264sh
 *     no message
 *
 *     Revision 1.34  2006/08/14 05:01:14  dark264sh
 *     no message
 *
 *     Revision 1.33  2006/08/14 05:00:01  dark264sh
 *     no message
 *
 *     Revision 1.32  2006/08/14 04:58:56  dark264sh
 *     no message
 *
 *     Revision 1.31  2006/08/14 04:57:17  dark264sh
 *     no message
 *
 *     Revision 1.29  2006/08/14 04:35:40  dark264sh
 *     nifo_msg_read 변경
 *
 *     Revision 1.28  2006/08/14 02:05:35  dark264sh
 *     no message
 *
 *     Revision 1.27  2006/08/11 11:52:51  dark264sh
 *     no message
 *
 *     Revision 1.26  2006/08/07 11:25:14  dark264sh
 *     nifo_msgq_init 함수 추가
 *
 *     Revision 1.25  2006/08/07 10:37:10  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.19  2006/08/07 07:52:50  dark264sh
 *     no message
 *
 *     Revision 1.18  2006/08/07 07:49:14  dark264sh
 *     no message
 *
 *     Revision 1.17  2006/08/07 07:47:14  dark264sh
 *     no message
 *
 *     Revision 1.16  2006/08/07 07:45:10  dark264sh
 *     no message
 *
 *     Revision 1.15  2006/08/07 07:43:46  dark264sh
 *     no message
 *
 *     Revision 1.14  2006/08/07 07:42:21  dark264sh
 *     no message
 *
 *     Revision 1.13  2006/08/07 07:36:40  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.12  2006/08/07 07:31:15  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.11  2006/08/07 07:22:15  dark264sh
 *     no message
 *
 *     Revision 1.10  2006/08/07 07:19:20  dark264sh
 *     no message
 *
 *     Revision 1.9  2006/08/07 07:16:29  dark264sh
 *     no message
 *
 *     Revision 1.8  2006/08/07 07:12:55  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.7  2006/08/07 07:04:48  dark264sh
 *     no message
 *
 *     Revision 1.6  2006/08/07 07:01:50  dark264sh
 *     no message
 *
 *     Revision 1.5  2006/08/07 06:50:19  dark264sh
 *     no message
 *
 *     Revision 1.4  2006/08/07 06:49:06  dark264sh
 *     no message
 *
 *     Revision 1.3  2006/08/07 02:48:06  dark264sh
 *     no message
 *
 *     Revision 1.2  2006/08/04 12:07:00  dark264sh
 *     no message
 *
 *     Revision 1.1  2006/08/04 12:02:06  dark264sh
 *     INIT
 *
 */
