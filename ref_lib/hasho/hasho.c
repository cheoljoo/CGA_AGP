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
 *     @warning     ���⼭�� pointer�� ����Ҽ� ���� ������ , hash function�� link�Ͽ� ����� ���� ����. 
 *     				�׳� �Ϲ����� �� �Ѱ��� ���ؾ� �� ���̴�.  
 *     @todo        �ϴ� hash�� �������� �̿��Ҽ� �ְ� �ϴ°� ��ǥ�̴�. src�� �ٲٸ� �ȵȴ�. 
 *     				offset������ pointer ���� 2������ ��������� �Ѵ�.
 *
 *     @section     Intro(�Ұ�)
 *      - hash library ����  (offset�������� �ۼ�)
 *      - hasho_init���� �ʱ�ָ� ���Ŀ� �⺻���� primitives �� �̿��ϰ� ��
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
 *      - Hasho ����  (v1.1) 
 *      ��Ģ 0 : memg�ȿ����� offset�� pstMEMGINFO ���������� offset��.
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
 *                 |    ��Ģ : hasho �� offset�� pstHASHOINFO���������� offset�� �ǹ���.
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
 *       offset ���� : 
 *       pstMEMGINFO      -> stMEMGINFO ����  offset ��
 *       pstHASHOINFO     -> stHASHOINFO , stHASHONODE ���� offset �� 
@endcode
 *
 *
 *
 *     @section     Requirement
 *      @li ��Ģ�� Ʋ�� ���� ã���ּ���.
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



/** �⺻ hash function : hasho_func_default function. 
 *
 * func�� user�� ���ؼ� �־����� �ʾ��� ��� �⺻������ ���ԵǴ� hash function.
 * 
 *
 * @param *pa	: HASH ������ (stHASHOINFO *)
 * @param *pb	:  pstHASHONODE->pstKey �� pointer (���� �𸣴� char�� ����) 
 *
 *  @return     U32 	Hash Array�� index�� ����Ų��.  
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       C++�� STL�� ó���ϸ� �󸶳� ���ұ� �ϴ� ������ ���.
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


/** �ʱ�ȭ �Լ� : hasho_init function. 
 *
 *  �ʱ�ȭ �Լ� 
 *
 * @param uiShmKey  	: Shared Memory Key Value (0: local memory ���)
 * @param usKeyLen  	: key�� byte��
 * @param usSortKeyLen  	: sort�� ���� key�� byte��
 * @param usDataLen  	: Data�� byte��
 * @param uiHashSize  	: open hash�� array size (open hashũ��) 
 * @param func  		: function pointer (hash function)
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       ���� Shared Memory�ȿ� �ִ� �͵� ���� �� ��. mem ���� �κ��� �߰� �Ǿ����� ��.
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
					,uiHashSize * 10);  /* �׽� 10�� �ƴҼ� ����. ��ȭ ���� */

	} else {
		pstMEMGINFO = memg_init(MEMG_SHARED_MEM
					,uiShmKey
					,sizeof(stHASHOINFO) + (uiHashSize * sizeof(char *))
					,stHASHONODE_SIZE + usKeyLen + usDataLen
					,uiHashSize * 10);  /* �׽� 10�� �ƴҼ� ����. ��ȭ ���� */
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


/** �⺻ hash function : hasho_link_node function. 
 *
 * NODE�� HASH�� �����Ѵ�.  (head�� �ٷ� ������ ���δ�.)
 * 
 *
 * @param *pstHASHOINFO	: HASH ������ 
 * @param *p	: ������ node�� pointer 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **pp�� *psthashnode[100] ����  pp = &psthashnode[1]�� ���� ó���ϱ� ������ \n
 **/
void 
hasho_link_node(stHASHOINFO *pstHASHOINFO , stHASHONODE *p)
{
	OFFSET 	*pNodeHead; 	/**< pNodeHead : head list���� index�� �´� �� */
	stHASHONODE *pNodeNext; /**< pNodeNext : head list�� �޷��ִ� ù��° node pointer */

#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : pstHASHONODE = 0x%x\n",__FUNCTION__,(U32) p);
#endif
	pNodeHead = ((S32 *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) 
			+ hasho_func(pstHASHOINFO, (U8 *) HASHO_PTR(pstHASHOINFO, p->offset_Key)) ;

	if(*pNodeHead){ /* NODE �� �پ� �ִٸ� */
		pNodeNext = (stHASHONODE *) HASHO_PTR(pstHASHOINFO, *pNodeHead);
		p->offset_prev = pNodeNext->offset_prev; /* maybe NULL */
		pNodeNext->offset_prev = HASHO_OFFSET(pstHASHOINFO, p);
		p->offset_next = *pNodeHead;
		*pNodeHead = HASHO_OFFSET(pstHASHOINFO, p);
	} else { /* NODE �� �ϳ��� ������ */
		*pNodeHead = HASHO_OFFSET(pstHASHOINFO, p);
	}

	return;
}

/** �⺻ hash function : hasho_unlink_node function. 
 *
 * NODE�� HASH���� �����. 
 * 
 *
 * @param *pstHASHOINFO	: HASH ������ 
 * @param *p	: ���� node�� pointer
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       prev , next�� offset
 **/
void 
hasho_unlink_node(stHASHOINFO *pstHASHOINFO, stHASHONODE *p)
{
	S32 	*pNodeHead; 	/**< pNodeHead : head list���� index�� �´� �� */
	stHASHONODE *pNodeNext; /**< HASHO_PTR( pNodeNext : p->offset_next ) */
	stHASHONODE *pNodePrev; /**< HASHO_PTR( pNodePrev : p->offset_prev ) */

#ifdef DEBUG
	FPRINTF(LOG_LEVEL,"%s : pstHASHONODE = %d\n",__FUNCTION__,(U32) p);
#endif
	pNodeHead = ((S32 *) HASHO_PTR(pstHASHOINFO, pstHASHOINFO->offset_psthashnode)) 
			+ hasho_func(pstHASHOINFO, (U8 *) HASHO_PTR(pstHASHOINFO, p->offset_Key)) ;
	pNodeNext = (stHASHONODE *) HASHO_PTR(pstHASHOINFO,  p->offset_next );
	pNodePrev = (stHASHONODE *) HASHO_PTR(pstHASHOINFO,  p->offset_prev );

	if(p->offset_prev){ 	/* ù��° node�� �ƴҶ� */
		pNodePrev->offset_next = p->offset_next;
	} else {	/* ù��° node�϶� */
		*pNodeHead = p->offset_next;
	}
	if(p->offset_next){ 	/* ������ node�� �ƴҶ� */
		pNodeNext->offset_prev = p->offset_prev;
	} else {	/* ������ node�϶� */
		/* NOTHING */
	}
	return;
}


/** �⺻ hash function : hasho_find function. 
 *
 * NODE�� HASH���� �����. 
 * 
 * @param *pstHASHOINFO	: HASH ������ 
 * @param *pKey	: Key pointer
 *
 *  @return     stHASHONODE  (ã���� node pointer)
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
 **/
stHASHONODE *
hasho_find(stHASHOINFO *pstHASHOINFO, U8 *pKey)
{
	OFFSET 	*pNodeHead; 	/**< pNodeHead : head list���� index�� �´� �� */
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


/** �⺻ hash function : hasho_add function. 
 *
 * NODE�� HASH���� �����. 
 * 
 * @param *pstHASHOINFO	: HASH ������ 
 * @param *pKey 	:	node Key Pointer
 * @param *pData	:	node Data Pointer
 *
 *  @return     Key , Data�� ���� ������ node pointer
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
 *  			NODE���� Key�� Data�� Size��ŭ�� �Ѳ����� �Ҵ��Ѵ�.
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

/** �⺻ hash function : hasho_del function. 
 *
 * NODE�� HASH���� �����. 
 * 
 * @param *pstHASHOINFO	: HASH ������ 
 * @param *pKey 	:	node Key Pointer
 *
 *  @return     Key , Data�� ���� ������ node pointer
 *  @see        hash.h
 *
 *  @exception  ��Ģ�� Ʋ�� ���� ã���ּ���.
 *  @note       **prev ����
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


/** �⺻ hash function : hasho_print_info function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstHASHOINFO	: HASH ������ 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
hasho_print_info(S8 *pcPrtPrefixStr,stHASHOINFO *pstHASHOINFO)
{
	stHASHOINFO_Prt(pcPrtPrefixStr,pstHASHOINFO);
}

/** �⺻ hash function : hasho_print_node function. 
 *
 * INFO print
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstHASHOINFO	: HASH ������ pointer
 * @param *pstHASHONODE	: HASH NODE pointer
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
 **/
void
hasho_print_node(S8 *pcPrtPrefixStr,stHASHOINFO *pstHASHOINFO,stHASHONODE *pstHASHONODE)
{
	stHASHONODE_Prt(pcPrtPrefixStr,pstHASHONODE);
	hasho_dump_DebugString("KEY",HASHO_PTR(pstHASHOINFO, pstHASHONODE->offset_Key),pstHASHOINFO->usKeyLen);
	hasho_dump_DebugString("DATA",HASHO_PTR(pstHASHOINFO, pstHASHONODE->offset_Data),pstHASHOINFO->usDataLen);
}

/** �⺻ hash function : hasho_print_all function. 
 *
 * HASH���� ��� data�� ����ش�.
 * 
 * @param *pcPrtPrefixStr	: print prefix string
 * @param *pstHASHOINFO	: HASH ������ 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       �տ��� prefix string�� �־��� (_%s)
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

/** �⺻ hash function : hasho_get_occupied_node_count function. 
 *
 * HASH�ȿ��� ���� node�� �ִ� ���� return���ش�.
 * 
 * @param *pstHASHOINFO	: HASH ������ 
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


/** �⺻ hash function : hasho_draw_all function. 
 *
 * HASH���� ��� data�� ����ش�.
 * 
 * @param *filename	:  Write�� filename
 * @param *labelname	: label��  
 * @param *pstHASHOINFO	: HASH ������ 
 *
 *  @return     void
 *  @see        hash.h
 *
 *  @note       ������ ���Ϸ� �����ȴ�. 
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

	/* 3 hash�� node�� �Ѱ� �ٿ��� ���ش�. */
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

	/* 3 hash�� node��  3�� ���δ�. */
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

	/* 3 hash�� ������ ��带 ���ش�. */
	stKey.d = 9;
	hasho_del(pstHASHOINFO,(U8 *)&stKey);
	sprintf(s,"Newdelete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_14.TXT",s,pstHASHOINFO);

	/* 3 hash�� node 2�� �����Ͽ� 4���� �����. */
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

	/* 3 hash�� �߰� �븦 ���ش�. */
	stKey.d = 13;
	hasho_del(pstHASHOINFO,(U8 *)&stKey);
	sprintf(s,"Newdelete %c %c %d %d",stKey.a,stKey.b,stKey.c,stKey.d);
	hasho_print_all(s,pstHASHOINFO);
	hasho_draw_all("TEST_RESULT_17.TXT",s,pstHASHOINFO);

	/* 3 hash�� �� �� ��带 ���ش�. */
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
 *     hasho default �Լ� ����
 *
 *     Revision 1.10  2006/11/07 07:52:52  cjlee
 *     �޸� node ���� ����
 *           -  U32 hasho_get_occupied_node_count(stHASHOINFO *pstHASHOINFO) �߰�
 *
 *     Revision 1.9  2006/11/07 07:20:03  cjlee
 *     - hasho_init(U32 uiShmKey, U16 usKeyLen, U16 usSortKeyLen, U16 usDataLen, U32 uiHashSize, U32 (*func)(void*,U8*))
 *          ���ν�  hash_func�� ����ϰ� �Ͽ���.
 *          �� hash function�� �� process�ȿ����� ���Ǿ�����.
 *          static���� ������.
 *          func == 0 �϶��� hasho_func_default() �� ����ϰ� ��.
 *
 *     Revision 1.8  2006/10/12 07:34:01  dark264sh
 *     lib ������ FPRINTF(LOG_LEVEL, ó���� ����
 *
 *     Revision 1.7  2006/08/09 00:55:15  cjlee
 *     MEMG_PTR�� argument ����
 *
 *     Revision 1.6  2006/06/19 01:30:16  mungsil
 *     hasho.h ������ HASHO_PTR, HASHO_OFFSET ���濡 ���� �ҽ� ����
 *
 *     Revision 1.5  2006/06/09 02:29:33  cjlee
 *     hasho_print_all���� node���� ���� ������ְ� ����
 *
 *     Revision 1.4  2006/04/26 08:33:31  yhshin
 *     SHM_KEY_TEST ����
 *
 *     Revision 1.3  2006/04/26 08:29:08  yhshin
 *     test ����
 *
 *     Revision 1.2  2006/04/26 08:26:41  yhshin
 *     hasho_init ����
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
