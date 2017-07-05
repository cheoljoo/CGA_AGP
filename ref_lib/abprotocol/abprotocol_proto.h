
#ifndef __abprotocol_protoo_h__
#define __abprotocol_protoo_h__

#pragma pack(1)

typedef struct _avp_flag_ 
{
	unsigned char 		vendor_specific_f:1;
	unsigned char		mandatory_f:1;
	unsigned char 		protected_f:1;
	unsigned char		reserved1:1;
	unsigned char		reserved2:1;
	unsigned char		reserved3:1;
	unsigned char		reserved4:1;
	unsigned char		reserved5:1;
} AVP_FLAG;


/* --- SCCP ---- */
#define MAX_GT_NUM      32

typedef struct
{
    unsigned char       nature_addr_indi:7;
    unsigned char       oven_odd:1;
    unsigned char       GT_addr[MAX_GT_NUM];

}GT_0001;

typedef struct
{
    unsigned char       translation_type;
    unsigned char       GT_addr[MAX_GT_NUM];

}GT_0010;

typedef struct
{
    unsigned char       translation_type;
    unsigned char       encoding_schema:4;
    unsigned char       number_plan:4;
    unsigned char       GT_addr[MAX_GT_NUM];

}GT_0011;

typedef struct
{
    unsigned char       translation_type;
    unsigned char       encoding_schema:4;
    unsigned char       number_plan:4;
    unsigned char       nature_addr_indi;
    unsigned char       GT_addr[MAX_GT_NUM];

}GT_0100;

typedef struct _sccp_addrd_ 
{
    /* address indicator */
#ifdef __BIG_ENDIAN__
    unsigned char       reserved:1;
    unsigned char       route_indi:1;
    unsigned char       GT_indi:4;
    unsigned char       ssn_indi:1;
    unsigned char       pc_indi:1;
#else
    unsigned char       pc_indi:1;
    unsigned char       ssn_indi:1;
    unsigned char       GT_indi:4;
    unsigned char       route_indi:1;
    unsigned char       reserved:1;
#endif

    unsigned short      pc;

    unsigned char       ssn;

    union sccpd_gt
    {
		unsigned char       GT_addr[MAX_GT_NUM + 3];
        GT_0001     gt_0001;
        GT_0010     gt_0010;
        GT_0011     gt_0011;
        GT_0100     gt_0100;
    }G1;

} SCCP_ADDRd;

typedef struct _sccp_addr_cp_ {
    /* address indicator */
    U8      pc_indi;
    U8      ssn_indi;
    U8      GT_indi;                /**< 0001, 0010, 0011, 0100 **/
    U8      route_indi;

    U16     pc;
    U8      ssn;

    /**< GT **/
     union sccp_gt
    {
		unsigned char       GT_addr[MAX_GT_NUM + 3];
        GT_0001     gt_0001;
        GT_0010     gt_0010;
        GT_0011     gt_0011;
        GT_0100     gt_0100;
    }G;

	U8	GT_addr_len;
} SCCP_ADDR_cp;

#pragma pack(0)

#endif
