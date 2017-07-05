/*
	$Id: proot.c,v 1.2 2007/02/09 00:18:44 yhshin Exp $
*/

#include <stdio.h>
#include <stdlib.h>

#include "dlink.h"
#include "proot.h"
#include "protocol_node.h"

void
proot_node_init (proot_t *pnode)
{
	pnode->pos = 0;
	pnode->len = 0;
	sprintf (pnode->desc, "AB Protocol Version 1.0");

	pnode->child.next = &pnode->child;
	pnode->child.prev = &pnode->child;
}

void
proot_node_free (proot_t *pnode)
{
	dlink_t			*item;

	while (!DLINK_EMPTY (&pnode->child)) {
		item = pnode->child.next;
		dlink_dq(item);
		protocol_node_free ((pnode_t *)item);
	}
	proot_node_init(pnode);
}

/*
	$Log: proot.c,v $
	Revision 1.2  2007/02/09 00:18:44  yhshin
	source Á¤¸®
	
	Revision 1.1  2007/02/06 23:20:00  yhshin
	dlink util
	
*/
