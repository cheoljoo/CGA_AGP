
#include <stdio.h>
#include <stdlib.h>
#include "clisto.h"


typedef struct _st_Buf {
    clist_head    	head;
    void    		*p;
} st_Buf;

int main(void)
{
    int 			i;
    st_Buf  		*pstBuf;			/* 임시 buffer 포인트 Tmp */
    st_Buf  		*pstHead;					/* list Header point */
    clist_head 		*p;					/* 임시 list_head 포인트 */
	st_Buf			stList[100];			/* linked list 메모리 */

	pstHead = &stList[10];

    CINIT_LIST_HEAD(stList, &pstHead->head);

    pstHead->p = (char *)malloc(10);
    sprintf((char *)pstHead->p, "Test 0");
	printf("start head[%d][%d][%d]\n", 
		pstHead->head.offset_prev, clisto_offset(stList, &pstHead->head), pstHead->head.offset_next);
    for(i = 0; i < 10; i++)
    {
        pstBuf = &stList[50-i];

        pstHead = clist_add_tail(stList, &pstBuf->head, &pstHead->head);

        //pstHead = clist_add_head(stList, &pstBuf->head, &pstHead->head);

		printf("head[%d][%d][%d]\n", 
			pstHead->head.offset_prev, clisto_offset(stList, &pstHead->head), pstHead->head.offset_next);
		printf("node[%d][%d][%d]\n", 
			pstBuf->head.offset_prev, clisto_offset(stList, &pstBuf->head), pstBuf->head.offset_next);
        pstBuf->p = (char *)malloc(10);

        sprintf(pstBuf->p, "Test %d", i + 1);

    }

	/* 
	 * Print Values 
	 * list_for_each, list_entry 사용 예제
	 */
    clist_for_each_start(stList, p, &pstHead->head) {
        pstBuf = clist_entry(p, st_Buf, head);
        printf("@ [%s]\n", (char *)pstBuf->p);
    } clist_for_each_end(stList, p, &pstHead->head)
    return 1;
}

