#include <stdio.h>
#include <string.h>
#include "aqua.h"

void 
Get_Detailed_URL(LOG_HTTP_TRANS *pLOG_HTTP_TRANS , char *lextext, int lexleng)
{
	int i;
	char sss[BUFSIZ];
	URL_ANALYSIS *pURL_ANALYSIS;

	pURL_ANALYSIS = (URL_ANALYSIS *)sss;
	memset(sss,0,BUFSIZ);
	printf("%s : txt %s leng %d\n",(char *)__FUNCTION__ , lextext , lexleng);
	URL_ANALYSIS_URL_S_LEX(lextext,lexleng,sss);

	memcpy(pLOG_HTTP_TRANS->MenuID, pURL_ANALYSIS->MenuID , MAX_MENUID_SIZE);
	memcpy( pLOG_HTTP_TRANS->SvcAction, pURL_ANALYSIS->SvcAction , MAX_SVCACTION_SIZE);
	memcpy( pLOG_HTTP_TRANS->ContentID, pURL_ANALYSIS->ContentID , MAX_CONTENTID_SIZE);
	memcpy( pLOG_HTTP_TRANS->CATID, pURL_ANALYSIS->CATID , MAX_CATID_SIZE);

	for(i=0;i<lexleng;i++){
		if( (lextext[i] == ' ') || (lextext[i] == '\t')){
			lextext[i] = 0;
			break;
		}
	}
	pLOG_HTTP_TRANS->usURLSize = strlen(lextext);

}

void 
Get_Detailed_Browser_Info(LOG_HTTP_TRANS *pLOG_HTTP_TRANS , char *lextext, int lexleng)
{
	int semi_cnt=0;
	int idxBrowserInfo=0;
	char szBrowserInfo[BUFSIZ];
	int idxModel=0;
	char szModel[BUFSIZ];
	int i;
	char *temp = lextext;

	for(i=0;i<lexleng;i++,temp++){
		if(*temp == ';'){ 
			semi_cnt++;
			continue;
		}
		if(semi_cnt == 1){
			szBrowserInfo[idxBrowserInfo]=*temp;
			idxBrowserInfo++;
		} else if(semi_cnt == 2){
			szModel[idxModel]=*temp;
			idxModel++;
		} else if (semi_cnt >= 3){
			break;
		}
	}
	szBrowserInfo[idxBrowserInfo]=0;
	szModel[idxModel]=0;

	printf("szBrowserInfo : %s\n",szBrowserInfo);
	printf("szModel : %s\n",szModel);
	printf("strcasecmp=%d\n",memcmp(lextext,";",lexleng));
	printf("lextext : %s\n",lextext);
	printf("lexleng : %d\n",lexleng);
	sprintf(lextext,"%s",szBrowserInfo);
	sprintf(pLOG_HTTP_TRANS->szModel,"%s",szModel);
}

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
	fp = fopen("../DATA/GET4.DAT","r");
	while(fgets(buf,BUFSIZ,fp)){
		sprintf(parse,"%s%s",parse,buf);
	}
	printf("%s\n",parse);
	LOG_HTTP_TRANS_WIPI_REQ_HDR_LEX(parse,strlen(parse),sss);
}


