
/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "aqua.h"

#define   FILEREF	"file:///"
#define   FILEREF_LEN	8

BODY	*pBODY;

int brace_cnt;
#define IMG_TYPE	1


%}

DIGIT    [0-9]
ID       [A-Za-z0-9]*
ac		</a>
%s		HREF

%%

^"url=http://"[^ \t;]* {
	pBODY->redirect_url_type = REDIRECT_HTTP;
	yyleng -= 4;
	if(yyleng > MAX_BODY_STR_LEN){
		pBODY->redirect_url_len = MAX_BODY_STR_LEN;
		memcpy(pBODY->redirect_url ,yytext+4,MAX_BODY_STR_SIZE);
		pBODY->redirect_url[MAX_BODY_STR_LEN] = 0;
	} else {
		pBODY->redirect_url_len = yyleng;
		memcpy(pBODY->redirect_url ,yytext+4,yyleng);
		pBODY->redirect_url[yyleng] = 0;
	}
	return  1;
}

^"url=rtsp://"[^ \t;]* {
	pBODY->redirect_url_type = REDIRECT_RTSP;
	yyleng -= 4;
	if(yyleng > MAX_BODY_STR_LEN){
		pBODY->redirect_url_len = MAX_BODY_STR_LEN;
		memcpy(pBODY->redirect_url ,yytext+4,MAX_BODY_STR_SIZE);
		pBODY->redirect_url[MAX_BODY_STR_LEN] = 0;
	} else {
		pBODY->redirect_url_len = yyleng;
		memcpy(pBODY->redirect_url ,yytext+4,yyleng);
		pBODY->redirect_url[yyleng] = 0;
	}
	return  1;
}

"<"[aA][ \t]+href=[^ <>]+ {
		BEGIN HREF;
		FPRINTF(LOG_LEVEL,"\nHTML: HREF %s [H]\n",yytext);
		brace_cnt = -1;
}
<HREF>\< {
		brace_cnt --;
		//FPRINTF(LOG_LEVEL,"HREF: <  brace %d\n",brace_cnt);
}
<HREF>\> {
		brace_cnt ++;
		//FPRINTF(LOG_LEVEL,"HREF: >  brace %d\n",brace_cnt);
}
<HREF>&nbsp; { 
	//FPRINTF(LOG_LEVEL,"HREF : nbsp %s\n",yytext);
	}
<HREF>title='[^'<>]+' {			/* Second */
		FPRINTF(LOG_LEVEL,"HREF: ALT T5 %s [H]\n",yytext);
}
<HREF>title=[^ <>]+[ \t]* {			/* Second */
		FPRINTF(LOG_LEVEL,"HREF: ALT T2 %s [H]\n",yytext);
}
<HREF>alt=[^ <>]+[ \t]*"</a>" {		/* third */
		FPRINTF(LOG_LEVEL,"HREF: ALT %s [H]\n",yytext);
		BEGIN 0;
}
<HREF>"</a>" {
		FPRINTF(LOG_LEVEL,"HREF: HREF END  %s [H]\n",yytext);
		BEGIN 0;
}
<HREF>[ \t]+	{}
<HREF>\r\n		{}
<HREF>[^ \t<>\r\n&;]*"상위"[^ \t<>\r\n&;]* 	{ 
	if(brace_cnt ==0) FPRINTF(LOG_LEVEL,"HREF: [%d] 바로보기 빼기 %s",brace_cnt,yytext);
}
<HREF>[^ \t<>\r\n&;]+ 	{ 
	if(brace_cnt ==0) FPRINTF(LOG_LEVEL,"HREF: [%d] %s\n",brace_cnt,yytext);   /* First */
	}

"<img src='"[^ \t\r\n>\\'"]+  {
			FPRINTF(LOG_LEVEL,"yytext- %s",yytext);
			if(pBODY->aLIST.listcnt >= MAX_URL_CNT){
				FPRINTF(LOG_BUG,"You reached the MAX -> MAX_URL_CNT = %d\n",MAX_URL_CNT);
			} else {
				if( (yyleng < 10+FILEREF_LEN) || memcmp(yytext+10, FILEREF, FILEREF_LEN) ){
					//FPRINTF(LOG_LEVEL,"IMG : img SRC %s ( %d : BODY %d)\n",yytext+10,pBODY->aLIST.listcnt,sizeof(BODY));
					pBODY->aLIST.strlist[pBODY->aLIST.listcnt].type = IMG_TYPE;
					pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len = yyleng - 10;
					if(pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len > MAX_BODY_STR_LEN){ pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len = MAX_BODY_STR_LEN; }
					memcpy(pBODY->aLIST.strlist[pBODY->aLIST.listcnt].str,yytext+10,pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len);
					pBODY->aLIST.strlist[pBODY->aLIST.listcnt].str[pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len] = 0;
					pBODY->aLIST.listcnt++;
				}
			}
}

"<img src=\""[^ \t\r\n>\\'"]+  {
			FPRINTF(LOG_LEVEL,"yytext- %s",yytext);
			if(pBODY->aLIST.listcnt >= MAX_URL_CNT){
				FPRINTF(LOG_BUG,"You reached the MAX -> MAX_URL_CNT = %d\n",MAX_URL_CNT);
			} else {
				if( (yyleng < 10+FILEREF_LEN) || memcmp(yytext+10, FILEREF, FILEREF_LEN) ){
					//FPRINTF(LOG_LEVEL,"IMG : img SRC %s ( %d : BODY %d)\n",yytext+10,pBODY->aLIST.listcnt,sizeof(BODY));
					pBODY->aLIST.strlist[pBODY->aLIST.listcnt].type = IMG_TYPE;
					pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len = yyleng - 10;
					if(pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len > MAX_BODY_STR_LEN){ pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len = MAX_BODY_STR_LEN; }
					memcpy(pBODY->aLIST.strlist[pBODY->aLIST.listcnt].str,yytext+10,pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len);
					pBODY->aLIST.strlist[pBODY->aLIST.listcnt].str[pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len] = 0;
					pBODY->aLIST.listcnt++;
				}
			}
}

"<img src="[^ \t\r\n>\\'"]+  {
			FPRINTF(LOG_LEVEL,"yytext- %s",yytext);
			if(pBODY->aLIST.listcnt >= MAX_URL_CNT){
				FPRINTF(LOG_BUG,"You reached the MAX -> MAX_URL_CNT = %d\n",MAX_URL_CNT);
			} else {
				if( (yyleng < 9+FILEREF_LEN) || memcmp(yytext+9, FILEREF, FILEREF_LEN) ){
					//FPRINTF(LOG_LEVEL,"IMG : img SRC %s ( %d : BODY %d)\n",yytext+9,pBODY->aLIST.listcnt,sizeof(BODY));
					pBODY->aLIST.strlist[pBODY->aLIST.listcnt].type = IMG_TYPE;
					pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len = yyleng - 9;
					if(pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len > MAX_BODY_STR_LEN){ pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len = MAX_BODY_STR_LEN; }
					memcpy(pBODY->aLIST.strlist[pBODY->aLIST.listcnt].str,yytext+9,pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len);
					pBODY->aLIST.strlist[pBODY->aLIST.listcnt].str[pBODY->aLIST.strlist[pBODY->aLIST.listcnt].len] = 0;
					pBODY->aLIST.listcnt++;
				}
			}
}

[\r\n]
.	

%%

int BODYwrap(){
	return 1;
}

int BODY_LEX (char *sp
		,int slen
		,U8 *dp)
{
	FPRINTF(LOG_LEVEL,"%s : slen %d\n",(char *)__FUNCTION__,slen);
	brace_cnt = 0;
	pBODY = (BODY *) dp;
	pBODY->aLIST.listcnt = 0;
	BODY_scan_bytes(sp,slen);
	BODYlex();
	BODY_delete_buffer(yy_current_buffer);
	yy_init = 1;

	BODY_Prt("BODY", pBODY);

	return 1;
}

main( argc, argv )
int argc;
char **argv;
{
	int size=0;
	char buf[BUFSIZ];
	char s[BUFSIZ],d[BUFSIZ];
	FILE *fp;

	memset(s,0,BUFSIZ);
	memset(d,0,BUFSIZ);

	fp = fopen("../DATA/BODY.DAT","r");

	while(fgets(buf,BUFSIZ,fp)){
		if( (size + strlen(buf)) >= BUFSIZ) break;
		sprintf(s,"%s%s\n",s,buf);
		size += strlen(buf);
	};

    BODY_LEX(s,size,d);
}


