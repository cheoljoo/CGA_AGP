/** @file hasho.c
 * Hash Library file.
 *
 *		$Id: hasho.c,v 1.16 2006/11/27 07:45:39 cjlee Exp $
 *
 *     Copyright (c) 2006~ by Upresto Inc, Korea
 *     All rights reserved.
 * 
 *     @Author      $Author: cjlee $
 *     @version     $Revision: 1.16 $
 *     @date        $Date: 2006/11/27 07:45:39 $
 *     @ref         hasho.h
 *     @warning     여기서는 pointer를 사용할수 없기 때문에 , hash function을 link하여 사용할 수가 없다. 
 *     				그냥 일방적인 것 한개를 정해야 할 것이다.  
 *     @todo        일단 hash를 자유로이 이용할수 있게 하는게 목표이다. src를 바꾸면 안된다. 
 *     				offset구조와 pointer 구조 2가지로 가져가기로 한다.
 *
 *     @section     Intro(소개)
 *      - hash library 파일  (offset개념으로 작성)
 *      - hasho_init으로 초기롸를 한후에 기본저인 primitives 를 이용하게 함
 *      - primitives
 *      	@li hasho_init
 *      	@li hasho_add  , hasho_link_node
 *      	@li hasho_del  , hasho_unlink_node
 *      	@li hasho_find
 *      	@li hasho_print_info
 *      	@li hasho_print_node
 *      	@li hasho_print_all
 *      	@li Supplement 		: hasho_draw_all
@code
 *      - Hasho 구조  (v1.1) 
 *      규칙 0 : memg안에서의 offset은 pstMEMGINFO 에서부터의 offset임.
 *   pstHASHOINFO = hasho_init(sizeof(stKEY)=8, sizeof(stKEY)=8, sizeof(stDATA)=4 , 4  :: hash size 0
 *
 *                        +----------------------------------+
 *                    48  |    memg_info (stMEMGINFO)        | [H]offset_memginfo = -48
 [M]offsetHeadRoom(48) -> +----------------------------------+
 *                    36  |    Head Room                     |  20 stHASHOINFO    
 *                        |                                  |  16 [H]offset_psthashnode = 20
 [M]offsetNodeStart(84)-> +----------------------------------+
 *                    16  |    memg node hdr1(stMEMGNODEHDR) |
 *                 +--28------+memg node data                |
 *                 |      +----------------------------------+
 *                 |  16  |    memg node hdr2(stMEMGNODEHDR) |
 *                 |  28  |    memg node data                |
 *                 |      +----------------------------------+
 *                 |      |    memg node hdr3(stMEMGNODEHDR) |
 *                 |      |    memg node data                |
 *                 |      +----------------------------------+
 *                 |
 *                 |
 *                 |    규칙 : hasho 의 offset은 pstHASHOINFO에서부터의 offset을 의미함.
 *           [H]52 +----> +----------------------------------+
 *                     4  |    offset_next          +----------------------------+      
 *                     4  |    offset_prev                   |                   |      
 *                     4  |    offset_Key     +--------------------+             |      
 *                     4  |    offset_Data    +--------------------|---+         |      
 *          offset_Key    +----------------------------------+<----+   |         |      
 *                     8  |    Key (usKeyLen)                |         |         |      
 *          offset_Data   +----------------------------------+<--------+         |      
 *                     4  |    Data (usDataLen)              |                   |      
 *                        +----------------------------------+                   |      
 *                                      .........                                |      
 *                                      .........                                |      
 *                                      .........                                |      
 *                        +----------------------------------+<------------------+      
 *                     4  |    offset_next                   |                          
 *                     4  |    offset_prev                   |                          
 *                     4  |    offset_Key                    |
 *                     4  |    offset_Data                   |
 *          offset_Key    +----------------------------------+
 *                     8  |    Key (usKeyLen)                |
 *          offset_Data   +----------------------------------+
 *                     4  |    Data (usDataLen)              |
 *                        +----------------------------------+
 *                     4  |    offset_next                   |
 *                     4  |    offset_prev                   |
 *                     4  |    offset_Key                    |
 *                     4  |    offset_Data                   |
 *          offset_Key    +----------------------------------+
 *                     8  |    Key (usKeyLen)                |
 *          offset_Data   +----------------------------------+
 *                     4  |    Data (usDataLen)              |
 *             [M] 1844   +----------------------------------+
 *
 *       offset 기준 : 
 *       pstMEMGINFO      -> stMEMGINFO 안의  offset 들
 *       pstHASHOINFO     -> stHASHOINFO , stHASHONODE 안의 offset 들 
@endcode
 *
 *
 *
 *     @section     Requirement
 *      @li 규칙에 틀린 곳을 찾아주세요.
 *
 **/




#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "memg.h"
#include "hasho.h"

U32 (*hasho_func)(void *pa, U8 *pb);

# define iscntrl(c) __isctype((c), _IScntrl)
#define WIDTH   16
int
hasho_dump_DebugString(char *debug_str,char *s,int len)
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
		FPRINTF(LOG_LEVEL,"%04x: %-*s    %s\n",line - 1,WIDTH * 3,lbuf,rbuf);
	}
	return line;
}



/** 기본 hash function : hasho_func_default function. 
 *
 * func이 user에 의해서 주어지지 않았을 경우 기본적으로 대입되는 hash function.
 * 
 *
 * @param *pa	: HASH 관리자 (stHASHOINFO *)
 * @param *pb	:  pstHASHONODE->pstKey 의 pointer (원지 모르니 char로 정의) 
 *
 *  @return     U32 	Hash Array의 index를 가리킨다.  
 *  @see        hash.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       C++의 STL로 처리하면 얼마나 편할까 하는 생각이 든다.
 **/
U32 hasho_func_default(void *pa,U8 *pb)
{
	stHASHOINFO *pstHASHOINFO = (stHASHOINFO *) pa;
	U32 		uiHashIndex = 0;
	int			portion4 , portion2 , portion1 , remainder;
	U32			*ptr4;
	U16			*ptr2;
	U32			iIndex;

	portion4 = (int) (pstHASHOINFO->usKeyLen / 4);
	remainder = pstHASHOINFO->usKeyLen % 4;
	portion2 = (int) (remainder / 2);
	portion1 = remainder % 2;

	if(portion4){
		ptr4 = (U32 *)pb;
		for(iIndex = 0; iIndex < portion4 ; iIndex++,ptr4++){
			uiHashIndex += (U32) *ptr4;
		}
		pb = (U8 *)ptr4;
	}
	if(portion2){			// 있으면 무조건 1
		ptr2 = (U16 *)pb;
		uiHashIndex += (U32) *ptr2;
		ptr2++;
		pb = (U8 *)ptr2;
	}
	if(portion1){			// 있으면 무조건 1
		uiHashIndex += (U32) *pb;
	}
#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : (keylen %d) 4 2 1 : %d %d %d  [ %d %% %d return =%d]\n",
			__FUNCTION__,
			pstHASHOINFO->usKeyLen, 
			portion4,
			portion2,
			portion1,
			uiHashIndex, 
			pstHASHOINFO->uiHashSize ,  
			uiHashIndex % pstHASHOINFO->uiHashSize);

	FPRINTF(LOG_LEVEL,"%s : uiHashIndex = %d retu =%d\n",__FUNCTION__,uiHashIndex, uiHashIndex % pstHASHOINFO->uiHashSize);
#endif

	return (uiHashIndex % pstHASHOINFO->uiHashSize);
}


/** 초기화 함수 : hasho_init function. 
 *
 *  초기화 함수 
 *
 * @param uiShmKey  	: Shared Memory Key Value (0: local memory 사용)
 * @param usKeyLen  	: key의 byte수
 * @param usSortKeyLen  	: sort를 위한 key의 byte수
 * @param usDataLen  	: Data의 byte수
 * @param uiHashSize  	: open hash의 array size (open hash크기) 
 * @param func  		: function pointer (hash function)
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       추후 Shared Memory안에 넣는 것도 좋을 듯 함. mem 관리 부분이 추가 되어져야 함.
 **/
stHASHOINFO *
hasho_init(U32 uiShmKey, U16 usKeyLen, U16 usSortKeyLen, U16 usDataLen, U32 uiHashSize, U32 (*func)(void*,U8*))
{
	stHASHOINFO *pstHASHOINFO;
	stMEMGINFO *pstMEMGINFO;

	if(0 == func){
		hasho_func = hasho_func_default;
	} else {
		hasho_func = func;
	}

#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : uiHashSize = %d\n",__FUNCTION__,uiHashSize);
#endif
	ASSERT(usKeyLen >= usSortKeyLen);

	if (uiShmKey == 0) {
		pstMEMGINFO = memg_init(MEMG_MAIN_MEM
					,0
					,sizeof(stHASHOINFO) + (uiHashSize * sizeof(char *))
					,stHASHONODE_SIZE + usKeyLen + usDataLen
					,uiHashSize * 10);  /* 항시 10이 아닐수 있음. 변화 가능 */

	} else {
		pstMEMGINFO = memg_init(MEMG_SHARED_MEM
					,uiShmKey
					,sizeof(stHASHOINFO) + (uiHashSize * sizeof(char *))
					,stHASHONODE_SIZE + usKeyLen + usDataLen
					,uiHashSize * 10);  /* 항시 10이 아닐수 있음. 변화 가능 */
	}

	pstHASHOINFO = (stHASHOINFO *) MEMG_PTR(pstMEMGINFO,pstMEMGINFO->offsetHeadRoom);
	pstHASHOINFO->usKeyLen 		= usKeyLen;
	pstHASHOINFO->usDataLen		= usDataLen;
	pstHASHOINFO->uiHashSize		= uiHashSize;
	pstHASHOINFO->offset_psthashnode	= stHASHOINFO_SIZE;
	pstHASHOINFO->offset_memginfo	= (S32) HASHO_OFFSET(pstHASHOINFO, pstMEMGINFO);
#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : stMEMGINFO_SIZE = %d\n",__FUNCTION__,stMEMGINFO_SIZE);
	FPRINTF(LOG_LEVEL,"%s : stMEMGNODEHDR_SIZE = %d\n",__FUNCTION__,stMEMGNODEHDR_SIZE);
	FPRINTF(LOG_LEVEL,"%s : stHASHOINFO_SIZE = %d\n",__FUNCTION__,stHASHOINFO_SIZE);
	FPRINTF(LOG_LEVEL,"%s : stHASHONODE_SIZE = %d\n",__FUNCTION__,stHASHONODE_SIZE);
	stMEMGINFO_Prt("MEMGINFO",pstMEMGINFO);
	stHASHOINFO_Prt("HASHOINFO",pstHASHOINFO);
#endif

	return pstHASHOINFO;
}


/** 기본 hash function : hasho_link_node function. 
 *
 * NODE를 HASH에 삽입한다.  (head의 바로 다음에 붙인다.)
 * 
 *
 * @param *pstHASHOINFO	: HASH 관리자 
 * @param *p	: 삽입할 node의 pointer 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       **pp는 *psthashnode[100] 에서  pp = &psthashnode[1]과 같이 처리하기 위함임 \n
 **/
void 
hasho_link_node(stHASHOINFO *pstHASHOINFO , stHASHONODE *p)
{
	OFFSET 	*pNodeHead; 	/**< pNodeHead : head list에서 index에 맞는 값 */
	stHASHONODE *pNodeNext; /**< pNodeNext : head list에 달려있는 첫번째 node pointer */

#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : pstHASHONODE = 0x%x\n",__FUNCTION__,(U32) p);
#endif
	pNodeHead = ((S32 *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) 
			+ hasho_func(pstHASHOINFO, (U8 *) HASHO_PTR(pstHASHOINFO, p->offset_Key)) ;

	if(*pNodeHead){ /* NODE 가 붙어 있다면 */
		pNodeNext = (stHASHONODE *) HASHO_PTR(pstHASHOINFO, *pNodeHead);
		p->offset_prev = pNodeNext->offset_prev; /* maybe NULL */
		pNodeNext->offset_prev = HASHO_OFFSET(pstHASHOINFO, p);
		p->offset_next = *pNodeHead;
		*pNodeHead = HASHO_OFFSET(pstHASHOINFO, p);
	} else { /* NODE 가 하나도 없을때 */
		*pNodeHead = HASHO_OFFSET(pstHASHOINFO, p);
	}

	return;
}

/** 기본 hash function : hasho_unlink_node function. 
 *
 * NODE를 HASH에서 지운다. 
 * 
 *
 * @param *pstHASHOINFO	: HASH 관리자 
 * @param *p	: 지울 node의 pointer
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       prev , next가 offset
 **/
void 
hasho_unlink_node(stHASHOINFO *pstHASHOINFO, stHASHONODE *p)
{
	S32 	*pNodeHead; 	/**< pNodeHead : head list에서 index에 맞는 값 */
	stHASHONODE *pNodeNext; /**< HASHO_PTR( pNodeNext : p->offset_next ) */
	stHASHONODE *pNodePrev; /**< HASHO_PTR( pNodePrev : p->offset_prev ) */

#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : pstHASHONODE = %d\n",__FUNCTION__,(U32) p);
#endif
	pNodeHead = ((S32 *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) 
			+ hasho_func(pstHASHOINFO, (U8 *) HASHO_PTR(pstHASHOINFO, p->offset_Key)) ;
	pNodeNext = (stHASHONODE *) HASHO_PTR(pstHASHOINFO,  p->offset_next );
	pNodePrev = (stHASHONODE *) HASHO_PTR(pstHASHOINFO,  p->offset_prev );

	if(p->offset_prev){ 	/* 첫번째 node가 아닐때 */
		pNodePrev->offset_next = p->offset_next;
	} else {	/* 첫번째 node일때 */
		*pNodeHead = p->offset_next;
	}
	if(p->offset_next){ 	/* 마지막 node가 아닐때 */
		pNodeNext->offset_prev = p->offset_prev;
	} else {	/* 마지막 node일때 */
		/* NOTHING */
	}
	return;
}


/** 기본 hash function : hasho_find function. 
 *
 * NODE를 HASH에서 지운다. 
 * 
 * @param *pstHASHOINFO	: HASH 관리자 
 * @param *pKey	: Key pointer
 *
 *  @return     stHASHONODE  (찾아진 node pointer)
 *  @see        hash.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       **prev 주의
 **/
stHASHONODE *
hasho_find(stHASHOINFO *pstHASHOINFO, U8 *pKey)
{
	OFFSET 	*pNodeHead; 	/**< pNodeHead : head list에서 index에 맞는 값 */
	OFFSET	pOff;
	stHASHONODE *p;

#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : pstHASHONODE = 0x%x\n",__FUNCTION__,(U32) pKey);
	hasho_dump_DebugString(__FUNCTION__,pKey,pstHASHOINFO->usKeyLen);
#endif
	pNodeHead = ((OFFSET *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) 
			+ hasho_func(pstHASHOINFO, pKey) ;
	pOff = (OFFSET) *pNodeHead;
	while(pOff){
		p = (stHASHONODE *) HASHO_PTR(pstHASHOINFO, pOff);
		if( ! memcmp((U8 *) pKey , (U8 *)HASHO_PTR(pstHASHOINFO, p->offset_Key), pstHASHOINFO->usKeyLen) ) return p;
		pOff = p->offset_next;
	}
	return NULL;
}


/** 기본 hash function : hasho_add function. 
 *
 * NODE를 HASH에서 지운다. 
 * 
 * @param *pstHASHOINFO	: HASH 관리자 
 * @param *pKey 	:	node Key Pointer
 * @param *pData	:	node Data Pointer
 *
 *  @return     Key , Data의 새로 생성된 node pointer
 *  @see        hash.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       **prev 주의
 *  			NODE안의 Key와 Data의 Size만큼을 한꺼번에 할당한다.
 **/
stHASHONODE *
hasho_add(stHASHOINFO *pstHASHOINFO, U8 *pKey, U8 *pData)
{
	stHASHONODE *p;
#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : pstHASHONODE = 0x%x\n",__FUNCTION__,(U32) pKey);
	hasho_dump_DebugString("add:Key",pKey,pstHASHOINFO->usKeyLen);
	hasho_dump_DebugString("add:Data",pData,pstHASHOINFO->usDataLen);
#endif
	if( (p=(stHASHONODE *)hasho_find(pstHASHOINFO,pKey)) ){
		return NULL;
	}
	p = (stHASHONODE *)memg_alloc((stMEMGINFO *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_memginfo)
				,stHASHONODE_SIZE + pstHASHOINFO->usKeyLen + pstHASHOINFO->usDataLen
				,(char *) __FUNCTION__);
	if(p){
		bzero(p,stHASHONODE_SIZE
						+ pstHASHOINFO->usKeyLen
						+ pstHASHOINFO->usDataLen);
		p->offset_Key  =  HASHO_OFFSET(pstHASHOINFO, p + 1);
		memcpy(HASHO_PTR(pstHASHOINFO, p->offset_Key) , pKey , pstHASHOINFO->usKeyLen);
		p->offset_Data = p->offset_Key + pstHASHOINFO->usKeyLen;
		memcpy(HASHO_PTR(pstHASHOINFO, p->offset_Data) , pData , pstHASHOINFO->usDataLen);
		p->offset_next = 0;
		p->offset_prev = 0;
		hasho_link_node(pstHASHOINFO,p);
	} 
	return p;
}

/** 기본 hash function : hasho_del function. 
 *
 * NODE를 HASH에서 지운다. 
 * 
 * @param *pstHASHOINFO	: HASH 관리자 
 * @param *pKey 	:	node Key Pointer
 *
 *  @return     Key , Data의 새로 생성된 node pointer
 *  @see        hash.h
 *
 *  @exception  규칙에 틀린 곳을 찾아주세요.
 *  @note       **prev 주의
 **/
void 
hasho_del(stHASHOINFO *pstHASHOINFO, U8 *pKey)
{
	stHASHONODE *p;
#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : pstHASHONODE = 0x%x\n",__FUNCTION__,(U32) pKey);
	hasho_dump_DebugString(__FUNCTION__,pKey,pstHASHOINFO->usKeyLen);
#endif
	if(!(p=hasho_find(pstHASHOINFO,pKey))) return ;
	hasho_unlink_node(pstHASHOINFO,p);
	memg_free((stMEMGINFO *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_memginfo) ,(U8 *)p);
	return;
}


/** 기본 hash function : hasho_print_info function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstHASHOINFO	: HASH 관리자 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       앞에는 prefix string을 넣어줌 (_%s)
 **/
void
hasho_print_info(S8 *pcPrtPrefixStr,stHASHOINFO *pstHASHOINFO)
{
	stHASHOINFO_Prt(pcPrtPrefixStr,pstHASHOINFO);
}

/** 기본 hash function : hasho_print_node function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstHASHOINFO	: HASH 관리자 pointer
 * @param *pstHASHONODE	: HASH NODE pointer
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       앞에는 prefix string을 넣어줌 (_%s)
 **/
void
hasho_print_node(S8 *pcPrtPrefixStr,stHASHOINFO *pstHASHOINFO,stHASHONODE *pstHASHONODE)
{
	stHASHONODE_Prt(pcPrtPrefixStr,pstHASHONODE);
	hasho_dump_DebugString("KEY",HASHO_PTR(pstHASHOINFO, pstHASHONODE->offset_Key),pstHASHOINFO->usKeyLen);
	hasho_dump_DebugString("DATA",HASHO_PTR(pstHASHOINFO, pstHASHONODE->offset_Data),pstHASHOINFO->usDataLen);
}

/** 기본 hash function : hasho_print_all function. 
 *
 * HASH안의 모든 data를 찍어준다.
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstHASHOINFO	: HASH 관리자 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       앞에는 prefix string을 넣어줌 (_%s)
 **/
void
hasho_print_all(S8 *pcPrtPrefixStr,stHASHOINFO *pstHASHOINFO)
{
	U32	iIndex;
	stHASHONODE *p;
	stMEMGINFO *pstMEMGINFO;
	OFFSET pOff,*pNodeHead;

	pstMEMGINFO = (stMEMGINFO *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_memginfo);
	FPRINTF(LOG_LEVEL,"%s : pstHASHOINFO=0x%08x , p->psthashnode=0x%08x\n",__FUNCTION__,(U32) pstHASHOINFO,(U32) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode));
	FPRINTF(LOG_LEVEL,"pstMEMGINFO->uiMemNodeTotCnt = %d\n",pstMEMGINFO->uiMemNodeTotCnt);
	FPRINTF(LOG_LEVEL,"pstMEMGINFO->uiMemNodeAllocedCnt = %d\n",pstMEMGINFO->uiMemNodeAllocedCnt);
	hasho_print_info(pcPrtPrefixStr,pstHASHOINFO);
	for(iIndex=0;iIndex < pstHASHOINFO->uiHashSize;iIndex++){
		pNodeHead = (OFFSET *) (((OFFSET *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) + iIndex);
		
		if(*pNodeHead){
			FPRINTF(LOG_LEVEL,"##%s : %s : [%3d] location : 0x%08x , valuep=%d\n"
					,pcPrtPrefixStr
					,__FUNCTION__,iIndex,
					(U32) (((U32 *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) + iIndex),
					*(((U32 *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) + iIndex));
			pOff = (OFFSET) *pNodeHead;
			while(pOff){
				p = (stHASHONODE *) HASHO_PTR(pstHASHOINFO, pOff);
				FPRINTF(LOG_LEVEL,"##%s : [%3d] p=0x%x , p offset=%d\n",__FUNCTION__,iIndex,(U32) p,(U32) HASHO_OFFSET(pstHASHOINFO, p));
				stHASHONODE_Prt(pcPrtPrefixStr,p);
				hasho_dump_DebugString("## : KEY",(U8 *) HASHO_PTR(pstHASHOINFO, p->offset_Key),pstHASHOINFO->usKeyLen);
				/* hasho_print_node(pstHASHOINFO,p); */
				pOff = p->offset_next;
			}
		}
	}
}

/** 기본 hash function : hasho_get_occupied_node_count function. 
 *
 * HASH안에서 딸린 node가 있는 수를 return해준다.
 * 
 * @param *pstHASHOINFO	: HASH 관리자 
 *
 *  @return     U32
 *  @see        hash.h
 **/
U32	hasho_get_occupied_node_count(stHASHOINFO *pstHASHOINFO)
{
	U32	iIndex;
	stHASHONODE *p;
	stMEMGINFO *pstMEMGINFO;
	U32	occupied_hash_cnt=0;
	U32	tot_node_cnt=0;
	OFFSET pOff,*pNodeHead;

	pstMEMGINFO = (stMEMGINFO *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_memginfo);
	FPRINTF(LOG_LEVEL,"pstMEMGINFO->uiMemNodeTotCnt = %d\n",pstMEMGINFO->uiMemNodeTotCnt);
	FPRINTF(LOG_LEVEL,"pstMEMGINFO->uiMemNodeAllocedCnt = %d\n",pstMEMGINFO->uiMemNodeAllocedCnt);
	for(iIndex=0;iIndex < pstHASHOINFO->uiHashSize;iIndex++){
		pNodeHead = (OFFSET *) (((OFFSET *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) + iIndex);
		if(*pNodeHead){ 
			occupied_hash_cnt++; 
			pOff = (OFFSET) *pNodeHead;
			while(pOff){
				tot_node_cnt ++;
				p = (stHASHONODE *) HASHO_PTR(pstHASHOINFO, pOff);
				pOff = p->offset_next;
			}
		}
	}
	FPRINTF(LOG_LEVEL,"%s : tot_node_cnt %d , uiHashSize=%d , occupied_hash_cnt=%d  (%d %%)\n",
			__FUNCTION__,
			tot_node_cnt,
			(U32) pstHASHOINFO->uiHashSize,
			(U32) occupied_hash_cnt, 
			(occupied_hash_cnt / pstHASHOINFO->uiHashSize) * 100 );
	return occupied_hash_cnt;
}


/** 기본 hash function : hasho_draw_all function. 
 *
 * HASH안의 모든 data를 찍어준다.
 * 
 * @param *filename	:  Write할 filename
 * @param *labelname	: label명  
 * @param *pstHASHOINFO	: HASH 관리자 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       개개의 파일로 생성된다. 
 **/
void
hasho_draw_all(S8 *filename,S8 *labelname,stHASHOINFO *pstHASHOINFO)
{
	U32	iIndex;
	stHASHONODE *p;
	stMEMGINFO *pstMEMGINFO;
	FILE *fp;
	OFFSET pOff,*pNodeHead;

	pstMEMGINFO = (stMEMGINFO *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_memginfo);
	fp = fopen(filename,"w");
	FPRINTF(fp,"/** @file %s\n",filename);
	FPRINTF(fp,"pstHASHOINFO->uiHashSize = %d \\n\n",pstHASHOINFO->uiHashSize);
	FPRINTF(fp,"pstMEMGINFO->uiMemNodeTotCnt = %d \\n\n",pstMEMGINFO->uiMemNodeTotCnt);
	FPRINTF(fp,"pstMEMGINFO->uiMemNodeAllocedCnt = %d \\n\n",pstMEMGINFO->uiMemNodeAllocedCnt);
	FPRINTF(fp,"\\dot \n	\
	digraph G{ 	\n\
	fontname=Helvetica; 	\n\
	label=\"Hash Table(%s)\"; 	\n\
	nodesep=.05; 	\n\
	rankdir=LR; 	\n\
	node [fontname=Helvetica,shape=record,width=.1,height=.1]; 	\n\
	node0 [label = \"",labelname);
	for(iIndex=0;iIndex < pstHASHOINFO->uiHashSize;iIndex++){
		if(iIndex == (pstHASHOINFO->uiHashSize -1)){
			FPRINTF(fp,"<f%d> %d ",iIndex,iIndex);
		} else {
			FPRINTF(fp,"<f%d> %d| ",iIndex,iIndex);
		}
	}
	FPRINTF(fp,"\",height = 2.5];\n");
	FPRINTF(fp,"node [width=1.5];\n");
	for(iIndex=0;iIndex < pstHASHOINFO->uiHashSize;iIndex++){
		pNodeHead = (OFFSET *) (((OFFSET *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) + iIndex);
		pOff = (OFFSET) *pNodeHead;
		while(pOff){
			p = (stHASHONODE *) HASHO_PTR(pstHASHOINFO, pOff);
			FPRINTF(fp,"N0x%08x [label = \"{ <n> 0x%08x | %3d\\ %d | <p> }\"];\n",(U32) p, (U32) p,iIndex,pOff);
			pOff = p->offset_next;
		}
	}
	FPRINTF(fp,"\n\n");
	for(iIndex=0;iIndex < pstHASHOINFO->uiHashSize;iIndex++){
		pNodeHead = (OFFSET *) (((OFFSET *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) + iIndex);
		pOff = (OFFSET) *pNodeHead;
		if(pOff){
			p = (stHASHONODE *) HASHO_PTR(pstHASHOINFO, pOff);
			FPRINTF(fp,"node0:f%d -> N0x%08x:n;\n",iIndex,(U32) p);
		}
		while(pOff){
			p = (stHASHONODE *) HASHO_PTR(pstHASHOINFO, pOff);
			pOff = p->offset_next;
			if(pOff){
			   	FPRINTF(fp,"N0x%08x:p -> N0x%08x:n;\n",(U32) p , (U32) HASHO_PTR(pstHASHOINFO, p->offset_next));
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

#define SHM_KEY_TEST	8000

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
int
main(int argc, char *argv[])
{
	stHASHOINFO *pstHASHOINFO;
	stKEY  stKey;
	stDATA  stData;
	char 	s[BUFSIZ];


	stKey.a = '0';
	stKey.b = '1';
	stKey.c = 0x01;
	stKey.d = 0x03;
	stData.a = '0';
	stData.b = '1';
	stData.c = '2';
	stData.d = '3';
	
	if (argc > 1) {
		if (strcmp (argv [1], "shm") != 0) {
			fprintf (stderr,"hasho main memory use!!\n");
			pstHASHOINFO = hasho_init(0 /**< maim memory */, sizeof(stKEY), sizeof(stKEY), sizeof(stDATA), 4 /**< hash size */, 0);
		} else {
			fprintf (stderr, "hasho shared memory use!!\n");
			pstHASHOINFO = hasho_init(SHM_KEY_TEST /**< shared memory key */, sizeof(stKEY), sizeof(stKEY), sizeof(stDATA), 4 /**< hash size */, 0);
		}
	} else 
		pstHASHOINFO = hasho_init(0 /**< maim memory */, sizeof(stKEY), sizeof(stKEY), sizeof(stDATA), 4 /**< hash size */, 0);
	
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_01.TXT",s,pstHASHOINFO);

	stKey.d = 0x04;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_02.TXT",s,pstHASHOINFO);

	stKey.d = 0x07;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_03.TXT",s,pstHASHOINFO);

	stKey.c = 0x03;
	stKey.d = 0x04;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_04.TXT",s,pstHASHOINFO);

	stKey.c = 0x0d;
	stKey.d = 0x04;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_05.TXT",s,pstHASHOINFO);

	stKey.c = 0x0d;
	stKey.d = 0x0e;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"insert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_06.TXT",s,pstHASHOINFO);

	hasho_del(pstHASHOINFO,(U8 *)&stKey);
	sprintf(s,"delete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_07.TXT",s,pstHASHOINFO);

	stKey.a = '0';
	stKey.b = '1';
	stKey.c = 0x01;
	stKey.d = 0x03;
	hasho_del(pstHASHOINFO,(U8 *)&stKey);
	sprintf(s,"delete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_08.TXT",s,pstHASHOINFO);

	/* 3 hash에 node를 한개 붙였다 없앤다. */
	stKey.a = '0';
	stKey.b = '1';
	stKey.c = 0x01;
	stKey.d = 0x01;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"Newinsert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_09.TXT",s,pstHASHOINFO);

	hasho_del(pstHASHOINFO,(U8 *)&stKey);
	sprintf(s,"Newdelete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_10.TXT",s,pstHASHOINFO);

	/* 3 hash에 node를  3개 붙인다. */
	stKey.d = 9;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"Newinsert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_11.TXT",s,pstHASHOINFO);
	stKey.d = 5;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"Newinsert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_12.TXT",s,pstHASHOINFO);
	stKey.d = 1;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"Newinsert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_13.TXT",s,pstHASHOINFO);

	/* 3 hash에 마지막 노드를 없앤다. */
	stKey.d = 9;
	hasho_del(pstHASHOINFO,(U8 *)&stKey);
	sprintf(s,"Newdelete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_14.TXT",s,pstHASHOINFO);

	/* 3 hash에 node 2를 잡입하여 4개를 만든다. */
	stKey.d = 13;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"Newinsert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_15.TXT",s,pstHASHOINFO);
	stKey.d = 17;
	hasho_add(pstHASHOINFO,(U8 *)&stKey,(U8 *)&stData);
	sprintf(s,"Newinsert %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_16.TXT",s,pstHASHOINFO);

	/* 3 hash의 중간 노를 없앤다. */
	stKey.d = 13;
	hasho_del(pstHASHOINFO,(U8 *)&stKey);
	sprintf(s,"Newdelete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_17.TXT",s,pstHASHOINFO);

	/* 3 hash의 맨 앞 노드를 없앤다. */
	stKey.d = 17;
	hasho_del(pstHASHOINFO,(U8 *)&stKey);
	sprintf(s,"Newdelete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_18.TXT",s,pstHASHOINFO);
	return 0;
}
#endif /* TEST */

/** file hash.c
 *     $Log: hasho.c,v $
 *     Revision 1.16  2006/11/27 07:45:39  cjlee
 *     doxygen
 *
 *     Revision 1.15  2006/11/08 03:32:54  cjlee
 *     *** empty log message ***
 *
 *     Revision 1.14  2006/11/08 01:37:48  cjlee
 *     *** empty log message ***
 *
 *     Revision 1.13  2006/11/08 01:36:33  cjlee
 *     no message
 *
 *     Revision 1.12  2006/11/08 01:16:22  cjlee
 *     *** empty log message ***
 *
 *     Revision 1.11  2006/11/07 08:26:13  cjlee
 *     hasho default 함수 변경
 *
 *     Revision 1.10  2006/11/07 07:52:52  cjlee
 *     달린 node 갯수 세기
 *           -  U32 hasho_get_occupied_node_count(stHASHOINFO *pstHASHOINFO) 추가
 *
 *     Revision 1.9  2006/11/07 07:20:03  cjlee
 *     - hasho_init(U32 uiShmKey, U16 usKeyLen, U16 usSortKeyLen, U16 usDataLen, U32 uiHashSize, U32 (*func)(void*,U8*))
 *          으로써  hash_func을 등록하게 하였음.
 *          이 hash function은 각 process안에서만 사용되어진다.
 *          static으로 선언함.
 *          func == 0 일때는 hasho_func_default() 을 사용하게 됨.
 *
 *     Revision 1.8  2006/10/12 07:34:01  dark264sh
 *     lib 생성시 FPRINTF(LOG_LEVEL, 처리로 변경
 *
 *     Revision 1.7  2006/08/09 00:55:15  cjlee
 *     MEMG_PTR의 argument 변경
 *
 *     Revision 1.6  2006/06/19 01:30:16  mungsil
 *     hasho.h 파일의 HASHO_PTR, HASHO_OFFSET 변경에 대한 소스 수정
 *
 *     Revision 1.5  2006/06/09 02:29:33  cjlee
 *     hasho_print_all에서 node없는 것은 안찍어주게 수정
 *
 *     Revision 1.4  2006/04/26 08:33:31  yhshin
 *     SHM_KEY_TEST 변경
 *
 *     Revision 1.3  2006/04/26 08:29:08  yhshin
 *     test 변경
 *
 *     Revision 1.2  2006/04/26 08:26:41  yhshin
 *     hasho_init 변경
 *
 *     Revision 1.1  2006/04/21 02:19:49  cjlee
 *     INIT
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
