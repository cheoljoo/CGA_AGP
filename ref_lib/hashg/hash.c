/** @file hash.c
 * Hash Library file.
 *
 *		$Id: hash.c,v 1.17 2006/11/15 02:39:23 cjlee Exp $
 *
 *     Copyright (c) 2006~ by Upresto Inc, Korea
 *     All rights reserved.
 * 
 *     @Author      $Author: cjlee $
 *     @version     $Revision: 1.17 $
 *     @date        $Date: 2006/11/15 02:39:23 $
 *     @ref         hashg.h
 *     @warning     hashg_func�� ���ڴ�  char *,char * 
 *     @todo        �ϴ� hash�� �������� �̿��Ҽ� �ְ� �ϴ°� ��ǥ�̴�. src�� �ٲٸ� �ȵȴ�. 
 *
 *     @section     Intro(�Ұ�)
 *      - hash library ���� 
 *      - hashg_init���� �ʱ�ָ� ���Ŀ� �⺻���� primitives �� �̿��ϰ� ��
 *      - primitives
 *      	@li hashg_init
 *      	@li hashg_add  , hashg_link_node
 *      	@li hashg_del  , hashg_unlink_node , hashg_del_from_key
 *      	@li hashg_find
 *      	@li hashg_print_info
 *      	@li hashg_print_node
 *      	@li hashg_print_all
 *      	@li Supplement 		: hashg_draw_all
 *      	@li To the Future 	: hashg_sort_add
 *      	@li To the Future 	: hashg_sort_find
 *
 *     @section     Requirement
 *      @li ��Ģ�� Ʋ�� ���� ã���ּ���.
 *
 **/




#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "hashg.h"



# define iscntrl(c) __isctype((c), _IScntrl)
#define WIDTH   16
S32
hashg_dump_DebugString(S8 *debug_str,S8 *s,S32 len)
{
	char buf[BUFSIZ],lbuf[BUFSIZ],rbuf[BUFSIZ];
	unsigned char *p;
	int line,i;

	printf("### %s\n",debug_str);
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
	return line;
}



/** �⺻ hash function : hashg_func_default function. 
 *
 * func�� user�� ���ؼ� �־����� �ʾ��� ��� �⺻������ ���ԵǴ� hash function.
 * 
 *
 * @param *pa	: HASH ������ (stHASHGINFO *)
 * @param *pb	:  pstHASHGNODE->pstKey �� pointer (���� �𸣴� char�� ����) 
 *
 *  @return     U32 	Hash Array�� index�� ����Ų��.  
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       C++�� STL�� ó���ϸ� �󸶳� ���ұ� �ϴ� ������ ���.
 **/
U32 
hashg_func_default(void *pa,U8 *pb)
{
	stHASHGINFO *pstHASHGINFO = (stHASHGINFO *) pa;
	U32 		uiHashIndex = 0;
	int			portion4 , portion2 , portion1 , remainder;
	U32			*ptr4;
	U16			*ptr2;
	U32			iIndex;

	portion4 = (int) (pstHASHGINFO->usKeyLen / 4);
	remainder = pstHASHGINFO->usKeyLen % 4;
	portion2 = (int) (remainder / 2);
	portion1 = remainder % 2;

	if(portion4){
		ptr4 = (U32 *)pb;
		for(iIndex = 0; iIndex < portion4 ; iIndex++,ptr4++){
			uiHashIndex += (U32) *ptr4;
		}
		pb = (U8 *)ptr4;
	}
	if(portion2){			// ������ ������ 1
		ptr2 = (U16 *)pb;
		uiHashIndex += (U32) *ptr2;
		ptr2++;
		pb = (U8 *)ptr2;
	}
	if(portion1){			// ������ ������ 1
		uiHashIndex += (U32) *pb;
	}
#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : (keylen %d) 4 2 1 : %d %d %d  [ %d %% %d return =%d]\n",
			__FUNCTION__,
			pstHASHGINFO->usKeyLen, 
			portion4,
			portion2,
			portion1,
			uiHashIndex, 
			pstHASHGINFO->uiHashSize ,  
			uiHashIndex % pstHASHGINFO->uiHashSize);

	FPRINTF(LOG_LEVEL,"%s : uiHashIndex = %d retu =%d\n",__FUNCTION__,uiHashIndex, uiHashIndex % pstHASHGINFO->uiHashSize);
#endif

	return (uiHashIndex % pstHASHGINFO->uiHashSize);
}


/** Set function : hashg_set_MaxNodeCnt function. 
 *
 *  Assign the Node MAX Count
 *
 * @param *pstHASHGINFO	: HASH ������ 
 * @param MaxNodeCnt  	: Max Node Count
 *
 *  @return     void
 *  @see        hashg.h
 *
 **/
void
hashg_set_MaxNodeCnt(stHASHGINFO *pstHASHGINFO,U32 MaxNodeCnt)
{
	pstHASHGINFO->MaxNodeCnt		= MaxNodeCnt;
}

/** �ʱ�ȭ �Լ� : hashg_init function. 
 *
 *  �ʱ�ȭ �Լ� 
 *
 * @param *hashg_func	: hashg_function (null�� ��� hashg_func_default() set 
 * @param *print_key	: key structure printing�Լ�  (null�� ��� hashg_dump_DebugString) set 
 * @param usKeyLen  	: key�� byte��
 * @param usDataLen  	: Data�� byte��
 * @param uiHashSize  	: open hash�� array size (open hashũ��) 
 *
 *  @return     *stHASHINFO
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       ���� Shared Memory�ȿ� �ִ� �͵� ���� �� ��. mem ���� �κ��� �߰� �Ǿ����� ��.
 **/
stHASHGINFO *
hashg_init(U32 (*hashg_func)(void*,U8*),U16 usKeyLen,  S32 (*print_key)(S8*,S8*,S32), U16 usDataLen, U32 uiHashSize)
{
	stHASHGINFO *pstHASHGINFO;

#ifdef DEBUG
	printf("%s : uiHashSize = %d\n",__FUNCTION__,uiHashSize);
#endif
	if((pstHASHGINFO = MALLOC(stHASHGINFO_SIZE)) == NULL) {
		return NULL;
	}
	pstHASHGINFO->usKeyLen 		= usKeyLen;
	pstHASHGINFO->usDataLen		= usDataLen;
	pstHASHGINFO->uiHashSize		= uiHashSize;
	pstHASHGINFO->MaxNodeCnt		= uiHashSize*10;
	if(hashg_func == 0){
		pstHASHGINFO->func		= hashg_func_default;
	} else {
		pstHASHGINFO->func 		= hashg_func;
	}
	if(print_key == 0){
		pstHASHGINFO->print_key		= hashg_dump_DebugString;
	} else {
		pstHASHGINFO->print_key 		= print_key;
	}
	if((pstHASHGINFO->psthashnode = MALLOC(uiHashSize * sizeof(char *))) == NULL) {
		FREE(pstHASHGINFO);
		return NULL;
	}
	pstHASHGINFO->uiLinkedCnt		= 0;

	return pstHASHGINFO;
}


/** �⺻ hash function : hashg_link_node function. 
 *
 * NODE�� HASH�� �����Ѵ�. 
 * 
 *
 * @param *pstHASHGINFO	: HASH ������ 
 * @param *p	: ������ node�� pointer
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **pp�� *psthashnode[100] ����  pp = &psthashnode[1]�� ���� ó���ϱ� ������ \n
 *  @code
void duinfo_hash(duinfo_t *p)
{   
		duinfo_t **pp = &duinfohash[duinfofn(p->id)];
		if((p->next = *pp))
				p->next->prev = &p->next;
		p->prev = pp;
		*pp = p;
		return;
}
duinfo_t *duinfohash[duinfo_hashg_size] = { NULL, };
@endcode
 **/
void 
hashg_link_node(stHASHGINFO *pstHASHGINFO , stHASHGNODE *p)
{
	/** ����.
	 * @code
		struct aaa {
				int a;
				int b;
				int c;
		};

		struct bbb {
				struct aaa *d;
				int e;
				int fi;
		};

		struct bbb *g[100];

		main ()
		{
				struct bbb b;
				printf("sizeof aaa : %d\n",sizeof(struct aaa));     // 12
				printf("sizeof bbb : %d\n",sizeof(struct bbb));     // 12
				printf("sizeof char * : %d\n",sizeof(char *));      // 4
				printf("0x%x   0x%x \n", b.d , b.d + 1);            // ? , ?+12
				printf("0x%x   0x%x \n", b.d , (int *) b.d + 1);    // ? , ?+4
				printf("0x%x   0x%x \n", &g[0] , &g[1]);            // ? , ?+4
		}
		@endcode
	**/
#ifdef DEBUG
	printf("%s : pstHASHGNODE = %x\n",__FUNCTION__,(U32) p);
#endif
	stHASHGNODE **pp = (stHASHGNODE **) (((U32 *) pstHASHGINFO->psthashnode) + 
					(U32) pstHASHGINFO->func( (void *) pstHASHGINFO, (U8 *) p->pstKey)
					);
	p->pstHASHGINFO = (U8 *) pstHASHGINFO;
	if((p->next = *pp))
		p->next->prev = &p->next;
	p->prev = pp;
	*pp = p;
	pstHASHGINFO->uiLinkedCnt++;
	return;
}

/** �⺻ hash function : hashg_unlink_node function. 
 *
 * NODE�� HASH���� �����. 
 * 
 *
 * @param *p	: ���� node�� pointer
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
 *  @code
void duinfo_unhash(duinfo_t *p)
{
	if(p->prev){
		if((*(p->prev) = p->next))
			p->next->prev = p->prev;
		p->next = NULL;
		p->prev = NULL;
	}
	return;
}
@endcode
 **/
void 
hashg_unlink_node(stHASHGNODE *p)
{
	stHASHGINFO *pstHASHGINFO;

	pstHASHGINFO = (stHASHGINFO *) p->pstHASHGINFO;
#ifdef DEBUG
	printf("%s : pstHASHGNODE = %d\n",__FUNCTION__,(U32) p);
#endif
	if(p->prev){
		if((*(p->prev) = p->next))
			p->next->prev = p->prev;
		p->next = NULL;
		p->prev = NULL;
		pstHASHGINFO->uiLinkedCnt--;
	}
	return;
}


/** �⺻ hash function : hashg_find function. 
 *
 * NODE�� HASH���� �����. 
 * 
 * @param *pstHASHGINFO	: HASH ������ 
 * @param *pKey	: Key pointer
 *
 *  @return     stHASHGNODE  (ã���� node pointer)
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
 *  @code
duinfo_t* duinfo_find(unsigned int id)
{
	duinfo_t *p;

	for(p=duinfohash[duinfofn(id)];p;p=p->next){
		if(p->id != id) continue;
		return p;
	}
	return NULL;
}
@endcode
 **/
stHASHGNODE *
hashg_find(stHASHGINFO *pstHASHGINFO, U8 *pKey)
{
	stHASHGNODE *p;

#ifdef DEBUG
	printf("%s : pstHASHGNODE = 0x%x\n",__FUNCTION__,(U32) pKey);
	hashg_dump_DebugString(__FUNCTION__,pKey,pstHASHGINFO->usKeyLen);
#endif
	p = (stHASHGNODE *) 
		*(  ((U32 *) pstHASHGINFO->psthashnode) 
			+ pstHASHGINFO->func(pstHASHGINFO, (U8 *) pKey)
		 );

	for(;p;p=p->next){
		if( memcmp((U8 *) pKey , (U8 *)p->pstKey, pstHASHGINFO->usKeyLen) ) continue;
		return p;
	}
	return NULL;
}


/** �⺻ hash function : hashg_add function. 
 *
 * NODE�� HASH���� ���Ѵ�. 
 * 
 * @param *pstHASHGINFO	: HASH ������ 
 * @param *pKey 	:	node Key Pointer
 * @param *pData	:	node Data Pointer
 *
 *  @return     Key , Data�� ���� ������ node pointer
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
 *  			NODE���� Key�� Data�� Size��ŭ�� �Ѳ����� �Ҵ��Ѵ�.
 *  @code
duinfo_t* duinfo_add(unsigned int id)
{
	duinfo_t *p;
	if( (p=(duinfo_t*)duinfo_find(id)) ){
		p->flag = 1;
		return NULL;
	}
	p = (duinfo_t*)malloc(sizeof(duinfo_t));
	if(p){
		memset(p, 0x00, sizeof(duinfo_t));
		p->id = id;
		p->next = NULL;
		p->prev = NULL;
		duinfo_hash(p);
	}
	return p;	
}
@endcode
 **/
stHASHGNODE *
hashg_add(stHASHGINFO *pstHASHGINFO, U8 *pKey, U8 *pData)
{
	stHASHGNODE *p;
#ifdef DEBUG
	printf("%s : pstHASHGNODE = 0x%x\n",__FUNCTION__,(U32) pKey);
	hashg_dump_DebugString("add:Key",pKey,pstHASHGINFO->usKeyLen);
	hashg_dump_DebugString("add:Data",pData,pstHASHGINFO->usDataLen);
#endif

	if(pstHASHGINFO->uiLinkedCnt >= pstHASHGINFO->MaxNodeCnt) return 0;

	if( (p=(stHASHGNODE *)hashg_find(pstHASHGINFO,pKey)) ){
		return NULL;
	}
	p = (stHASHGNODE *)malloc(stHASHGNODE_SIZE
					+ pstHASHGINFO->usKeyLen
					+ pstHASHGINFO->usDataLen);
	if(p){
		memset(p, 0x00, stHASHGNODE_SIZE
						+ pstHASHGINFO->usKeyLen
						+ pstHASHGINFO->usDataLen);
		p->pstKey  = (U8 *) (p + 1);
		memcpy(p->pstKey , pKey , pstHASHGINFO->usKeyLen);
		p->pstData = (U8 *) (p->pstKey + pstHASHGINFO->usKeyLen);
		memcpy(p->pstData , pData , pstHASHGINFO->usDataLen);
		p->pstHASHGINFO = (U8 *) pstHASHGINFO;
		p->next = NULL;
		p->prev = NULL;
		hashg_link_node(pstHASHGINFO,p);
	} 
	return p;
}

/** �⺻ hash function : hashg_del_from_key function. 
 *
 * key�� arguemtn���ؼ� NODE�� HASH���� �����. 
 * 
 * @param *pstHASHGINFO	: HASH ������ 
 * @param *pKey 	:	node Key Pointer
 *
 *  @return     Key , Data�� ���� ������ node pointer
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
 *  @code
void duinfo_del(unsigned int id)
{
	duinfo_t *p;
	if(!(p=duinfo_find(id))) return;
	duinfo_unhash(p);
	FREE(p);
	return;
}
@endcode
 **/
void 
hashg_del_from_key(stHASHGINFO *pstHASHGINFO, U8 *pKey)
{
	stHASHGNODE *p;
#ifdef DEBUG
	printf("%s : pstHASHGNODE = 0x%x\n",__FUNCTION__,(U32) pKey);
	hashg_dump_DebugString(__FUNCTION__,pKey,pstHASHGINFO->usKeyLen);
#endif
	if(!(p=hashg_find(pstHASHGINFO,pKey))) return ;
	hashg_unlink_node(p);
	FREE(p);
	return;
}

/** �⺻ hash function : hashg_del function. 
 *
 * NODE�� HASH���� �����. 
 * 
 * @param *pstHASHGNODE 	:	node Pointer
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
 **/
void 
hashg_del(stHASHGNODE *pstHASHGNODE)
{
	stHASHGINFO *pstHASHGINFO;

	pstHASHGINFO = (stHASHGINFO *) pstHASHGNODE->pstHASHGINFO;
#ifdef DEBUG
	printf("%s : pstHASHGNODE = 0x%x\n",__FUNCTION__,(U32) pstHASHGNODE);
	pstHASHGINFO->print_key("KEY",pstHASHGNODE->pstKey,pstHASHGINFO->usKeyLen);
#endif
	hashg_unlink_node(pstHASHGNODE);
	FREE(pstHASHGNODE);
	return;
}


/** �⺻ hash function : hashg_print_info function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstHASHGINFO	: HASH ������ 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
hashg_print_info(S8 *pcPrtPrefixStr,stHASHGINFO *pstHASHGINFO)
{
	stHASHGINFO_Prt(pcPrtPrefixStr,pstHASHGINFO);
}

/** �⺻ hash function : hashg_print_node function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstHASHGINFO	: HASH ������ pointer
 * @param *pstHASHGNODE	: HASH NODE pointer
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
hashg_print_node(S8 *pcPrtPrefixStr,stHASHGINFO *pstHASHGINFO,stHASHGNODE *pstHASHGNODE)
{
	stHASHGNODE_Prt(pcPrtPrefixStr,pstHASHGNODE);
	pstHASHGINFO->print_key("KEY",pstHASHGNODE->pstKey,pstHASHGINFO->usKeyLen);
	hashg_dump_DebugString("DATA",pstHASHGNODE->pstData,pstHASHGINFO->usDataLen);
}

/** �⺻ hash function : hashg_print_all function. 
 *
 * HASH���� ��� data�� ����ش�.
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstHASHGINFO	: HASH ������ 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
hashg_print_all(S8 *pcPrtPrefixStr,stHASHGINFO *pstHASHGINFO)
{
	U32	iIndex;
	stHASHGNODE *p;

	FPRINTF(stdout,"##%s : pstHASHGINFO\n",__FUNCTION__);
	hashg_print_info(pcPrtPrefixStr,pstHASHGINFO);

	FPRINTF(stdout,"##%s : pstHASHGNODE ...\n",__FUNCTION__);
	for(iIndex=0;iIndex < pstHASHGINFO->uiHashSize;iIndex++){
		p = (stHASHGNODE *) *(  
				(U32 *) pstHASHGINFO->psthashnode 
				+ iIndex
		 	);
		
		/* FPRINTF(stdout,"##%s : %s : [%3d] location : 0x%08x , valuep=0x%x\n",pcPrtPrefixStr,__FUNCTION__,iIndex,
		(U32) (((U32 *) pstHASHGINFO->psthashnode) + iIndex),
		*((U32 *) pstHASHGINFO->psthashnode + iIndex));*/
		for(;p;p=p->next){
			FPRINTF(stdout,"##%s : [%3d] p->prev=0x%x , p=0x%x , p->next=0x%x keylen=%d\n",__FUNCTION__,iIndex,(U32) p->prev, (U32) p,(U32) p->next,pstHASHGINFO->usKeyLen);
			pstHASHGINFO->print_key("KEY",p->pstKey,pstHASHGINFO->usKeyLen);
			/* hashg_print_node(pstHASHGINFO,p); */
		}
	}
}

/** �⺻ hash function : hashg_get_occupied_node_count function. 
 *
 * HASH�ȿ��� ���� node�� �ִ� ���� return���ش�.
 * 
 * @param *pstHASHGINFO	: HASH ������ 
 *
 *  @return     U32
 *  @see        hash.h
 **/
U32	hashg_get_occupied_node_count(stHASHGINFO *pstHASHGINFO)
{
	U32	iIndex;
	stHASHGNODE *p;
	U32	occupied_hash_cnt=0;

	FPRINTF(LOG_LEVEL,"pstHASHGINFO->uiHashSize = %d \\n\n",pstHASHGINFO->uiHashSize);
	FPRINTF(LOG_LEVEL,"pstHASHGINFO->uiLinkedCnt = %d \\n\n",pstHASHGINFO->uiLinkedCnt);

	for(iIndex=0;iIndex < pstHASHGINFO->uiHashSize;iIndex++){
		p = (stHASHGNODE *) *(  
				(U32 *) pstHASHGINFO->psthashnode 
				+ iIndex
		 	);
		if(p){ 
			occupied_hash_cnt++; 
		}
	}
	FPRINTF(LOG_LEVEL,"%s : occupied_hash_cnt=%d  (%d %%)\n",
			__FUNCTION__,
			(U32) occupied_hash_cnt, 
			(occupied_hash_cnt / pstHASHGINFO->uiHashSize) * 100 );
	return occupied_hash_cnt;
}


/** �⺻ hash function : hashg_draw_all function. 
 *
 * HASH���� ��� data�� ����ش�.
 * 
 * @param *filename	:  Write�� filename
 * @param *labelname	: label��  
 * @param *pstHASHGINFO	: HASH ������ 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       ������ ���Ϸ� �����ȴ�. 
 **/
void
hashg_draw_all(S8 *filename,S8 *labelname,stHASHGINFO *pstHASHGINFO)
{
	U32	iIndex;
	stHASHGNODE *p;
	FILE *fp;

	fp = fopen(filename,"w");
	FPRINTF(fp,"/** @file %s\n",filename);
	FPRINTF(fp,"pstHASHGINFO->uiHashSize = %d \\n\n",pstHASHGINFO->uiHashSize);
	FPRINTF(fp,"pstHASHGINFO->uiLinkedCnt = %d \\n\n",pstHASHGINFO->uiLinkedCnt);
	FPRINTF(fp,"\\dot \n	\
	digraph G{ 	\n\
	fontname=Helvetica; 	\n\
	label=\"Hash Table(%s)\"; 	\n\
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
				FPRINTF(fp,"<f%d> %d ",iIndex,iIndex);
			} else {
				FPRINTF(fp,"<f%d> %d | ",iIndex,iIndex);
			}
		}
	}
	FPRINTF(fp,"\",height = 2.5];\n");
	FPRINTF(fp,"node [width=1.5];\n");
	for(iIndex=0;iIndex < pstHASHGINFO->uiHashSize;iIndex++){
		p = (stHASHGNODE *) *(  
				(U32 *) pstHASHGINFO->psthashnode 
				+ iIndex
		 	);
		for(;p;p=p->next){
			FPRINTF(fp,"N0x%08x [label = \"{ <n> 0x%08x | %3d | <p> }\"];\n",(U32) p,(U32) p,iIndex);
		}
	}
	FPRINTF(fp,"\n\n");
	for(iIndex=0;iIndex < pstHASHGINFO->uiHashSize;iIndex++){
		p = (stHASHGNODE *) *(  
				(U32 *) pstHASHGINFO->psthashnode 
				+ iIndex
		 	);
		if(p){
			FPRINTF(fp,"node0:f%d -> N0x%08x:n;\n",iIndex,(U32) p);
		}
		for(;p;p=p->next){
			if(p->next){
				FPRINTF(fp,"N0x%08x:p -> N0x%08x:n;\n",(U32) p , (U32) p->next);
			}
		}
	}
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

S32
hashg_test_print_key(S8 *debug_str,S8 *s,S32 len)
{
	stKEY *p;
	p = (stKEY *) s;

	printf("%s : p->a = %d\n",__FUNCTION__,p->a);
	printf("%s : p->b = %d\n",__FUNCTION__,p->b);
	printf("%s : p->c = %d\n",__FUNCTION__,p->c);
	printf("%s : p->d = %d\n",__FUNCTION__,p->d);

	return 0;
}

/** main function.
 *
 *  Node�� �����ϰ� , �����ϴ� ������ text �� �׸����� �����ش�.  
 *  -DTEST �� ���ؼ� ���Ǿ����� ������ main�� TEST�� ���ǵɶ��� ����
 *  �� ���α׷��� �⺻������ library��. 
 * 
 *  @return     void
 *  @see        hash.h
 *
 *  @note       �׸����δ� ������ file�� �����Ǹ� file���� code���� �Է��ϰ� �Ǿ����ֽ��ϴ�.
 **/
int
main()
{
	stHASHGINFO *pstHASHGINFO;
	stHASHGNODE *pstHASHGNODE;
	stKEY  stKey;
	stDATA  stData;
	char 	s[1000];

	stKey.a = '0';
	stKey.b = '1';
	stKey.c = 0x01;
	stKey.d = 0x03;
	stData.a = '0';
	stData.b = '1';
	stData.c = '2';
	stData.d = '3';
	
	pstHASHGINFO = hashg_init(0, sizeof(stKEY), 0, sizeof(stDATA), 4 /**<hash size */);
	
	hashg_add(pstHASHGINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hashg_print_all(s,pstHASHGINFO);
	hashg_draw_all("TEST_RESULT_01.TXT",s,pstHASHGINFO);

	stKey.d = 0x04;
	hashg_add(pstHASHGINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hashg_print_all(s,pstHASHGINFO);
	hashg_draw_all("TEST_RESULT_02.TXT",s,pstHASHGINFO);

	stKey.d = 0x07;
	hashg_add(pstHASHGINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hashg_print_all(s,pstHASHGINFO);
	hashg_draw_all("TEST_RESULT_03.TXT",s,pstHASHGINFO);

	stKey.c = 0x03;
	stKey.d = 0x04;
	hashg_add(pstHASHGINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hashg_print_all(s,pstHASHGINFO);
	hashg_draw_all("TEST_RESULT_04.TXT",s,pstHASHGINFO);

	stKey.c = 0x0d;
	stKey.d = 0x04;
	hashg_add(pstHASHGINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hashg_print_all(s,pstHASHGINFO);
	hashg_draw_all("TEST_RESULT_05.TXT",s,pstHASHGINFO);

	stKey.c = 0x0d;
	stKey.d = 0x0e;
	hashg_add(pstHASHGINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hashg_print_all(s,pstHASHGINFO);
	hashg_draw_all("TEST_RESULT_06.TXT",s,pstHASHGINFO);

	hashg_del_from_key(pstHASHGINFO,(U8 *)&stKey);
	sprintf(s,"delete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hashg_print_all(s,pstHASHGINFO);
	hashg_draw_all("TEST_RESULT_07.TXT",s,pstHASHGINFO);

	stKey.a = '0';
	stKey.b = '1';
	stKey.c = 0x01;
	stKey.d = 0x03;
	hashg_del_from_key(pstHASHGINFO,(U8 *)&stKey);
	sprintf(s,"delete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hashg_print_all(s,pstHASHGINFO);
	hashg_draw_all("TEST_RESULT_08.TXT",s,pstHASHGINFO);


	/* New */
	pstHASHGINFO = hashg_init(0, sizeof(stKEY), hashg_test_print_key, sizeof(stDATA), 4 /**<hash size */);
	
	pstHASHGNODE = hashg_add(pstHASHGINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hashg_print_all(s,pstHASHGINFO);
	hashg_draw_all("TEST_RESULT_New_01.TXT",s,pstHASHGINFO); 
	
	hashg_del(pstHASHGNODE);
	sprintf(s,"delete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hashg_print_all(s,pstHASHGINFO);
	hashg_draw_all("TEST_RESULT_New_02.TXT",s,pstHASHGINFO); 

	return 0;
}
#endif /* TEST */

/** file hash.c
 *     $Log: hash.c,v $
 *     Revision 1.17  2006/11/15 02:39:23  cjlee
 *     - MaxNodeCnt ���� (   hashg_set_MaxNodeCnt() �Լ� ���)
 *     	���� hashg_init�� �������� �ʰ� �ذ�
 *     	stHASHGINFO �� �߰�
 *     - hashg_add()���� ��� ���� Max�� ������ return 0
 *     - tiemr�� �ذ� ���
 *     	U64 Timer�� �Ѱ��̰�, �� tiemr�� 0������ ����
 *     	create���� update������ �����ϸ�� ���̴�.
 *
 *     Revision 1.16  2006/11/08 03:36:44  cjlee
 *     hashg default �Լ� ����
 *     hashg_get_occupied_node_count �߰�
 *
 *     Revision 1.15  2006/07/26 05:48:58  dark264sh
 *     free => FREE ��ũ�η� ����
 *
 *     Revision 1.14  2006/07/24 11:44:42  dark264sh
 *     hashg_init �Լ�
 *     malloc ���� �ڵ鸵 �߰�
 *
 *     Revision 1.13  2006/07/24 11:12:19  dark264sh
 *     bzero => memset ����
 *
 *     Revision 1.12  2006/05/03 00:43:46  cjlee
 *     link_node���� node�� HASHGINFO�� ��������
 *
 *     Revision 1.11  2006/05/03 00:04:31  cjlee
 *     unlink_node�� ��ȭ
 *
 *     Revision 1.10  2006/04/26 01:19:17  cjlee
 *     minor change: �ּ� �߰�
 *
 *     Revision 1.9  2006/04/26 01:17:01  cjlee
 *     minor change : draw node�� �������� �׸���
 *
 *     Revision 1.8  2006/04/26 01:05:37  cjlee
 *     timerg ���� ���� : major
 *
 *     Revision 1.7  2006/04/24 00:59:25  cjlee
 *     unlink arg �߰�
 *
 *     Revision 1.6  2006/04/21 07:23:58  cjlee
 *     minor change
 *
 *     Revision 1.5  2006/03/14 02:53:30  cjlee
 *     minor change
 *
 *     Revision 1.4  2006/03/14 02:17:10  cjlee
 *     hash -> hashg prefix ����
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
