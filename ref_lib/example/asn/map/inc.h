#ifndef __INC_H__
#define __INC_H__

#include <stdio.h>

#include <string.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <sys/stat.h>
#include <sys/errno.h>
#include <sys/ipc.h>
#include <sys/shm.h>

typedef unsigned char   uchar;
typedef unsigned short  ushort;
typedef unsigned int    uint;

#define MAX_GT_NUM      32
#define MAX_ADDR        30
#define MAX_ISUP_OPT_DATA       30
#define MAX_USER_DATA   256
#define MAX_PARA_CNT	32
#define MAX_COMPONENT			32

#define     MAX_VAR_DATA        64
#define     MAX_AUTH_DATA       256
#define     MAX_BEARER_DATA     512
#define     MAX_UNKNOWN_CNT     64

#define         MAX_DECODE_ITEM     128


#include <SS7_feature.h>
//#include <cap_com.h>
//#include <dagapi.h>
#include <ISUP_para.h>
#include <SS7_data_st.h>
#include <SS7_define.h>
#include <ISUP_desc.h>
#include <SS7_define_k.h>
#include <MAP_para.h>
#include <MAP_st.h>
#include <BSSAP_para.h>
#include <BSSAP_st.h>
#ifdef GSM_DECODE
//#include <GSMMAP.h>
//#include <R4_GSMMAP.h>
//#include <R99_GSMMAP.h>
#endif
#ifdef FEATURE_KTF
#include <KTF_CNSR.h>
#endif

// For WCDMA Dynamic DB
#define  DD_CP(a)       DYNAMIC_DB_CP(a, pvalue->numocts, pvalue->data)
#define  DD_CP_BIT(a)   DYNAMIC_DB_CP(a, (pvalue->numbits/8)+1, pvalue->data)
#define  DD_CP_ENUM(a)  DYNAMIC_DB_CP(a, 4, pvalue)

// CAMEL 
#define  CAP_CP(a)       CAP_MEM_CP((a), pvalue->numocts, pvalue->data)
#define  CAP_CP_BIT(a)   CAP_MEM_CP((a), (pvalue->numbits/8)+1, pvalue->data)
#define  CAP_CP_ENUM(a)  CAP_MEM_CP((a), 4, pvalue)


int DEC_MTP2(MTP2_PACKET_t *pkt, char *data, ushort caplen, int *dec_pos);
int DEC_MTP3(MTP3_PACKET_t *pkt, char *data, ushort caplen, int *dec_pos);
int DEC_SCCP(SCCP_PACKET_t *pkt, char *data, ushort caplen, int *dec_pos);
int DEC_TCAP(TCAP_PACKET_t *pkt, char *data, ushort caplen, int *dec_pos);
int DEC_BSSAP(BSSAP_MSG_t   *b_msg, char *data, ushort caplen, int *dec_pos, uchar user_data_len);
int DEC_SCMG(SCMG_PACKET_t *scmg, char *data, ushort caplen, int *dec_pos, int scmg_len);
#ifdef FEATURE_KTF
int DEC_CNSR(CNSR_PACKET_t *pkt, char *data, ushort caplen, int *dec_pos);
#endif

#ifdef DYNAMIC_DB_SUPPORT
void CLR_LIB_TBL();
int     Set_userPara(int proto, int para_id, int db_idx);
int     Del_userPara(int proto, int prar_id, int db_idx);
#endif

int DumpLog(char *data, char *name, int Ilen);
char *err2str(int code);

typedef struct
{
    char            *ptr;
    uint            code;
	char			dec_ok;
	char			man_opt;
	uint			max_len;
}DEC_BOX_t;

#define MAX_PC_TABLE		1024
typedef struct
{
	char			name[256];
	char			gtid[32];
	ushort			pc;
	char			gen;
}PC_TABLE_t;

#define		MAX_USER_SET_PARA					64

#ifdef DYNAMIC_DB_SUPPORT
#define		DYNAMIC_DB_PROTO_ISUP				0
#define		DYNAMIC_DB_PROTO_CDMA_MAP			1	
#define		DYNAMIC_DB_PROTO_WCDMA_MAP			2

/* Application 에서 사용하는 structure */
typedef struct
{
	int				para_id;
	int				para_len;
	int				db_idx;
	int				decode_ok;
	char			data[512];
}USER_PARA_t;

/* Library 내부에서 사용하는 structure */
typedef struct
{
    char        used_flag;
    int         protocol;
    int         parameter;
    int         db_idx;
}USER_SET_PARA_t;

#endif // DYNAMIC_DB_SUPPORT

#ifdef NEW_DB
typedef struct
{
	uint		dec_total_cnt;
	uint		Tag[MAX_USER_SET_PARA];
	uint		Length[MAX_USER_SET_PARA];
	char		data[MAX_USER_SET_PARA][128];
}Para_t;
#endif

#ifdef DYNAMIC_DB_SUPPORT
int DEC_CDMA_MAP(CDMA_MAP_t *cdma_map, char *data, int caplen, int *dec_pos, char *u_data);
int DEC_ISUP(ISUP_PACKET_t *pkt, char *data, ushort caplen, int *dec_pos);
#elif defined(NEW_DB)
int DEC_CDMA_MAP(CDMA_MAP_t *cdma_map, char *data, int caplen, int *dec_pos, Para_t *u_data);
int DEC_ISUP(ISUP_PACKET_t *pkt, char *data, ushort caplen, int *dec_pos, Para_t *para);
#else
int DEC_ISUP(ISUP_PACKET_t *pkt, char *data, ushort caplen, int *dec_pos);
int DEC_CDMA_MAP(CDMA_MAP_t *cdma_map, char *data, int caplen, int *dec_pos);
#endif

#endif
