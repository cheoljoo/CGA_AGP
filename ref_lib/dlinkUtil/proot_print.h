

#ifndef __PROOT_PRINT_H__
#define __PROOT__PRINTH__

#include "proot.h"
#include "protocol_node.h"
#include "param_node.h"

void print_prefix(int depth);
void param_msg_print (param_node_t *pnode, int depth);
void protocol_msg_print (pnode_t *pnode, int depth);
void root_print (proot_t *proot);


#endif
