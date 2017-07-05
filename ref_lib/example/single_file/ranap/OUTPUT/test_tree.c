/*
	$Id: test_tree.c,v 1.1 2007/04/23 01:18:41 tjryu Exp $
*/

#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include "ranap.h"
#include "dlink.h"
#include "tree_node.h"

void
tree_node_print(tree_node_t *tn)
{
	int				i;
	tree_node_t		*node;

	if (tn == NULL)
		return;

	switch(tn->type) {
	case TREE_NODE_TYPE_UNSIGNED:
		printf("[ %d : %u ]\n", tn->id, tn->v.uvalue);
		break;
	case TREE_NODE_TYPE_SIGNED:
		printf("[ %d : %d ]\n", tn->id, tn->v.svalue);
		break;
	case TREE_NODE_TYPE_STRING:
		printf("[ %d :", tn->id);
		for (i = 0; i < tn->len; i++) {
			printf(" %02X", tn->v.str[i]);
		}
		printf(" ]\n");
		break;
	default:
		printf("[ %d ]\n", tn->id);
		break;
	}

	node = (tree_node_t *)tn->child.next;

	while (&tn->child != (dlink_t *)node) {
		tree_node_print(node);
		node = (tree_node_t *)node->sibling.next;
	}
}

int
main(int argc, char *argv[])
{
	struct stat		st;
	int				fd;
	int				size, len;
	char			buf[8192];
	int				result;
    RANAP_PDU       ranap_pdu;
	ASN1CTXT		asn1_ctxt;

	tree_node_t		*root;

	if (argc != 2) {
	 	printf("Usage: %s <filename>\n", argv[0]);
		exit(0);
	}

	if (stat(argv[1], &st) != 0) {
	 	printf("cannot stat file: %s\n", argv[1]);
		exit(0);
	}

	if (!S_ISREG(st.st_mode)) {
	 	printf("not regular file: %s\n", argv[1]);
		exit(0);
	}
	size = ((st.st_size > 8192) ? 8192 : st.st_size);
	
	if ((fd = open(argv[1], O_RDONLY)) == -1) {
	 	printf("cannot open file: %s\n", argv[1]);
		exit(0);
	}

	if ((len = read(fd, buf, size)) != size) {
		printf("cannot read full buffer : %d / %d\n", len, size);
		exit(0);
	}
	close(fd);

	if (rtInitContext(&asn1_ctxt) != 0)
		exit(-1);

	RANAP_PDU_Descriptions_init (&asn1_ctxt);
	RANAP_PDU_Contents_init (&asn1_ctxt);
	RANAP_IEs_init (&asn1_ctxt);

	if (rtInitContextBuffer(&asn1_ctxt, buf+16, len-16) != 0) {
		rtFreeContext(&asn1_ctxt);
		return(-1);
	}

	pu_setBuffer(&asn1_ctxt, buf+16, len-16, 1);
	pu_setTrace(&asn1_ctxt, 0);

	root = tree_node_alloc();

	if (asn1PD_RANAP_PDU(root, "S", &asn1_ctxt, &ranap_pdu) != 0) {
		rtFreeContext(&asn1_ctxt);
		return(-1);
	}

	tree_node_print(root);
	tree_node_free(root);

	return(1);
}

/*
	$Log: test_tree.c,v $
	Revision 1.1  2007/04/23 01:18:41  tjryu
	*** empty log message ***
	
	Revision 1.1  2007/04/10 01:22:23  tjryu
	*** empty log message ***
	
	Revision 1.1.1.1  2007/04/06 04:32:24  yhshin
	hidra
	
	Revision 1.3  2006/11/21 04:14:21  tjryu
	상위 프로토콜 정보 관리 기능 추가
	
	Revision 1.2  2006/11/13 05:42:26  tjryu
	Security Mode Command 메시지 분석 기능 추가
	
	Revision 1.1  2006/11/11 05:06:12  tjryu
	RANAP decoding test
	
*/

