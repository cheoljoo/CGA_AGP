#!/usr/bin/perl
##
## $Id: pstg.pl,v 1.19 2007/04/02 13:09:12 cjlee Exp $
##

## pstg.pl		2006.08.22
#  stg�� structg.pl�� compile�ϱ� ���� stg������� ��������ִ� �ϵ��� �ϴ� ������
#  ���� �����ϴ� ������δ� ::
#  STG_COMMON
#  		STG_COMMON : <TAG_KEY>    </TAG_KEY>
#  		STG_COMMON : <tAG_COMMON_MEMBER> alternative rule
#  <TAG_DEFINE_START: .. >   <-- structg.pl ������ ó�� ���� : ���� �Ҽ��� ����. 
#  <TAG_DEFINE_END: .. >  

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
	foreach_print_hash("TAG_KEY");
	foreach_print_hash("STG_COMMON_caller");
	foreach_print_hash("STG_REPLACE");

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
	if($inputfilename =~ /\.pstg/){
		$outputfilename = $inputfilename;
		$outputfilename =~ s/\.pstg/\.stg/;
	} else {
		print "invalid filename : wrong extension : $inputfilename\n";
		die $error = 1;
	}
}

print "INPUT filename : $inputfilename\n";

open(DBG,">DEBUG_pre.TXT");
open(GLOBAL,">GLOBAL_pre.TXT");
#open(OUTH,">$inputfilename\.Pre1");
open(OUTH,">$outputfilename");
print "OUTPUT filename : $outputfilename\n";

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
	if($line =~ /^\#\#/){
		print DBG "Comments : $line";
		next;
	}
	chop($line);
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

		while($typedef_prt =~ /\s*\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/){
			my $common_name = $1;
			#$typedef_prt =~ s/\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/$STG_COMMON{$1}/g;
			$STG_COMMON = $$common_name{$TYPEDEF_NAME};
			if($STG_COMMON eq ""){ 
				$STG_COMMON = $$common_name{"STG_BASIC"}; 
			}
			print DBG "foreach $common_name : $TYPEDEF_NAME STG_COMMON $STG_COMMON\n";
			my $stg_common_association;
			my $stg_common_text_parsing;
			my $stg_common_normal;
			$stg_common_association = "\t/* STG_COMMON:$common_name */\n";
			$stg_common_text_parsing = "\t/* STG_COMMON:$common_name */\n";
			$stg_common_normal = "\t/* STG_COMMON:$common_name */\n";
			@temp = split('\n',$STG_COMMON);
			foreach $temp (@temp){
				my $stg_var="";
				my $stg_ass="";
				my $stg_parsing="";
				my $stg_checking_value="";
				my $stg_tag_define="";
				my $stg_comments="";
				

				print DBG "foreach : $temp\n";
				if($temp =~ s/<\s*TAG_DEFINE\s*:\s*(\w+)\s*>\s*//){
						$stg_tag_define = $1;
						print DBG "TAG : $stg_tag_define : $temp\n";
				}
				if($temp =~ /^\s*ALTERNATIVE_ASSOCIATION/){
					$stg_common_association .= "$temp\n";
					next;
				} elsif($temp =~ /^\s*ALTERNATIVE_RULE/){
					$stg_common_text_parsing .= "$temp\n";
					next;
				}
				
				if($temp =~ /([^:\n\r]*);/){
					my $sss = $1;
					my $temp1 = "";
					my $temp2 = "";

					$sss =~ /(\s*\w+)\s*(.*)$/;
					$temp1 = $1;
					$temp2 = $2;
					if($stg_tag_define eq ""){
							$stg_var = $sss;
					} else {
							$stg_var = "$temp1 		<TAG_DEFINE:$stg_tag_define>$temp2";
							print DBG "-#TAG : $stg_tag_define : $stg_var :- $sss\n";
					}
				}
				if($temp =~ /([^:\n\r]*):([^;]*);/){
					my $sss = $1;
					my $ssd = $2;
					my $temp1 = "";
					my $temp2 = "";

					$sss =~ /(\s*\w+)\s*(.*)$/;
					$temp1 = $1;
					$temp2 = $2;
					if($stg_tag_define eq ""){
							$stg_var = $sss;
					} else {
							$stg_var = "$temp1 		<TAG_DEFINE:$stg_tag_define>$temp2";
							print DBG "--TAG : $stg_tag_define : $stg_var :- $sss\n";
					}
					$stg_ass = $ssd;
				}
				if($temp =~ /(\/\*[^\/]*\*\/)/){
					$stg_comments = $1;
				}
				if($temp =~ /(#PARSING_RULE.*#)/){
					$stg_parsing = $1;
				}
				my $stg_temp=$temp;
				while($stg_temp =~ s/(@[^@]*@)//){
					$stg_checking_value .= "$1 	";
				};
				if($stg_ass){
					$stg_common_association .= "$stg_var:$stg_ass;  $stg_checking_value    $stg_comments   /**< Reference : $common_name  : $stg_parsing */  \n";
				} else {
					$stg_common_association .= "$stg_var;  $stg_checking_value    $stg_comments   /**< Reference : $common_name  : $stg_parsing */  \n";
				}
				$stg_common_text_parsing .= "$stg_var;  $stg_parsing   $stg_checking_value  $stg_comments   /**< Reference : $common_name : $stg_ass */\n";
				$stg_common_normal .= "$stg_var;  $stg_checking_value  $stg_comments   /**< Reference : $common_name : $stg_parsing  : $stg_ass */\n";
			}
			print DBG "normal : $stg_common_normal\n";
			print DBG "association : $stg_common_association\n";
			print DBG "text_parsing : $stg_common_text_parsing\n";
			if($typedef_prt =~ /STG_LOG_TEXT_PARSING/){
				$typedef_prt =~ s/\t?\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/$stg_common_text_parsing/;
				print DBG "STG_COMMON = $stg_common_text_parsing\n";
			} elsif($typedef_prt =~ /STG_ASSOCIATION/){
				$typedef_prt =~ s/\t?\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/$stg_common_association/;
				print DBG "STG_COMMON = $stg_common_association\n";
			} else {
				print DBG "STG_COMMON = $stg_common_normal\n";
				$typedef_prt =~ s/\t?\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/$stg_common_normal/;
			}
			$STG_COMMON_caller{$TYPEDEF_NAME} = $common_name;
		};
		if($typedef_prt =~ /\<\s*STG_REPLACE\s*\:\s*(\w+)\s*\>/){
			my $to;
			my $comment;
			$to = $1;
			$comment = "/* <STG_REPLACE:$to> */";
			$typedef_prt =~ s/\<\s*STG_REPLACE\s*\:\s*(\w+)\s*\>/$comment\n$STG_REPLACE{$to}/g;
		}

		if($typedef_cr =~ /^\s*STG_REPLACE\s+typedef\s+struct/){
			my $from;
			$typedef_cr =~ s/^\s*STG_REPLACE\s*//g; 

			@temp_vars = split("\n",$typedef_cr);
			foreach $temp_vars (@temp_vars){
				print DBG "TT \$temp_vars = $temp_vars\n";	
				if($temp_vars =~ /^(\s*\w+\s*.+)\;(.*)$/){
					$STG_REPLACE{$TYPEDEF_NAME} .= $temp_vars . "\n";
				}
			}
			print OUTH $typedef_cr;
		} elsif($typedef_cr =~ /^\s*STG_COMMON\s+typedef\s+struct/){
			my $from;
			$typedef_cr =~ s/^\s*STG_COMMON\s*/STG_ASSOCIATION /g; 
			
			# �ʱ�ȭ 
			$typedef_prt = "";
			$undefined_name = "$TYPEDEF_NAME";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			foreach $temp_vars (keys %$TYPEDEF_NAME){
				$$TYPEDEF_NAME{$temp_vars} = "";
			}
			$$TYPEDEF_NAME{"STG_BASIC"} = "";

			print DBG "SSTG_COMMON alternative_statement: $alternative_statement\n";

			@temp_vars = split("\n",$typedef_cr);
			foreach $temp_vars (@temp_vars){
				print DBG "TT \$temp_vars = $temp_vars\n";	
				$undefined_name = "STG_COMMON_TT";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$TYPEDEF_NAME} = $TYPEDEF_NAME;
				if($temp_vars =~ /\<\s*TAG_COMMON_MEMBER\s*\:\s*(\w+)\s*\>(.*)$/){
					if("" eq $$TYPEDEF_NAME{$1}){
						print DBG "SSTG_COMMON_MEMBER : $1\n";
						$$TYPEDEF_NAME{$1} = $$TYPEDEF_NAME{"STG_BASIC"};
						$undefined_name = "$TYPEDEF_NAME";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$1} = $$TYPEDEF_NAME{"STG_BASIC"};
					}
					$alternative_statement .= $temp_vars . "\n";
					print DBG "SSTG_COMMON_MEMBER alternative_statement: $alternative_statement\n";
				} elsif($temp_vars =~ /^\s*ALTERNATIVE_ASSOCIATION/){
					foreach $vars (keys %$TYPEDEF_NAME){
						$undefined_name = "$TYPEDEF_NAME";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$vars} .= "$temp_vars\n";
						print DBG "NULL ALTERNATIVE_ASSOCIATION SSTG_COMMON $TYPEDEF_NAME $vars: $$TYPEDEF_NAME{$vars}\n";
					}
				} elsif($temp_vars =~ /^\s*ALTERNATIVE_RULE/){
					foreach $vars (keys %$TYPEDEF_NAME){
						$undefined_name = "$TYPEDEF_NAME";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$vars} .= "$temp_vars\n";
						print DBG "NULL ALTERNATIVE_RULE SSTG_COMMON $TYPEDEF_NAME $vars: $$TYPEDEF_NAME{$vars}\n";
					}
				} elsif($temp_vars =~ /^(\s*\w+\s*.+)\;(.*)$/){
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
					while($temp =~ /(\@[^@]*\@)/){
						$typedef_prt .= "\t$1 ";
						$temp =~ s/(\@[^@]*\@)//;
					}
					$typedef_prt .= "\n";

					# ==> $LOG_KUN_MSG { REQ_HDR } =  LOG_KUN_MSG_STATE_REQ_HDR
					$undefined_name = "STG_COMMON_" . $TYPEDEF_NAME . "_member";
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$temp1} = $temp2;

					print DBG "SSTG_COMMON alternative_statement: $alternative_statement\n";
					if("" eq $alternative_statement){
						foreach $vars (keys %$TYPEDEF_NAME){
							$undefined_name = "$TYPEDEF_NAME";
							$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
							$$undefined_name{$vars} .= $statement . "\;\t" . $rule . "\n";
							print DBG "NULL SSTG_COMMON $TYPEDEF_NAME $vars: $$TYPEDEF_NAME{$vars}\n";
						}
					} else {
						foreach $vvv (keys %$TYPEDEF_NAME){
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
								$undefined_name = "$TYPEDEF_NAME";
								$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
								$$TYPEDEF_NAME{$vvv} .= $statement . "\;\t" . $rule . "\n";
							} else {
								$undefined_name = "$TYPEDEF_NAME";
								$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
								$$TYPEDEF_NAME{$vvv} .= $statement . "\;\t" . $yes_rule . "\n";
							}
						}
					}
					$alternative_statement = "";
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
## $Log: pstg.pl,v $
## Revision 1.19  2007/04/02 13:09:12  cjlee
## add the comments function in the pstg and stg's file
## ex)
## ##Stc_.....
##
## Revision 1.18  2007/03/08 00:44:59  cjlee
## bug fix: STG_ASSOCIATION�� ��� bug �ذ�
##
## Revision 1.17  2007/03/02 07:19:23  cjlee
## STG_COMMON���� �Ѱ��� ����� �� �ִ� �Ͱ��� multi�� �ø�
## �ּ��� �� �� ���ü� �մ� ���� ù��° �ּ��� �츲
## @...@ ���� ������ �׷��� �����
##
## Revision 1.16  2007/02/28 04:05:51  cjlee
##  LOG_COMMON (STG_COMMON)�ȿ����� TAG_DEFINE:... ��밡��
##
## Revision 1.15  2007/02/27 08:02:25  cjlee
## pstg.pl : LOG_COMMON������ @..@�� �κ��� �����
##
## Revision 1.14  2006/11/14 03:31:25  cjlee
## ����  :  STG_COMMON  ����  ALTERNATIVE_ASSOCIATION  , ALTERNATIVE_RULE ������.
## ALTERNATIVE_RULE        #PARSING_RULE:^^:WIPI_REQ_HDR:^^:<COOKIE>MIN={DIGIT}#
## - pstg.pl - STG_COMMON�ȿ�  �߰���.
## 	ALTERNATIVE_RULE        #PARSING_RULE:^^:WIPI_REQ_HDR:^^:<COOKIE>MIN={DIGIT}#
## 	�� �߰������ν� CILOG�� ���� ����� �Ǵ����� check�Ҽ� �ִ�.
## - aqua.pstg
## 	LOG_COMMON�ȿ�
## 	ALTERNATIVE_RULE        #PARSING_RULE:^^:WIPI_REQ_HDR:^^:<COOKIE>MIN={DIGIT}# �߰�
##
## Revision 1.13  2006/11/13 08:32:16  cjlee
## ����  :  STG_COMMON  ���� @...@ �� ������
## @CILOG_HIDDEN@      ,    @CHECKING_VALUE:...@
## 	- pstg.pl - STG_COMMON�ȿ�  �߰���.
## 		@CHECKING_VALUE:string , string...@
## 		@CHECKING_VALUE:digit~digit , digit~digit...@
## 		�� �߰������ν� CILOG�� ���� ����� �Ǵ����� check�Ҽ� �ִ�.
## 	- aqua.pstg
## 		���� �߰�   $ make aqua
## 		GLOBAL.TXT �� AQUA2/TOOLS/HandMade ���� �ʿ���.
##
## Revision 1.12  2006/11/03 09:30:27  cjlee
## �ּ��� �ٴ� ��� ���� : log_table.stc�� ���� ���� ��� ���ؼ� �߰�
##
## Revision 1.11  2006/09/27 00:21:19  cjlee
## STG_COMMON����
## U32 TT; �̷� ����� �ȵǾ��� �� �ذ�
## U32 TT; �� Association�� ���� U32 TT:PP; ��� ����
##
## Revision 1.10  2006/09/26 07:27:24  cjlee
## STG_ASSOCIATION �߰�
## - STG_COMMON -> STG_ASSOCIATION���� ����
## - pstg.pl���� <TAG_KEY> ó�� ����
## - ASSOCIATION�� ���� ASSOCIATION.stcI �⺻ �߰�
##
## Revision 1.9  2006/09/19 02:42:24  cjlee
## WIPI download  �������� �����߰�
##
## Revision 1.8  2006/09/11 08:53:55  cjlee
## no message
##
## Revision 1.7  2006/09/08 05:27:42  cjlee
## Configuration File ó��
##
## Revision 1.6  2006/09/07 08:08:28  cjlee
## *** empty log message ***
##
## Revision 1.5  2006/09/07 00:20:53  cjlee
## debugging
##
## Revision 1.4  2006/09/06 06:56:03  cjlee
## <TAG_KEY> ��� ����Ҽ� �ְ� �߰�
## structg.pl ������ �̰��� ���� ó���Ҽ� �ְ� ���ش�. : ���⼭�� .h���� �߰�
## pstg.pl ������ �ڿ� �߰���������, structg.pl�� �� ������ �ϹǷ� �� KEY��� ���ǵ� �������� strucuture���� dec,enc,prt���� �پ��� �Լ����� �����Ǿ���.
##
## Revision 1.3  2006/09/04 05:53:38  cjlee
## STG_REPLACE �߰�
## : ���״�� �״�� ��ġ�� ��Ű�� ���̴�.
## �����Ͽ� ���� ���� ���� ������ ���δ�.
##
## Revision 1.2  2006/09/04 02:46:24  cjlee
## 1. COMMON���� caller�� HASH_KEY structure�� .h�� ���� �������� �߰�
## HASH_LEY_ �� typedef�̸� �տ� prefix�� ���̴� ������� �߰���.
## 2. TAG_DEFINE ó�� ���� : structg.pl���� ó���� ���� (�ߺ��� ������ ����.)
##
## Revision 1.1  2006/08/22 01:30:14  cjlee
## 1. precomile�� �ؾ��ϴ� �͵鿡 ���� Ȯ���ڴ� .pstg �� �ϴ� ���� ���� ������ ���δ�. �̰��� �ϸ� Ȯ���ڰ� .stg�� ������ �ϸ� �� ������ ���δ�.
## 	pstg.pl ����
## 	pstg�� file�� : test.stg -> test.pstg  , aqua.stg -> aqua.pstg
## 	Makefile�� flow , aqua , test  �������� �߰�
##
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
