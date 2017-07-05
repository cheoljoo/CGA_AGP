/* 
 * $Id: lbody.c,v 1.5 2006/10/23 08:27:07 cjlee Exp $
 */
#include <stdio.h>
#include <string.h>
#include "aqua.h"

int 
Get_Detailed_URL(LOG_HTTP_TRANS *pLOG_HTTP_TRANS , char **lextext, int *lexleng)
{
	int i;
	char sss[BUFSIZ];
	URL_ANALYSIS *pURL_ANALYSIS;

	return 1;

}

int 
Get_Detailed_Browser_Info(LOG_HTTP_TRANS *pLOG_HTTP_TRANS , char **lextext, int *lexleng)
{
	return 1;
}

main()
{
	FILE *fp;
	char buf[BUFSIZ];
	int start = 0;
	char parse[BUFSIZ];
	char sss[BUFSIZ];
	int  i, j;
	LIST *pBODY;
	LIST httpURL,*phttpURL;
	int doublecomma,singlecomma;
#define	URLTYPE_HTTP		1
#define	URLTYPE_SLASH		2
#define	URLTYPE_COMMA		3
	int urltype;
	struct timeval			stStart, stLast;
	struct tm				*pstTime;
	long long				llDelTime;

	LIST  aaa;
	int parse_len;


	phttpURL = &httpURL;
	sprintf(buf,"http://ktf.magicn.com:8080/AAAA/BBBB/CCCCC/t.asp?a=3");
	httpURL_LEX(buf,strlen(buf),phttpURL);
	LIST_Prt("HTTP URL" , phttpURL);

	pBODY = (LIST *) sss;
	memset(buf,0,BUFSIZ);
	memset(parse,0,BUFSIZ);
	memset(sss,0,BUFSIZ);
	fp = fopen("../DATA/BODY.DAT","r");
	while(fgets(buf,BUFSIZ,fp)){
		sprintf(parse,"%s%s",parse,buf);
	}
	printf("%s\n",parse);
	parse_len = strlen(parse);
	gettimeofday(&stStart);
	for(j = 0; j < 1; j++){
		pBODY->listcnt = 0;
		BODY_LEX(parse,parse_len,sss);
		//if((j == 0)  || (j== 9)){ BODY_Prt("TT",pBODY);}
	}
	gettimeofday(&stLast);

	llDelTime = stLast.tv_sec * 1000000 + stLast.tv_usec - (stStart.tv_sec * 1000000 + stStart.tv_usec);
	pstTime = localtime(&stLast.tv_sec);
	printf("LAST j = [%d] Current Time = %04d/%02d/%02d %02d:%02d:%02d.%06d\n", 
		j, pstTime->tm_year + 1900, pstTime->tm_mon + 1, pstTime->tm_mday,
		pstTime->tm_hour, pstTime->tm_min, pstTime->tm_sec,
		stLast.tv_usec);
	printf("DEL TIME = %lld.%lld\n", llDelTime/1000000, llDelTime%1000000);


	aaa = *pBODY;
	for(j=0;j<pBODY->listcnt;j++){
		printf("%d : %s\n",pBODY->strlist[j].len , pBODY->strlist[j].str);
	}
	sleep(1);

	gettimeofday(&stStart);
	for(j = 0; j < 1; j++)
	{
	 	*pBODY = aaa;
		for(i=0;i<pBODY->listcnt;i++) {
			doublecomma = 0;
			singlecomma = 0;
			urltype = 0;
//			printf("A %d : %d : %d : T%d : %s\n",pBODY->url[i].len,doublecomma,singlecomma,urltype,pBODY->url[i].str); 
			pBODY->strlist[i].len = bodyURL_LEX(pBODY->strlist[i].str,(pBODY->strlist[i].len),&doublecomma,&singlecomma,&urltype);
/*			printf("B %d : %d : %d : T%d : %s\n",pBODY->url[i].len,doublecomma,singlecomma,urltype,pBODY->url[i].str);
			switch(urltype){
			case URLTYPE_HTTP:
				printf("Result : %s\n",pBODY->url[i].str);
				break;
			case URLTYPE_SLASH:
				printf("Result : %s**%s\n",phttpURL->url[0].str,pBODY->url[i].str);
				break;
			case URLTYPE_COMMA:
				printf("Result : %s,,%s\n",phttpURL->url[phttpURL->listcnt -1 -doublecomma].str,pBODY->url[i].str);
				break;
			default:
				break;
			}
*/
		}

	/*
		if( j != 0 && j % 100000 == 0) {
			gettimeofday(&stLast);
			pstTime = localtime(&stLast.tv_sec);
			printf("Current j = [%d] Current Time = %04d/%02d/%02d %02d:%02d:%02d.%06d\n", 
				j, pstTime->tm_year + 1900, pstTime->tm_mon + 1, pstTime->tm_mday,
				pstTime->tm_hour, pstTime->tm_min, pstTime->tm_sec,
				stLast.tv_usec);
		}
	*/
	}
	gettimeofday(&stLast);

	llDelTime = stLast.tv_sec * 1000000 + stLast.tv_usec - (stStart.tv_sec * 1000000 + stStart.tv_usec);
	pstTime = localtime(&stLast.tv_sec);
	printf("LAST j = [%d] Current Time = %04d/%02d/%02d %02d:%02d:%02d.%06d\n", 
		j, pstTime->tm_year + 1900, pstTime->tm_mon + 1, pstTime->tm_mday,
		pstTime->tm_hour, pstTime->tm_min, pstTime->tm_sec,
		stLast.tv_usec);
	printf("DEL TIME = %lld.%lld\n", llDelTime/1000000, llDelTime%1000000);

//	BODY_Prt("LAST BODY" , pBODY);
}


/* 
 * $Log: lbody.c,v $
 * Revision 1.5  2006/10/23 08:27:07  cjlee
 * *** empty log message ***
 *
 * Revision 1.4  2006/10/11 08:28:10  cjlee
 * *** empty log message ***
 *
 * Revision 1.3  2006/10/11 06:44:14  shlee
 * body.c
 *
 * Revision 1.2  2006/10/11 06:29:23  shlee
 * 1000000 Loop Test && Block Printf
 *
 * Revision 1.1  2006/10/11 05:08:02  cjlee
 * INIT
 *
 * Revision 1.3  2006/10/11 00:57:06  cjlee
 * ???
 *
 */
