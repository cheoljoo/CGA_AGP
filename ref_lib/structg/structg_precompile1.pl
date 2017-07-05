#!/usr/bin/perl
##
## $Id: structg_precompile1.pl,v 1.5 2006/08/21 11:12:32 cjlee Exp $
##

##   -----      STG_COMMON 을 처리하는 Process    ----    ####
# <TAG_KEY>
# <TAG_COMMOM_MEMBER:... >
# <STG_COMMON:...>
#
##주석: [[2006.07.27]]
##주석: STG_COMMON typedef struct _stg_call {
##주석: 	##	;;   STG_COMMON_MEMBER{"STIME time"} =  %CreateTime% /**<  기본 주석  : DEFAULT로 없으면 이것을 사용하게 됨 : 초까지 나타내는 시간 */ 
##주석: 	STIME time;	 %CreateTime% /**<  기본 주석  : DEFAULT로 없으면 이것을 사용하게 됨 : 초까지 나타내는 시간 */ 
##주석: 		##	;;   STG_COMMON_MEMBER_LOG_KUN{"STIME time"} = %Time%  /**< 주석2 */ 	
##주석: 		<TAG_COMMON_MEMBER:LOG_KUN>%Time%  /**< 주석2 */ 	
##주석: 		##	;;   STG_COMMON_MEMBER_LOG_ME{"STIME time"} = %METime%  /**< 주석3 */ 	
##주석: 		<TAG_COMMON_MEMBER:LOG_ME>%METime%  /**< 주석3 */ 
##주석: 	MTIME		utime;  %MTime%	 	/**< micro 초 나타내는 시간 */
##주석: 
##주석: <TAG_KEY>
##주석: 	IP4 		uiIP;					%IPAddr%				/**< IP address */
##주석: 	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
##주석: 	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
##주석: </TAG_KEY>
##주석: 
##주석: 	U32		uiBase; 			%BASE%  /**< BASEID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>BASE_ID:{DIGIT}#
##주석: 	U8		uiNID[EX_MAX_NID]; 	 %NID%  /**< NID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>NID:{VALUE}#  
##주석: 		<TAG_COMMON_MEMBER:LOG_KUN> /**< NID */  %NID%		#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_NID:{VALUE}#  
##주석: 	U32		uiSID; 				
##주석: 		<TAG_COMMON_MEMBER:LOG_ME>  /**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>ME_SID:{DIGIT}#
##주석: 		<TAG_COMMON_MEMBER:LOG_KUN>  /**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_SID:{DIGIT}#
##주석: } LOG_CALL;
##주석: 
##주석: STG_LOG_TEXT_PARSING typedef struct _... {
##주석: 	<STG_COMMON:LOG_CALL>
##주석: 	U32		Test1;
##주석: } LOG_KUN;
##주석: 
##주석: STG_LOG_TEXT_PARSING typedef struct _... {
##주석: 	<STG_COMMON:LOG_CALL>
##주석: 	U32		Test2;
##주석: } LOG_ME;
##주석: 
##주석: 이것을 안에 선언할때는 <STG_CALL>
##주석: 이것에 대래서 처리를 해주어야 하는데????
##주석: STG_CALL이라는 것으로 한개를 더 만들 것이다.
##주석: 
##주석: TAG_COMMON:KEY안의 각각에 대한 KEY  HASH를 만들어두어야 한다.
##주석: 그 안의 DATA는 위의 LOG_CALL이 되어질 것이다.
##주석: - signal은 어떻게 존해를 할 것인가?  uiCommand가 들어간 structure를 자동으로 한개씩 만들어준다. 해당 key로 뭔짓을 하게 하면 될 것이다.
##주석:   LOG_CALL앞에 uiCommand 만을 추가해도 문제가 되지는 않을 것이다.  그 command를 보고 
##주석:   ADD일 경우 -> 그 안에 set되어진 값을 보고 IP가 set되어져있다면 IP로된 hash안의 값에 현재의 값들을 반영하면 될 것으로 보인다. (FIRST, LAST가 존재해야 하는지는 고려???)
##주석:   	COMMON_DATA값들은 FIRST,LAST 규칙을 보고 추가를 해주던지 하면 될 것이고, KEY가 여러개 포함되는 것이면 각기 찾아서 set해주는것을 기본으로 한다.  
##주석:   DEL일 경우 -> 그 안에 set되어진 값이 IP , TMSI인 경우는 각각을 찾아서 HASH DEL을 해주면 되고
##주석:   ALL_DEL인 경우는 각각을 찾아서 loop를 각기 한번씩 더 돌아 완전히 지워주는 것을 기본으로 한다.
##주석: 
##주석: 이것을 기본으로 생성해야 하는 것이 2가지가 있다.
##주석: 앞 부분 --> 위의 기본 <COMMON> structure {} 으로 있어야하며  KEY 만 // KEY+DATA
##주석: 뒷 부분 --> 부가 정보를 포함하는 것  // KEY + DATA + Timer/Combination같은 부가 정보 
##주석: 뒷 부분 --> uiCommand를 포함하는 정보로 한개 더 추가 (signal을 위한 정보) 
##주석: 함수 --> 각 field를 보면서 null이 아니면 set을 해주거나(FIRST) , LAST (값이 NULL이 아니면 덮어쓴다.)
##주석: 
##주석: 기존 STG_HASH_KEY와는 어떻게 구별을 할 것인가? 일단  structure가 구분되어진다.
##주석: GLOBAL에는 LOG관련 정보가 있으며 , COMBINATION , STAT 관련 정보들이 들어가있다.
##주석: STG에 STC를 쌍으로 묶어서 한개의 Package로 사용하면 될 것으로 보인다. 
##주석: (STC에 Primitives들을 정의를 하면 한개의 library가 나올수 있을 것으로 보인다. makefile도 추가)
##주석: 
##주석: 문법 : STG_COMMON 으로 시작을 하며 
##주석: <TAG_KEY> 로 이중에서 KEY만을 정의
##주석: U32 uiBase; 뒤에 나오는 것은 밑에 정의된게 없으면 default값
##주석: 밑에 <TAG_COMMON_MEMBER:TT> 로 정의 되면 TT structure에서는 여기 정의된 의미로 사용되어짐을 의미
##주석: 
##주석: 
##주석: 예상 결과 :
##주석: /* LOG로 정의되지 않음 */
##주석: # BASIC_TYPEDEF #
##주석: typedef struct _stg_call {
##주석: 	STIME time;	 /**<  기본 주석  : DEFAULT로 없으면 이것을 사용하게 됨 : 초까지 나타내는 시간 */ 
##주석: 	MTIME		utime;  	/**< micro 초 나타내는 시간 */
##주석: 
##주석: 	IP4 		uiIP;					%IPAddr%				/**< IP address */
##주석: 	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
##주석: 	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
##주석: 
##주석: 	U32		uiBase; /**< BASEID */ 	
##주석: 	U8		uiNID[EX_MAX_NID]; 	 /**< NID */  
##주석: 	U32		uiSID; 				
##주석: } LOG_CALL;
##주석: 
##주석: #BASIC_SIGNAL #
##주석: typedef struct ... {
##주석: 	U32	uiCommand;
##주석: 	LOG_CALL aLOG_CALL;
##주석: } LOG_CALL_SIGNAL;
##주석: 
##주석: # BASIC_KEY #
##주석: typedef struct ...  {
##주석: 	IP4 		uiIP;					%IPAddr%				/**< IP address */
##주석: } LOG_CALL_KEY_uiIP;
##주석: 
##주석: typedef struct ...  {
##주석: 	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
##주석: } LOG_CALL_KEY_ucTMSI;
##주석: 
##주석: typedef struct ...  {
##주석: 	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
##주석: } LOG_CALL_KEY_ucIMSI;
##주석: 
##주석: # BASIC_DATA #
##주석: typedef struct ... {
##주석: 	LOG_CALL	aLOG_CALL;
##주석: 	U64			TimerId;
##주석: 	/* LOG정보 반복 */
##주석: 	U16 		usCntLOG_CFLOW;
##주석: 	U16 		usIsDoneLOG_CFLOW;
##주석: 	LOG_CFLOW 	*pLOG_CFLOW;
##주석: 	/* Combination / Stat 정보 */
##주석: 	COMBI_NewTable 	aCOMBI_NewTable;
##주석: 	COMBI_Accum 	aCOMBI_Accum;
##주석: 	COMBI_NewTest 	aCOMBI_NewTest;
##주석: 	STAT_Accum 	aSTAT_Accum;
##주석: 	STAT_NewTest 	aSTAT_NewTest;
##주석: } LOG_CALL_DATA;
##주석: 
##주석: STG_LOG_TEXT_PARSING typedef struct _... {
##주석: # BASIC_COMMON_LOG_KUN #
##주석: 	STIME time;	 %Time%  /**< 주석2 */ 	
##주석: 	MTIME		utime;  %MTime%	 	/**< micro 초 나타내는 시간 */
##주석: 
##주석: 	IP4 		uiIP;					%IPAddr%				/**< IP address */
##주석: 	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
##주석: 	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
##주석: 
##주석: 	U32		uiBase; 			%BASE%  /**< BASEID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>BASE_ID:{DIGIT}#
##주석: 	U8		uiNID[EX_MAX_NID]; 	 /**< NID */  %NID%		#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_NID:{VALUE}#  
##주석: 	U32		uiSID; 				/**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>KUN_SID:{DIGIT}#
##주석: 
##주석: 	U32		Test1;
##주석: } LOG_KUN;
##주석: 
##주석: STG_LOG_TEXT_PARSING typedef struct _... {
##주석: # BASIC_COMMON_LOG_ME #
##주석: 	STIME time;	 %METime%  /**< 주석3 */ 
##주석: 	MTIME		utime;  %MTime%	 	/**< micro 초 나타내는 시간 */
##주석: 
##주석: 	IP4 		uiIP;					%IPAddr%				/**< IP address */
##주석: 	U8			ucTMSI[DEF_SIZE_TMSI];	%TMSI%					/**< TMSI */
##주석: 	U8			ucIMSI[DEF_SIZE_IMSI];	%IMSI%					/**< IMSI */
##주석: 
##주석: 	U32		uiBase; 			%BASE%  /**< BASEID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>BASE_ID:{DIGIT}#
##주석: 	U8		uiNID[EX_MAX_NID]; 	 %NID%  /**< NID */ 	#PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>NID:{VALUE}#  
##주석: 	U32		uiSID; 				/**< SID */  #PARSING_RULE:^^:REQ_HDR:^^:<HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>ME_SID:{DIGIT}#
##주석: 
##주석: 	U32		Test2;
##주석: } LOG_ME;
##주석: 
##주석: FIRST / LAST 추가 : 하는 김에 이것도 추가 - combination등에도 추가되어져야 한다.  
##주석: 그냥 keyword로 Fix를 시킬 예정이다. 특수문자와 일반 문자의 혼합의 Keyword
##주석: #FIRST#  / #LAST#
##주석: 없으면 default 는 #FIRST#


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


# function.upr의 내용대로 subroutine에 대해서도 같은 방식의 주석을 단다.
#/** print_fp function.
# *
# *  print_fp String , FileDescriptor.....
# *  perl의 장점으로는 뒤의 FileDescriptor를 "ENC" / ENC 모두 통용된다는 것이다.
# *
# *  @param  string
# *  @param  FileDescriptors
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl을 변형하여 flat....h 를 만든 화일
# *
# *  @exception  STD일경우 DBG으로 처리하게 함.
# *  @note      +Note+
# **/
sub print_fp
{
	my $print_contents;
	my $to_file;

	$print_contents = shift @_;
	foreach $to_file (@_) {
		## STD라는 것은 DBG에 대해서 만들어둔 것으로 STD 나 DBG이나 같은 값을 의미한다.  
		print $to_file $print_contents;
	}
}

### 처리 가능한 INPUT 파일 내용 (sample : hash.stg)
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
# * hash안의 node들의 structure.
# * 확장을 가능하게 하기 위해서 key와 data 부분을 분리 하였다.
# * key와
# * @see hash.c  다음 내용을 본다.
# */
#typedef struct _st_hashnode {
#    struct _st_hashnode *next  ;  ///< self-pointer
#    struct _st_hashnode **prev; /*!< self-pointer */
#    U8 *pstKey;       ///< struct Key
#                        /*!< 계속 되는 comment를 위한 시험 \n
#                         *    잘 써지겠지요 */
#    U8 *pstData;      ///< struct Data  \n
#                        ///< TTT
#   U32     uiSBS;
#   stAAA   stAaa;
#} stHASHNODE;
#
#
#/**
# * @brief Hash 전체를 관리하는 structure
# * \brief Hash 전체를 관리하는 structure
# * */
#typedef struct _st_hashinfo {
#    stHASHNODE **hashnode  ;  //!< self-pointer
#    U16 usKeyLen;           //!< Node들이 사용할 Key 길이.  Key 비교와 copy를 위해서 사용
#    U16 usSortKeyLen;       /*!< Node들이 Sort시 사용할 길이.
#                                 Key안에서 Sort를 위해서 사용할 앞에서 부터의 길이
#                                 assert(usKeyLen >= usSortKeyLen) */
#    U16 usDataLen;          /*!< Node에서 사용할 DataLen
#                                 @exception pstData의 Structure의 type도 필요하면 추가 할수 있어야 할 것이다. */
#    U32 uiHashSize;         /*!< Hash 크기. 임의의 설정을 위해서 set */
#   U8  ucIMSI_a[];         /*!< 단말 ID : IMSI값 - [15] 마지막에는 항시 NULL을 넣어주어야 한다. */
#   U8  ucIMSI_b[16];           /*!< 단말 ID : IMSI값 - [15] 마지막에는 항시 NULL을 넣어주어야 한다. */
#   stHASHNODE  *pstGtp;
#   stHASHNODE  stGtp;
#   U16 usLen[2];
#   IP4 uiIPAddress;
#} stHASHINFO;

### WARNING -- 처리 안되는 INPUT 파일 내용
#typedef struct { } AAA;      // struct 뒤에 이름이 빠졌음.
#typdef struct _st_aaa { } ;  // typedef의 이름이 빠졌음.
#tpedef struct _st_aaa {      // structure를 호출은 가능하지만
#    struct _st_bbb {         // 이것처럼 nested structure를 정의하는 부분이 들어가면 처리가 안됨.
#    ....
#    }
#} TTT ;
#tpedef struct _st_aaa {      // structure를 호출은 가능하지만
#    struct _st_bbb *ppp;       // pointer만 가능
#    struct _st_ccc ttt;        // pointer가 아닌 값은 제대로 수행하지 못함.
#    ....                           //  해결 : typedef로 된 것은 stCCC tttt; 처럼 선언 가능
#    }
#} TTT ;                      // 주의 : struct는 pointer로만 사용하고 모두 typedef된 모양으로만 사용하라.!!!



### structg.pl hash.stg과  같이 INPUT file의 이름을 받게 하였음.
### input file은 한개를 만든 것으로 한다.  (나주에 합쳐야 하는 것은 추구 고려)
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

### STG : 확장자 stg를 가지는 INPUT FILE
open(STG , "<$inputfilename");

while ($line = <STG>) {

	### 주석등을 그래도 살려두기 위해서 무조건 찍게 해주었다. 
	### 이상한 것을 filtering을 해야 한다면 윗 부분의 next; 를 이용하여야 한다.
	### Find the keyword and Remove the keyword
	###	type 1. typedef struct
	###	type 2. STG_HASH_KEY typedef struct
	###	type 3. STG_COMBINATION_TABLE typedef struct

    ### typedef struct로 된 부분만을 뽑아내기 위해서 사용하는 부분이다.
    ### $in_typedef 가 1 이면서  \} .... ; 까지가  typedef 의 정의 마지막 부분이다.
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
		$TAG_DEFINE{$tag_define_name} =~ s/\/\*.+\*\///g;    # 주석문 삭제
		next;
	}
	if ($line =~ /typedef\s+struct\s+\w+\s*{/){  $in_typedef = 1 ; }		# ... typedef struct .. 로써 
	if ($line =~ /^\s*\}\s*\w+\s*\;/){  
		$in_typedef = 2; 
		print DBG "DBG_TYPEDEF_CR ($line) ==> \n$typedef_cr\n";
		print DBG "DBG_TYPEDEF_ORG ($line) ==> \n$typedef_prt\n";
	}

	### //... 시작하는 주석을 /*  ... */ 형태로 바꿔줌
	### /// A --> /**	A		*/
	if ($line =~ s/\/\/\/\</\/\*\*\</){ $line .= "\*\/ "}
	### //  A --> /*	A		*/  http:// 등이 있어서 지워주면 안된다.
	### 기본을 ///< 을 사용하거나 , /* 을 사용하는 것을 기본으로 한다. 
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
		#$typedef_cr =~ s/\/\*.+\*\///g;    # 주석문 삭제
		$typedef_prt .= $line_prt;

		### /* ... */ 주석을 삭제
		## 주석처리 때문에 $typedef는 \n 이 들어가지 않는 것으로 만들어져야 한다.
		## 이를 해결하기 위해서는 어떻게 해야 할까?
		## $typedef_cr을 만들어야 할 것으로 보인다.
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
			
			# 초기화 
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
									print DBG " $1 $vvv 심\n";
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


## NTAM을 위한 것은 한개를 더 돌려서 header file을 한개 더 만드는 것으로 하자.
## NTAM용으로 perl을 한개 더 만들어서, 만든 header file을 stg로 돌리면 같은 값이 나오게만 하면 될 것으로 보인다. 

## 
## $Log: structg_precompile1.pl,v $
## Revision 1.5  2006/08/21 11:12:32  cjlee
## precompile : STG_COMMON 에서 alternative를 한개도 사용하지 않을때 문제 해결 (STG_BASIC을 사용)
## aqua.stg
## structg_precompile1.pl
##
## Revision 1.4  2006/07/31 12:01:22  cjlee
## integer , string 변환 완료. (각 경우 만족)
## LOG_ME가 제대로 , LOG_KUN은 변경해야 함.
##
## Revision 1.3  2006/07/31 06:39:04  cjlee
## precompile이 되게 함.
## KUN , ME에 대해서 call 관련 structure에 대한 처리 완료
## structg.pl -> input : argv , output : 안의 FileName : 으로 된 것
## structg_precompile1.pl -> input : pre.stg , output : userfile_pre.stg
## make pre --> input : pre.stg , output : userfile_pre.stg
##
## Makefile안을 보면 좀더 상세히 알수 있음.
##
## Revision 1.2  2006/07/31 02:12:01  cjlee
## Pre-Compile
##
## Revision 1.1  2006/07/28 12:15:05  cjlee
## STG_COMMON 처리 대충..... 완료
##
##
