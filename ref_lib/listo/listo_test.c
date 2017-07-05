
#include <stdio.h>
#include <stdlib.h>
#include "listo.h"


typedef struct _st_Buf {
    list_head    	head;
    void    		*p;
} st_Buf;

int main(void)
{
    int 			i;
    st_Buf  		*pstBuf;			/* �ӽ� buffer ����Ʈ Tmp */
    st_Buf  		*pstHead;					/* list Header point */
    list_head 		*p;					/* �ӽ� list_head ����Ʈ */
	st_Buf			stList[100];			/* linked list �޸� */

	pstHead = &stList[10];

    INIT_LIST_HEAD(stList, &pstHead->head);

    pstHead->p = (char *)malloc(10);
    sprintf((char *)pstHead->p, "Test 0");
printf("head[%d][%d][%d]\n", pstHead->head.offset_prev, listo_offset(stList, &pstHead->head), pstHead->head.offset_next);
    for(i = 0; i < 10; i++)
    {
        pstBuf = &stList[50-i];

        pstHead = (st_Buf *)list_add_tail(stList, &pstBuf->head, &pstHead->head);

printf("t1[%d][%d][%d]\n", pstHead->head.offset_prev, listo_offset(stList, &pstHead->head), pstHead->head.offset_next);
printf("t2[%d][%d][%d]\n", pstBuf->head.offset_prev, listo_offset(stList, &pstBuf->head), pstBuf->head.offset_next);
        pstBuf->p = (char *)malloc(10);

        sprintf(pstBuf->p, "Test %d", i + 1);

    }

	/* 
	 * Print Values 
	 * list_for_each, list_entry ��� ����
	 */
    list_for_each(stList, p, &pstHead->head) {
        pstBuf = list_entry(p, st_Buf, head);
        printf("@ [%s]\n", (char *)pstBuf->p);
    }
    return 1;
}

