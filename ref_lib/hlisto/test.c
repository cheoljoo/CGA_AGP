
#include <stdio.h>
#include <stdlib.h>
#include "hlisto.h"


typedef struct _st_Buf {
    hlist_head    	head;
    void    		*p;
} st_Buf;

int main(void)
{
    int 			i;
    st_Buf  		*pstBuf;			/* �ӽ� buffer ����Ʈ Tmp */
    st_Buf  		*pstHead;					/* list Header point */
    hlist_head 		*p;					/* �ӽ� list_head ����Ʈ */
	st_Buf			stList[100];			/* linked list �޸� */

	pstHead = &stList[10];

    HINIT_LIST_HEAD(stList, &pstHead->head);

    pstHead->p = (char *)malloc(10);
    sprintf((char *)pstHead->p, "Test 0");
	printf("start head[%d][%d][%d]\n", 
		pstHead->head.offset_prev, hlisto_offset(stList, &pstHead->head), pstHead->head.offset_next);
    for(i = 0; i < 10; i++)
    {
        pstBuf = &stList[50-i];

        hlist_add_tail(stList, &pstBuf->head, &pstHead->head);

        //hlist_add_head(stList, &pstBuf->head, &pstHead->head);

		printf("head[%d][%d][%d]\n", 
			pstHead->head.offset_prev, hlisto_offset(stList, &pstHead->head), pstHead->head.offset_next);
		printf("node[%d][%d][%d]\n", 
			pstBuf->head.offset_prev, hlisto_offset(stList, &pstBuf->head), pstBuf->head.offset_next);
        pstBuf->p = (char *)malloc(10);

        sprintf(pstBuf->p, "Test %d", i + 1);

    }

	/* 
	 * Print Values 
	 * list_for_each, list_entry ��� ����
	 */
    hlist_for_each(stList, p, &pstHead->head) {
        pstBuf = hlist_entry(p, st_Buf, head);
        printf("@ [%s]\n", (char *)pstBuf->p);
    }
    return 1;
}

