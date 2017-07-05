/** @file memg.c
 * 한정 Memory Library file.
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
 *     @todo        hasho project에 이것을 적용할 것이다. 
 *
 *     @section     Intro(소개)
 *      - memg library 파일 
 *      - memg_init으로 초기롸를 한후에 기본저인 primitives 를 이용하게 함
 *      - primitives
 *      	@li memg_init
 *      	@li memg_alloc
 *      	@li memg_free
 *      	@li memg_print_info
 *      	@li memg_print_node
 *      	@li memg_print_all
 *      	@li Supplement 		: memg_draw_all
 *      - memory 구조\n
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

/** 초기화 함수 : memg_init function. 
 *
 *  초기화 함수 
 *
 * @param uiType	: Main Memory = 1 , Shared Memory = 2 
 * @param uiShmKey  	: Shared Memory Key (case type is shared Memory)
 * @param uiHeadRoomSize  	: sort를 위한 key의 byte수
 * @param uiMemNodeBodySize  	: Data의 byte수
 * @param uiMemNodeTotCnt  	: open memg의 array size (open memg크기) 
 *
 *  @return     void
 *  @see        memg.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       추후 Shared Memory안에 넣는 것도 좋을 듯 함. mem 관리 부분이 추가 되어져야 함.
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

	/* 맨 처음 초기화 되었을시 */
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




/** 기본 memg function : memg_alloc function. 
 *
 * NODE를 mem에서 할당한다. 
 * -DDEBUG  할당한 함수를 넣어준다.  
 *
 * @li ID를 삽입하여 확인을 한다.
 * @li Free에서 Alloc과 Free를 확인하고 값을 ALLOCED로 set
 * @li 호출한 함수 이름 적음
 * 
 *
 * @param *pstMEMGINFO	: MEM 관리자 
 * @param uiSize	:  NODE에 할당할 Size (실제로는 INFO에 정의된 Size만큼이 alloc될 것이다.)  ASSERT(pstMEMGINFO->uiMemNodeBodySize >= uiSize);
 * @param *pDbgPtr	: __FUNCTION__ 같이 호출한 함수나 특정 string을 나타냄 
 *
 *  @return     success : not 0 , fail : 0 
 *  @see        memg.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       **pp는 *pstmemgnode[100] 에서  pp = &pstmemgnode[1]과 같이 처리하기 위함임 \n
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

/** 기본 memg function : memg_free function. 
 *
 * NODE를 mem에서 free한다.
 * -DDEBUG  할당한 함수를 넣어준다.  
 *
 * @li ID를 삽입하여 확인을 한다.
 * @li Free에서 Alloc과 Free를 확인하고 값을 ALLOCED로 set
 * @li 호출한 함수 이름 적음
 * 
 *
 * @param *pstMEMGINFO	: MEM 관리자 
 * @param *pFree	: free할 pointer
 *
 *  @return     success : 0 , fail : not 0
 *  @see        memg.h
 *
 *  @warning 	만약에 전에 할당한 것에 대해서는 어떻게 할 것인가?  free를 누가 시켜주는가 하는 것이다. (일정 시간을 set하여 그것을 넘는 것들이 있을때는 하루에 한번씩 clear를 시킨다든지 하는 작업이 필요할 것이다(나름대로의 garbage collection을 수행하여야 한다.)   
 *  @note       memg node header만큼 뒤로 가서 확인을 하여 처리 
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

/** 기본 memg function : memg_print_info function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMGINFO	: MEM 관리자 
 *
 *  @return     void
 *  @see        memg.h
 *
 *  @note       앞에는 prefix string을 넣어줌 (_%s)
 **/
void
memg_print_info(S8 *pcPrtPrefixStr,stMEMGINFO *pstMEMGINFO)
{
	stMEMGINFO_Prt(pcPrtPrefixStr,pstMEMGINFO);
}

/** 기본 memg function : memg_print_node function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMGNODEHDR	: MEM NODE pointer
 *
 *  @return     void
 *  @see        memg.h
 *
 *  @note       앞에는 prefix string을 넣어줌 (_%s)
 **/
void
memg_print_node(S8 *pcPrtPrefixStr,stMEMGNODEHDR *pstMEMGNODEHDR)
{
	stMEMGNODEHDR_Prt(pcPrtPrefixStr,pstMEMGNODEHDR);
}

/** 기본 memg function : memg_print_all function. 
 *
 * MEM안의 모든 data를 찍어준다.
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstMEMGINFO	: MEM 관리자 
 *
 *  @return     void
 *  @see        memg.h
 *
 *  @note       앞에는 prefix string을 넣어줌 (_%s)
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

/** 기본 memg function : memg_draw_all function. 
 *
 * MEM안의 모든 data를 찍어준다.
 * 
 * @param *filename	:  Write할 filename
 * @param *labelname	: label명  
 * @param *pstMEMGINFO	: MEM 관리자 
 *
 *  @return     void
 *  @see        memg.h
 *
 *  @note       개개의 파일로 생성된다. 
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

/** Free 함수 : memg_shm_free function. 
 *
 *  shared memory 삭제 함수
 *
 * @param uiShmKey  	: Shared Memory Key (case type is shared Memory)
 * @param uiSize  		: Shared Memory Size
 *
 *  @return     1: 정상 종료 , -1: 삭제할 memory 못 찾음
 *  @see        memg.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       추후 Shared Memory안에 넣는 것도 좋을 듯 함. mem 관리 부분이 추가 되어져야 함.
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
 *  Node를 삽입하고 , 삭제하는 과정을 text 및 그림으로 보여준다.  
 *  -DTEST 를 위해서 사용되어지는 것으로 main은 TEST가 정의될때만 수행
 *  이 프로그램은 기본적으로 library임. 
 * 
 *  @return     void
 *  @see        memg.h
 *
 *  @note       그림으로는 개개의 file로 생성되면 file명은 code에서 입력하게 되어져있습니다.
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
 *     lib 생성시 FPRINTF(LOG_LEVEL, 처리로 변경
 *
 *     Revision 1.14  2006/08/02 05:46:01  cjlee
 *     warning제거
 *
 *     Revision 1.13  2006/08/02 05:22:09  cjlee
 *     *** empty log message ***
 *
 *     Revision 1.12  2006/08/02 05:18:14  cjlee
 *     NODE header에 TIME추가 (garbage collection과 DEBUG용)
 *
 *     Revision 1.11  2006/05/08 08:19:21  yhshin
 *     memg_shm_free 수정
 *
 *     Revision 1.10  2006/04/26 08:02:07  yhshin
 *     null check 삭제
 *
 *     Revision 1.9  2006/04/26 07:53:58  yhshin
 *     shared memory 추가
 *
 *     Revision 1.8  2006/04/26 05:31:04  yhshin
 *     *** empty log message ***
 *
 *     Revision 1.7  2006/04/26 05:22:26  yhshin
 *     bug 수정
 *
 *     Revision 1.6  2006/04/26 04:37:43  yhshin
 *     shared memory 추가
 *
 *     Revision 1.5  2006/04/20 07:43:11  cjlee
 *     minor change: DEBUG 구간
 *
 *     Revision 1.4  2006/04/20 00:37:51  cjlee
 *     minor change : draw dot print 변경 - main node 추가
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
