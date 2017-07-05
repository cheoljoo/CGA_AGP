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
 *     @warning     timerN_func�� ���ڴ�  char *,char * 
 *     @todo        �ϴ� hash�� �������� �̿��Ҽ� �ְ� �ϴ°� ��ǥ�̴�. src�� �ٲٸ� �ȵȴ�. 
 *
 *     @section     Intro(�Ұ�)
 *      - timer library ���� 
 *      - timerN_init���� �ʱ�ȭ�� ���Ŀ� �⺻���� primitives �� �̿��ϰ� ��
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
 *      @li ��Ģ�� Ʋ�� ���� ã���ּ���.
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



/** �⺻ hash function : timerN_timeout_func function. 
 *
 * func�� user�� ���ؼ� �־����� �ʾ��� ��� �⺻������ ���ԵǴ� hash function.
 * 
 *
 * @param *pa	: TIMER ������ (stTIMERNINFO *)
 * @param *pb	:  pstTIMERNNODE->pstKey �� pointer (���� �𸣴� char�� ����) 
 *
 *  @return     U32 	Hash Array�� index�� ����Ų��.  
 *  @see        timerN.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       C++�� STL�� ó���ϸ� �󸶳� ���ұ� �ϴ� ������ ���.
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

/** �ʱ�ȭ �Լ� : timerN_init function. 
 *
 *  �ʱ�ȭ �Լ� 
 *
 * @param uiMaxNodeCnt  : �޸��� �ִ� NODE�� MAX
 * @param uiArgMaxSize  	: invoke function�� argument�� size�߿��� �ִ밪 (�̸�ŭ alloc�� ���ѵӴϴ�.)
 *
 *  @return     stTIMERNINFO * : Timer���� info pointer
 *  @see        timerN.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       ���� Shared Memory�ȿ� �ִ� �͵� ���� �� ��. mem ���� �κ��� �߰� �Ǿ����� ��. \n shared memory���� ������ �о�ͼ� �ٽ� timerN�� add�� �����ִ� ���� ���� ������ ����.(invoke���� pointer���� �����ϱ� �����̴�.) 
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


/** �⺻ hash function : timerN_add function. 
 *
 * NODE�� TIMER���� �����. 
 * 
 * @param *pstTIMERNINFO	: TIMER ������ 
 * @param *invoke_func	: invoke �Լ�
 * @param *pArg 	:	arg structure pointer
 * @param uiArgSize	:	arg structure size
 * @param timeout	:	���� timeout �ð� 
 *
 *  @return     TIMERNID : timer id (���ﶧ�� �̰����� ����)
 *  @see        timerN.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
 *  			NODE���� Key�� Data�� Size��ŭ�� �Ѳ����� �Ҵ��Ѵ�.
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

	if(timeout <= pstTIMERNINFO->uiCurrentTime){	/* invoke ���Ѿ��� */
		invoke_func(pArg);
		return (U64) 0;
	} 

	/* hash�� add��. */
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
	timerN_print_info("Ȯ��1",pstTIMERNINFO);
	stTIMERNKEY_Prt("Ȯ��1KEY",(stTIMERNKEY *)p->pstKey);
	stTIMERNDATA_Prt("Ȯ��1DATA",(stTIMERNDATA *)p->pstData);
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

/** �⺻ hash function : timerN_del function. 
 *
 * NODE�� TIMER���� �����. 
 * 
 * @param *pstTIMERNINFO	: TIMER ������ 
 * @param timerNid 	:	U64 �Ǵ� stTIMERNKEY �� timer id
 *
 *  @return     void : ������ ���� ������ Ȯ����.
 *  @see        timerN.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
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

/** �⺻ hash function : timerN_update function. 
 *
 * NODE�� timeout�� ������. 
 * ��ȭ�� �ϰ� �� ���� ���ؼ� �ٽ� �޾Ƶ�. 
 *
 * 
 * @param *pstTIMERNINFO	: TIMER ������ 
 * @param timerNid 	:	U64 �Ǵ� stTIMERNKEY �� timer id
 * @param timeout	:	���� timeout �ð� 
 *
 *  @return     TIMERNID : ����� timer id (���ﶧ�� �̰����� ����)
 *  @see        timerN.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
 *  			NODE���� Key�� Data�� Size��ŭ�� �Ѳ����� �Ҵ��Ѵ�.
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

	if(timeout <= pstTIMERNINFO->uiCurrentTime){	/* invoke ���Ѿ��� */
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

/** �⺻ hash function : timerN_print_info function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstTIMERNINFO	: TIMER ������ 
 *
 *  @return     void
 *  @see        timerN.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
timerN_print_info(S8 *pcPrtPrefixStr,stTIMERNINFO *pstTIMERNINFO)
{
	stTIMERNINFO_Prt(pcPrtPrefixStr,pstTIMERNINFO);
}

/** �⺻ hash function : timerN_print_node function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstTIMERNINFO	: TIMER ������ pointer
 * @param *pstTIMERNNODEKEY	: TIMER NODE pointer
 *
 *  @return     void
 *  @see        timerN.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
timerN_print_nodekey(S8 *pcPrtPrefixStr,stTIMERNINFO *pstTIMERNINFO,stTIMERNKEY *pstTIMERNNODEKEY)
{
	stTIMERNKEY_Prt(pcPrtPrefixStr,pstTIMERNNODEKEY);
}

/** �⺻ hash function : timerN_print_all function. 
 *
 * TIMER���� ��� data�� ����ش�.
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstTIMERNINFO	: TIMER ������ 
 *
 *  @return     void
 *  @see        timerN.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
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


/** �⺻ hash function : timerN_draw_all function. 
 *
 * TIMER���� ��� data�� ����ش�.
 * 
 * @param *filename	:  Write�� filename
 * @param *labelname	: label��  
 * @param *pstTIMERNINFO	: TIMER ������ 
 *
 *  @return     void
 *  @see        timerN.h
 *
 *  @note       ������ ���Ϸ� �����ȴ�. 
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
	fprintf(fp," �ð� ==  %s\\n\n",s);
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

/** �⺻ hash function : timerN_invoke function. 
 *
 * �ֱ������� ���鼭 timerN�� ���� node���� invoke �����ִ� �Լ��̴�.
 * polling �Լ���� �����ϸ� �ȴ�.  
 * 
 *
 * @param *pstTIMERNINFO	: TIMER ������ (stTIMERNINFO *)
 *
 *  @return     void
 *  @see        timerN.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       C++�� STL�� ó���ϸ� �󸶳� ���ұ� �ϴ� ������ ���.
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
 *  Node�� �����ϰ� , �����ϴ� ������ text �� �׸����� �����ش�.  
 *  -DTEST �� ���ؼ� ���Ǿ����� ������ main�� TEST�� ���ǵɶ��� ����
 *  �� ���α׷��� �⺻������ library��. 
 * 
 *  @return     void
 *  @see        timerN.h
 *
 *  @note       �׸����δ� ������ file�� �����Ǹ� file���� code���� �Է��ϰ� �Ǿ����ֽ��ϴ�.
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
	
	/* ������ ������ �ʿ䰡 �ִ�. 
	 * �����ֿ� �ͼ��� �� ������ �����ϴ� ���� �ʿ��� ���̴�.
	 */
	/* ���� ��� : N_DAY , ONE_MINUTE 30 5 �� �θ� �۰� ������ �Ҽ� �ִ�. 
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
 *     timerN_invokde ó�� ����
 *
 *     Revision 1.5  2006/09/29 08:51:28  dark264sh
 *     FPRINTF ��� �ϵ��� ����
 *
 *     Revision 1.4  2006/08/21 10:46:02  dark264sh
 *     malloc �Լ� ���� �ڵ鸵 �߰�
 *
 *     Revision 1.3  2006/08/09 01:05:30  cjlee
 *     warning ����
 *
 *     Revision 1.2  2006/05/12 00:50:50  cjlee
 *     main : ���� ����
 *
 *     Revision 1.1  2006/05/11 01:37:42  cjlee
 *     INIT
 *
 *     Revision 1.5  2006/05/03 01:03:36  cjlee
 *     Cnt ���� �ذ�
 *
 *     Revision 1.4  2006/05/03 00:16:39  cjlee
 *     minor change: for TEST
 *
 *     Revision 1.3  2006/05/03 00:12:46  cjlee
 *     timerN_init���� ����
 *
 *     Revision 1.2  2006/04/26 08:21:26  cjlee
 *     �ּ� �߰�
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
 *     hash -> timerN prefix ����
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
