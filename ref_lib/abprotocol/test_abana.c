/*
 * 	$Id: test_abana.c,v 1.6 2007/02/08 01:21:46 yhshin Exp $
 */


#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "sb_protocol_stg.h"
#include "proot.h"
#include "protocol_node.h"
#include "param_node.h"


#define WIDTH   16          
int                                         
dump(char *s,int len)                
{
    char buf[BUFSIZ],lbuf[BUFSIZ],rbuf[BUFSIZ];
    unsigned char *p;
    int line,i;

    p =(unsigned char *) s;
    for(line = 1; len > 0; len -= WIDTH,line++) {
        memset(lbuf,0,BUFSIZ);
        memset(rbuf,0,BUFSIZ);

        for(i = 0; i < WIDTH && len > i; i++,p++) {
            sprintf(buf,"%02x ",(unsigned char) *p);
            strcat(lbuf,buf);
            sprintf(buf,"%c",(!iscntrl(*p) && *p <= 0x7f) ? *p : '.');
            strcat(rbuf,buf);
        }
        printf("%04x: %-*s    %s\n",line - 1,WIDTH * 3,lbuf,rbuf);
    }
    /*if(!(len%16)) dAppLog(LOG_INFO, "\n"); */
    return line;
}

int
read_data_file (int iInd, unsigned char *pData, unsigned char *string)
{
    FILE                *pOpenF;
    unsigned char       ucFileName [80];
    int                 red, idx;

    sprintf (ucFileName, "./tdata/%s_%d.test", string, iInd);
    pOpenF = fopen (ucFileName, "r");
    if (pOpenF == NULL) {
        printf ("Read file Open Fail !! %s \n", ucFileName);
        return -1;
    }

    idx = 0;
    while (1) {
        red = fread (pData + idx, 1, 1, pOpenF);
        if (red <= 0)   
            break;      
        idx++;
    }
        
    printf ("Read Data %d\n", idx);
    fclose (pOpenF);
    return idx;
}



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

    if (pnode->depth == 0) {
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

    printf ("Message : %s\n", proot->description);

    pn = (pnode_t *)proot->child.next;

    while (&proot->child != (dlink_t *)pn) {
        protocol_msg_print (pn, 0);
        pn = (pnode_t *)pn->sibling.next;
    }
}






int
main (int argc, char *argv[])
{
	unsigned char		ucBuf [2046];
	int					iIndex, iread, dec_pos, ilen;
	GMM_ServiceReq		**pUser;
	GMM_ServiceReq		*pUser1;
	SM_ActpdpReq		*pSM;

	TCP_Header			*pTCPHdr;
	IP_Header			*pIPHdr;

	proot_t				mRoot;

	proot_node_init (&mRoot);

	pUser = &pUser1;

	printf ("Ana Binary Protocol Test Program\n");

	/**< GMM service requet Tree */
	iIndex = dec_pos = 0;
	iread = read_data_file (iIndex, ucBuf, "gmm");
	printf ("iread: %d\n", iread);
	dump (ucBuf, iread);
	make_tree_addr_GMM_ServiceReq (ucBuf, iread, &dec_pos, &pUser1, &mRoot.child);


	/**< GMM service requet binary decode */
	iIndex = dec_pos = 0;
	decode_addr_GMM_ServiceReq (ucBuf, iread, &dec_pos, &pUser1);
	printf ("POSITION: %d\n", dec_pos);
	GMM_ServiceReq_Prt ("GMM Service Req", pUser1);


	/**< SM Activate PDP Request binary decode */
	iIndex = dec_pos = 0;
	iread = read_data_file (iIndex, ucBuf, "sm");
	printf ("iread: %d\n", iread);
	dump (ucBuf, iread);
	ilen = decode_SM_ActpdpReq (ucBuf, iread, &dec_pos);
    if (ilen != iread) {
        fprintf (stderr, "ERROR!! Protocol Analysis not complete!! ilen: %d (%d)", ilen, iread);
    }
//	SM_ActpdpReq_Prt ("SM- Activate PDP Req", &mSM_ActpdpReq);

	/**< SM Activate PDP Request Tree*/
	iIndex = dec_pos = 0;
	make_tree_addr_SM_ActpdpReq (ucBuf, iread, &dec_pos, &pSM, &mRoot.child);
	printf ("POSITION: %d\n", dec_pos);

#if 0
	printf ("POSITION: %d\n", dec_pos);
	printf ("ActpdpReq ucQoSLen: %d \n", ActpdpReq.ucQoSLen);
	dump (ActpdpReq.ucQoS, ActpdpReq.ucQoSLen);
	printf ("ActpdpReq ucAccPointNameType: 		%02x \n", ActpdpReq.ucAccPointNameType);
	printf ("ActpdpReq ucAccPointNameLen: 		%d\n", ActpdpReq.ucAccPointNameLen);
	printf ("ActpdpReq ucProtocolConfOptType: 	%02x \n", ActpdpReq.ucProtocolConfOptType);
	printf ("ActpdpReq ucProtocolConfOptLen: 	%d\n", ActpdpReq.ucProtocolConfOptLen);
	dump (ActpdpReq.ucProtocolConfOpt, ActpdpReq.ucProtocolConfOptLen);

#endif


	/**< Tree Test */
	iIndex = dec_pos = 0;
	iread = read_data_file (iIndex, ucBuf, "iptcptest");
	printf ("iread: %d\n", iread);
	dump (ucBuf, iread);

	mRoot.length = iread;

    make_tree_addr_IP_Header (ucBuf, iread, &dec_pos, &pIPHdr, &mRoot.child);
	printf ("Tree POSITION: %d\n", dec_pos);

    make_tree_addr_TCP_Header (ucBuf+dec_pos, iread-dec_pos, &dec_pos, &pTCPHdr, &mRoot.child);
	printf ("Tree POSITION: %d\n", dec_pos);


	root_print (&mRoot);

	// free 하는 함수 있어야 함 
	exit(0);
}

/**  
 *  $Log: test_abana.c,v $
 *  Revision 1.6  2007/02/08 01:21:46  yhshin
 *  *** empty log message ***
 *
 *  Revision 1.5  2007/02/06 23:12:41  yhshin
 *  tree test
 *
 *  Revision 1.4  2007/01/26 04:25:13  yhshin
 *  test
 *
 *  Revision 1.3  2007/01/24 04:51:43  yhshin
 *  decode_addr_GMM_ServiceReq 사용
 *
 *  Revision 1.2  2007/01/23 04:52:45  yhshin
 *  test
 *
 *  Revision 1.1  2007/01/18 01:46:03  yhshin
 *  rename test_tcphdr.c
 *
 *  Revision 1.1  2007/01/16 11:12:58  yhshin
 *  TCP header test
 *
 **/

