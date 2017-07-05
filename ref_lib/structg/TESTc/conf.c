#include <stdio.h>
#include "conf.h"

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
	fp = fopen("../DATA/conf.DAT","r");
	while(fgets(buf,BUFSIZ,fp)){
		switch(buf[0]){
		case '(':
			start++;
			memset(parse,0,BUFSIZ);
			sprintf(parse,"%s%s",parse,buf);
			break;	
		case ')':
			start -- ;
			sprintf(parse,"%s%s",parse,buf);
			memset(sss,0,BUFSIZ);
			if(start == 0){
				printf("¿ø¹® %d -> %s",strlen(parse),parse);
				if(buf[3] == '4'){
					CONFL4_GRASP_LEX(parse,strlen(parse),sss);
					/// CONFL4_Prt("confL4",sss);
				}
				if(buf[3] == '7'){
					CONFL7_GRASP_LEX(parse,strlen(parse),sss);
					/// CONFL7_Prt("confL7",sss);
				}
				if(buf[3] == 'N'){
					CONFMN_GRASP_LEX(parse,strlen(parse),sss);
					/// CONFMN_Prt("confL4",sss);
				}
			} else {
				printf("ERROR : start = %d\n",start);
				exit(0);
			}
			break;
		default:
			sprintf(parse,"%s%s",parse,buf);
		}
	}
}


