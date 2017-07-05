/*
	$Id: proot.h,v 1.2 2007/02/09 00:18:44 yhshin Exp $
*/

#ifndef __PROOT_H__
#define __PROOT_H__

#include "dlink.h"

#define 	MAX_STRING_LEN		256

typedef struct _proot {
	dlink_t				child;			/**< child : protocol node point */

	unsigned int		pos;			/**< 시작 위치 */
	unsigned int		len;			/**< 길이 */

	unsigned char 		desc [MAX_STRING_LEN];	/**< description **/
} proot_t;

void proot_node_init (proot_t *pnode);
void proot_node_free (proot_t *pnode);

#endif

/*
	$Log: proot.h,v $
	Revision 1.2  2007/02/09 00:18:44  yhshin
	source 정리
	
	Revision 1.1  2007/02/06 23:20:00  yhshin
	dlink util
	
*/
