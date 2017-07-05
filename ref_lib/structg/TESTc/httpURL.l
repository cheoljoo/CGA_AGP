
/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "aqua.h"


LIST *phttpURL;
char url_buf[BUFSIZ];
int url_buf_cnt;



%}

DIGIT    [0-9]*
ID       [^ \t\r\n/]*
VALUE       [^ \t\r\n/:]*
%s		HTTP

%%

^"http://"	{
	BEGIN HTTP;
	FPRINTF(LOG_LEVEL,"HTTP : %s\n",yytext);
	memcpy(&url_buf[url_buf_cnt],yytext,yyleng);
	url_buf_cnt += yyleng;
}

<HTTP>{VALUE} {
	FPRINTF(LOG_LEVEL,"HTTP : %s\n",yytext);
	memcpy(&url_buf[url_buf_cnt],yytext,yyleng);
	url_buf_cnt += yyleng;
}

<HTTP>:{DIGIT} {
	FPRINTF(LOG_LEVEL,"HTTP : %s\n",yytext);
}

<HTTP>"/" {
	FPRINTF(LOG_LEVEL,"HTTP : %s\n",yytext);
	memcpy(&url_buf[url_buf_cnt],yytext,yyleng);
	url_buf_cnt += yyleng;
	memcpy(phttpURL->strlist[phttpURL->listcnt].str,url_buf,url_buf_cnt);
	phttpURL->strlist[phttpURL->listcnt].len = url_buf_cnt;
	phttpURL->strlist[phttpURL->listcnt].str[url_buf_cnt] = 0;

	phttpURL->listcnt++;
	BEGIN 0;
}

<HTTP>. {
	FPRINTF(LOG_LEVEL,"HTTP ERROR: %s\n",yytext);
	BEGIN 0;
}

"/" {
	if( (url_buf_cnt + yyleng) >= MAX_BODY_STR_LEN){ return url_buf_cnt; }
	FPRINTF(LOG_LEVEL,"H: %s\n",yytext);
	memcpy(&url_buf[url_buf_cnt],yytext,yyleng);
	url_buf_cnt += yyleng;
	memcpy(phttpURL->strlist[phttpURL->listcnt].str,url_buf,url_buf_cnt);
	phttpURL->strlist[phttpURL->listcnt].len = url_buf_cnt;
	phttpURL->strlist[phttpURL->listcnt].str[url_buf_cnt] = 0;

	phttpURL->listcnt++;
}

. 	{
	if( (url_buf_cnt + yyleng) >= MAX_BODY_STR_LEN){ return url_buf_cnt; }
	/* FPRINTF(LOG_LEVEL,"H: %s\n",yytext); */
	memcpy(&url_buf[url_buf_cnt],yytext,yyleng);
	url_buf_cnt += yyleng;
}

%%

int httpURLwrap(){
	return 1;
}

int httpURL_LEX (char *sp
		,int slen
		,LIST *pBODY
		)
{
	phttpURL = pBODY;
	url_buf_cnt = 0;
	phttpURL->listcnt=0;
	httpURL_scan_bytes(sp,slen);
	httpURLlex();

	return 1;
}


