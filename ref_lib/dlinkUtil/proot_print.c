
#include "stdio.h"
#include "string.h"
#include "proot.h"
#include "protocol_node.h"
#include "param_node.h"

void
print_prefix(int depth)
{
    int     i;
    
    for (i = 0; i < depth; i++) {
        printf(" ");
    }   
}   

void
param_msg_print (param_node_t *pnode, int depth)
{
    param_node_t        *pn;
    
    if (pnode == NULL)
        return;
        
    print_prefix (depth);
    
    if (&pnode->child == (dlink_t *)pnode) {
        printf ("%s\n", pnode->data);
        return;
    }   
    
//    printf ("Parameter description: %s\n", pnode->data);
    printf ("%s\n", pnode->data);
    pn = (param_node_t *)pnode->child.next;
    
    while (&pnode->child != (dlink_t *)pn) {
        param_msg_print(pn, depth+1);
        pn = (param_node_t *)pn->sibling.next;
    }

}

void
protocol_msg_print (pnode_t *pnode, int depth)
{
    param_node_t        *pn;

    if (pnode == NULL)
        return;

    printf ("Protocol Message : %s\n", pnode->pdesc);

    pn = (param_node_t *)pnode->child.next;

    while (&pnode->child != (dlink_t *)pn) {
        param_msg_print (pn, depth+1);
        pn = (param_node_t *)pn->sibling.next;
    }

}

void
root_print (proot_t *proot)
{
    pnode_t     *pn;

    printf ("Message : %s\n", proot->desc);

    pn = (pnode_t *)proot->child.next;

    while (&proot->child != (dlink_t *)pn) {
        protocol_msg_print (pn, 0);
        pn = (pnode_t *)pn->sibling.next;
    }
}
