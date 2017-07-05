/** @file memg.c
 * ���� Memory Library file.
 *
 *		$Id: memg.c,v 1.16 2006/12/04 08:04:54 dark264sh Exp $
 *
 *     Copyright (c) 2006~ by Upresto Inc, Korea
 *     All rights reserved.
 * 
 *     @Author      $Author: dark264sh $
 *     @version     $Revision: 1.16 $
 *     @date        $Date: 2006/12/04 08:04:54 $
 *     @ref         memg.h
 *     @todo        hasho project�� �̰��� ������ ���̴�. 
 *
 *     @section     Intro(�Ұ�)
 *      - memg library ���� 
 *      - memg_init���� �ʱ�ָ� ���Ŀ� �⺻���� primitives �� �̿��ϰ� ��
 *      - primitives
 *      	@li memg_init
 *      	@li memg_alloc
 *      	@li memg_free
 *      	@li memg_print_info
 *      	@li memg_print_node
 *      	@li memg_print_all
 *      	@li Supplement 		: memg_draw_all
 *      - memory ����\n
 *          +----------------------------------+\n
 *          |    memg_info (stMEMGINFO)        |\n
 *          +----------------------------------+\n
 *          |    Head Room                     |\n
 *          +----------------------------------+\n
 *          |    memg node hdr1(stMEMGNODEHDR) |\n
 *          |    memg node data                |\n
 *          +----------------------------------+\n
 *          |    memg node hdr2(stMEMGNODEHDR) |\n
 *          |    memg node data                |\n
 *          +----------------------------------+\n
 *          |    memg node hdr3(stMEMGNODEHDR) |\n
 *          |    memg node data                |\n
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
#include <sys/shm.h>
#include <errno.h>
#include <time.h>

#include "memg.h"



# define iscntrl(c) __isctype((c), _IScntrl)
#define WIDTH   16
int
memg_dump_DebugString(char *debug_str,char *s,int len)
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

/** �ʱ�ȭ �Լ� : memg_init function. 
 *
 *  �ʱ�ȭ �Լ� 
 *
 * @param uiType	: Main Memory = 1 , Shared Memory = 2 
 * @param uiShmKey  	: Shared Memory Key (case type is shared Memory)
 * @param uiHeadRoomSize  	: sort�� ���� key�� byte��
 * @param uiMemNodeBodySize  	: Data�� byte��
 * @param uiMemNodeTotCnt  	: open memg�� array size (open memgũ��) 
 *
 *  @return     void
 *  @see        memg.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       ���� Shared Memory�ȿ� �ִ� �͵� ���� �� ��. mem ���� �κ��� �߰� �Ǿ����� ��.
 **/
stMEMGINFO *
memg_init(U32 uiType,U32 uiShmKey,U32 uiHeadRoomSize, U32 uiMemNodeBodySize,U32 uiMemNodeTotCnt)
{
	U32	iIndex;
	stMEMGNODEHDR *pstMEMGNODEHDR;
	U8 *pBase,*pIndex;
	stMEMGINFO *pstMEMGINFO;
	U32		uiTotMemSize;
	int		shm_id;

	switch(uiType){
		case MEMG_MAIN_MEM:
    		uiTotMemSize = stMEMGINFO_SIZE + uiHeadRoomSize 
				+ (stMEMGNODEHDR_SIZE + uiMemNodeBodySize) * uiMemNodeTotCnt;
			pstMEMGINFO = (stMEMGINFO *) MALLOC(uiTotMemSize);
			memset(pstMEMGINFO,0,uiTotMemSize);
    		pstMEMGINFO->uiTotMemSize = uiTotMemSize;

			break;
		case MEMG_SHARED_MEM:
            uiTotMemSize = stMEMGINFO_SIZE + uiHeadRoomSize
                + (stMEMGNODEHDR_SIZE + uiMemNodeBodySize) * uiMemNodeTotCnt;

            if ((shm_id = shmget (uiShmKey, uiTotMemSize, SEMPERM | IPC_CREAT | IPC_EXCL)) < 0) {

				if (errno == EEXIST) {
                	shm_id = shmget (uiShmKey, uiTotMemSize, SEMPERM | IPC_CREAT);
                	if (shm_id < 0) {
						FPRINTF(LOG_LEVEL,"##%s Shm create fail!!: exit()\n",__FUNCTION__);
						exit (-1);
					}

					FPRINTF(LOG_LEVEL,"EEXIST..........\n");
                	if((int)(pstMEMGINFO = (stMEMGINFO *) shmat(shm_id, 0, 0)) == -1)
					{
						FPRINTF(LOG_BUG, "shmat FAIL 1");
						exit(-1);
					}
					return pstMEMGINFO;
				}
            }

			FPRINTF(LOG_LEVEL, " NO EEXIST..........\n");
            if((int)(pstMEMGINFO = (stMEMGINFO *) shmat(shm_id, 0, 0)) == -1)
			{
				FPRINTF(LOG_BUG, "shmat FAIL 1");
				exit(-1);
			}
			memset(pstMEMGINFO,0,uiTotMemSize);
   			pstMEMGINFO->uiTotMemSize = uiTotMemSize;

			if (pstMEMGINFO == NULL) {
				FPRINTF(LOG_LEVEL,"##%s Shm create fail!! NULL!!: exit()\n",__FUNCTION__);
				exit (-1);
			}
			break;
		default: 
			break;
	}

	/* �� ó�� �ʱ�ȭ �Ǿ����� */
    pstMEMGINFO->uiType = uiType;
    pstMEMGINFO->uiShmKey = uiShmKey;
    pstMEMGINFO->uiHeadRoomSize = uiHeadRoomSize;
    pstMEMGINFO->uiMemNodeHdrSize = stMEMGNODEHDR_SIZE;
    pstMEMGINFO->uiMemNodeBodySize = uiMemNodeBodySize;
    pstMEMGINFO->uiMemNodeAllocedCnt = 0;
    pstMEMGINFO->uiMemNodeTotCnt = uiMemNodeTotCnt;
    pstMEMGINFO->offsetHeadRoom = stMEMGINFO_SIZE;
    pstMEMGINFO->offsetNodeStart = pstMEMGINFO->offsetHeadRoom + pstMEMGINFO->uiHeadRoomSize;
    pstMEMGINFO->offsetFreeList = pstMEMGINFO->offsetNodeStart;
    pstMEMGINFO->offsetNodeEnd = pstMEMGINFO->offsetNodeStart + 
			(stMEMGNODEHDR_SIZE + pstMEMGINFO->uiMemNodeBodySize) * pstMEMGINFO->uiMemNodeTotCnt;

	pBase = (U8 *) (pstMEMGINFO) ; 
	pBase += pstMEMGINFO->offsetNodeStart;
	for(iIndex=0;iIndex < pstMEMGINFO->uiMemNodeTotCnt;iIndex++){
		pIndex = (U8*) (pBase + iIndex * (stMEMGNODEHDR_SIZE + pstMEMGINFO->uiMemNodeBodySize)); 
		pstMEMGNODEHDR = (stMEMGNODEHDR *) pIndex;
		pstMEMGNODEHDR->uiID = MEMG_ID;
#ifdef DEBUG
		FPRINTF(LOG_LEVEL,"##%s : [%3d] pstMEMGNODEHDR 0x%x, ID :0x%x\n",__FUNCTION__,iIndex,(U32) pstMEMGNODEHDR,pstMEMGNODEHDR->uiID);
		FPRINTF(LOG_LEVEL,"##%s : offset %d 0x%x\n",__FUNCTION__,iIndex * (stMEMGNODEHDR_SIZE + pstMEMGINFO->uiMemNodeBodySize),iIndex * (stMEMGNODEHDR_SIZE + pstMEMGINFO->uiMemNodeBodySize));
#endif
	}

	return pstMEMGINFO;
}




/** �⺻ memg function : memg_alloc function. 
 *
 * NODE�� mem���� �Ҵ��Ѵ�. 
 * -DDEBUG  �Ҵ��� �Լ��� �־��ش�.  
 *
 * @li ID�� �����Ͽ� Ȯ���� �Ѵ�.
 * @li Free���� Alloc�� Free�� Ȯ���ϰ� ���� ALLOCED�� set
 * @li ȣ���� �Լ� �̸� ����
 * 
 *
 * @param *pstMEMGINFO	: MEM ������ 
 * @param uiSize	:  NODE�� �Ҵ��� Size (�����δ� INFO�� ���ǵ� Size��ŭ�� alloc�� ���̴�.)  ASSERT(pstMEMGINFO->uiMemNodeBodySize >= uiSize);
 * @param *pDbgPtr	: __FUNCTION__ ���� ȣ���� �Լ��� Ư�� string�� ��Ÿ�� 
 *
 *  @return     success : not 0 , fail : 0 
 *  @see        memg.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **pp�� *pstmemgnode[100] ����  pp = &pstmemgnode[1]�� ���� ó���ϱ� ������ \n
 **/
U8 *
memg_alloc(stMEMGINFO *pstMEMGINFO , U32 uiSize, S8 *pDbgPtr)
{
	U8 *pBase,*pRet = NULL,*pFree;
	stMEMGNODEHDR *pstMEMGNODEHDR;
	U32 iDebug=0;


	if(pstMEMGINFO->uiMemNodeBodySize < uiSize) return NULL;

	pBase = (U8 *) pstMEMGINFO;
	/* pBase += pstMEMGINFO->uiHeadRoomSize; */

#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : pstMEMGINFO = 0x%x\n",__FUNCTION__,(U32) pstMEMGINFO);
	FPRINTF(LOG_LEVEL,"%s : pstMEMGINFO->uiMemNodeBodySize=%d >= uiSize=%d\n",__FUNCTION__,(U32) pstMEMGINFO->uiMemNodeBodySize,uiSize);
	FPRINTF(LOG_LEVEL,"%s : pBase = 0x%x\n",__FUNCTION__,(U32) pBase);
#endif

	while(pstMEMGINFO->uiMemNodeAllocedCnt < pstMEMGINFO->uiMemNodeTotCnt){
		pFree = (U8*) (pBase + pstMEMGINFO->offsetFreeList);
		pstMEMGNODEHDR = (stMEMGNODEHDR *) pFree;
		if( (pstMEMGINFO->offsetFreeList += (stMEMGNODEHDR_SIZE + pstMEMGINFO->uiMemNodeBodySize)) 
				== pstMEMGINFO->offsetNodeEnd){
    		pstMEMGINFO->offsetFreeList = pstMEMGINFO->offsetNodeStart;
		}
#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : pstMEMGINFO = 0x%x pstMEMGNODEHDR=0x%x\n",__FUNCTION__,(U32) pstMEMGINFO ,(U32) pstMEMGNODEHDR);
	FPRINTF(LOG_LEVEL,"%s : pstMEMGINFO->offsetFreeList = 0x%x\n",__FUNCTION__,pstMEMGINFO->offsetFreeList);
	FPRINTF(LOG_LEVEL,"%s : pstMEMGNODEHDR->ucIsFree = 0x%x  MAX %d\n",__FUNCTION__,pstMEMGNODEHDR->ucIsFree,MEMG_MAX_DEBUG_STR);
#endif
			/*pstMEMGNODEHDR->uiID = MEMG_ID; */
		if(MEMG_FREE == pstMEMGNODEHDR->ucIsFree){
			pstMEMGNODEHDR->ucIsFree = MEMG_ALLOCED;
			pstMEMGNODEHDR->TimeSec = time(0);
			sprintf(pstMEMGNODEHDR->DebugStr,"%.*s",MEMG_MAX_DEBUG_STR - 1,pDbgPtr);
			pstMEMGNODEHDR->DebugStr[MEMG_MAX_DEBUG_STR-1] = 0;
			pstMEMGINFO->uiMemNodeAllocedCnt++;
			pRet = (U8*) (pFree + stMEMGNODEHDR_SIZE);
			break;
		}
		if(++iDebug > pstMEMGINFO->uiMemNodeTotCnt){
			FPRINTF(LOG_LEVEL,"Err : %s : iDebug %d , TotCnt %d\n",__FUNCTION__,iDebug,pstMEMGINFO->uiMemNodeTotCnt);
			break;
		}

	}
	return pRet;
}

/** �⺻ memg function : memg_free function. 
 *
 * NODE�� mem���� free�Ѵ�.
 * -DDEBUG  �Ҵ��� �Լ��� �־��ش�.  
 *
 * @li ID�� �����Ͽ� Ȯ���� �Ѵ�.
 * @li Free���� Alloc�� Free�� Ȯ���ϰ� ���� ALLOCED�� set
 * @li ȣ���� �Լ� �̸� ����
 * 
 *
 * @param *pstMEMGINFO	: MEM ������ 
 * @param *pFree	: free�� pointer
 *
 *  @return     success : 0 , fail : not 0
 *  @see        memg.h
 *
 *  @warning 	���࿡ ���� �Ҵ��� �Ϳ� ���ؼ��� ��� �� ���ΰ�?  free�� ���� �����ִ°� �ϴ� ���̴�. (���� �ð��� set�Ͽ� �װ��� �Ѵ� �͵��� �������� �Ϸ翡 �ѹ��� clear�� ��Ų�ٵ��� �ϴ� �۾��� �ʿ��� ���̴�(��������� garbage collection�� �����Ͽ��� �Ѵ�.)   
 *  @note       memg node header��ŭ �ڷ� ���� Ȯ���� �Ͽ� ó�� 
 **/
S32 
memg_free(stMEMGINFO *pstMEMGINFO , U8 *pFree)
{
	stMEMGNODEHDR *pstMEMGNODEHDR;

#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : pstMEMGNODE = 0x%x\n",__FUNCTION__,(U32) pstMEMGINFO);
#endif

	pstMEMGNODEHDR = (stMEMGNODEHDR *) (pFree - stMEMGNODEHDR_SIZE);

	if( (MEMG_ID != pstMEMGNODEHDR->uiID)  ||
		(MEMG_ALLOCED != pstMEMGNODEHDR->ucIsFree) ){
	   FPRINTF(LOG_LEVEL,"Err %s : uiID 0x%x  , MEMG_ID 0x%x\n",__FUNCTION__,pstMEMGNODEHDR->uiID,MEMG_ID);
	   FPRINTF(LOG_LEVEL,"Err %s : ucIsFree 0x%x  , MEMG_ALLOCED 0x%x\n",__FUNCTION__,pstMEMGNODEHDR->ucIsFree,MEMG_ALLOCED);
	   FPRINTF(LOG_LEVEL,"Err %s : called function name : %s\n",__FUNCTION__,pstMEMGNODEHDR->DebugStr);
	   return 1;
	}

	/* memset(pstMEMGNODEHDR,0,stMEMGNODEHDR_SIZE); */
	pstMEMGNODEHDR->ucIsFree = MEMG_FREE;
	pstMEMGNODEHDR->DebugStr[0] = 0;
	pstMEMGINFO->uiMemNodeAllocedCnt--;

	return 0;
}

/** �⺻ memg function : memg_print_info function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMGINFO	: MEM ������ 
 *
 *  @return     void
 *  @see        memg.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
memg_print_info(S8 *pcPrtPrefixStr,stMEMGINFO *pstMEMGINFO)
{
	stMEMGINFO_Prt(pcPrtPrefixStr,pstMEMGINFO);
}

/** �⺻ memg function : memg_print_node function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMGNODEHDR	: MEM NODE pointer
 *
 *  @return     void
 *  @see        memg.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
memg_print_node(S8 *pcPrtPrefixStr,stMEMGNODEHDR *pstMEMGNODEHDR)
{
	stMEMGNODEHDR_Prt(pcPrtPrefixStr,pstMEMGNODEHDR);
}

/** �⺻ memg function : memg_print_all function. 
 *
 * MEM���� ��� data�� ����ش�.
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMGINFO	: MEM ������ 
 *
 *  @return     void
 *  @see        memg.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
memg_print_all(S8 *pcPrtPrefixStr,stMEMGINFO *pstMEMGINFO)
{
	U32	iIndex;
	stMEMGNODEHDR *pstMEMGNODEHDR;
	U8 *pBase,*pIndex;

	FPRINTF(LOG_LEVEL,"%s ##1: pstMEMGINFO=0x%08x \n",__FUNCTION__,(U32) pstMEMGINFO);
	FPRINTF(LOG_LEVEL,"%s ##1: pstMEMGINFO\n",__FUNCTION__);
	memg_print_info(pcPrtPrefixStr,pstMEMGINFO);

	pBase = (U8 *) (pstMEMGINFO) ; 
	pBase += pstMEMGINFO->offsetNodeStart;
	for(iIndex=0;iIndex < pstMEMGINFO->uiMemNodeTotCnt;iIndex++){
		pIndex = (U8*) (pBase + iIndex * (stMEMGNODEHDR_SIZE + pstMEMGINFO->uiMemNodeBodySize)); 
		pstMEMGNODEHDR = (stMEMGNODEHDR *) pIndex;
		FPRINTF(LOG_LEVEL,"%s ##2: %s : [%3d] ID :0x%x pIndex=0x%x\n",pcPrtPrefixStr,__FUNCTION__,iIndex,pstMEMGNODEHDR->uiID,(U32) pIndex);
		FPRINTF(LOG_LEVEL,"%s ##2: offset %d 0x%x\n",__FUNCTION__,iIndex * (stMEMGNODEHDR_SIZE + pstMEMGINFO->uiMemNodeBodySize),iIndex * (stMEMGNODEHDR_SIZE + pstMEMGINFO->uiMemNodeBodySize));
		if(pstMEMGNODEHDR->ucIsFree == MEMG_ALLOCED){
			FPRINTF(LOG_LEVEL,"%s ##3: %s : [%3d] \n",pcPrtPrefixStr,__FUNCTION__,iIndex);
			memg_print_node(pcPrtPrefixStr,pstMEMGNODEHDR);
		}
	}
}

/** �⺻ memg function : memg_draw_all function. 
 *
 * MEM���� ��� data�� ����ش�.
 * 
 * @param *filename	:  Write�� filename
 * @param *labelname	: label��  
 * @param *pstMEMGINFO	: MEM ������ 
 *
 *  @return     void
 *  @see        memg.h
 *
 *  @note       ������ ���Ϸ� �����ȴ�. 
 **/
void
memg_draw_all(S8 *filename,S8 *labelname,stMEMGINFO *pstMEMGINFO)
{
	U32	iIndex;
	stMEMGNODEHDR *pstMEMGNODEHDR;
	FILE *fp;
	U8 *pBase,*pIndex;

	pBase = (U8 *) (pstMEMGINFO) ; 
	pBase += pstMEMGINFO->offsetNodeStart;

	fp = fopen(filename,"w");
	FPRINTF(fp,"/** @file %s\n",filename);
	FPRINTF(fp,"uiMemNodeTotCnt = %d\\n\n",pstMEMGINFO->uiMemNodeTotCnt);
	FPRINTF(fp,"uiMemNodeAllocedCnt = %d\\n\n",pstMEMGINFO->uiMemNodeAllocedCnt);
	FPRINTF(fp,"\\dot \n	\
	digraph G{ 	\n\
	fontname=Helvetica; 	\n\
	label=\"Hash Table(%s)\"; 	\n\
	nodesep=.05; 	\n\
	rankdir=LR; 	\n\
	node [fontname=Helvetica,shape=record,width=.1,height=.1]; 	\n\
	node0 [label = \"",labelname);
	for(iIndex=0;iIndex < pstMEMGINFO->uiMemNodeTotCnt;iIndex++){
		pIndex = (U8*) (pBase + iIndex * (stMEMGNODEHDR_SIZE + pstMEMGINFO->uiMemNodeBodySize)); 
		pstMEMGNODEHDR = (stMEMGNODEHDR *) pIndex;
		if(iIndex == pstMEMGINFO->uiMemNodeTotCnt -1){
			FPRINTF(fp,"<f%d> %d_%d_%s",iIndex,iIndex,pstMEMGNODEHDR->ucIsFree,pstMEMGNODEHDR->DebugStr);
		} else {
			FPRINTF(fp,"<f%d> %d_%d_%s |",iIndex,iIndex,pstMEMGNODEHDR->ucIsFree,pstMEMGNODEHDR->DebugStr);
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

#define SHM_KEY_TEST    8001

/** Free �Լ� : memg_shm_free function. 
 *
 *  shared memory ���� �Լ�
 *
 * @param uiShmKey  	: Shared Memory Key (case type is shared Memory)
 * @param uiSize  		: Shared Memory Size
 *
 *  @return     1: ���� ���� , -1: ������ memory �� ã��
 *  @see        memg.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       ���� Shared Memory�ȿ� �ִ� �͵� ���� �� ��. mem ���� �κ��� �߰� �Ǿ����� ��.
 **/
int
memg_shm_free (int shm_key, int size)
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
 *  @see        memg.h
 *
 *  @note       �׸����δ� ������ file�� �����Ǹ� file���� code���� �Է��ϰ� �Ǿ����ֽ��ϴ�.
 **/
int
main(int argc, char *argv[])
{
	stMEMGINFO *pstMEMGINFO;
	U8 *a,*c,*d,*e,*f,*g,*h,*i;
	

	if (argc == 1) {
		printf ("main mem\n");
		pstMEMGINFO = memg_init(MEMG_MAIN_MEM, 0, 128, 32, 8 /**<memg node count */);
	} else {
		if (strcmp (argv [1], "shm") != 0) {
			printf ("main mem\n");
			pstMEMGINFO = memg_init(MEMG_MAIN_MEM, 0, 128, 32, 8 /**<memg node count */);
		} else {
			printf ("shm mem\n");
			pstMEMGINFO = memg_init(MEMG_SHARED_MEM, SHM_KEY_TEST, 128, 32, 8 /**<memg node count */);
		}
	}


	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	
	printf("111\n");
	a = memg_alloc(pstMEMGINFO,32,(U8*)__FUNCTION__);
	if (a == NULL)
		printf ("NULL!!\n");
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_01.TXT",(S8*)__FUNCTION__,pstMEMGINFO);
/*
	printf("222 b\n");
	b = memg_alloc(pstMEMGINFO,40,__FUNCTION__);
	memg_print_all(__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_02.TXT",__FUNCTION__,pstMEMGINFO);
*/
	printf("333 c\n");
	c = memg_alloc(pstMEMGINFO,32,(S8*)__FUNCTION__);
	if (c == NULL)
		printf ("NULL!!\n");
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_03.TXT",(S8*)__FUNCTION__,pstMEMGINFO);

	printf("444 d \n");
	d = memg_alloc(pstMEMGINFO,32,(S8*)__FUNCTION__);
	if (d == NULL)
		printf ("NULL!!\n");
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_04.TXT",(S8*)__FUNCTION__,pstMEMGINFO);

	printf("555 e\n");
	e = memg_alloc(pstMEMGINFO,32,(S8*)__FUNCTION__);
	if (e == NULL)
		printf ("NULL!!\n");
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_05.TXT",(S8*)__FUNCTION__,pstMEMGINFO);

	printf("666 f\n");
	f = memg_alloc(pstMEMGINFO,32,(S8*)__FUNCTION__);
	if (f == NULL)
		printf ("NULL!!\n");
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_06.TXT",(S8*)__FUNCTION__,pstMEMGINFO);


	printf("777 a\n");
	memg_free(pstMEMGINFO,a);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_07.TXT",(S8*)__FUNCTION__,pstMEMGINFO);

	printf("888 d\n");
	memg_free(pstMEMGINFO,d);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_08.TXT",(S8*)__FUNCTION__,pstMEMGINFO);

	printf("999 c\n");
	memg_free(pstMEMGINFO,c);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_09.TXT",(S8*)__FUNCTION__,pstMEMGINFO);

	printf("111 e\n");
	memg_free(pstMEMGINFO,e);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_10.TXT",(S8*)__FUNCTION__,pstMEMGINFO);

	printf("222 f %d\n", memg_free(pstMEMGINFO,f));
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_11.TXT",(S8*)__FUNCTION__,pstMEMGINFO);


#if 1
	printf("###222 f\n");
	g = memg_alloc(pstMEMGINFO,32,(S8*)__FUNCTION__);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_12.TXT",(S8*)__FUNCTION__,pstMEMGINFO);
	printf("###222 f\n");
	h = memg_alloc(pstMEMGINFO,32,(S8*)__FUNCTION__);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_13.TXT",(S8*)__FUNCTION__,pstMEMGINFO);
	printf("###222 f\n");
	i = memg_alloc(pstMEMGINFO,32,(S8*)__FUNCTION__);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_14.TXT",(S8*)__FUNCTION__,pstMEMGINFO);
	printf("###222 f\n");
	g = memg_alloc(pstMEMGINFO,32,(S8*)__FUNCTION__);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_15.TXT",(S8*)__FUNCTION__,pstMEMGINFO);
	printf("###222 f\n");
	h = memg_alloc(pstMEMGINFO,32,(S8*)__FUNCTION__);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_16.TXT",(S8*)__FUNCTION__,pstMEMGINFO);
	printf("###222 f\n");
	i = memg_alloc(pstMEMGINFO,32,(S8*)__FUNCTION__);
	memg_print_all((S8*)__FUNCTION__,pstMEMGINFO);
	memg_draw_all("TEST_RESULT_17.TXT",(S8*)__FUNCTION__,pstMEMGINFO);

	if (argc == 3) {
		if (strcmp (argv [2], "del") == 0) 
			memg_shm_free (SHM_KEY_TEST, pstMEMGINFO->uiTotMemSize);
	} 
#endif

	return 0;
}
#endif /* TEST */

/** file memg.c
 *     $Log: memg.c,v $
 *     Revision 1.16  2006/12/04 08:04:54  dark264sh
 *     *** empty log message ***
 *
 *     Revision 1.15  2006/10/12 07:34:01  dark264sh
 *     lib ������ FPRINTF(LOG_LEVEL, ó���� ����
 *
 *     Revision 1.14  2006/08/02 05:46:01  cjlee
 *     warning����
 *
 *     Revision 1.13  2006/08/02 05:22:09  cjlee
 *     *** empty log message ***
 *
 *     Revision 1.12  2006/08/02 05:18:14  cjlee
 *     NODE header�� TIME�߰� (garbage collection�� DEBUG��)
 *
 *     Revision 1.11  2006/05/08 08:19:21  yhshin
 *     memg_shm_free ����
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
