#!/usr/bin/perl
##
## $Id: structg_precompile1.pl,v 1.5 2006/08/21 11:12:32 cjlee Exp $
##

##   -----      STG_COMMON �� ó���ϴ� Process    ----    ####
# <TAG_KEY>
# <TAG_COMMOM_MEMBER:... >
# <STG_COMMON:...>
#
##�ּ�: [[2006.07.27]]
##�ּ�: STG_COMMON typedef struct _stg_call {
##�ּ�: 	##	;;   STG_COMMON_MEMBER{"STIME time"} =  %CreateTime% /**<  �⺻ �ּ�  : DEFAULT�� ������ �̰��� ����ϰ� �� : �ʱ��� ��Ÿ���� �ð� */ 
##�ּ�: 	STIME time;	 %CreateTime% /**<  �⺻ �ּ�  : DEFAULT�� ������ �̰��� ����ϰ� �� : �ʱ��� ��Ÿ���� �ð� */ 
##�ּ�: 		##	;;   STG_COMMON_MEMBER_LOG_KUN{"STIME time"} = %Time%  /**< �ּ�2 */ 	
##�ּ�: 		<TAG_COMMON_MEMBER:LOG_KUN>%Time%  /**< �ּ�2 */ 	
##�ּ�: 		##	;;   STG_COMMON_MEMBER_LOG_ME{"STIME time"} = %METime%  /**< �ּ�3 */ 	
##�ּ�: 		<TAG_COMMON_MEMBER:LOG_ME>%METime%  /**< �ּ�3 */ 
##�ּ�: 	MTIME		utime;  %MTime%	 	/**< micro �� ��Ÿ���� �ð� */
##�ּ�: 
##�ּ�: <TAG_KEY>
##�ּ�: 	IP4 		uiIP;					%IPAddr%				/**< IP address */
##�ּ�: 	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
##�ּ�: 	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
##�ּ�: </TAG_KEY>
##�ּ�: 
##�ּ�: 	U32		uiBase; 			%BASE%  /**< BASEID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>BASE_ID:{DIGIT}#
##�ּ�: 	U8		uiNID[EX_MAX_NID]; 	 %NID%  /**< NID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>NID:{VALUE}#  
##�ּ�: 		<TAG_COMMON_MEMBER:LOG_KUN> /**< NID */  %NID%		#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_NID:{VALUE}#  
##�ּ�: 	U32		uiSID; 				
##�ּ�: 		<TAG_COMMON_MEMBER:LOG_ME>  /**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>ME_SID:{DIGIT}#
##�ּ�: 		<TAG_COMMON_MEMBER:LOG_KUN>  /**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_SID:{DIGIT}#
##�ּ�: } LOG_CALL;
##�ּ�: 
##�ּ�: STG_LOG_TEXT_PARSING typedef struct _... {
##�ּ�: 	<STG_COMMON:LOG_CALL>
##�ּ�: 	U32		Test1;
##�ּ�: } LOG_KUN;
##�ּ�: 
##�ּ�: STG_LOG_TEXT_PARSING typedef struct _... {
##�ּ�: 	<STG_COMMON:LOG_CALL>
##�ּ�: 	U32		Test2;
##�ּ�: } LOG_ME;
##�ּ�: 
##�ּ�: �̰��� �ȿ� �����Ҷ��� <STG_CALL>
##�ּ�: �̰Ϳ� �뷡�� ó���� ���־�� �ϴµ�????
##�ּ�: STG_CALL�̶�� ������ �Ѱ��� �� ���� ���̴�.
##�ּ�: 
##�ּ�: TAG_COMMON:KEY���� ������ ���� KEY  HASH�� �����ξ�� �Ѵ�.
##�ּ�: �� ���� DATA�� ���� LOG_CALL�� �Ǿ��� ���̴�.
##�ּ�: - signal�� ��� ���ظ� �� ���ΰ�?  uiCommand�� �� structure�� �ڵ����� �Ѱ��� ������ش�. �ش� key�� ������ �ϰ� �ϸ� �� ���̴�.
##�ּ�:   LOG_CALL�տ� uiCommand ���� �߰��ص� ������ ������ ���� ���̴�.  �� command�� ���� 
##�ּ�:   ADD�� ��� -> �� �ȿ� set�Ǿ��� ���� ���� IP�� set�Ǿ����ִٸ� IP�ε� hash���� ���� ������ ������ �ݿ��ϸ� �� ������ ���δ�. (FIRST, LAST�� �����ؾ� �ϴ����� ���???)
##�ּ�:   	COMMON_DATA������ FIRST,LAST ��Ģ�� ���� �߰��� ���ִ��� �ϸ� �� ���̰�, KEY�� ������ ���ԵǴ� ���̸� ���� ã�Ƽ� set���ִ°��� �⺻���� �Ѵ�.  
##�ּ�:   DEL�� ��� -> �� �ȿ� set�Ǿ��� ���� IP , TMSI�� ���� ������ ã�Ƽ� HASH DEL�� ���ָ� �ǰ�
##�ּ�:   ALL_DEL�� ���� ������ ã�Ƽ� loop�� ���� �ѹ��� �� ���� ������ �����ִ� ���� �⺻���� �Ѵ�.
##�ּ�: 
##�ּ�: �̰��� �⺻���� �����ؾ� �ϴ� ���� 2������ �ִ�.
##�ּ�: �� �κ� --> ���� �⺻ <COMMON> structure {} ���� �־���ϸ�  KEY �� // KEY+DATA
##�ּ�: �� �κ� --> �ΰ� ������ �����ϴ� ��  // KEY + DATA + Timer/Combination���� �ΰ� ���� 
##�ּ�: �� �κ� --> uiCommand�� �����ϴ� ������ �Ѱ� �� �߰� (signal�� ���� ����) 
##�ּ�: �Լ� --> �� field�� ���鼭 null�� �ƴϸ� set�� ���ְų�(FIRST) , LAST (���� NULL�� �ƴϸ� �����.)
##�ּ�: 
##�ּ�: ���� STG_HASH_KEY�ʹ� ��� ������ �� ���ΰ�? �ϴ�  structure�� ���еǾ�����.
##�ּ�: GLOBAL���� LOG���� ������ ������ , COMBINATION , STAT ���� �������� ���ִ�.
##�ּ�: STG�� STC�� ������ ��� �Ѱ��� Package�� ����ϸ� �� ������ ���δ�. 
##�ּ�: (STC�� Primitives���� ���Ǹ� �ϸ� �Ѱ��� library�� ���ü� ���� ������ ���δ�. makefile�� �߰�)
##�ּ�: 
##�ּ�: ���� : STG_COMMON ���� ������ �ϸ� 
##�ּ�: <TAG_KEY> �� ���߿��� KEY���� ����
##�ּ�: U32 uiBase; �ڿ� ������ ���� �ؿ� ���ǵȰ� ������ default��
##�ּ�: �ؿ� <TAG_COMMON_MEMBER:TT> �� ���� �Ǹ� TT structure������ ���� ���ǵ� �ǹ̷� ���Ǿ����� �ǹ�
##�ּ�: 
##�ּ�: 
##�ּ�: ���� ��� :
##�ּ�: /* LOG�� ���ǵ��� ���� */
##�ּ�: # BASIC_TYPEDEF #
##�ּ�: typedef struct _stg_call {
##�ּ�: 	STIME time;	 /**<  �⺻ �ּ�  : DEFAULT�� ������ �̰��� ����ϰ� �� : �ʱ��� ��Ÿ���� �ð� */ 
##�ּ�: 	MTIME		utime;  	/**< micro �� ��Ÿ���� �ð� */
##�ּ�: 
##�ּ�: 	IP4 		uiIP;					%IPAddr%				/**< IP address */
##�ּ�: 	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
##�ּ�: 	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
##�ּ�: 
##�ּ�: 	U32		uiBase; /**< BASEID */ 	
##�ּ�: 	U8		uiNID[EX_MAX_NID]; 	 /**< NID */  
##�ּ�: 	U32		uiSID; 				
##�ּ�: } LOG_CALL;
##�ּ�: 
##�ּ�: #BASIC_SIGNAL #
##�ּ�: typedef struct ... {
##�ּ�: 	U32	uiCommand;
##�ּ�: 	LOG_CALL aLOG_CALL;
##�ּ�: } LOG_CALL_SIGNAL;
##�ּ�: 
##�ּ�: # BASIC_KEY #
##�ּ�: typedef struct ...  {
##�ּ�: 	IP4 		uiIP;					%IPAddr%				/**< IP address */
##�ּ�: } LOG_CALL_KEY_uiIP;
##�ּ�: 
##�ּ�: typedef struct ...  {
##�ּ�: 	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
##�ּ�: } LOG_CALL_KEY_ucTMSI;
##�ּ�: 
##�ּ�: typedef struct ...  {
##�ּ�: 	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
##�ּ�: } LOG_CALL_KEY_ucIMSI;
##�ּ�: 
##�ּ�: # BASIC_DATA #
##�ּ�: typedef struct ... {
##�ּ�: 	LOG_CALL	aLOG_CALL;
##�ּ�: 	U64			TimerId;
##�ּ�: 	/* LOG���� �ݺ� */
##�ּ�: 	U16 		usCntLOG_CFLOW;
##�ּ�: 	U16 		usIsDoneLOG_CFLOW;
##�ּ�: 	LOG_CFLOW 	*pLOG_CFLOW;
##�ּ�: 	/* Combination / Stat ���� */
##�ּ�: 	COMBI_NewTable 	aCOMBI_NewTable;
##�ּ�: 	COMBI_Accum 	aCOMBI_Accum;
##�ּ�: 	COMBI_NewTest 	aCOMBI_NewTest;
##�ּ�: 	STAT_Accum 	aSTAT_Accum;
##�ּ�: 	STAT_NewTest 	aSTAT_NewTest;
##�ּ�: } LOG_CALL_DATA;
##�ּ�: 
##�ּ�: STG_LOG_TEXT_PARSING typedef struct _... {
##�ּ�: # BASIC_COMMON_LOG_KUN #
##�ּ�: 	STIME time;	 %Time%  /**< �ּ�2 */ 	
##�ּ�: 	MTIME		utime;  %MTime%	 	/**< micro �� ��Ÿ���� �ð� */
##�ּ�: 
##�ּ�: 	IP4 		uiIP;					%IPAddr%				/**< IP address */
##�ּ�: 	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
##�ּ�: 	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
##�ּ�: 
##�ּ�: 	U32		uiBase; 			%BASE%  /**< BASEID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>BASE_ID:{DIGIT}#
##�ּ�: 	U8		uiNID[EX_MAX_NID]; 	 /**< NID */  %NID%		#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_NID:{VALUE}#  
##�ּ�: 	U32		uiSID; 				/**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_SID:{DIGIT}#
##�ּ�: 
##�ּ�: 	U32		Test1;
##�ּ�: } LOG_KUN;
##�ּ�: 
##�ּ�: STG_LOG_TEXT_PARSING typedef struct _... {
##�ּ�: # BASIC_COMMON_LOG_ME #
##�ּ�: 	STIME time;	 %METime%  /**< �ּ�3 */ 
##�ּ�: 	MTIME		utime;  %MTime%	 	/**< micro �� ��Ÿ���� �ð� */
##�ּ�: 
##�ּ�: 	IP4 		uiIP;					%IPAddr%				/**< IP address */
##�ּ�: 	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
##�ּ�: 	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
##�ּ�: 
##�ּ�: 	U32		uiBase; 			%BASE%  /**< BASEID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>BASE_ID:{DIGIT}#
##�ּ�: 	U8		uiNID[EX_MAX_NID]; 	 %NID%  /**< NID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>NID:{VALUE}#  
##�ּ�: 	U32		uiSID; 				/**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>ME_SID:{DIGIT}#
##�ּ�: 
##�ּ�: 	U32		Test2;
##�ּ�: } LOG_ME;
##�ּ�: 
##�ּ�: FIRST / LAST �߰� : �ϴ� �迡 �̰͵� �߰� - combination��� �߰��Ǿ����� �Ѵ�.  
##�ּ�: �׳� keyword�� Fix�� ��ų �����̴�. Ư�����ڿ� �Ϲ� ������ ȥ���� Keyword
##�ּ�: #FIRST#  / #LAST#
##�ּ�: ������ default �� #FIRST#


sub print_all_global_var
{
	my $key;
	print GLOBAL  "=============================================\n";
	print GLOBAL  "===== Global Variables ======================\n";
	print GLOBAL  "=============================================\n";
	foreach_print_hash("define_digit");
	foreach_print_hash("table");
	foreach_print_hash("table_log");
	foreach_print_hash("table_cf");
	foreach_print_hash("table_combi");
	foreach_print_hash("table_stat");
	foreach_print_hash("stg_key_hashs");
	foreach_print_hash("TAG_DEFINE");

	foreach_print_array("typedef_name");

	foreach_print_undefined("undefined_typedef");

	foreach_print_hash("STG_COMMON");
	foreach_print_hash("STG_COMMON_KEY");

}
sub foreach_print_undefined
{
	my $key;
	my $hash_name;
	my $undefined_hash_name;

	$undefined_hash_name = shift @_;
	foreach $hash_name (sort keys %$undefined_hash_name){
		print GLOBAL "HASH : 				\$$undefined_hash_name \{ $hash_name \} = $$undefined_hash_name{$hash_name}\n";
		if($$undefined_hash_name{$hash_name} =~ /^HASH/){
			foreach_print_hash($hash_name);
			#foreach $key (keys %$hash_name) {
			#print GLOBAL "HASH : \$$hash_name \{ $key \} = $$hash_name{$key}\n";
			#}
		} else {		# ^ARRAY
			foreach_print_array($hash_name);
			#foreach $key (sort keys %$hash_name) {
			#print GLOBAL "HASH : \$$hash_name \{ $key \} = $$hash_name{$key}\n";
			#}
		}
	}
}
sub foreach_print_hash
{
	my $key;
	my $name;

	$name = shift @_;
	print GLOBAL "--> HASH : \$$name\n";
	foreach $key (keys %$name) {
		print GLOBAL "HASH : \$$name \{ $key \} = $$name{$key}\n";
	}
}
sub foreach_print_array
{
	my $name;
	my $cnt;

	$name = shift @_;
	$cnt = @$name;
	print GLOBAL "--> ARRAY : $name   $cnt\n";
	for(my $i = 0 ; $i < $cnt ; $i++){
		print GLOBAL "ARRAY : \$$name \[ $i \] = $$name[$i]\n";
	}
}


# function.upr�� ������ subroutine�� ���ؼ��� ���� ����� �ּ��� �ܴ�.
#/** print_fp function.
# *
# *  print_fp String , FileDescriptor.....
# *  perl�� �������δ� ���� FileDescriptor�� "ENC" / ENC ��� ���ȴٴ� ���̴�.
# *
# *  @param  string
# *  @param  FileDescriptors
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl�� �����Ͽ� flat....h �� ���� ȭ��
# *
# *  @exception  STD�ϰ�� DBG���� ó���ϰ� ��.
# *  @note      +Note+
# **/
sub print_fp
{
	my $print_contents;
	my $to_file;

	$print_contents = shift @_;
	foreach $to_file (@_) {
		## STD��� ���� DBG�� ���ؼ� ������ ������ STD �� DBG�̳� ���� ���� �ǹ��Ѵ�.  
		print $to_file $print_contents;
	}
}

### ó�� ������ INPUT ���� ���� (sample : hash.stg)
#FileName : hash.h
#
#typedef struct _st_AAA {
#   U32 BBB;
#   U32 *CCC;
#	U8		(*func)(char,...);
#} stAAA;
#
#
#/**
# * hash���� node���� structure.
# * Ȯ���� �����ϰ� �ϱ� ���ؼ� key�� data �κ��� �и� �Ͽ���.
# * key��
# * @see hash.c  ���� ������ ����.
# */
#typedef struct _st_hashnode {
#    struct _st_hashnode *next  ;  ///< self-pointer
#    struct _st_hashnode **prev; /*!< self-pointer */
#    U8 *pstKey;       ///< struct Key
#                        /*!< ��� �Ǵ� comment�� ���� ���� \n
#                         *    �� ���������� */
#    U8 *pstData;      ///< struct Data  \n
#                        ///< TTT
#   U32     uiSBS;
#   stAAA   stAaa;
#} stHASHNODE;
#
#
#/**
# * @brief Hash ��ü�� �����ϴ� structure
# * \brief Hash ��ü�� �����ϴ� structure
# * */
#typedef struct _st_hashinfo {
#    stHASHNODE **hashnode  ;  //!< self-pointer
#    U16 usKeyLen;           //!< Node���� ����� Key ����.  Key �񱳿� copy�� ���ؼ� ���
#    U16 usSortKeyLen;       /*!< Node���� Sort�� ����� ����.
#                                 Key�ȿ��� Sort�� ���ؼ� ����� �տ��� ������ ����
#                                 assert(usKeyLen >= usSortKeyLen) */
#    U16 usDataLen;          /*!< Node���� ����� DataLen
#                                 @exception pstData�� Structure�� type�� �ʿ��ϸ� �߰� �Ҽ� �־�� �� ���̴�. */
#    U32 uiHashSize;         /*!< Hash ũ��. ������ ������ ���ؼ� set */
#   U8  ucIMSI_a[];         /*!< �ܸ� ID : IMSI�� - [15] ���������� �׽� NULL�� �־��־�� �Ѵ�. */
#   U8  ucIMSI_b[16];           /*!< �ܸ� ID : IMSI�� - [15] ���������� �׽� NULL�� �־��־�� �Ѵ�. */
#   stHASHNODE  *pstGtp;
#   stHASHNODE  stGtp;
#   U16 usLen[2];
#   IP4 uiIPAddress;
#} stHASHINFO;

### WARNING -- ó�� �ȵǴ� INPUT ���� ����
#typedef struct { } AAA;      // struct �ڿ� �̸��� ������.
#typdef struct _st_aaa { } ;  // typedef�� �̸��� ������.
#tpedef struct _st_aaa {      // structure�� ȣ���� ����������
#    struct _st_bbb {         // �̰�ó�� nested structure�� �����ϴ� �κ��� ���� ó���� �ȵ�.
#    ....
#    }
#} TTT ;
#tpedef struct _st_aaa {      // structure�� ȣ���� ����������
#    struct _st_bbb *ppp;       // pointer�� ����
#    struct _st_ccc ttt;        // pointer�� �ƴ� ���� ����� �������� ����.
#    ....                           //  �ذ� : typedef�� �� ���� stCCC tttt; ó�� ���� ����
#    }
#} TTT ;                      // ���� : struct�� pointer�θ� ����ϰ� ��� typedef�� ������θ� ����϶�.!!!



### structg.pl hash.stg��  ���� INPUT file�� �̸��� �ް� �Ͽ���.
### input file�� �Ѱ��� ���� ������ �Ѵ�.  (���ֿ� ���ľ� �ϴ� ���� �߱� ���)
my $argcnt = @ARGV;
if($argcnt != 1) {
	print "invalid argument : $argcnt\n";
	print "will be used default value : @ARGV\n";
	#$inputfilename = "userfile.stg";
} else {
	$inputfilename = shift @ARGV;
}

print "INPUT[$inputfilename]\n";

open(DBG,">DEBUG_pre.TXT");
open(GLOBAL,">GLOBAL_pre.TXT");
#open(OUTH,">$inputfilename\.Pre1");
open(OUTH,">userfile_pre.stg");

### STG : Ȯ���� stg�� ������ INPUT FILE
open(STG , "<$inputfilename");

while ($line = <STG>) {

	### �ּ����� �׷��� ����α� ���ؼ� ������ ��� ���־���. 
	### �̻��� ���� filtering�� �ؾ� �Ѵٸ� �� �κ��� next; �� �̿��Ͽ��� �Ѵ�.
	### Find the keyword and Remove the keyword
	###	type 1. typedef struct
	###	type 2. STG_HASH_KEY typedef struct
	###	type 3. STG_COMBINATION_TABLE typedef struct

    ### typedef struct�� �� �κи��� �̾Ƴ��� ���ؼ� ����ϴ� �κ��̴�.
    ### $in_typedef �� 1 �̸鼭  \} .... ; ������  typedef �� ���� ������ �κ��̴�.
	chop($line);
	if ($line =~ /^\s*\<\s*TAG_DEFINE_START\s*\:\s*(\w+)\s*\>/){ 
		print DBG "TAG $line : name = $1\n";
		$tag_define_name = $1;
		next;
	}
	if ($line =~ /^\s*\<TAG_DEFINE_END\s*\:\s*(\w+)\s*\>/){
		print DBG "TAG $line : name = $1\n";
		$tag_define_name = "";
		next;
	}
	if ($line =~ /^\s*\#define\s+(\w+)\s+(\d+)/){
		$define_digit{$1} = $2;
		print DBG "\#define \[$1\] \[$2\]\n";
		if($in_typedef == 1) {
			$typedef_prt .= $line . "\n";
		} else {
			print OUTH "$line\n";
		}
		$TAG_DEFINE{$tag_define_name} .= "*\t" . $line . "\n";
		$TAG_DEFINE{$tag_define_name} =~ s/\/\*.+\*\///g;    # �ּ��� ����
		next;
	}
	if ($line =~ /typedef\s+struct\s+\w+\s*{/){  $in_typedef = 1 ; }		# ... typedef struct .. �ν� 
	if ($line =~ /^\s*\}\s*\w+\s*\;/){  
		$in_typedef = 2; 
		print DBG "DBG_TYPEDEF_CR ($line) ==> \n$typedef_cr\n";
		print DBG "DBG_TYPEDEF_ORG ($line) ==> \n$typedef_prt\n";
	}

	### //... �����ϴ� �ּ��� /*  ... */ ���·� �ٲ���
	### /// A --> /**	A		*/
	if ($line =~ s/\/\/\/\</\/\*\*\</){ $line .= "\*\/ "}
	### //  A --> /*	A		*/  http:// ���� �־ �����ָ� �ȵȴ�.
	### �⺻�� ///< �� ����ϰų� , /* �� ����ϴ� ���� �⺻���� �Ѵ�. 
	#if ($line =~ s/\/\//\/\*/){ $line .= "\*\/ "}
	$line_prt = $line . "\n";
	print  DBG "PPP  [$in_typedef] : $line\n";
	
	if($in_typedef == 0) {
		print OUTH $line_prt;
	}
	if($in_typedef == 1) {
		if($line =~ /^\s*(\w+)\s+<\s*TAG_DEFINE\s*\:\s*(\w+)>\s*(\w+)\s*\;(.*)$/){		##  U32		<TAG_DEFINE:RespCode>RespCode;	
			my $tag_name;
			print DBG "TAG_DEFINE =$1 =$2 =$3 =$4\n";
			$tag_name = $2;
			$line = "\t$1 \t$3\;$4";
			$temp = $line;
			#$temp =~ s/(\#[^\#]*\#)/\/**< [$1] *\//g;
			$line_prt = "\/**<\n$TAG_DEFINE{$tag_name}*\/\n$temp\n";
			print DBG "\$TAG line= $line\n";
			print DBG "\$TAG line_prt = $line_prt\n";
		}

		$typedef_cr .= " " . $line . "\n";
		#$typedef_cr =~ s/\/\*.+\*\///g;    # �ּ��� ����
		$typedef_prt .= $line_prt;

		### /* ... */ �ּ��� ����
		## �ּ�ó�� ������ $typedef�� \n �� ���� �ʴ� ������ ��������� �Ѵ�.
		## �̸� �ذ��ϱ� ���ؼ��� ��� �ؾ� �ұ�?
		## $typedef_cr�� ������ �� ������ ���δ�.
		#$typedef =~ s/\/\*.+\*\///g;
	} 

	if($in_typedef == 2) {
		my $TYPEDEF_NAME;
		if($line =~ /^\s*\}\s*(\w+)\s*\;/){ 
			print DBG "^^^typedef $1\n";
			$TYPEDEF_NAME = $1;
		}
		$typedef_cr .= " " . $line . "\n";
		$typedef_prt .= $line_prt;
		print DBG "[2] result null \$typedef_cr = $typedef_cr\n";
		print DBG "[2] result org \$typedef_prt = $typedef_prt\n";


		#if($typedef =~ /\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/){
		#		print "STG_COMMON CTYPEDEF $1\n";
		#	print "STG_COMMON $typedef\n";
		#	$typedef =~ s/\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/$1/g;
		#	print "STG_COMMON $typedef\n";
		#}

		if($typedef_prt =~ /\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/){
			#$typedef_prt =~ s/\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/$STG_COMMON{$1}/g;
			$STG_COMMON = $STG_COMMON{$TYPEDEF_NAME};
			if($STG_COMMON eq ""){ $STG_COMMON = $STG_COMMON{STG_BASIC}; }
			$typedef_prt =~ s/\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/$STG_COMMON/g;
		}

		if($typedef_cr =~ /^\s*STG_COMMON\s+typedef\s+struct/){
			my $from;
			$typedef_cr =~ s/^\s*STG_COMMON\s*//g; 
			
			# �ʱ�ȭ 
			$tag_key = 0;
			$typedef_prt = "";
			foreach $temp_vars (keys %STG_COMMON){
				$STG_COMMON{$temp_vars} = "";
			}
			$STG_COMMON{"STG_BASIC"} = "";

			print DBG "SSTG_COMMON alternative_statement: $alternative_statement\n";

			@temp_vars = split("\n",$typedef_cr);
			foreach $temp_vars (@temp_vars){
				print DBG "TT \$temp_vars = $temp_vars\n";	
				if($temp_vars =~ /^(\s*\w+\s*.+)\;(.*)$/){
					my $temp1 = $1;
					my $temp2 = $2;

					$statement = $1;
					$rule = $2;

					# ==> KK [REQ_HDR] [GET] [^[ \t]*GET[ \t]+]
					print DBG "KKKK [$1] [$2]\n";

					$typedef_prt .= "$1\;";
					$temp = $2;
					while($temp =~ /(\/\*[^\/]*\*\/)/){
						$typedef_prt .= "\t$1 ";
						$temp =~ s/(\/\*[^\/]*\*\/)//;
					}
					$typedef_prt .= "\n";

					# ==> $LOG_KUN_MSG { REQ_HDR } =  LOG_KUN_MSG_STATE_REQ_HDR
					$undefined_name = "STG_COMMON_" . $TYPEDEF_NAME . "_member";
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$temp1} = $temp2;

					if($tag_key == 1){
						$STG_COMMON_KEY{$TYPEDEF_NAME} .= $temp1 . "\n";
					}
					 
					print DBG "SSTG_COMMON alternative_statement: $alternative_statement\n";
					if("" eq $alternative_statement){
						foreach $vars (keys %STG_COMMON){
							$STG_COMMON{$vars} .= $statement . "\;\t" . $rule . "\n";
							print DBG "NULL SSTG_COMMON $vars: $STG_COMMON{$vars}\n";
						}
					} else {
						foreach $vvv (keys %STG_COMMON){
							my $yes_a = 0;
							@vars = split("\n",$alternative_statement);
							foreach $vars (@vars){
								if($vars =~ /\<\s*TAG_COMMON_MEMBER\s*\:\s*(\w+)\s*\>(.*)/){
									print DBG " $1 $vvv ��\n";
									if($1 eq $vvv){
										$yes_a = 1;
										$yes_rule = $2;
									}
								}
							}
							if($yes_a == 0){
								$STG_COMMON{$vvv} .= $statement . "\;\t" . $rule . "\n";
							} else {
								$STG_COMMON{$vvv} .= $statement . "\;\t" . $yes_rule . "\n";
							}
						}
					}
					$alternative_statement = "";
				} elsif($temp_vars =~ /\<\s*TAG_COMMON_MEMBER\s*\:\s*(\w+)\s*\>(.*)$/){
					if("" eq $STG_COMMON{$1}){
						print DBG "SSTG_COMMON_MEMBER : $1\n";
						$STG_COMMON{$1} = $STG_COMMON{"STG_BASIC"};
					}
					$alternative_statement .= $temp_vars . "\n";
					print DBG "SSTG_COMMON_MEMBER alternative_statement: $alternative_statement\n";
				} elsif($temp_vars =~ /\<\s*TAG_KEY\s*\>/){
					$tag_key = 1;
				} elsif($temp_vars =~ /\<\s*\/TAG_KEY\s*\>/){
					$tag_key = 0;
				} else {
					$typedef_prt .= "$temp_vars\n";
				}
			}

			print OUTH $typedef_prt;

		} else {
			print OUTH $typedef_prt;
		}

		$in_typedef = 0;
		$typedef_cr = "";
		$typedef_prt = "";
	}
}

print_all_global_var;


close DBG;
close GLOBAL;
close OUTH;


## NTAM�� ���� ���� �Ѱ��� �� ������ header file�� �Ѱ� �� ����� ������ ����.
## NTAM������ perl�� �Ѱ� �� ����, ���� header file�� stg�� ������ ���� ���� �����Ը� �ϸ� �� ������ ���δ�. 

## 
## $Log: structg_precompile1.pl,v $
## Revision 1.5  2006/08/21 11:12:32  cjlee
## precompile : STG_COMMON ���� alternative�� �Ѱ��� ������� ������ ���� �ذ� (STG_BASIC�� ���)
## aqua.stg
## structg_precompile1.pl
##
## Revision 1.4  2006/07/31 12:01:22  cjlee
## integer , string ��ȯ �Ϸ�. (�� ��� ����)
## LOG_ME�� ����� , LOG_KUN�� �����ؾ� ��.
##
## Revision 1.3  2006/07/31 06:39:04  cjlee
## precompile�� �ǰ� ��.
## KUN , ME�� ���ؼ� call ���� structure�� ���� ó�� �Ϸ�
## structg.pl -> input : argv , output : ���� FileName : ���� �� ��
## structg_precompile1.pl -> input : pre.stg , output : userfile_pre.stg
## make pre --> input : pre.stg , output : userfile_pre.stg
##
## Makefile���� ���� ���� ���� �˼� ����.
##
## Revision 1.2  2006/07/31 02:12:01  cjlee
## Pre-Compile
##
## Revision 1.1  2006/07/28 12:15:05  cjlee
## STG_COMMON ó�� ����..... �Ϸ�
##
##
