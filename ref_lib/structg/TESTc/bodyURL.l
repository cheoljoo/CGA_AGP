
/* scanner for a toy Pascal-like language */

%{
/* need this for the call to atof() below */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "aqua.h"

#define	URLTYPE_HTTP		1
#define	URLTYPE_SLASH		2
#define	URLTYPE_COMMA		3

char url_buf[BUFSIZ];
int url_buf_cnt;
int prev_direc;
int cur_direc;
int is_start;
int url_type;



%}

DIGIT    [0-9]*
ID       [A-Za-z0-9.]*
VALUE       [^ \t\r\n/:]*
%s		HTTP

%%

^"http"	{
	//BEGIN HTTP;
	//FPRINTF(LOG_LEVEL,"HTTP : %s\n",yytext);
	//is_start = 1;
	//memcpy(&url_buf[url_buf_cnt],yytext,yyleng);
	//url_buf_cnt += yyleng;
	url_type = URLTYPE_HTTP;
	return 0;
}

"../" {
	/* FPRINTF(LOG_LEVEL,"H: %s\n",yytext); */
			prev_direc++;
			url_type = URLTYPE_COMMA;
			//memcpy(&url_buf[url_buf_cnt],yytext,yyleng);
			url_buf_cnt += yyleng;
}
"./" {
	 //FPRINTF(LOG_LEVEL,"H: %s\n",yytext); 
			cur_direc++;
			url_type = URLTYPE_COMMA;
			url_buf_cnt += yyleng;
}
^"/" {
	 //FPRINTF(LOG_LEVEL,"H: %s\n",yytext); 
	/* memcpy(&url_buf[url_buf_cnt],yytext,yyleng);
	url_buf_cnt += yyleng; */
	//is_start = 1;
	url_type = URLTYPE_SLASH;
	return 0;
}
. { 
	// if( (url_buf_cnt + yyleng)  >= MAX_BODY_STR_LEN){ return url_buf_cnt; }
	//FPRINTF(LOG_LEVEL,"H: %s\n",yytext); 
	//memcpy(&url_buf[url_buf_cnt],yytext,yyleng);
	//url_buf_cnt += yyleng;
	//is_start = 1;
	return 0;
}

%%

int bodyURLwrap(){
	return 1;
}

int bodyURL_LEX (char *sp
		,int slen
		,int *doublecomma
		,int *singlecomma
		,int *urltype
		)
{
	url_buf_cnt = 0;
	prev_direc=0;
	cur_direc=0;
	is_start=0;
	url_type=0;
	bodyURL_scan_bytes(sp,slen);
	bodyURLlex();
	//memcpy(sp,url_buf,url_buf_cnt);
	*doublecomma = prev_direc;
	*singlecomma = cur_direc;
	*urltype = url_type;

	if(url_buf_cnt >= MAX_BODY_STR_LEN){ return MAX_BODY_STR_LEN;}
	return url_buf_cnt;
}


