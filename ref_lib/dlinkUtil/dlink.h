/*
	$Id: dlink.h,v 1.1 2007/02/06 23:20:00 yhshin Exp $
*/

#ifndef __DLINK_H__
#define __DLINK_H__

typedef struct _dlink {
	struct _dlink	*next;
	struct _dlink	*prev;
} dlink_t;

#define DLINK_EMPTY(dl) (((dlink_t *)(dl))->next == ((dlink_t *)(dl)))

void	dlink_nq(dlink_t *list, dlink_t *item);
void	dlink_nq_head(dlink_t *list, dlink_t *item);
void	dlink_dq(dlink_t *item);

#endif

/*
	$Log: dlink.h,v $
	Revision 1.1  2007/02/06 23:20:00  yhshin
	dlink util
	
	Revision 1.1  2006/11/09 01:25:32  tjryu
	RANAP decoding library structure
	
*/
