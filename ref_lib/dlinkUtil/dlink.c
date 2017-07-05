/*
	$Id: dlink.c,v 1.1 2007/02/06 23:20:00 yhshin Exp $
*/

#include "dlink.h"

/*****************************************************************************
* Enqueue function of Doubly Linked List 
*
* insert item into the tail of list
*****************************************************************************/
void
dlink_nq(dlink_t *list, dlink_t *item)
{
	list->prev->next = item;
	item->prev       = list->prev;
	item->next       = list;
	list->prev       = item;
}   

/*****************************************************************************
* Enqueue function of Doubly Linked List 
*
* insert item into the head of list
*****************************************************************************/
void
dlink_nq_head(dlink_t *list, dlink_t *item)
{
	list->next->prev = item;
	item->next = list->next;
	list->next = item;
	item->prev = list;
}

/*****************************************************************************
* Dequeue function of Doubly Linked List 
*
* remove item from list
*****************************************************************************/
void
dlink_dq(dlink_t *item)
{
	item->prev->next = item->next;
	item->next->prev = item->prev;
	item->next       = item;
	item->prev       = item;
}

/*
	$Log: dlink.c,v $
	Revision 1.1  2007/02/06 23:20:00  yhshin
	dlink util
	
	Revision 1.1  2006/11/09 01:30:33  tjryu
	RANAP decoding utility added
	
*/
