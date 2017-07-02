#include <stdio.h>
#include "Bit.h"

#define __LINUX__

main()
{
	LOG_IUPS aLOG_IUPS;
	LOG_IUPS *pLOG_IUPS;


	pLOG_IUPS = & aLOG_IUPS;
	memset((char *)pLOG_IUPS,0,sizeof(LOG_IUPS));

	pLOG_IUPS->PING_A = 0x0101;
	LOG_IUPS_Prt((char *) __FUNCTION__,pLOG_IUPS);
}

