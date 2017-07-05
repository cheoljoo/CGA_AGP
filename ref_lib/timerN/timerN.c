/** @file timerN.c
 * Timer Library file.
 *
 *		$Id: timerN.c,v 1.6 2007/03/19 01:26:45 yhshin Exp $
 *
 *     Copyright (c) 2006~ by Upresto Inc, Korea
 *     All rights reserved.
 * 
 *     @Author      $Author: yhshin $
 *     @version     $Revision: 1.6 $
 *     @date        $Date: 2007/03/19 01:26:45 $
 *     @ref         timerN.h
 *     @warning     timerN_func의 인자는  char *,char * 
 *     @todo        일단 hash를 자유로이 이용할수 있게 하는게 목표이다. src를 바꾸면 안된다. 
 *
 *     @section     Intro(소개)
 *      - timer library 파일 
 *      - timerN_init으로 초기화를 한후에 기본저인 primitives 를 이용하게 함
 *      - primitives
 *      	@li timerN_init
 *      	@li timerN_add
 *      	@li timerN_del
 *      	@li timerN_update
 *      	@li timerN_invoke
 *      	@li timerN_print_info
 *      	@li timerN_print_node
 *      	@li timerN_print_all
 *      	@li Supplement 		: timerN_draw_all
 *
 *     @section     Requirement
 *      @li 규칙에 틀린 곳을 찾아주세요.
 *
 **/




#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <unistd.h>

#include "hashg.h"
#include "timerN.h"

extern U32 timerN_timeout_func(void *pa,U8 *pb);

S32
timerN_print_key(S8 *pcPrtPrefixStr,S8 *s,S32 len)
{
	stTIMERNKEY *pstTIMERNKEY;

	pstTIMERNKEY = (stTIMERNKEY *) s;
	stTIMERNKEY_Prt(pcPrtPrefixStr,pstTIMERNKEY);

	return 0;
}

#define iscntrl(c) __isctype((c), _IScntrl)
#define WIDTH   16
int
timerN_dump_DebugString(char *debug_str,char *s,int len)
{
	char buf[BUFSIZ],lbuf[BUFSIZ],rbuf[BUFSIZ];
	unsigned char *p;
	int line,i;

	FPRINTF(LOG_LEVEL, "### %s : len %d\n",debug_str,len);
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



/** 기본 hash function : timerN_timeout_func function. 
 *
 * func이 user에 의해서 주어지지 않았을 경우 기본적으로 대입되는 hash function.
 * 
 *
 * @param *pa	: TIMER 관리자 (stTIMERNINFO *)
 * @param *pb	:  pstTIMERNNODE->pstKey 의 pointer (원지 모르니 char로 정의) 
 *
 *  @return     U32 	Hash Array의 index를 가리킨다.  
 *  @see        timerN.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       C++의 STL로 처리하면 얼마나 편할까 하는 생각이 든다.
 **/
U32 
timerN_timeout_func(void *pa,U8 *pb)
{
	stHASHGINFO *pstHASHGINFO = (stHASHGINFO *) pa;
	stTIMERNKEY *pstTIMERNKEY;

	pstTIMERNKEY = (stTIMERNKEY *) pb;

#ifdef DEBUG
	FPRINTF(LOG_LEVEL, "%s : uiTimerNIdIndex = %d retu =%d\n",__FUNCTION__,pstTIMERNKEY->uiTimerNIdIndex, (U32) pstTIMERNKEY->sTimeKey % pstHASHGINFO->uiHashSize);
#endif

	return (U32) (pstTIMERNKEY->sTimeKey % pstHASHGINFO->uiHashSize);
}

#define N_DAY   						24*3600
#define ONE_MINUTE 						60 

/** 초기화 함수 : timerN_init function. 
 *
 *  초기화 함수 
 *
 * @param uiMaxNodeCnt  : 달릴수 있는 NODE의 MAX
 * @param uiArgMaxSize  	: invoke function의 argument의 size중에서 최대값 (이만큼 alloc을 시켜둡니다.)
 *
 *  @return     stTIMERNINFO * : Timer관리 info pointer
 *  @see        timerN.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       추후 Shared Memory안에 넣는 것도 좋을 듯 함. mem 관리 부분이 추가 되어져야 함. \n shared memory에서 값들을 읽어와서 다시 timerN에 add를 시켜주는 것이 맞을 것으로 보임.(invoke관련 pointer들이 존재하기 때문이다.) 
 **/
stTIMERNINFO *
timerN_init(U32 uiMaxNodeCnt, U32 uiArgMaxSize)
{
	stTIMERNINFO *pstTIMERNINFO;

#ifdef DEBUG
	FPRINTF(LOG_LEVEL, "%s : uiMaxNodeCnt = %d\n",__FUNCTION__,uiMaxNodeCnt);
	FPRINTF(LOG_LEVEL, "%s : uiArgMaxSize = %d\n",__FUNCTION__,uiArgMaxSize);
#endif
	if((pstTIMERNINFO = MALLOC( stTIMERNINFO_SIZE )) == NULL) {
		return NULL;
	}
	pstTIMERNINFO->uiMaxNodeCnt 		= uiMaxNodeCnt;
	pstTIMERNINFO->uiNodeCnt	= 0;
	pstTIMERNINFO->uiArgMaxSize		= uiArgMaxSize;
	pstTIMERNINFO->uiTimerNIdIndex		= 1;
	pstTIMERNINFO->uiCurrentTime		= time(0);

	if((pstTIMERNINFO->pstHASHGINFO	= hashg_init(timerN_timeout_func, sizeof(stTIMERNKEY), timerN_print_key, sizeof(stTIMERNDATA)+uiArgMaxSize, N_DAY)) == NULL) {
		return NULL;
	}

#ifdef DEBUG
	stHASHGINFO_Prt((S8 *)__FUNCTION__,pstTIMERNINFO->pstHASHGINFO);
#endif

	return pstTIMERNINFO;
}


/** 기본 hash function : timerN_add function. 
 *
 * NODE를 TIMER에서 지운다. 
 * 
 * @param *pstTIMERNINFO	: TIMER 관리자 
 * @param *invoke_func	: invoke 함수
 * @param *pArg 	:	arg structure pointer
 * @param uiArgSize	:	arg structure size
 * @param timeout	:	절대 timeout 시간 
 *
 *  @return     TIMERNID : timer id (지울때도 이것으로 지움)
 *  @see        timerN.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       **prev 주의
 *  			NODE안의 Key와 Data의 Size만큼을 한꺼번에 할당한다.
 **/
TIMERNID
timerN_add(stTIMERNINFO *pstTIMERNINFO,void (*invoke_func)(void*),U8 *pArg,U32 uiArgSize,time_t timeout)
{
	char buf1[BUFSIZ],buf2[BUFSIZ];
	stTIMERNKEY *pstTIMERNKEY;
	stTIMERNDATA *pstTIMERNDATA;
	stHASHGNODE *p;

	p = 0;
	pstTIMERNKEY = (stTIMERNKEY *) buf1;
	pstTIMERNDATA = (stTIMERNDATA *) buf2;
#ifdef DEBUG
	FPRINTF(LOG_LEVEL, "%s : pstTIMERNKEY = 0x%x\n",__FUNCTION__,(U32) pstTIMERNKEY);
	timerN_dump_DebugString("add:ARG",pArg,uiArgSize);
#endif

	if(timeout <= pstTIMERNINFO->uiCurrentTime){	/* invoke 시켜야함 */
		invoke_func(pArg);
		return (U64) 0;
	} 

	/* hash에 add함. */
	pstTIMERNINFO->uiTimerNIdIndex++;
	pstTIMERNKEY->uiTimerNIdIndex = pstTIMERNINFO->uiTimerNIdIndex;
	pstTIMERNKEY->sTimeKey = timeout;

	pstTIMERNDATA->pstTIMERNINFO = pstTIMERNINFO;
	pstTIMERNDATA->invoke_func = invoke_func;
	memcpy((U8*) &(pstTIMERNDATA->arg), pArg,uiArgSize);

#ifdef DEBUG
	stTIMERNKEY_Prt((S8 *)__FUNCTION__,pstTIMERNKEY);
	stTIMERNDATA_Prt((S8 *)__FUNCTION__,pstTIMERNDATA);
#endif

	if(timeout <= (pstTIMERNINFO->uiCurrentTime + N_DAY - ONE_MINUTE)){
		p = hashg_add(pstTIMERNINFO->pstHASHGINFO,(U8 *)pstTIMERNKEY,(U8 *)pstTIMERNDATA);
		if(p){
		   pstTIMERNINFO->uiNodeCnt++;
#ifdef DEBUG
	timerN_print_info("확인1",pstTIMERNINFO);
	stTIMERNKEY_Prt("확인1KEY",(stTIMERNKEY *)p->pstKey);
	stTIMERNDATA_Prt("확인1DATA",(stTIMERNDATA *)p->pstData);
	FPRINTF(LOG_LEVEL, "indexa = %d\n",(U32) (((stTIMERNKEY *)p->pstKey)->uiTimerNIdIndex));
	FPRINTF(LOG_LEVEL, "indexb = %d\n",(U32) (((stTIMERNKEY *)p->pstKey)->sTimeKey % N_DAY));
#endif
		}
	} else {
		FPRINTF(LOG_LEVEL, "%s : ERROR hashg_add return NULL\n",__FUNCTION__);
	}

#ifdef DEBUG
	FPRINTF(LOG_LEVEL, "====== p 0x%x\n",(U32) p);
#endif

	if(p){ 
		return *((U64 *) pstTIMERNKEY);
	} else {
		return 0;
	}
}

/** 기본 hash function : timerN_del function. 
 *
 * NODE를 TIMER에서 지운다. 
 * 
 * @param *pstTIMERNINFO	: TIMER 관리자 
 * @param timerNid 	:	U64 또는 stTIMERNKEY 의 timer id
 *
 *  @return     void : 지워진 것이 무조건 확실함.
 *  @see        timerN.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       **prev 주의
 **/
void 
timerN_del(stTIMERNINFO *pstTIMERNINFO,TIMERNID timerNid)
{
	stTIMERNKEY *pstTIMERNKEY;
	stHASHGNODE *pstHASHGNODE;

	pstTIMERNKEY = (stTIMERNKEY *) &timerNid;
#ifdef DEBUG
	stTIMERNKEY_Prt((S8 *)__FUNCTION__,pstTIMERNKEY);
#endif
	pstHASHGNODE = hashg_find(pstTIMERNINFO->pstHASHGINFO,(U8 *) &timerNid);

	if(pstHASHGNODE){
		hashg_del(pstHASHGNODE);
		pstTIMERNINFO->uiNodeCnt--;
	}
	return;
}

/** 기본 hash function : timerN_update function. 
 *
 * NODE의 timeout을 변경함. 
 * 변화를 하고 한 값에 대해서 다시 달아둠. 
 *
 * 
 * @param *pstTIMERNINFO	: TIMER 관리자 
 * @param timerNid 	:	U64 또는 stTIMERNKEY 의 timer id
 * @param timeout	:	절대 timeout 시간 
 *
 *  @return     TIMERNID : 변경된 timer id (지울때도 이것으로 지움)
 *  @see        timerN.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       **prev 주의
 *  			NODE안의 Key와 Data의 Size만큼을 한꺼번에 할당한다.
 **/
TIMERNID
timerN_update(stTIMERNINFO *pstTIMERNINFO,U64 timerNid,time_t timeout)
{
	stTIMERNKEY *pstTIMERNKEY;
	stTIMERNDATA *pstTIMERNDATA;
	stHASHGNODE *pstHASHGNODE;
	stHASHGINFO	*pstNODEHASHGINFO;

	pstHASHGNODE = hashg_find(pstTIMERNINFO->pstHASHGINFO,(U8 *) &timerNid);

	if(!pstHASHGNODE) return 0;

	pstTIMERNKEY = (stTIMERNKEY *) pstHASHGNODE->pstKey;
	pstTIMERNDATA = (stTIMERNDATA *) pstHASHGNODE->pstData;
	pstNODEHASHGINFO = (stHASHGINFO *) pstHASHGNODE->pstHASHGINFO;

	/* change time */
	pstTIMERNKEY->sTimeKey = timeout;

	if(timeout <= pstTIMERNINFO->uiCurrentTime){	/* invoke 시켜야함 */
		hashg_unlink_node(pstHASHGNODE);
		pstTIMERNINFO->uiNodeCnt--;
		pstTIMERNDATA->invoke_func((U8 *) &(pstTIMERNDATA->arg));
		FREE(pstHASHGNODE);
		return 0;
	} 
	if(timeout <= (pstTIMERNINFO->uiCurrentTime + N_DAY - ONE_MINUTE)){
		hashg_unlink_node(pstHASHGNODE);
		hashg_link_node((stHASHGINFO *) pstTIMERNINFO->pstHASHGINFO,pstHASHGNODE);
	} else {
		FPRINTF(LOG_LEVEL, "%s : ERROR hashg_add return NULL\n",__FUNCTION__);
	}

	return *((U64 *) pstTIMERNKEY);
}

/** 기본 hash function : timerN_print_info function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstTIMERNINFO	: TIMER 관리자 
 *
 *  @return     void
 *  @see        timerN.h
 *
 *  @note       앞에는 prefix string을 넣어줌 (_%s)
 **/
void
timerN_print_info(S8 *pcPrtPrefixStr,stTIMERNINFO *pstTIMERNINFO)
{
	stTIMERNINFO_Prt(pcPrtPrefixStr,pstTIMERNINFO);
}

/** 기본 hash function : timerN_print_node function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstTIMERNINFO	: TIMER 관리자 pointer
 * @param *pstTIMERNNODEKEY	: TIMER NODE pointer
 *
 *  @return     void
 *  @see        timerN.h
 *
 *  @note       앞에는 prefix string을 넣어줌 (_%s)
 **/
void
timerN_print_nodekey(S8 *pcPrtPrefixStr,stTIMERNINFO *pstTIMERNINFO,stTIMERNKEY *pstTIMERNNODEKEY)
{
	stTIMERNKEY_Prt(pcPrtPrefixStr,pstTIMERNNODEKEY);
}

/** 기본 hash function : timerN_print_all function. 
 *
 * TIMER안의 모든 data를 찍어준다.
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstTIMERNINFO	: TIMER 관리자 
 *
 *  @return     void
 *  @see        timerN.h
 *
 *  @note       앞에는 prefix string을 넣어줌 (_%s)
 **/
void
timerN_print_all(S8 *pcPrtPrefixStr,stTIMERNINFO *pstTIMERNINFO)
{
	stHASHGINFO *pstHASHGINFO;

	FPRINTF(LOG_LEVEL,"##%s : %s : pstTIMERNINFO\n",pcPrtPrefixStr,__FUNCTION__);
	pstHASHGINFO = (stHASHGINFO *) pstTIMERNINFO->pstHASHGINFO;

	timerN_print_info(pcPrtPrefixStr,pstTIMERNINFO);
	hashg_print_all(pcPrtPrefixStr,pstHASHGINFO);
}


/** 기본 hash function : timerN_draw_all function. 
 *
 * TIMER안의 모든 data를 찍어준다.
 * 
 * @param *filename	:  Write할 filename
 * @param *labelname	: label명  
 * @param *pstTIMERNINFO	: TIMER 관리자 
 *
 *  @return     void
 *  @see        timerN.h
 *
 *  @note       개개의 파일로 생성된다. 
 **/
void
timerN_draw_all(S8 *filename,S8 *labelname,stTIMERNINFO *pstTIMERNINFO)
{
	U32	iIndex;
	stHASHGNODE *p;
	stHASHGINFO *pstHASHGINFO;
	FILE *fp;
	char s[1000];


	fp = fopen(filename,"w");
	fprintf(fp,"/** @file %s\n",filename);
	fprintf(fp,"%s : pstTIMERNINFO->uiMaxNodeCnt = %d\\n\n",__FUNCTION__,pstTIMERNINFO->uiMaxNodeCnt);
	fprintf(fp,"%s : pstTIMERNINFO->uiNodeCnt = %d\\n\n",__FUNCTION__,pstTIMERNINFO->uiNodeCnt);
	fprintf(fp,"%s : pstTIMERNINFO->uiArgMaxSize = %d\\n\n",__FUNCTION__,pstTIMERNINFO->uiArgMaxSize);
	fprintf(fp,"%s : pstTIMERNINFO->uiCurrentTime Idx = %d\\n\n",__FUNCTION__,(U32) pstTIMERNINFO->uiCurrentTime % N_DAY);
	strftime(s, 1024, "%H_%M_%S", localtime((time_t *)&pstTIMERNINFO->uiCurrentTime )); 
	fprintf(fp," 시간 ==  %s\\n\n",s);
	fprintf(fp,"%s : pstHASHGINFO->uiLinkedCnt = %d\\n\n",__FUNCTION__,((stHASHGINFO *)pstTIMERNINFO->pstHASHGINFO)->uiLinkedCnt);
	pstHASHGINFO = pstTIMERNINFO->pstHASHGINFO;
	fprintf(fp,"\\dot \n	\
	digraph G{ 	\n\
	fontname=Helvetica; 	\n\
	label=\"Hash Table Time-Seconds(%s)\"; 	\n\
	nodesep=.05; 	\n\
	rankdir=LR; 	\n\
	node [shape=record,fontname=Helvetica,width=.1,height=.1]; 	\n\
	node0 [label = \"",labelname);
	for(iIndex=0;iIndex < pstHASHGINFO->uiHashSize;iIndex++){
		p = (stHASHGNODE *) *(  
				(U32 *) pstHASHGINFO->psthashnode 
				+ iIndex
		 	);
		if(p){
			if(iIndex == (pstHASHGINFO->uiHashSize -1)){
				fprintf(fp,"<f%d> %d ",iIndex,iIndex);
			} else {
				fprintf(fp,"<f%d> %d | ",iIndex,iIndex);
			}
		}
	}
	fprintf(fp,"\",height = 2.5];\n");
	fprintf(fp,"node [width=1.5];\n");
	for(iIndex=0;iIndex < pstHASHGINFO->uiHashSize;iIndex++){
		p = (stHASHGNODE *) *(  
				(U32 *) pstHASHGINFO->psthashnode 
				+ iIndex
		 	);
		for(;p;p=p->next){
			strftime(s, 1024, "%H_%M_%S", localtime((time_t *)&(((stTIMERNKEY *)(p->pstKey))->sTimeKey) )); 
			sprintf(s, "%s 0x%x", s, (U32) (((stTIMERNKEY *)(p->pstKey))->sTimeKey) ); 
			fprintf(fp,"N0x%08x [label = \"{ <n> 0x%08x | %3d | <p> %s }\"];\n",(U32) p,(U32) p,iIndex,s);
		}
	}
	fprintf(fp,"\n\n");
	for(iIndex=0;iIndex < pstHASHGINFO->uiHashSize;iIndex++){
		p = (stHASHGNODE *) *(  
				(U32 *) pstHASHGINFO->psthashnode 
				+ iIndex
		 	);
		if(p){
			fprintf(fp,"node0:f%d -> N0x%08x:n;\n",iIndex,(U32) p);
		}
		for(;p;p=p->next){
			if(p->next){
				fprintf(fp,"N0x%08x:p -> N0x%08x:n;\n",(U32) p , (U32) p->next);
			}
		}
	}
	fprintf(fp,"}\n\\enddot\n");
	fprintf(fp,"*/\n");
	fclose(fp);
}

/** 기본 hash function : timerN_invoke function. 
 *
 * 주기적으로 돌면서 timerN에 대한 node들을 invoke 시켜주는 함수이다.
 * polling 함수라고 생각하면 된다.  
 * 
 *
 * @param *pstTIMERNINFO	: TIMER 관리자 (stTIMERNINFO *)
 *
 *  @return     void
 *  @see        timerN.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       C++의 STL로 처리하면 얼마나 편할까 하는 생각이 든다.
 **/
void 
timerN_invoke(stTIMERNINFO *pstTIMERNINFO)
{
	stTIMERNDATA *pstTIMERNDATA;
	stHASHGNODE *p,*pn;
	stHASHGINFO *pstHASHGINFO;
	U32 tt;

	pstHASHGINFO = pstTIMERNINFO->pstHASHGINFO;
	tt = (U32) time(0);
#ifdef DEBUG
	timerN_print_all("-- invoke start--",pstTIMERNINFO);
#endif
	while(pstTIMERNINFO->uiCurrentTime <= tt){
#if 0
		p = (stHASHGNODE *) *(  
				(U32 *) pstHASHGINFO->psthashnode 
				+ (pstTIMERNINFO->uiCurrentTime % (N_DAY))
		 	);
		for(;p;){
			pn = p->next;
#ifdef DEBUG
			FPRINTF(LOG_LEVEL, "---- KEY ---- \n");
			stHASHGNODE_Prt((S8 *)__FUNCTION__,p);
			stTIMERNKEY_Prt((S8 *)__FUNCTION__,(stTIMERNKEY *)p->pstKey);
			stTIMERNDATA_Prt((S8 *)__FUNCTION__,(stTIMERNDATA *)p->pstData);
#endif
			pstTIMERNINFO->uiNodeCnt--;
			hashg_unlink_node(p);
			pstTIMERNDATA = (stTIMERNDATA *)p->pstData;
			pstTIMERNDATA->invoke_func(&(pstTIMERNDATA->arg));
			free(p);
			p=pn;
#ifdef DEBUG
			timerN_print_all((S8 *)__FUNCTION__,pstTIMERNINFO);
#endif
		}
		pstTIMERNINFO->uiCurrentTime ++;
#else
		for( ; ; ) {
			p = (stHASHGNODE *) *(  
					(U32 *) pstHASHGINFO->psthashnode 
					+ (pstTIMERNINFO->uiCurrentTime % (N_DAY))
		 		);
			if (p == NULL) {
				break;
			}
			pstTIMERNINFO->uiNodeCnt--;
			hashg_unlink_node(p);
			pstTIMERNDATA = (stTIMERNDATA *)p->pstData;
			pstTIMERNDATA->invoke_func(&(pstTIMERNDATA->arg));
			free(p);
		}
		pstTIMERNINFO->uiCurrentTime ++;
#endif
	}
}

#ifdef TEST
void 
invoke_del2(void *pa){
	FPRINTF(LOG_LEVLE, "EXPIRE %s : 0x%x\n", __FUNCTION__,(U32) pa);
}

typedef struct _bbb {
	U8 a;
	U8 b;
	U8 c;
	U8 d;
	U32	i;
} stDATA;

void
invoke_del1(void *pa){
	stDATA *pstDATA;
	pstDATA = (stDATA *) pa;
	FPRINTF(LOG_LEVLE, "EXPIRE %s : 0x%x  %c %c %c %c\n", __FUNCTION__,(U32) pa
			,pstDATA->a
			,pstDATA->b
			,pstDATA->c
			,pstDATA->d
			);
}


/** main function.
 *
 *  Node를 삽입하고 , 삭제하는 과정을 text 및 그림으로 보여준다.  
 *  -DTEST 를 위해서 사용되어지는 것으로 main은 TEST가 정의될때만 수행
 *  이 프로그램은 기본적으로 library임. 
 * 
 *  @return     void
 *  @see        timerN.h
 *
 *  @note       그림으로는 개개의 file로 생성되면 file명은 code에서 입력하게 되어져있습니다.
 **/
int
main()
{
	stTIMERNINFO *pstTIMERNINFO;
	stTIMERNKEY *pstTIMERNKEY;
	stDATA  stData;
	char 	s[1000];
	char 	filename[1000];
	time_t tt;
	int i,ii[10];
	TIMERNID 	timerid[10];
	ii[0]= 7;
	ii[1]= 5;
	ii[2]= 2;
	ii[3]= 4;
	ii[4]= 6;
	ii[5]= 8;
	ii[6]= 9;
	ii[7]= 4;
	ii[8]= 5;
	ii[9]= 4;

	stData.a = '0';
	stData.b = '1';
	stData.c = '2';
	stData.d = '3';
	
	/* 변수를 조절할 필요가 있다. 
	 * 다음주에 와서는 이 변수를 조절하는 것이 필요할 것이다.
	 */
	/* 시험 방법 : N_DAY , ONE_MINUTE 30 5 로 두면 작게 시험을 할수 있다. 
	 * */
	pstTIMERNINFO = timerN_init(1000,sizeof(stDATA));
	

	for(i=0;i<10;i++){
		tt = time(0);
		stData.a = '0' + i;
		printf("ADD RECORD------------[%03d]-- tt %d  %d--\n",i,(U32)tt,(U32)tt+ii[i]);
		timerid[i] = timerN_add(pstTIMERNINFO,invoke_del1,(U8 *) &stData,sizeof(stDATA),tt+ii[i]);
		strftime(s, 1024, "ADD_%H_%M_%S", localtime((time_t *)&pstTIMERNINFO->uiCurrentTime));
		pstTIMERNKEY = (stTIMERNKEY *) &timerid[i];
		stTIMERNKEY_Prt((char *) __FUNCTION__,pstTIMERNKEY);
		sprintf(s,"%s idx %d",s,(U32) pstTIMERNINFO->uiCurrentTime % N_DAY);
		timerN_print_all(s,pstTIMERNINFO);
		sprintf(filename,"TEST_RESULT_%02d.TXT",i);
		timerN_draw_all(filename,s,pstTIMERNINFO);
	}

	for(i=0;i<5;i++){
		sleep(4);
		printf("INVOKE ------------[%03d]----\n",i);
		tt = time(0);
		timerN_invoke(pstTIMERNINFO);
		sprintf(filename,"TEST_RESULT_INVOKE_%02d.TXT",i);
		strftime(s, 1024, "INVOKE_%H_%M_%S", localtime((time_t *)&pstTIMERNINFO->uiCurrentTime)); 
		sprintf(s,"%s idx %d",s,(U32) pstTIMERNINFO->uiCurrentTime % N_DAY);
		timerN_draw_all(filename,s,pstTIMERNINFO);
	}

	for(i=0;i<10;i++){
		tt = time(0);
		stData.a = '0' + i;
		printf("ADD RECORD------------[%03d]-- tt %d  %d--\n",i,(U32)tt,(U32)tt+ii[i]);
		timerid[i] = timerN_add(pstTIMERNINFO,invoke_del1,(U8 *) &stData,sizeof(stDATA),tt+ii[i]);
	}
	sprintf(filename,"TEST_NEW_INSERT_01.TXT");
	timerN_draw_all(filename,s,pstTIMERNINFO);

	timerid[0] = timerN_update(pstTIMERNINFO , timerid[0] , time(0) + 100);
	sprintf(filename,"TEST_NEW_UPDATE_01.TXT");
	timerN_draw_all(filename,s,pstTIMERNINFO);

	timerid[1] = timerN_update(pstTIMERNINFO , timerid[1] , time(0) - 100);
	sprintf(filename,"TEST_NEW_UPDATE_02.TXT");
	timerN_draw_all(filename,s,pstTIMERNINFO);

	for(i=0;i<2;i++){
		sleep(4);
		printf("INVOKE ------------[%03d]----\n",i);
		tt = time(0);
		timerN_invoke(pstTIMERNINFO);
		sprintf(filename,"TEST_NEW_INVOKE_%02d.TXT",i);
		strftime(s, 1024, "INVOKE_%H_%M_%S", localtime((time_t *)&pstTIMERNINFO->uiCurrentTime)); 
		sprintf(s,"%s idx %d",s,(U32) pstTIMERNINFO->uiCurrentTime % N_DAY);
		timerN_draw_all(filename,s,pstTIMERNINFO);
	}

	for(i=0;i<10;i++){
		tt = time(0);
		stData.a = '0' + i;
		printf("DEL RECORD------------[%03d]-- tt %d  %d--\n",i,(U32)tt,(U32)tt+ii[i]);
		timerN_del(pstTIMERNINFO,timerid[i]);
		strftime(s, 1024, "ADD_%H_%M_%S", localtime((time_t *)&pstTIMERNINFO->uiCurrentTime));
		pstTIMERNKEY = (stTIMERNKEY *) &timerid[i];
		stTIMERNKEY_Prt((char *) __FUNCTION__,pstTIMERNKEY);
		sprintf(s,"%s idx %d",s,(U32) pstTIMERNINFO->uiCurrentTime % N_DAY);
		timerN_print_all(s,pstTIMERNINFO);
		sprintf(filename,"TEST_NEW_DELETE_%02d.TXT",i);
		timerN_draw_all(filename,s,pstTIMERNINFO);
	}

	return 0;
}
#endif /* TEST */

/** file hash.c
 *     $Log: timerN.c,v $
 *     Revision 1.6  2007/03/19 01:26:45  yhshin
 *     timerN_invokde 처리 수정
 *
 *     Revision 1.5  2006/09/29 08:51:28  dark264sh
 *     FPRINTF 사용 하도록 변경
 *
 *     Revision 1.4  2006/08/21 10:46:02  dark264sh
 *     malloc 함수 에러 핸들링 추가
 *
 *     Revision 1.3  2006/08/09 01:05:30  cjlee
 *     warning 제거
 *
 *     Revision 1.2  2006/05/12 00:50:50  cjlee
 *     main : 예제 변경
 *
 *     Revision 1.1  2006/05/11 01:37:42  cjlee
 *     INIT
 *
 *     Revision 1.5  2006/05/03 01:03:36  cjlee
 *     Cnt 문제 해결
 *
 *     Revision 1.4  2006/05/03 00:16:39  cjlee
 *     minor change: for TEST
 *
 *     Revision 1.3  2006/05/03 00:12:46  cjlee
 *     timerN_init변수 변경
 *
 *     Revision 1.2  2006/04/26 08:21:26  cjlee
 *     주석 추가
 *
 *     Revision 1.1  2006/04/26 07:56:19  cjlee
 *     INIT
 *
 *     Revision 1.6  2006/04/21 07:23:58  cjlee
 *     minor change
 *
 *     Revision 1.5  2006/03/14 02:53:30  cjlee
 *     minor change
 *
 *     Revision 1.4  2006/03/14 02:17:10  cjlee
 *     hash -> timerN prefix 변경
 *
 *     Revision 1.3  2006/03/12 23:56:14  cjlee
 *     minor_chagne
 *
 *     Revision 1.2  2006/03/12 00:56:15  cjlee
 *     minor change
 *
 *     Revision 1.1  2006/03/11 08:58:50  cjlee
 *     INIT
 *
 *
 *     */
