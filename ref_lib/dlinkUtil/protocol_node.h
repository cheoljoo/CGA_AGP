/*
	$Id: protocol_node.h,v 1.1 2007/02/06 23:20:00 yhshin Exp $
*/

#ifndef __PROTOCOL_NODE_H__
#define __PROTOCOL_NODE_H__

#include "dlink.h"

#define MAX_STRING_DESC				256

typedef struct _protocol_node {
	dlink_t					sibling;	/* other protocol with same depth */
	dlink_t					child;		/* root parameter */

	unsigned int			pos;		/* node position within whole packet */
	unsigned int			len;		/* length of this node */
	unsigned int			msg_type;

	unsigned int			upper_proto;	/**< upper layer protocol type */
	unsigned char			*upper_buf;		/**< upper layer message buf point */
	unsigned char			upper_len;		/**< upper layer message length */

	unsigned char			pdesc [MAX_STRING_DESC];	/* data : raw stream (4byte-aligned) */
} pnode_t;

pnode_t *			protocol_node_alloc(int data_size);
void				protocol_node_free(pnode_t *node);
void 				protocol_node_init (pnode_t *pnode);

#endif

/*
	$Log: protocol_node.h,v $
	Revision 1.1  2007/02/06 23:20:00  yhshin
	dlink util
	
*/

