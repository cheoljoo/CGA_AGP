/** @file mems.c
 * ���� Memory Library file.
 *
 *		$Id: mems.c,v 1.25 2007/06/13 02:40:40 dark264sh Exp $
 *
 *     Copyright (c) 2006~ by Upresto Inc, Korea
 *     All rights reserved.
 * 
 *     @Author      $Author: dark264sh $
 *     @version     $Revision: 1.25 $
 *     @date        $Date: 2007/06/13 02:40:40 $
 *     @ref         mems.h
 *     @todo        hasho project�� �̰��� ������ ���̴�. 
 *
 *     @section     Intro(�Ұ�)
 *      - mems library ���� 
 *      - mems_init���� �ʱ�ָ� ���Ŀ� �⺻���� primitives �� �̿��ϰ� ��
 *      - primitives
 *      	@li mems_init
 *      	@li mems_alloc
 *      	@li mems_free
 *      	@li mems_print_info
 *      	@li mems_print_node
 *      	@li mems_print_all
 *      	@li Supplement 		: mems_draw_all
 *      	@li Supplement 		: mems_garbage_collector	-  ���� �ð����� ó�� �ȵ� �͵��� �����ְ� �ش� ������ ���
 *      - memory ����\n
 *          +----------------------------------+\n
 *          |    mems_info (stMEMSINFO)        |\n
 *          +----------------------------------+\n
 *          |    Head Room                     |\n
 *          +----------------------------------+\n
 *          |    mems node hdr1(stMEMSNODEHDR) |\n
 *          |    mems node data                |\n
 *          +----------------------------------+\n
 *          |    mems node hdr2(stMEMSNODEHDR) |\n
 *          |    mems node data                |\n
 *          +----------------------------------+\n
 *          |    mems node hdr3(stMEMSNODEHDR) |\n
 *          |    mems node data                |\n
 *          +----------------------------------+\n
 *
 *     @section     Requirement
 *      @li perl , doxygen , graphviz
 *
 *
 **/




#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/shm.h>
#include <errno.h>

#include "mems.h"



# define iscntrl(c) __isctype((c), _IScntrl)
#define WIDTH   16
int
mems_dump_DebugString(char *debug_str,char *s,int len)
{
	char buf[BUFSIZ],lbuf[BUFSIZ],rbuf[BUFSIZ];
	unsigned char *p;
	int line,i;

	FPRINTF(LOG_LEVEL, "### %s\n",debug_str);
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
		FPRINTF(LOG_LEVEL, "%04x: %-*s    %s\n",line - 1,WIDTH * 3,lbuf,rbuf);
	}
	return line;
}

#define SEMPERM     0666

/** �⺻ mems function : mems_sem_init function. 
 *
 * MEM���� ��� data�� ����ش�.
 * 
 * @param semkey	:  Semaphore Key
 * @param flag	:  Semaphore Flag (MEMS_SEMA_ON) 
 *
 *  @return     S32
 *  @see        mems.h
 *
 *  @note       ������ ���Ϸ� �����ȴ�. 
 **/
S32 mems_sem_init(key_t semkey, U32 flag)
{
	S32 ret = 0, semid = -1;
	
	if(flag != MEMS_SEMA_ON)
		return 0;

	if((semid = semget(semkey, 1, SEMPERM | IPC_CREAT | IPC_EXCL)) == -1)
	{
		if(errno == EEXIST)
			semid = semget(semkey, 1, SEMPERM | IPC_CREAT);
	}
	else	/* if created... */
	{
		ret = semctl(semid, 0, SETVAL, 1);
	}

	if(semid == -1 || ret == -1)
		exit(13);
	else
		return semid;
}

/** �⺻ mems function : mems_sem_remove function. 
 *
 * MEM���� ��� data�� ����ش�.
 * 
 * @param semkey	:  Semaphore Key 
 * @param flag	:  Semaphore Flag (MEMS_SEMA_ON) 
 *
 *  @return     S32
 *  @see        mems.h
 *
 *  @note       ������ ���Ϸ� �����ȴ�. 
 **/
S32 mems_sem_remove(key_t semkey, U32 flag)
{
	S32 ret = 0, semid = -1;

	if(flag != MEMS_SEMA_ON)
		return 0;

	if((semid = semget(semkey, 1, 0)) == -1)
	{
		return 1;	/* error */
	}

	ret = semctl(semid, 1, IPC_RMID, 1);
	if(ret < 0)
	{
		if(errno == EIDRM)
			return 0;
		else
			exit(14);
	}

	return 0;
}

/** �⺻ mems function : P function. 
 *
 * MEM���� ��� data�� ����ش�.
 * 
 * @param semid	:  Semaphore ID
 * @param flag	:  Semaphore Flag (MEMS_SEMA_ON) 
 *
 *  @return     S32
 *  @see        mems.h
 *
 *  @note       ������ ���Ϸ� �����ȴ�. 
 **/
S32 P(S32 semid, U32 flag)
{
	struct sembuf p_buf;

	if(flag != MEMS_SEMA_ON)
		return 0;

	p_buf.sem_num = 0;
	p_buf.sem_op  = -1;
	p_buf.sem_flg = SEM_UNDO;

	if(semop(semid, &p_buf, 1) == -1)
		exit(15);
	else
		return 0;
}

/** �⺻ mems function : V function. 
 *
 * MEM���� ��� data�� ����ش�.
 * 
 * @param semid	:  Semaphore ID
 * @param flag	:  Semaphore Flag (MEMS_SEMA_ON) 
 *
 *  @return     S32
 *  @see        mems.h
 *
 *  @note       ������ ���Ϸ� �����ȴ�. 
 **/
S32 V(S32 semid, U32 flag)
{
	struct sembuf v_buf;

	if(flag != MEMS_SEMA_ON)
		return 0;

	v_buf.sem_num = 0;
	v_buf.sem_op  = 1;
	v_buf.sem_flg = SEM_UNDO;

	if(semop(semid, &v_buf, 1) == -1)
		exit(16);
	else
		return 0;
}

/** �ʱ�ȭ �Լ� : mems_init function. 
 *
 *  �ʱ�ȭ �Լ� 
 *
 * @param uiType	: Main Memory = 1 , Shared Memory = 2 
 * @param uiShmKey  	: Shared Memory Key (case type is shared Memory)
 * @param uiSemFlag  	: Semaphore Flag (MEMS_SEMA_ON)
 * @param uiSemKey  	: Semaphore Key 
 * @param uiHeadRoomSize  	: sort�� ���� key�� byte��
 * @param uiMemNodeBodySize  	: Data�� byte��
 * @param uiMemNodeTotCnt  	: open mems�� array size (open memsũ��) 
 *
 *  @return     void
 *  @see        mems.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       ���� Shared Memory�ȿ� �ִ� �͵� ���� �� ��. mem ���� �κ��� �߰� �Ǿ����� ��.
 **/
stMEMSINFO *
mems_init(U32 uiType,U32 uiShmKey, U32 uiSemFlag, U32 uiSemKey, U32 uiHeadRoomSize, U32 uiMemNodeBodySize,U32 uiMemNodeTotCnt)
{
	U32	iIndex;
	stMEMSNODEHDR *pstMEMSNODEHDR;
	U8 *pBase,*pIndex;
	stMEMSINFO *pstMEMSINFO;
	U32		uiTotMemSize;
	int		shm_id;

	switch(uiType){
		case MEMS_MAIN_MEM:
    		uiTotMemSize = stMEMSINFO_SIZE + uiHeadRoomSize 
				+ (stMEMSNODEHDR_SIZE + uiMemNodeBodySize) * uiMemNodeTotCnt;
			pstMEMSINFO = (stMEMSINFO *) MALLOC(uiTotMemSize);
			memset(pstMEMSINFO,0,uiTotMemSize);
    		pstMEMSINFO->uiTotMemSize = uiTotMemSize;

			break;
		case MEMS_SHARED_MEM:
            uiTotMemSize = stMEMSINFO_SIZE + uiHeadRoomSize
                + (stMEMSNODEHDR_SIZE + uiMemNodeBodySize) * uiMemNodeTotCnt;

            if ((shm_id = shmget (uiShmKey, uiTotMemSize, SEMPERM | IPC_CREAT | IPC_EXCL)) < 0) {

				if (errno == EEXIST) {
                	shm_id = shmget (uiShmKey, uiTotMemSize, SEMPERM | IPC_CREAT);
                	if (shm_id < 0) {
						FPRINTF(LOG_BUG,"##%s Shm create fail!!: exit()\n",__FUNCTION__);
						exit (-1);
					}

					FPRINTF(LOG_LEVEL, "EEXIST..........\n");
                	if((int)(pstMEMSINFO = (stMEMSINFO *) shmat(shm_id, 0, 0)) == -1)
					{
						FPRINTF(LOG_BUG, "shmat FAIL 1");
						exit(-1);
					}

					if((uiSemFlag == MEMS_SEMA_ON) && (pstMEMSINFO->uiSemKey == uiSemKey)) {
						return pstMEMSINFO;
					} else {
						FPRINTF(LOG_LEVEL,"##%s Diff SemKey !: exit()\n",__FUNCTION__);
						exit (-1);
					}
				}
            }

			FPRINTF(LOG_LEVEL, " NO EEXIST..........\n");
            if((int)(pstMEMSINFO = (stMEMSINFO *) shmat(shm_id, 0, 0)) == -1)
			{
				FPRINTF(LOG_BUG, "shmat FAIL 2");
				exit(-1);
			}
			memset(pstMEMSINFO,0,uiTotMemSize);
   			pstMEMSINFO->uiTotMemSize = uiTotMemSize;

			if (pstMEMSINFO == NULL) {
				FPRINTF(LOG_LEVEL,"##%s Shm create fail!! NULL!!: exit()\n",__FUNCTION__);
				exit (-1);
			}
			break;
		default: 
			break;
	}


	/* �� ó�� �ʱ�ȭ �Ǿ����� */
    pstMEMSINFO->uiType = uiType;
    pstMEMSINFO->uiShmKey = uiShmKey;
	pstMEMSINFO->uiSemFlag = uiSemFlag;
	pstMEMSINFO->uiSemKey = uiSemKey;
	pstMEMSINFO->iSemID = mems_sem_init(uiSemKey, uiSemFlag);
    pstMEMSINFO->uiHeadRoomSize = uiHeadRoomSize;
    pstMEMSINFO->uiMemNodeHdrSize = stMEMSNODEHDR_SIZE;
    pstMEMSINFO->uiMemNodeBodySize = uiMemNodeBodySize;
    pstMEMSINFO->uiMemNodeAllocedCnt = 0;
    pstMEMSINFO->uiMemNodeTotCnt = uiMemNodeTotCnt;
    pstMEMSINFO->offsetHeadRoom = stMEMSINFO_SIZE;
    pstMEMSINFO->offsetNodeStart = pstMEMSINFO->offsetHeadRoom + pstMEMSINFO->uiHeadRoomSize;
    pstMEMSINFO->offsetFreeList = pstMEMSINFO->offsetNodeStart;
    pstMEMSINFO->offsetNodeEnd = pstMEMSINFO->offsetNodeStart + 
			(stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize) * pstMEMSINFO->uiMemNodeTotCnt;
	pstMEMSINFO->createCnt = 0;
	pstMEMSINFO->delCnt = 0;

	pBase = (U8 *) (pstMEMSINFO) ; 
	pBase += pstMEMSINFO->offsetNodeStart;
	for(iIndex=0;iIndex < pstMEMSINFO->uiMemNodeTotCnt;iIndex++){
		pIndex = (U8*) (pBase + iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize)); 
		pstMEMSNODEHDR = (stMEMSNODEHDR *) pIndex;
		pstMEMSNODEHDR->uiID = MEMS_ID;
#ifdef DEBUG
		FPRINTF(LOG_LEVEL,"##%s : [%3d] pstMEMSNODEHDR 0x%x, ID :0x%x\n",__FUNCTION__,iIndex,(U32) pstMEMSNODEHDR,pstMEMSNODEHDR->uiID);
		FPRINTF(LOG_LEVEL,"##%s : offset %d 0x%x\n",__FUNCTION__,iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize),iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize));
#endif
	}

	return pstMEMSINFO;
}




/** �⺻ mems function : mems_alloc function. 
 *
 * NODE�� mem���� �Ҵ��Ѵ�. 
 * -DDEBUG  �Ҵ��� �Լ��� �־��ش�.  
 *
 * @li ID�� �����Ͽ� Ȯ���� �Ѵ�.
 * @li Free���� Alloc�� Free�� Ȯ���ϰ� ���� ALLOCED�� set
 * @li ȣ���� �Լ� �̸� ����
 * 
 *
 * @param *pstMEMSINFO	: MEM ������ 
 * @param uiSize	:  NODE�� �Ҵ��� Size (�����δ� INFO�� ���ǵ� Size��ŭ�� alloc�� ���̴�.)  ASSERT(pstMEMSINFO->uiMemNodeBodySize >= uiSize);
 * @param *pDbgPtr	: __FUNCTION__ ���� ȣ���� �Լ��� Ư�� string�� ��Ÿ�� 
 *
 *  @return     success : not 0 , fail : 0 
 *  @see        mems.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **pp�� *pstmemsnode[100] ����  pp = &pstmemsnode[1]�� ���� ó���ϱ� ������ \n
 **/
U8 *
mems_alloc(stMEMSINFO *pstMEMSINFO , U32 uiSize, U8 *pDbgPtr)
{
	U8 *pBase,*pRet = NULL,*pFree;
	stMEMSNODEHDR *pstMEMSNODEHDR;
	U32 iDebug=0;


	if(pstMEMSINFO->uiMemNodeBodySize < uiSize) return NULL;

	P(pstMEMSINFO->iSemID, pstMEMSINFO->uiSemFlag);

	pBase = (U8 *) pstMEMSINFO;
	/* pBase += pstMEMSINFO->uiHeadRoomSize; */

#ifdef DEBUG
	FPRINTF(LOG_LEVEL, "%s : pstMEMSINFO = 0x%x\n",__FUNCTION__,(U32) pstMEMSINFO);
	FPRINTF(LOG_LEVEL, "%s : pstMEMSINFO->uiMemNodeBodySize=%d >= uiSize=%d\n",__FUNCTION__,(U32) pstMEMSINFO->uiMemNodeBodySize,uiSize);
	FPRINTF(LOG_LEVEL, "%s : pBase = 0x%x\n",__FUNCTION__,(U32) pBase);
#endif

//	while(pstMEMSINFO->uiMemNodeAllocedCnt < pstMEMSINFO->uiMemNodeTotCnt){
	while(1){
		pFree = (U8*) (pBase + pstMEMSINFO->offsetFreeList);
		pstMEMSNODEHDR = (stMEMSNODEHDR *) pFree;
		if( (pstMEMSINFO->offsetFreeList += (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize)) 
				== pstMEMSINFO->offsetNodeEnd){
    		pstMEMSINFO->offsetFreeList = pstMEMSINFO->offsetNodeStart;
		}
#ifdef DEBUG
	FPRINTF(LOG_LEVEL, "%s : pstMEMSINFO = 0x%x pstMEMSNODEHDR=0x%x\n",__FUNCTION__,(U32) pstMEMSINFO ,(U32) pstMEMSNODEHDR);
	FPRINTF(LOG_LEVEL, "%s : pstMEMSINFO->offsetFreeList = 0x%x\n",__FUNCTION__,pstMEMSINFO->offsetFreeList);
	FPRINTF(LOG_LEVEL, "%s : pstMEMSNODEHDR->ucIsFree = 0x%x  MAX %d\n",__FUNCTION__,pstMEMSNODEHDR->ucIsFree,MEMS_MAX_DEBUG_STR);
#endif
			/*pstMEMSNODEHDR->uiID = MEMS_ID; */
		if(MEMS_FREE == pstMEMSNODEHDR->ucIsFree){
			pstMEMSNODEHDR->TimeSec = time(NULL);
			pstMEMSNODEHDR->ucIsFree = MEMS_ALLOCED;
#if 1
			memcpy(pstMEMSNODEHDR->DebugStr,pDbgPtr,MEMS_MAX_DEBUG_STR-1);
			pstMEMSNODEHDR->DebugStr[MEMS_MAX_DEBUG_STR-1] = 0x00;
			pstMEMSNODEHDR->DelStr[0] = 0x00;
//			pstMEMSINFO->uiMemNodeAllocedCnt++;
#endif
			pstMEMSINFO->createCnt++;
			pRet = (U8*) (pFree + stMEMSNODEHDR_SIZE);
			break;
		}
		if(++iDebug > pstMEMSINFO->uiMemNodeTotCnt){
			FPRINTF(LOG_LEVEL,"Err : %s : iDebug %d , TotCnt %d\n",__FUNCTION__,iDebug,pstMEMSINFO->uiMemNodeTotCnt);
			break;
		}

	}

	V(pstMEMSINFO->iSemID, pstMEMSINFO->uiSemFlag);

	return pRet;
}

/** �⺻ mems function : mems_free function. 
 *
 * NODE�� mem���� free�Ѵ�.
 * -DDEBUG  �Ҵ��� �Լ��� �־��ش�.  
 *
 * @li ID�� �����Ͽ� Ȯ���� �Ѵ�.
 * @li Free���� Alloc�� Free�� Ȯ���ϰ� ���� ALLOCED�� set
 * @li ȣ���� �Լ� �̸� ����
 * 
 *
 * @param *pstMEMSINFO	: MEM ������ 
 * @param *pFree		: free�� pointer
 * @param *pDbgPtr		: string pointer for debugging 
 *
 *  @return     success : 0 , fail : not 0
 *  @see        mems.h
 *
 *  @warning 	���࿡ ���� �Ҵ��� �Ϳ� ���ؼ��� ��� �� ���ΰ�?  free�� ���� �����ִ°� �ϴ� ���̴�. (���� �ð��� set�Ͽ� �װ��� �Ѵ� �͵��� �������� �Ϸ翡 �ѹ��� clear�� ��Ų�ٵ��� �ϴ� �۾��� �ʿ��� ���̴�(��������� garbage collection�� �����Ͽ��� �Ѵ�.)   
 *  @note       mems node header��ŭ �ڷ� ���� Ȯ���� �Ͽ� ó�� 
 **/
S32 
mems_free(stMEMSINFO *pstMEMSINFO , U8 *pFree, U8 *pDbgPtr)
{
	stMEMSNODEHDR *pstMEMSNODEHDR;

//	P(pstMEMSINFO->iSemID, pstMEMSINFO->uiSemFlag);

#ifdef DEBUG
	FPRINTF(LOG_LEVEL, "%s : pstMEMSNODE = 0x%x\n",__FUNCTION__,(U32) pstMEMSINFO);
#endif

	pstMEMSNODEHDR = (stMEMSNODEHDR *) (pFree - stMEMSNODEHDR_SIZE);

	if( (MEMS_ID != pstMEMSNODEHDR->uiID)  ||
		(MEMS_ALLOCED != pstMEMSNODEHDR->ucIsFree) ){
#ifdef DEBUG
	   FPRINTF(LOG_LEVEL,"Err %s : uiID 0x%x  , MEMS_ID 0x%x\n",__FUNCTION__,pstMEMSNODEHDR->uiID,MEMS_ID);
	   FPRINTF(LOG_LEVEL,"Err %s : ucIsFree 0x%x  , MEMS_ALLOCED 0x%x\n",__FUNCTION__,pstMEMSNODEHDR->ucIsFree,MEMS_ALLOCED);
	   FPRINTF(LOG_LEVEL,"Err %s : called function name : %s\n",__FUNCTION__,pstMEMSNODEHDR->DebugStr);
#endif

//		V(pstMEMSINFO->iSemID, pstMEMSINFO->uiSemFlag);
   		return 1;
	}

	/* memset(pstMEMSNODEHDR,0,stMEMSNODEHDR_SIZE); */
	pstMEMSNODEHDR->ucIsFree = MEMS_FREE;
#if 1
//	pstMEMSNODEHDR->DebugStr[0] = 0x00;
	memcpy(pstMEMSNODEHDR->DelStr, pDbgPtr, MEMS_MAX_DEBUG_STR-1);
	pstMEMSNODEHDR->DelStr[MEMS_MAX_DEBUG_STR-1] = 0x00;
//	pstMEMSINFO->uiMemNodeAllocedCnt--;
#endif
	pstMEMSINFO->delCnt++;

//	V(pstMEMSINFO->iSemID, pstMEMSINFO->uiSemFlag);

	return 0;
}

/** �⺻ mems function : mems_print_info function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMSINFO	: MEM ������ 
 *
 *  @return     void
 *  @see        mems.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
mems_print_info(S8 *pcPrtPrefixStr,stMEMSINFO *pstMEMSINFO)
{
	stMEMSINFO_Prt(pcPrtPrefixStr,pstMEMSINFO);
}

/** �⺻ mems function : mems_print_node function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMSNODEHDR	: MEM NODE pointer
 *
 *  @return     void
 *  @see        mems.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
mems_print_node(S8 *pcPrtPrefixStr,stMEMSNODEHDR *pstMEMSNODEHDR)
{
	stMEMSNODEHDR_Prt(pcPrtPrefixStr,pstMEMSNODEHDR);
}

/** �⺻ mems function : mems_print_all function. 
 *
 * MEM���� ��� data�� ����ش�.
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMSINFO	: MEM ������ 
 *
 *  @return     void
 *  @see        mems.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
mems_print_all(S8 *pcPrtPrefixStr,stMEMSINFO *pstMEMSINFO)
{
	U32	iIndex;
	stMEMSNODEHDR *pstMEMSNODEHDR;
	U8 *pBase,*pIndex;

	FPRINTF(LOG_LEVEL,"%s ##1: pstMEMSINFO=0x%08x \n",__FUNCTION__,(U32) pstMEMSINFO);
	FPRINTF(LOG_LEVEL,"%s ##1: pstMEMSINFO\n",__FUNCTION__);
	mems_print_info(pcPrtPrefixStr,pstMEMSINFO);

	pBase = (U8 *) (pstMEMSINFO) ; 
	pBase += pstMEMSINFO->offsetNodeStart;
	for(iIndex=0;iIndex < pstMEMSINFO->uiMemNodeTotCnt;iIndex++){
		pIndex = (U8*) (pBase + iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize)); 
		pstMEMSNODEHDR = (stMEMSNODEHDR *) pIndex;
#ifdef DEBUG
		FPRINTF(LOG_LEVEL,"%s ##2: %s : [%3d] ID :0x%x pIndex=0x%x\n",pcPrtPrefixStr,__FUNCTION__,iIndex,pstMEMSNODEHDR->uiID,(U32) pIndex);
		FPRINTF(LOG_LEVEL,"%s ##2: offset %d 0x%x\n",__FUNCTION__,iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize),iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize));
#endif
		if(pstMEMSNODEHDR->ucIsFree == MEMS_ALLOCED){
			FPRINTF(LOG_LEVEL,"%s ##3: %s : [%3d] \n",pcPrtPrefixStr,__FUNCTION__,iIndex);
			mems_print_node(pcPrtPrefixStr,pstMEMSNODEHDR);
		}
	}
}

/** �⺻ mems function : mems_draw_all function. 
 *
 * MEM���� ��� data�� ����ش�.
 * 
 * @param *filename	:  Write�� filename
 * @param *labelname	: label��  
 * @param *pstMEMSINFO	: MEM ������ 
 *
 *  @return     void
 *  @see        mems.h
 *
 *  @note       ������ ���Ϸ� �����ȴ�. 
 **/
void
mems_draw_all(S8 *filename,S8 *labelname,stMEMSINFO *pstMEMSINFO)
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

/** �⺻ mems function : mems_garbage_collector function. 
 *
 *  ���� �ð��� ���� �޸𸮸� ���� ���ش�.\n ���� node������ ���� ���
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMSINFO	: MEM ������ 
 * @param timegap	:  �Ҵ� �ð��� ���� �ð��� ���� �� ��ġ
 * @param *print_func	:  print function pointer
 *
 *  @return     void
 *  @see        mems.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
mems_garbage_collector(S8 *pcPrtPrefixStr,stMEMSINFO *pstMEMSINFO,int timegap, void (*print_func)(stMEMSINFO *pmem, stMEMSNODEHDR * pmemhdr))
{
	U32	iIndex;
	stMEMSNODEHDR *pstMEMSNODEHDR;
	U8 *pBase,*pIndex;
	U32 ga_before_alloced_cnt =0;
	U32 ga_before_free_cnt =0;
	U32 ga_after_alloced_cnt =0;
	U32 ga_after_free_cnt =0;
	U32 ga_changed_cnt =0;
	int cur_time = time(0);

	FPRINTF(LOG_LEVEL,"%s : %s ##1: pstMEMSINFO=0x%08x \n",__FUNCTION__, pcPrtPrefixStr,(U32) pstMEMSINFO);
	mems_print_info(pcPrtPrefixStr,pstMEMSINFO);

	pBase = (U8 *) (pstMEMSINFO) ; 
	pBase += pstMEMSINFO->offsetNodeStart;
	for(iIndex=0;iIndex < pstMEMSINFO->uiMemNodeTotCnt;iIndex++){
		pIndex = (U8*) (pBase + iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize)); 
		pstMEMSNODEHDR = (stMEMSNODEHDR *) pIndex;
#ifdef DEBUG
		FPRINTF(LOG_LEVEL,"%s ##2: %s : [%3d] ID :0x%x pIndex=0x%x\n",pcPrtPrefixStr,__FUNCTION__,iIndex,pstMEMSNODEHDR->uiID,(U32) pIndex);
		FPRINTF(LOG_LEVEL,"%s ##2: offset %d 0x%x\n",__FUNCTION__,iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize),iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize));
#endif
		if(pstMEMSNODEHDR->ucIsFree == MEMS_ALLOCED){
			ga_before_alloced_cnt ++;
			ga_after_alloced_cnt ++;
			if( (pstMEMSNODEHDR->TimeSec + timegap) < cur_time){		/* Free ���Ѿ� ��. */
//				FPRINTF(LOG_BUG,"CHANGED NODE :  %s ##3: %s : [%3d] \n",pcPrtPrefixStr,__FUNCTION__,iIndex);
				FPRINTF(LOG_BUG,"ID[%u]TIME[%u]IsFree[%d]CREATE_NODE[%s]DEL_NODE[%s]CURTIME[%u]IDX[%u]",
					pstMEMSNODEHDR->uiID, pstMEMSNODEHDR->TimeSec, pstMEMSNODEHDR->ucIsFree,
					pstMEMSNODEHDR->DebugStr, pstMEMSNODEHDR->DelStr, cur_time, iIndex);
				if(print_func != NULL)
					print_func(pstMEMSINFO, pstMEMSNODEHDR);
				mems_print_node(pcPrtPrefixStr,pstMEMSNODEHDR);
				mems_free(pstMEMSINFO , ((char *) pstMEMSNODEHDR) + stMEMSNODEHDR_SIZE, pcPrtPrefixStr);
				ga_changed_cnt ++;
				ga_after_alloced_cnt --;
				ga_after_free_cnt ++;
			} 
		} else {
			ga_before_free_cnt ++;
			ga_after_free_cnt ++;
		}
	}
}

/** �⺻ mems function : mems_view function. 
 *
 *  mems node ���� ���
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMSINFO	: MEM ������ 
 * @param timegap	:  �Ҵ� �ð��� ���� �ð��� ���� �� ��ġ
 * @param *print_func	:  print function pointer
 *
 *  @return     void
 *  @see        mems.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
mems_view(S8 *pcPrtPrefixStr, stMEMSINFO *pstMEMSINFO, int timegap, void (*print_func)(stMEMSINFO *pmem, stMEMSNODEHDR * pmemhdr))
{
	U32	iIndex;
	stMEMSNODEHDR *pstMEMSNODEHDR;
	U8 *pBase,*pIndex;
	int cur_time = time(0);

	pBase = (U8 *) (pstMEMSINFO) ; 
	pBase += pstMEMSINFO->offsetNodeStart;
	for(iIndex=0;iIndex < pstMEMSINFO->uiMemNodeTotCnt;iIndex++){
		pIndex = (U8*) (pBase + iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize)); 
		pstMEMSNODEHDR = (stMEMSNODEHDR *) pIndex;

		if(pstMEMSNODEHDR->ucIsFree == MEMS_ALLOCED){
			if( (pstMEMSNODEHDR->TimeSec + timegap) < cur_time){		/* Free ���Ѿ� ��. */
				FPRINTF(LOG_LEVEL,"ID=%u TIME=%u IsFree=%d CREATE_NODE=%s DEL_NODE=%s CURTIME=%u IDX=%u",
					pstMEMSNODEHDR->uiID, pstMEMSNODEHDR->TimeSec, pstMEMSNODEHDR->ucIsFree,
					pstMEMSNODEHDR->DebugStr, pstMEMSNODEHDR->DelStr, cur_time, iIndex);
				if(print_func != NULL)
					print_func(pstMEMSINFO, pstMEMSNODEHDR);
			} 
		}
	}
}


/** �⺻ mems function : mems_alloced_cnt function. 
 *
 * 	���� ALLOC�� NODE ����
 * 
 * @param *pstMEMSINFO	: MEM ������ 
 *
 *  @return     void
 *  @see        mems.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
S32
mems_alloced_cnt(stMEMSINFO *pstMEMSINFO)
{
	S32	allocedCnt = 0;
	U32	iIndex;
	stMEMSNODEHDR *pstMEMSNODEHDR;
	U8 *pBase,*pIndex;

	pBase = (U8 *) (pstMEMSINFO) ; 
	pBase += pstMEMSINFO->offsetNodeStart;
	for(iIndex=0; iIndex < pstMEMSINFO->uiMemNodeTotCnt; iIndex++){
		pIndex = (U8*) (pBase + iIndex * (stMEMSNODEHDR_SIZE + pstMEMSINFO->uiMemNodeBodySize)); 
		pstMEMSNODEHDR = (stMEMSNODEHDR *) pIndex;

		if(pstMEMSNODEHDR->ucIsFree == MEMS_ALLOCED){
			allocedCnt++;
		}
	}

	return allocedCnt;
}

#ifdef TEST

#define SHM_KEY_TEST    8001
#define SEMA_KEY_TEST	8100

/** Free �Լ� : mems_shm_free function. 
 *
 *  shared memory ���� �Լ�
 *
 * @param uiShmKey  	: Shared Memory Key (case type is shared Memory)
 * @param uiSize  		: Shared Memory Size
 *
 *  @return     1: ���� ���� , -1: ������ memory �� ã��
 *  @see        mems.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       ���� Shared Memory�ȿ� �ִ� �͵� ���� �� ��. mem ���� �κ��� �߰� �Ǿ����� ��.
 **/
int
mems_shm_free (int shm_key, int size)
{
	int shm_id;

	if ((shm_id = shmget(shm_key, size, 0666 | IPC_CREAT)) < 0) 
		return -1;
	
	if (shmctl (shm_id, IPC_RMID, (struct shmid_ds *)0) < 0) 
		return -1;

	return 1;
}

/** main function.
 *
 *  Node�� �����ϰ� , �����ϴ� ������ text �� �׸����� �����ش�.  
 *  -DTEST �� ���ؼ� ���Ǿ����� ������ main�� TEST�� ���ǵɶ��� ����
 *  �� ���α׷��� �⺻������ library��. 
 * 
 *  @return     void
 *  @see        mems.h
 *
 *  @note       �׸����δ� ������ file�� �����Ǹ� file���� code���� �Է��ϰ� �Ǿ����ֽ��ϴ�.
 **/
int
main(int argc, char *argv[])
{
	stMEMSINFO *pstMEMSINFO;
	U8 *a,*c,*d,*e,*f,*g,*h,*i;
	

	if (argc == 1) {
		printf ("main mem\n");
		pstMEMSINFO = mems_init(MEMS_MAIN_MEM, 0, MEMS_SEMA_OFF, 0, 128, 32, 8 /**<mems node count */);
	} else {
		if (strcmp (argv [1], "shm") != 0) {
			printf ("main mem\n");
			pstMEMSINFO = mems_init(MEMS_MAIN_MEM, 0, MEMS_SEMA_OFF, 0, 128, 32, 8 /**<mems node count */);
		} else {
			printf ("shm mem\n");
			pstMEMSINFO = mems_init(MEMS_SHARED_MEM, SHM_KEY_TEST, MEMS_SEMA_ON, SEMA_KEY_TEST, 128, 32, 8 /**<mems node count */);
		}
	}


	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	
	printf("111\n");
	a = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	if (a == NULL)
		printf ("NULL!!\n");
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_01.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);
/*
	printf("222 b\n");
	b = mems_alloc(pstMEMSINFO,40,(S8 *)__FUNCTION__);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_02.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);
*/
	printf("333 c\n");
	c = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	if (c == NULL)
		printf ("NULL!!\n");
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_03.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);

	printf("444 d \n");
	d = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	if (d == NULL)
		printf ("NULL!!\n");
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_04.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);

	printf("555 e\n");
	e = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	if (e == NULL)
		printf ("NULL!!\n");
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_05.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);

	printf("666 f\n");
	f = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	if (f == NULL)
		printf ("NULL!!\n");
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_06.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);


	printf("777 a\n");
	mems_free(pstMEMSINFO,a);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_07.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);

	printf("888 d\n");
	mems_free(pstMEMSINFO,d);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_08.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);

	printf("999 c\n");
	mems_free(pstMEMSINFO,c);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_09.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);

	printf("111 e\n");
	mems_free(pstMEMSINFO,e);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_10.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);

	printf("222 f %d\n", mems_free(pstMEMSINFO,f));
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_11.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);


#if 1
	printf("###222 f\n");
	g = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_12.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);
	printf("###222 f\n");
	h = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_13.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);
	printf("###222 f\n");
	i = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_14.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);
	printf("###222 f\n");
	g = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_15.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);
	printf("###222 f\n");
	h = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_16.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);
	printf("###222 f\n");
	i = mems_alloc(pstMEMSINFO,32,(S8 *)__FUNCTION__);
	mems_print_all((S8 *)__FUNCTION__,pstMEMSINFO);
	mems_draw_all("TEST_RESULT_17.TXT",(S8 *)__FUNCTION__,pstMEMSINFO);

	if (argc == 3) {
		if (strcmp (argv [2], "del") == 0) 
			mems_shm_free (SHM_KEY_TEST, pstMEMSINFO->uiTotMemSize);
	} 
#endif

	return 0;
}
#endif /* TEST */

/** file mems.c
 *     $Log: mems.c,v $
 *     Revision 1.25  2007/06/13 02:40:40  dark264sh
 *     no message
 *
 *     Revision 1.24  2007/06/06 15:26:24  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.23  2007/02/16 04:36:27  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.22  2006/12/04 08:05:06  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.21  2006/11/28 00:49:24  cjlee
 *     doxygen
 *
 *     Revision 1.20  2006/11/08 07:47:13  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.19  2006/11/06 07:27:26  dark264sh
 *     nifo NODE size 4*1024 => 6*1024�� �����ϱ�
 *     nifo_tlv_alloc���� argument�� memset���� ���� �����ϵ��� ����
 *     nifo_node_free���� semaphore ����
 *
 *     Revision 1.18  2006/10/23 11:33:12  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.17  2006/10/18 10:55:45  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.16  2006/10/18 08:54:23  dark264sh
 *     nifo debug �ڵ� �߰�
 *
 *     Revision 1.15  2006/10/18 02:23:07  dark264sh
 *     free�� alloced �Ҵ�� ���°� �ƴϸ� �׵��� ó��
 *
 *     Revision 1.14  2006/10/12 07:34:01  dark264sh
 *     lib ������ FPRINTF(LOG_LEVEL, ó���� ����
 *
 *     Revision 1.13  2006/09/27 02:49:07  cjlee
 *     *** empty log message ***
 *
 *     Revision 1.12  2006/09/27 02:47:01  cjlee
 *     mem_garbage_collector ()  �߰�
 *
 *     Revision 1.11  2006/09/11 07:42:38  dark264sh
 *     no message
 *
 *     Revision 1.10  2006/09/11 07:36:10  dark264sh
 *     no message
 *
 *     Revision 1.9  2006/08/31 01:09:14  dark264sh
 *     test main���� ������� �ʴ� ���� *b ����
 *
 *     Revision 1.8  2006/08/31 01:08:06  dark264sh
 *     test main ���� __FUNCTION__ => (S8 *)__FUNCTION__���� ����
 *
 *     Revision 1.7  2006/08/31 01:02:57  dark264sh
 *     test main ����
 *
 *     Revision 1.6  2006/08/07 05:54:23  dark264sh
 *     no message
 *
 *     Revision 1.5  2006/08/07 05:51:46  dark264sh
 *     no message
 *
 *     Revision 1.4  2006/08/07 05:50:39  dark264sh
 *     no message
 *
 *     Revision 1.3  2006/08/07 05:49:22  dark264sh
 *     no message
 *
 *     Revision 1.2  2006/08/04 12:08:15  dark264sh
 *     no message
 *
 *     Revision 1.1  2006/08/03 11:58:37  dark264sh
 *     no message
 *
 *     Revision 1.1  2006/08/01 08:21:37  dark264sh
 *     no message
 *
 *     Revision 1.11  2006/05/08 08:19:21  yhshin
 *     mems_shm_free ����
 *
 *     Revision 1.10  2006/04/26 08:02:07  yhshin
 *     null check ����
 *
 *     Revision 1.9  2006/04/26 07:53:58  yhshin
 *     shared memory �߰�
 *
 *     Revision 1.8  2006/04/26 05:31:04  yhshin
 *     *** empty log message ***
 *
 *     Revision 1.7  2006/04/26 05:22:26  yhshin
 *     bug ����
 *
 *     Revision 1.6  2006/04/26 04:37:43  yhshin
 *     shared memory �߰�
 *
 *     Revision 1.5  2006/04/20 07:43:11  cjlee
 *     minor change: DEBUG ����
 *
 *     Revision 1.4  2006/04/20 00:37:51  cjlee
 *     minor change : draw dot print ���� - main node �߰�
 *
 *     Revision 1.3  2006/03/17 07:30:05  cjlee
 *     minor change
 *
 *     Revision 1.2  2006/03/17 07:29:10  cjlee
 *     minor change
 *
 *     Revision 1.1  2006/03/17 07:23:14  cjlee
 *     INIT
 *
 *
 *     */
