/*
	$Id: param_node.h,v 1.3 2007/03/17 09:46:27 yhshin Exp $
*/

#ifndef __PARAM_NODE_H__
#define __PARAM_NODE_H__

#include "dlink.h"

#define PARAM_NODE_TYPE_U32     1
#define PARAM_NODE_TYPE_U16     2
#define PARAM_NODE_TYPE_U8      3
#define PARAM_NODE_TYPE_CHAR    4
#define PARAM_NODE_TYPE_BIT     5

#define PARAM_NODE_MAX_DATASIZE     4096

#define MAX_STRING_DESC				256

typedef struct _param_node {
	dlink_t					sibling;	/* other parameter with same depth */
	dlink_t					child;		/* child parameter */

	unsigned int			pos;		/* node position within whole packet */
	unsigned int			len;		/* length of this node */

    unsigned int            code;       /* node code */
    unsigned int            type;       /* data type 
                                            PARAM_NODE_TYPE_U32, 
                                            PARAM_NODE_TYPE_U16, 
                                            PARAM_NODE_TYPE_U8 */
    unsigned int            size;       /* data size */
	unsigned char			data[0];	/* data : raw stream (4byte-aligned) */
} param_node_t;

param_node_t *		param_node_alloc(int data_size);
void				param_node_free(param_node_t *node);

#endif

/*
	$Log: param_node.h,v $
	Revision 1.3  2007/03/17 09:46:27  yhshin
	*** empty log message ***
	
	Revision 1.2  2007/02/09 00:18:30  yhshin
	source Á¤¸®
	
	Revision 1.1  2007/02/06 23:20:00  yhshin
	dlink util
	
*/

