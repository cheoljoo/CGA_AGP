/* 
 * $Id: body.c,v 1.14 2006/10/20 08:36:04 shlee Exp $
 */
#include <stdio.h>
#include <string.h>
#include "aqua.h"

int dMakeBodyList(U8 *pBody, U16 usLen, LIST *pstBODY)
{
	int     	i, dStep;
	STR_LIST	*pBODYSTR;

	dStep = 0;
	pstBODY->listcnt = 0;
	for(i = 0; i < usLen; i++)
	{
		if(pBody[i] == 'i' || pBody[i] == 'I') {

			if(usLen < i + 7)		/* "img src" -> minimum 7 Length */
				continue;

			if(	(pBody[i+1] == 'm' || pBody[i+1] == 'M') &&
				(pBody[i+2] == 'g' || pBody[i+2] == 'G') ) {

				i += 3;
				while(i < usLen) {
					if(pBody[i] == 0x20)
						i++;
					else
						break;
				}

				if( i > usLen )
					break;

				if(	(pBody[i] 	== 's' || pBody[i] 	== 'S') &&
					(pBody[i+1] == 'r' || pBody[i+1] == 'R') &&
					(pBody[i+2] == 'c' || pBody[i+2] == 'C') ) {

					i += 3;
					while(i < usLen) {	
						if(pBody[i] == 0x3D || pBody[i] == 0x22 || pBody[i] == 0x27) /* 0x3d = '=', 0x22 = '"', 0x27 = ''' */
							i++;
						else
							break;
					}

					if( (i < usLen - 8) && (memcmp(pBody+i, "file:///", 8) == 0) )
						continue;
					
					pBODYSTR = &pstBODY->strlist[pstBODY->listcnt++];
					pBODYSTR->len = 0;
					while(i < usLen) {
						if(pBody[i] == 0x22 || pBody[i] == 0x27 || pBody[i] == 0x20) {
							i++;
							break;
						} else {
							pBODYSTR->str[pBODYSTR->len] = pBody[i++];
							pBODYSTR->len++;
							if(pBODYSTR->len > MAX_BODY_STR_LEN) {
								pBODYSTR->len = MAX_BODY_STR_LEN;
								break;
							}
						}
					}

					pBODYSTR->str[pBODYSTR->len] = 0x00;
				} /* End of IF "src" */
			} /* End of If "mg" */
		} /* End of If "i" */
	} /* End of For */

	return 0;
}

/** Remake URL with Delete Port :**/
int Remake_URL(U16 *pusURLSize, U8 *pURL)
{
	int 		i , dRet = 0;
	int 		dFirst, dLast;

	dLast = 7; dFirst = 0;
	for(i = 7; i < *pusURLSize; i++)
	{
		dLast++;
		if(pURL[i] == '/') {
			dLast--;
			break;
		} else if(pURL[i] == ':') {
			dFirst = i;
		} else if(pURL[i] == '?') { 
			break;
		}

	} /* End of For i */

	if(dFirst != 0 ) {
		memcpy(pURL + dFirst, pURL + dLast, *pusURLSize - dLast);
		*pusURLSize = *pusURLSize - (dLast - dFirst);
		pURL[*pusURLSize] = 0x00;
		printf("REMAKE URL[%d]=[%s] F[%d] L[%d]\n", *pusURLSize, pURL, dFirst, dLast);
	} else {
	; 	printf("NO REMAKE URL[%d]=[%s]\n", *pusURLSize, pURL);
	}

	return dRet;
}

/** Remake URL to Other Buffer with Delete Port :**/
int Remake_URL_Buf(U16 usURLSize, U8 *pURL, U16 *pusOutSize, U8 *pOUTPUT)
{
	int 		i , dRet = 0;
	int 		dFirst, dLast;

	dLast = 7; dFirst = 0;
	if(memcmp(pURL, "https", 5) == 0) {
		dLast = 8;
		i = 8;
	} else {
		dLast = 7;
		i = 7;
	}

	for(; i < usURLSize; i++)
	{
		dLast++;
		if(pURL[i] == '/') {
			dLast--;
			break;
		} else if(pURL[i] == ':') {
			dFirst = i;
		} else if(pURL[i] == '?') { 
			break;
		}

	} /* End of For i */

	if(dFirst != 0 ) {
		memcpy(pOUTPUT, pURL, 7 + dFirst); 
		memcpy(pOUTPUT+dFirst, pURL+dLast, usURLSize - dLast);
		*pusOutSize = usURLSize - (dLast - dFirst);
		pOUTPUT[*pusOutSize] = 0x00;
			printf("REMAKE URL[%d][%d]=[%s][%s]\n", usURLSize, *pusOutSize, pURL, pOUTPUT);
	} else {
		memcpy(pOUTPUT, pURL, usURLSize);	
		*pusOutSize = usURLSize;
			printf("NO REMAKE URL[%d][%d]=[%s][%s]\n", usURLSize, *pusOutSize, pURL, pOUTPUT);
	}

	return dRet;
}

/** BODY URL CHECK TYPE : ../../../, ./, / **/
int Devide_ReqURL(U16 usURLSize, U8 *pURL, LIST *pBODY)
{
	int 		i , dRet = 0;
	int 		dLast;
	STR_LIST	*pBODYSTR;

	if(memcmp(pURL, "https", 5) == 0) {
		dLast = 8;
		i = 8;
	} else {
		dLast = 7;
		i = 7;
	}

	pBODY->listcnt = 0;
	for(; i < usURLSize; i++)
	{
		dLast++;
		if(pURL[i] == '/') {

			pBODYSTR = &pBODY->strlist[pBODY->listcnt];
			pBODYSTR->len = dLast;
			if(pBODYSTR->len > MAX_BODY_STR_LEN) {
				pBODYSTR->len = MAX_BODY_STR_LEN;
				dRet++;
			}

			memcpy(pBODYSTR->str, pURL, pBODYSTR->len);
			pBODYSTR->str[pBODYSTR->len] = 0x00;

			printf("STACK[%d] = [%s] dLast[%d], dLen[%d]\n", pBODY->listcnt, pBODYSTR->str, dLast, pBODYSTR->len);
			pBODY->listcnt++;

			if(pBODY->listcnt == MAX_URL_CNT) {
				printf("pBODY->listcnt[%d] = MAX_URL_CNT[%d] BREAK URL[%s]\n",
					pBODY->listcnt, MAX_URL_CNT, pURL);
				dRet++;
				break;
			}
		} else if(pURL[i] == '?') {
			break; 
		}
	} /* End of For i */

	if(pBODY->listcnt == 0) {
		if(usURLSize > MAX_BODY_STR_LEN) {
			pBODY->strlist[0].len = MAX_BODY_STR_LEN;
			dRet = 1000;
		} else {
			pBODY->strlist[0].len = usURLSize;
		}

		memcpy(pBODY->strlist[0].str, pURL, pBODY->strlist[0].len);
		pBODY->strlist[0].str[pBODY->strlist[0].len] = 0x00;

		pBODY->listcnt++;
		printf("pBODY->listcnt[%d] = MIN_URL_CNT[0] BREAK URL[%s]\n",
			pBODY->listcnt, pURL);
	} else {
		pBODYSTR = &pBODY->strlist[pBODY->listcnt - 1];
		if(pBODYSTR->len < MAX_BODY_STR_LEN && pBODYSTR->str[pBODYSTR->len - 1] != '/') {
			pBODYSTR->str[pBODYSTR->len] = '/';
			pBODYSTR->len++;
		}
	}

	return dRet;
}

/** ABSOLUTE_URL STACK  : BODY */
int Make_Absolute_URL(U16 usURLSize, U8 *szURL, LIST *pBODY)
{
	int 		i, j, k;
	int			dRet, dMFlag;
	int			dFirst, dLast, dCount, dStop;
	U8			szTempURL[MAX_BODY_STR_SIZE];
	U8			*pURL;
	STR_LIST	*pBODYSTR;
	LIST		stBODY;

	dRet = Devide_ReqURL(usURLSize, szURL, &stBODY);
	if(dRet < 0) {	/* Error */
		printf("Devide_ReqURL Ret =[%d] < 0\n", dRet);
		return -1;
	} else if(dRet > 0) { /* Warning */
 		printf("Devide_ReqURL Ret = [%d] > 0\n", dRet);
	}

	for(i = 0; i < pBODY->listcnt; i++)
	{
		pBODYSTR = &pBODY->strlist[i];		
		pURL = pBODYSTR->str;

		printf("stBODY.listcnt[%d] = ORIGINAL URL[%d][%s]\n", stBODY.listcnt, strlen(pURL), pURL);

		dFirst = 0; dLast = 0; dCount = 0; dStop = 0;
		for(j = 0; j < pBODYSTR->len; )
		{
			if(j == 0) {
				if( (pBODYSTR->len >= j + 4) && (memcmp(pURL+j , "http", 4) == 0) ) {
					dCount = stBODY.listcnt;
					Remake_URL(&pBODYSTR->len, pURL);
					dStop = 1;
				} else if( (pBODYSTR->len >= j + 3) && (memcmp(pURL+j , "../", 3) == 0) ) {
					dCount++;
					j += 3;
					dFirst = j;
				} else if(pBODYSTR->len >= j + 2 && memcmp(pURL+j, "./", 2) == 0) {
					j += 2;
					dFirst = j;
				} else if(pBODYSTR->len >= j + 1 && pURL[j] == '/') {
					dCount = stBODY.listcnt - 1; 
					dStop = 1;
					dFirst = 1;
				} else {
					dStop = 1;
				}
			} else {
				if( (pBODYSTR->len >= j + 3) && memcmp(pURL+j , "../", 3) == 0) {
					dCount++;
					j += 3;
					dFirst = j;
				} else if(pBODYSTR->len >= j + 2 && memcmp(pURL+j, "./", 2) == 0) {
					j += 2;
					dFirst = j;
				} else {
					dStop = 1;
				}
			}

			if(dStop == 1)
				break;
		} /* End of For j */

		/* if(dCount == 0) Current Directory */

		if(stBODY.listcnt > dCount) {
			dLast = pBODYSTR->len - dFirst;
			memcpy(szTempURL, pURL+dFirst, dLast);
			szTempURL[dLast] = 0x00;
			printf("####### TEMPURL[%s] Last=[%d] First=[%d], Len=[%d]\n",
				szTempURL, dLast, dFirst, pBODYSTR->len);
				
			k = stBODY.listcnt - dCount - 1;
			memcpy(pURL, stBODY.strlist[k].str, stBODY.strlist[k].len);
			pBODYSTR->len = stBODY.strlist[k].len;

			if(pBODYSTR->len > MAX_BODY_STR_LEN - dLast)
				dLast = MAX_BODY_STR_LEN - pBODYSTR->len;

			memcpy(pURL+pBODYSTR->len, szTempURL, dLast);
			pBODYSTR->len += dLast;
			pURL[pBODYSTR->len] = 0x00;

			printf("stBODY.listcnt[%d] = MAKE URL[%d][%s]\n",
				k, strlen(pURL), pURL);

		} else {
 			printf("stBODY.listcnt[%d] = DONOT MAKE URL[%d][%s]\n",
				stBODY.listcnt, strlen(pURL), pURL);
		}
	} 

	return 0;
}

/** ABSOLUTE_URL STACK to Buffer  : BODY */
int Make_Absolute_URL_Buf(U16 usURLSize, U8 *szURL, U16 usLocSize, U8 *pLOC, U16 *pusOutSize, U8 *pOUTPUT)
{
	int 		i, j, k;
	int			dRet, dMFlag;
	int			dFirst, dLast, dCount, dStop;
	U8			szTempURL[MAX_BODY_STR_SIZE];
	STR_LIST	*pBODYSTR;
	LIST		stBODY;

	dRet = Devide_ReqURL(usURLSize, szURL, &stBODY);
	if(dRet < 0) {	/* Error */
		printf("Devide_ReqURL Ret =[%d] < 0\n", dRet);
		return -1;
	} else if(dRet > 0) { /* Warning */
		printf("Devide_ReqURL Ret = [%d] > 0\n", dRet);
	}

	printf("stBODY.listcnt[%d] = ORIGINAL URL[%d][%s]\n", stBODY.listcnt, strlen(pLOC), pLOC);
	dFirst = 0; dLast = 0; dCount = 0; dStop = 0;
	for(j = 0; j < usLocSize; )
	{
		if(j == 0) {
			if( (usLocSize >= j + 4) && (memcmp(pLOC+j , "http", 4) == 0) ) {
				dCount = stBODY.listcnt;
				Remake_URL_Buf(usLocSize, pLOC, pusOutSize, pOUTPUT);
				dStop = 1;
			} else if( (usLocSize >= j + 3) && (memcmp(pLOC+j , "../", 3) == 0) ) {
				dCount++;
				j += 3;
				dFirst = j;
			} else if(usLocSize >= j + 2 && memcmp(pLOC+j, "./", 2) == 0) {
				j += 2;
				dFirst = j;
			} else if(usLocSize >= j + 1 && pLOC[j] == '/') {
				dCount = stBODY.listcnt - 1; 
				dStop = 1;
				dFirst = 1;
			} else {
				dStop = 1;
			}
		} else {
			if( (usLocSize >= j + 3) && memcmp(pLOC+j , "../", 3) == 0) {
				dCount++;
				j += 3;
				dFirst = j;
			} else if(usLocSize >= j + 2 && memcmp(pLOC+j, "./", 2) == 0) {
				j += 2;
				dFirst = j;
			} else {
				dStop = 1;
			}
		}

		if(dStop == 1)
			break;
	} /* End of For j */

	/* if(dCount == 0) Current Directory */
	if(stBODY.listcnt > dCount) {

		dLast = usLocSize - dFirst;
		k = stBODY.listcnt - dCount - 1;
		memcpy(pOUTPUT, stBODY.strlist[k].str, stBODY.strlist[k].len);

		usLocSize = stBODY.strlist[k].len;
		if(usLocSize > MAX_BODY_STR_LEN - dLast)
			dLast = MAX_BODY_STR_LEN - usLocSize;

		memcpy(pOUTPUT+usLocSize, pLOC+dFirst, dLast);

		usLocSize += dLast;
		pOUTPUT[usLocSize] = 0x00;
		*pusOutSize = usLocSize;
		printf("stBODY.listcnt[%d] = MAKE URL[%d][%s]\n",
			k, *pusOutSize, pOUTPUT);

	} else {
		memcpy(pOUTPUT, pLOC, usLocSize);
		*pusOutSize = usLocSize;
 		printf("stBODY.listcnt[%d] = DONOT MAKE URL[%d][%s]\n",
			stBODY.listcnt, *pusOutSize, pOUTPUT);
	} 

	return 0;
}

main()
{
	int				dRet, j;
	FILE 			*fp;
	char 			buf[BUFSIZ], parse[BUFSIZ],	sss[BUFSIZ];
	U16				usURLSize, usOutSize, usLocSize;
	U8				szURL[MAX_BODY_STR_LEN], szOUTPUT[MAX_BODY_STR_LEN], szLOC[MAX_BODY_STR_LEN];
	LIST			*pLIST, stLIST;
	BODY			*pBODY;
    struct timeval	stStart, stLast;
    struct tm		*pstTime;
    long long		llDelTime;
	LIST			stBODY;

	memset(buf,0,BUFSIZ);
	memset(parse,0,BUFSIZ);
	memset(sss,0,BUFSIZ);

//	sprintf(szURL,"https://ktf.magicn.com:8080/AAAA/BBBB/CCCCC/t.asp?a=3");
	sprintf(szURL,"https://ktf.magicn.com:8080");
	usURLSize = strlen(szURL);
	sprintf(szLOC,"t.asp?a=3");
	usLocSize = strlen(szLOC);

//	printf("ORL REQURL=[%s] [%d]\n", szURL, usURLSize);
//	Remake_URL_Buf(usURLSize, szURL, &usOutSize, szOUTPUT);
//	printf("ORL REQURL=[%s] [%d]\n", szOUTPUT, usOutSize);

	printf("ORL REQURL=[%s] [%d]\n", szURL, usURLSize);
	Remake_URL(&usURLSize, szURL);
	printf("REMAKE REQURL=[%s] [%d] RealLen=[%d]\n", szURL, usURLSize, strlen(szURL));

	dRet = Devide_ReqURL(usURLSize, szURL, &stLIST);

return;

	printf("ORL REQURL=[%s][%d]\n", szURL, usURLSize);
	printf("ORL LOCATION=[%s][%d]\n", szLOC, usLocSize);
	dRet =  Make_Absolute_URL_Buf(usURLSize, szURL, usLocSize, szLOC, &usOutSize, szOUTPUT);
	printf("ORL REQURL=[%s] [%d]\n", szOUTPUT, usOutSize);


	fp = fopen("../DATA/BODY.DAT","r");
	while(fgets(buf,BUFSIZ,fp)){
		sprintf(parse,"%s%s",parse,buf);
	}
	printf("%s\n",parse);
	BODY_LEX(parse,strlen(parse),sss);

	pBODY = (BODY *)sss;
	pLIST = &pBODY->aLIST;

	gettimeofday(&stStart);
	for(j = 0; j < 1; j++)
	{
		pLIST->listcnt = 0;
		dMakeBodyList(parse, strlen(parse), pLIST);
	}

	gettimeofday(&stLast);
	llDelTime = stLast.tv_sec * 1000000 + stLast.tv_usec - (stStart.tv_sec * 1000000 + stStart.tv_usec);
	pstTime = localtime(&stLast.tv_sec);
	printf("LAST j = [%d] Current Time = %04d/%02d/%02d %02d:%02d:%02d.%06d\n",
	j, pstTime->tm_year + 1900, pstTime->tm_mon + 1, pstTime->tm_mday,
	pstTime->tm_hour, pstTime->tm_min, pstTime->tm_sec,
	stLast.tv_usec);
	printf("DEL TIME = %lld.%lld\n", llDelTime/1000000, llDelTime%1000000);

	for(j=0;j<pLIST->listcnt;j++){
		printf("%d : %s\n",pLIST->strlist[j].len , pLIST->strlist[j].str);
	}
	sleep(1);

	stBODY = *pLIST;

	gettimeofday(&stStart);
	for(j = 0; j < 1; j++)
	{
		*pLIST = stBODY;
		dRet = Make_Absolute_URL(usURLSize, szURL, pLIST);
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

}


/* 
 * $Log: body.c,v $
 * Revision 1.14  2006/10/20 08:36:04  shlee
 * Devide Req URL Function modified for pBODY->listcnt == 0
 *
 * Revision 1.13  2006/10/20 07:49:07  shlee
 * Make Function to write the other buffer inputed
 *
 * Revision 1.12  2006/10/11 09:25:02  cjlee
 * *** empty log message ***
 *
 * Revision 1.11  2006/10/11 08:53:44  shlee
 * Test OK 100000 Body List -> About 2 Seconds
 *
 * Revision 1.10  2006/10/11 08:36:52  shlee
 * Add Function Make Body List
 *
 * Revision 1.9  2006/10/11 07:41:30  cjlee
 * *** empty log message ***
 *
 * Revision 1.8  2006/10/11 06:44:14  shlee
 * body.c
 *
 * Revision 1.7  2006/10/11 05:59:16  shlee
 * Add RemakeURL Function that remove Port Information
 *
 * Revision 1.6  2006/10/11 04:12:57  shlee
 * update parsing
 *
 * Revision 1.5  2006/10/11 03:59:37  shlee
 * Make main function
 *
 * Revision 1.4  2006/10/11 03:37:35  shlee
 * Add comparing condition for http and etc
 *
 * Revision 1.3  2006/10/11 00:57:06  cjlee
 * ???
 *
 */
