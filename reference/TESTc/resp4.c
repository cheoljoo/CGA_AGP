#include <stdio.h>
#include "aqua.h"

main()
{
	FILE *fp;
	char buf[BUFSIZ];
	int start = 0;
	char parse[BUFSIZ];
	char sss[BUFSIZ];
	memset(buf,0,BUFSIZ);
	memset(parse,0,BUFSIZ);
	memset(sss,0,BUFSIZ);
	fp = fopen("../DATA/RESP4.DAT","r");
	while(fgets(buf,BUFSIZ,fp)){
		sprintf(parse,"%s%s",parse,buf);
	}
	printf("%s\n",parse);
	LOG_HTTP_TRANS_WIPI_RESP_HDR_LEX(parse,strlen(parse),sss);
}


