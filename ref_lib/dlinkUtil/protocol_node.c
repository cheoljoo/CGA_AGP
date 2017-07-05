/*
	$Id: protocol_node.c,v 1.2 2007/02/09 00:18:55 yhshin Exp $
*/

#include <stdlib.h>

#include "dlink.h"
#include "protocol_node.h"
#include "param_node.h"

void
protocol_node_init (pnode_t *pnode)
{
	pnode->pos = 0;
	pnode->len = 0;
	pnode->msg_type = 0xffffffff;

	pnode->upper_proto = 0x00;
	pnode->upper_buf = NULL;
	pnode->upper_len = 0;

	pnode->sibling.next = &pnode->sibling;
	pnode->sibling.prev = &pnode->sibling;

	pnode->child.next = &pnode->child;
	pnode->child.prev = &pnode->child;
}


pnode_t *
protocol_node_alloc(int data_size)
{
	pnode_t	*node;

	node = (pnode_t *)malloc(sizeof(pnode_t));
	if (node == NULL) {
		return(NULL);
	}

	node->sibling.next = &(node->sibling);
	node->sibling.prev = &(node->sibling);
	node->child.next = &(node->child);
	node->child.prev = &(node->child);

	return(node);
}

void
protocol_node_free(pnode_t *node)
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
	$Log: protocol_node.c,v $
	Revision 1.2  2007/02/09 00:18:55  yhshin
	source Á¤¸®
	
	Revision 1.1  2007/02/06 23:20:00  yhshin
	dlink util
	
*/
