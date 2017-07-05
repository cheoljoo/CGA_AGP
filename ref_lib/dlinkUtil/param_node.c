/*
	$Id: param_node.c,v 1.3 2007/03/17 09:46:25 yhshin Exp $
*/

#include <stdlib.h>

#include "dlink.h"
#include "param_node.h"

param_node_t *
param_node_alloc(int data_size)
{
	param_node_t	*node;
	int				aligned_size;

	aligned_size = ((data_size+3)/4)*4;

	node = (param_node_t *)malloc(sizeof(param_node_t) + aligned_size);
	if (node == NULL) {
		return(NULL);
	}

	node->sibling.next = &node->sibling;
	node->sibling.prev = &node->sibling;
	node->child.next = &node->child;
	node->child.prev = &node->child;

	node->pos = 0;
	node->len = 0;
	node->size = 0;

	return(node);
}

void
param_node_free(param_node_t *node)
{
	dlink_t		*item;

	while (!DLINK_EMPTY(&(node->child))) {
		item = node->child.next;
		dlink_dq(item);
		param_node_free((param_node_t *)item);
	}
	free(node);
}

/*
	$Log: param_node.c,v $
	Revision 1.3  2007/03/17 09:46:25  yhshin
	*** empty log message ***
	
	Revision 1.2  2007/02/09 00:18:30  yhshin
	source 정리
	
	Revision 1.1  2007/02/06 23:20:00  yhshin
	dlink util
	
	Revision 1.2  2006/11/15 01:43:08  tjryu
	메모리 할당시 aligned 크기 계산 오류 수정
	
	Revision 1.1  2006/11/09 01:30:33  tjryu
	RANAP decoding utility added
	
*/
