#!/usr/bin/perl
##
## $Id: structg.pl,v 1.244 2007/05/31 01:19:04 cjlee Exp $
##


use strict 'vars';


# 어떠한 결과를 계속 저장을 하는 global variable
# sub print_all_global_var  에서 아래의 변수들의 값을 찍어준다.
our $inputfilename; 		# input filename
our $file_delimiter = "\t";
our $flatprefix = "stFlat_";
our $shortprefix = "Short_";
our $expansionprefix = "";
our $shortremoveprefix = "TTTTT__";
our $pointerprefix = "p";		# TIME64 *pTIME;   
our $staticprefix = "a";		# TIME64 aTIME;
our $outputdir;
our $FileName;
our $FlatFileName;
our $typedef_def_cnt=100;
our $stg_hash_timer_type;
our $stg_hash_timer_name;
our $stg_hash_sess_timeout;
our $stg_hash_del_timeout;
our $stg_hash_size;
our $stg_hash_key;
our $prefix_logdb_table="LOG_";
our $stg_hash_first_data; 	# 첫번째 HASH key가 되는 것으로 여기에 매달린 것들을 활용하기 위한 DATA structure의 이름이다.  
our $stg_hash_first_key; 
our $stg_hash_first_key_name; 
our $stg_hash_first_key_type; 
our $stg_hash_first_key_is; 
our %lex_option;
our %stg_stc_file;		# 이상하게 이것만 global에 값이 안 나오는데 이유를 모르겠음.  ???
our %primitives;
our %type;
our %type_size;
our %type_enc_func;			# NTOH32일때는 %type_twin_func = 1 , ntohl일때는 %type_twin_func = 0
our %type_twin_func;		# NTOH32(to,from) 으로 처리하는 것 , off일때는 ntohl 같은 으로 return하는 값을 사용할때
our %type_printPre;
our %type_printM;
our %type_printV;
our %type_define;
our %type_CREATE;
our %type_set_func;
our %type_set_type;
our %type_is;
our %filelist;				# $filelist{"stAAA_Enc.c"} = "CFILE"
our %typedef_enc_func;		# stAAA_Enc
our %typedef_dec_func;		# stAAA_Dec
our %typedef_prt_func;		# stAAA_Prt
our %typedef_fpp_func;
our %typedef_combi_func;		# Set_Combination_Once
our %typedef_stat_func;		# Set_Combination_Once
our %typedef_contents;		# stAAA안의 member들
our %flat_typedef_contents;		# stFlat_stAAA안의 member들
our %function_def;			# void stAAA_Enc(_stAAA *pstTo,_stAAA *pstFrom)
our %flat_function_def;			# flat : DB....
our %typedef;				# $typedef{stAAA} = stflat_stAAA
our %typedef_def_cnt;		# stAAA  -> #define STG_DEF_stAAA  10
our %typedef_def_num;		# stAAA  -> #define STG_DEF_stAAA  10   $typedef_def_num{10} = STG_DEF_stAAA
our %typedef_member_count;		# typedef struct안의 member들의 수 (flat기준의수)
our %stat_typedef;			# stg_combination_table 에서 수행 func들을 삽입하고, stg_hash_key()안에서 이를 사용하여 .c 화일을 만든다. 
our %association_typedef;			# stg_combination_table 에서 수행 func들을 삽입하고, stg_hash_key()안에서 이를 사용하여 .c 화일을 만든다. 
our %combi_typedef;			# stg_combination_table 에서 수행 func들을 삽입하고, stg_hash_key()안에서 이를 사용하여 .c 화일을 만든다. 
our %stat_accumulate;			# stg_stat에서 축적을 요하는 것들을 따로 모은 것이다.  
our %stat_accumulate_typedef;			# stg_combination에서 축적을 요하는 typedef들
our %association_accumulate;			# stg_stat에서 축적을 요하는 것들을 따로 모은 것이다.  
our %association_accumulate_typedef;			# stg_combination에서 축적을 요하는 typedef들
our %combi_accumulate;			# stg_combination에서 축적을 요하는 것들을 따로 모은 것이다.  
our %combi_accumulate_typedef;			# stg_combination에서 축적을 요하는 typedef들
our %combi_inc;			# stg_combination에서 축적을 요하는 typedef들
our %stat_inc;			# stg_combination에서 축적을 요하는 typedef들
our %association_inc;			# stg_combination에서 축적을 요하는 typedef들
our %define_digit;			# #define  DEF_SIZE_SESSIONID	8  로 된 것들을 기억
our %table;					# TABLE_?? 로 정의 된 것과 실제 DB에 들어가야하는 structure들  
our %table_log;					# TABLE_?? 로 정의 된 것과 LOG으로 실제 DB에 들어가야하는 structure들  
our %table_cf;					# TABLE_?? 로 정의 된 것과 CF으로 실제 DB에 들어가야하는 structure들  
our %table_combi;					# TABLE_?? 로 정의 된 것과 COMBINATION으로 실제 DB에 들어가야하는 structure들  
our %table_association;					# TABLE_?? 로 정의 된 것과 ASSOCIATION으로 실제 DB에 들어가야하는 structure들  
our %table_stat;					# TABLE_?? 로 정의 된 것과 STAT으로 실제 DB에 들어가야하는 structure들  
our %Not_flat_table;					# table classes without including the nested typedef structure
our %stg_key_hashs;				# STG_HASH_KEY의 쌍들
our %undefined_typedef;				# STG_HASH_KEY의 쌍들
our @undefined_array;				# STG_HASH_KEY의 쌍들
our @struct_name ;
our @typedef_name ;
our @stc_filearray;
our @global_filearray;
our @stg_filearray;
our %TAG_DEFINE;
our %TAG_KEY;
our %abbreviation_define_name;
our %tag_flow_name;
our %tag_flow_pTHIS;
our %tag_flow_pINPUT;
our %state_diagram_edge_name;
our %state_diagram_edge_pTHIS;
our %state_diagram_edge_pINPUT;
our %ARRAY_SIZE;

our $iterate_comments = "ON";

# %type 
### $FileName (*.h)  안에 정의된 것들을 타나내는 것으로 특이한 것으로는 IP4같은 것을 나름대로 추가를 할수 있다는 것이다.
### IP4 를 중심으로 설명하면
###     type{"IP4"} = 기본 어떤 type인지
###     _size : byte수
###     _func   : encode , decode시 수행할 함수이름
###     _printV : printf(" ...."   %로 type을 선언해야 하는 부분의 모양
###     _printM : printf("  " , ....)  뒤에 변수를 넣어야 하는 부분에 들어가야 하는 모양
###     _define : .h 안에 포함될 내용이다. 
###
### Note : 추후 이  %type을 가지고도 *.h를 자동으로 만들수 있을 것으로 보임 ( #define      U16     unsigned short )
### Current : 수동으로 조작한다고 보시면 됩니다.
$type{"structp"} = "structure pointer";
$type_size{"structp"} = 1;
$type_printV{"structp"} = "0x\%08x";
$type_printM{"structp"} = "(U32)";
$type_set_type{"structp"} = "STG_INTEGER";
$type{"STRING"} = "unsigned char";
$type_size{"STRING"} = 1;
$type_enc_func{"STRING"} = "";
$type_printV{"STRING"} = "\%s";
$type_define{"STRING"} = "unsigned char";
$type_CREATE{"STRING"} = "VARCHAR2";
$type_is{"STRING"} = "strlen";
$type_set_type{"STRING"} = "STG_STRING";
$type{"U8"} = "unsigned char";
$type_size{"U8"} = 1;
$type_enc_func{"U8"} = "";
#$type_printV{"U8"} = "c[\%3d]";
$type_printV{"U8"} = "\%3d";
$type_define{"U8"} = "unsigned char";
$type_CREATE{"U8"} = "VARCHAR2";
$type_is{"U8"} = "strlen";
$type_set_type{"U8"} = "STG_STRING";
$type{"X8"} = "unsigned char";
$type_size{"X8"} = 1;
$type_enc_func{"X8"} = "";
$type_printV{"X8"} = "c[\%02X]";
$type_define{"X8"} = "unsigned char";
$type_CREATE{"X8"} = "VARCHAR2";
$type_is{"X8"} = "strlen";
$type_set_type{"X8"} = "STG_STRING";
$type{"U16"} = "unsigned short";
$type_size{"U16"} = 2;
$type_enc_func{"U16"} = "ntohs";
$type_printV{"U16"} = "\%5d";
$type_define{"U16"} = "unsigned short";
$type_CREATE{"U16"} = "NUMBER";
$type_set_func{"U16"} = "atoi";
$type_set_type{"U16"} = "STG_INTEGER";
$type{"DEF"} = "unsigned int";
$type_size{"DEF"} = 4;
$type_enc_func{"DEF"} = "ntohl";
$type_printV{"DEF"} = "\%d";
$type_printM{"DEF"} = "(U32)";
$type_define{"DEF"} = "unsigned int";
$type_CREATE{"DEF"} = "NUMBER";
$type_set_func{"DEF"} = "atoi";
$type_set_type{"DEF"} = "STG_DEF";
$type{"U32"} = "unsigned int";
$type_size{"U32"} = 4;
$type_enc_func{"U32"} = "ntohl";
$type_printV{"U32"} = "\%u";
$type_printM{"U32"} = "(U32)";
$type_define{"U32"} = "unsigned int";
$type_CREATE{"U32"} = "NUMBER";
$type_set_func{"U32"} = "atoi";
$type_set_type{"U32"} = "STG_INTEGER";
$type{"IP4"} = "unsigned int";
$type_size{"IP4"} = 4;
$type_enc_func{"IP4"} = "ntohl";
#$type_printV{"IP4"} = "\%03d\.\%03d\.\%03d\.\%03d";
$type_printV{"IP4"} = "\%d\.\%d\.\%d\.\%d";
$type_printM{"IP4"} = "HIPADDR";
$type_define{"IP4"} = "unsigned int";
$type_CREATE{"IP4"} = "NUMBER";
$type_set_type{"IP4"} = "STG_IP";
$type{"S8"} = "char";
$type_size{"S8"} = 1;
$type_enc_func{"S8"} = "";
#$type_printV{"S8"} = "c[\%3d]";
$type_printV{"S8"} = "\%3d";
$type_define{"S8"} = "char";
$type_CREATE{"S8"} = "VARCHAR2";
$type_is{"S8"} = "strlen";
$type_set_type{"S8"} = "STG_STRING";
$type{"S16"} = "short";
$type_size{"S16"} = 2;
$type_enc_func{"S16"} = "ntohs";
$type_printV{"S16"} = "\%5d";
$type_define{"S16"} = "short";
$type_CREATE{"S16"} = "NUMBER";
$type_set_func{"S16"} = "atoi";
$type_set_type{"S16"} = "STG_INTEGER";
$type{"S32"} = "int";
$type_size{"S32"} = 4;
$type_enc_func{"S32"} = "ntohl";
$type_printV{"S32"} = "\%d";
$type_define{"S32"} = "int";
$type_CREATE{"S32"} = "NUMBER";
$type_set_func{"S32"} = "atoi";
$type_set_type{"S32"} = "STG_INTEGER";
$type{"S64"} = "long long";
$type_size{"S64"} = 8;
$type_enc_func{"S64"} = "NTOH64";
$type_twin_func{"S64"} = 1;
$type_printV{"S64"} = "\%lld";
$type_define{"S64"} = "long long";
$type{"U64"} = "unsigned long long";
$type_size{"U64"} = 8;
$type_enc_func{"U64"} = "NTOH64"; 
$type_twin_func{"U64"} = 1;
$type_printPre{"U64"} = "S8 STG_PrintPre[1024]\; U8 *_stg_s; _stg_s = (U8 *) &+U64+\; sprintf(STG_PrintPre, \"0x\%02x\%02x\%02x\%02x\%02x\%02x\%02x\%02x\" ,_stg_s[7] ,_stg_s[6] ,_stg_s[5] ,_stg_s[4] ,_stg_s[3] ,_stg_s[2] ,_stg_s[1] ,_stg_s[0] )\;";
$type_printM{"U64"} = "STG_PrintPre";
$type_printV{"U64"} = "\%s";
$type_define{"U64"} = "unsigned long long";
$type{"UTIME64"} = "unsigned long long";
$type_size{"UTIME64"} = 8;
$type_enc_func{"UTIME64"} = "NTOH64V2"; 		
$type_twin_func{"UTIME64"} = 1;
$type_printPre{"UTIME64"} = "S8 STG_PrintPre[1024]\; U32 *_stg_time\; U32 *_stg_utime\; _stg_time = (U32 *) &+UTIME64+\; _stg_utime = _stg_time + 1\;  strftime(STG_PrintPre, 1024, \"\%Y \%m-\%d \%H:\%M \%S\", localtime((time_t *)_stg_time))\; sprintf(STG_PrintPre,\"\%s : \%ld\",STG_PrintPre,(U32) *_stg_utime)\; ";
$type_printM{"UTIME64"} = "STG_PrintPre";
$type_printV{"UTIME64"} = "\%s";
$type_define{"UTIME64"} = "unsigned long long";
$type{"OFFSET"} = "int";
$type_size{"OFFSET"} = 4;
$type_enc_func{"OFFSET"} = "ntohl";
$type_printV{"OFFSET"} = "\%16d";
$type_define{"OFFSET"} = "int";
$type_CREATE{"OFFSET"} = "NUMBER";
$type_set_type{"OFFSET"} = "STG_INTEGER";
### STIME : 초 시간  (time_t)
$type{"STIME"} = "time_t";			
$type_size{"STIME"} = 4;
$type_enc_func{"STIME"} = "ntohl";
#$type_printPre{"STIME"} = "if(+STIME+){ S8 STG_PrintPre[1024]\; strftime(STG_PrintPre, 1024, \"\%Y \%m-\%d \%H:\%M \%S\", localtime((time_t *)&+STIME+))\; sprintf(STG_PrintPre,\"\%s : 0x\%x\",STG_PrintPre,(S32) +STIME+)\; } else { sprintf(STG_PrintPre,\"0\"); } ";
$type_printPre{"STIME"} = "S8 STG_PrintPre[1024]\; if(+STIME+){ strftime(STG_PrintPre, 1024, \"\%Y\%m\%d\%H\%M\%S\", localtime((time_t *)&+STIME+))\; } else { sprintf(STG_PrintPre,\"0\"); }";
#$type_printPre{"STIME"} = "S8 STG_PrintPre[1024]\; strftime(STG_PrintPre, 1024, \"\%Y\%m\%d\%H\%M\%S\", localtime((time_t *)&+STIME+))\;";
$type_printM{"STIME"} = "STG_PrintPre";
$type_printV{"STIME"} = "\%s";
$type_define{"STIME"} = "int";
$type_CREATE{"STIME"} = "NUMBER";
$type_set_type{"STIME"} = "STG_INTEGER";
### MTIME : micro second 시간
$type{"MTIME"} = "int";
$type_size{"MTIME"} = 4;
$type_enc_func{"MTIME"} = "ntohl";
$type_printV{"MTIME"} = "\%d";
$type_printM{"MTIME"} = "(S32)";
$type_define{"MTIME"} = "int";
$type_CREATE{"MTIME"} = "NUMBER";
$type_set_type{"MTIME"} = "STG_INTEGER";
$type{"FLOAT"} = "float";
$type_size{"FLOAT"} = 4;
$type_enc_func{"FLOAT"} = "ntohl";
$type_printV{"FLOAT"} = "%f";
$type_define{"FLOAT"} = "float";
$type{"BIT8"} = "unsigned char";
$type_size{"BIT8"} = 1;
$type_printV{"BIT8"} = "\%5d";
$type_define{"BIT8"} = "unsigned char";
$type_CREATE{"BIT8"} = "NUMBER";
$type{"BIT16"} = "unsigned short";
$type_size{"BIT16"} = 2;
$type_printV{"BIT16"} = "\%8d";
$type_define{"BIT16"} = "unsigned short";
$type_CREATE{"BIT16"} = "NUMBER";
### 이 아래의 define을 define.upr를 정의하여 넣는 것도 좋을 것으로 보인다.
### 거기에는 extern으로 함수들도 같이 넣어야 할 것이다.

### 위의 해쉬가 잘되는지 시험하는 부분 (OK)
#foreach $key (keys %type) {
	#print "$key ==> $type{$key}\n";
#}
#foreach $key (keys %type_printV) {
	#print "$key ==> $type_printV{$key}\n";
#}
#foreach $key (keys %type_printM) {
	#print "$key ==> $type_printM{$key}\n";
#}

sub get_all_global_var
{
		my $global_filename = shift @_;
		my $global_which = shift @_;
		my $line;
		my $undefined_hash_name;
		my $undefined_array_name;
		print "GETG --> $global_filename\n";
		open(GETG , "<$global_filename");

		while ($line = <GETG>) {
				chop($line);
				if($line =~ /undefined_typedef/){  next; }
				if($line =~ /^HASH : \$(\S+) \{ (\S+) \} = (.*)$/){
					$undefined_hash_name = $1;
					$undefined_typedef{$undefined_hash_name} = "HASH_$undefined_hash_name";
					if($global_which eq "FIRST"){
						if($$1{"$2"} ne ""){
							print "Already Exist : HASH : \$ $1 \{ $2 \} = $$1{$2}    <--  $3\n";
						} else {
							$$1{"$2"} = $3;
						}
					} else {
						$$1{"$2"} = $3;
					}
				}
				if($line =~ /^ARRAY : \$(\S+) \[ (\d+) \] = (.*)$/){
					$undefined_array_name = $1;
					$undefined_typedef{$undefined_array_name} = "ARRAY_$undefined_array_name";
					#$ARRAYNAME__{$1} = "ARRAY_$1";
					if($global_which eq "FIRST"){
						if($$1[$2] ne ""){
							print "Already Exist : ARRAY : \$ $1 \[ $2 \] = $$1[$2]    <--  $3\n";
						} else {
							$$1[$2] = $3;
						}
					} else {
						$$1[$2] = $3;
					}
				}
		}
		close (GETG);
}


sub print_all_global_var
{
	my $global_filename;
	$global_filename = shift @_;

	open(GLOBAL,">$global_filename");
	my $key;
	print GLOBAL  "=============================================\n";
	print GLOBAL  "===== Global Variables ======================\n";
	print GLOBAL  "=============================================\n";
	print GLOBAL  "\$file_delimiter = $file_delimiter\n";
	print GLOBAL  "\$flatprefix = $flatprefix\n";
	print GLOBAL  "\$shortprefix = $shortprefix\n";
	print GLOBAL  "\$expansionprefix =\>$expansionprefix\<=\n";
	print GLOBAL  "\$shortremoveprefix =\>$shortremoveprefix\<=\n";
	print GLOBAL  "\$pointerprefix =\>$pointerprefix\<=\n";
	print GLOBAL  "\$staticprefix =\>$staticprefix\<=\n";
	print GLOBAL  "\$inputfilename = $inputfilename\n";
	print GLOBAL  "\$outputdir = $outputdir\n";
	print GLOBAL  "\$FileName = $FileName\n";
	print GLOBAL  "\$FlatFileName = $FlatFileName\n";
	print GLOBAL  "\$typedef_def_cnt = $typedef_def_cnt\n";
	print GLOBAL  "\$stg_hash_timer_type = $stg_hash_timer_type\n";
	print GLOBAL  "\$stg_hash_timer_name = $stg_hash_timer_name\n";
	print GLOBAL  "\$stg_hash_sess_timeout = $stg_hash_sess_timeout\n";
	print GLOBAL  "\$stg_hash_del_timeout = $stg_hash_del_timeout\n";
	print GLOBAL  "\$stg_hash_size = $stg_hash_size\n";
	print GLOBAL  "\$stg_hash_key = $stg_hash_key\n";
	print GLOBAL  "\$prefix_logdb_table = $prefix_logdb_table\n";
	print GLOBAL  "\$stg_hash_first_data = $stg_hash_first_data\n";
	print GLOBAL  "\$stg_hash_first_key = $stg_hash_first_key\n";
	print GLOBAL  "\$stg_hash_first_key_name = $stg_hash_first_key_name\n";
	print GLOBAL  "\$stg_hash_first_key_type = $stg_hash_first_key_type\n";
	print GLOBAL  "\$stg_hash_first_key_is = $stg_hash_first_key_is\n";
	#foreach_print_hash("primitives");
	foreach_print_hash("lex_option");
	foreach_print_hash("stg_stc_file");
	foreach_print_hash("primitives");
	foreach_print_hash("type");
	foreach_print_hash("type_size");
	foreach_print_hash("type_enc_func");
	foreach_print_hash("type_twin_func");
	foreach_print_hash("type_printPre");
	foreach_print_hash("type_printM");
	foreach_print_hash("type_printV");
	foreach_print_hash("type_define");
	foreach_print_hash("type_CREATE");
	foreach_print_hash("type_set_func");
	foreach_print_hash("type_set_type");
	foreach_print_hash("type_is");
	foreach_print_hash("filelist");
	foreach_print_hash("typedef_enc_func");
	foreach_print_hash("typedef_dec_func");
	foreach_print_hash("typedef_prt_func");
	foreach_print_hash("typedef_fpp_func");
	foreach_print_hash("typedef_combi_func");
	foreach_print_hash("typedef_stat_func");
	foreach_print_hash("typedef_contents");
	foreach_print_hash("flat_typedef_contents");
	foreach_print_hash("function_def");
	foreach_print_hash("flat_function_def");
	foreach_print_hash("typedef");
	foreach_print_hash("typedef_def_cnt");
	foreach_print_hash("typedef_def_num");
	foreach_print_hash("typedef_member_count");
	foreach_print_hash("stat_typedef");
	foreach_print_hash("combi_typedef");
	foreach_print_hash("stat_accumulate");
	foreach_print_hash("stat_accumulate_typedef");
	foreach_print_hash("combi_accumulate");
	foreach_print_hash("combi_accumulate_typedef");
	foreach_print_hash("combi_inc");
	foreach_print_hash("stat_inc");
	foreach_print_hash("define_digit");
	foreach_print_hash("table");
	foreach_print_hash("table_log");
	foreach_print_hash("table_cf");
	foreach_print_hash("table_combi");
	foreach_print_hash("table_association");
	foreach_print_hash("table_stat");
	foreach_print_hash("Not_flat_table");
	foreach_print_hash("stg_key_hashs");
	foreach_print_hash("TAG_DEFINE");
	foreach_print_hash("TAG_KEY");
	foreach_print_hash("abbreviation_define_name");
	foreach_print_hash("tag_flow_name");
	foreach_print_hash("tag_flow_pTHIS");
	foreach_print_hash("tag_flow_pINPUT");
	foreach_print_hash("state_diagram_edge_name");
	foreach_print_hash("state_diagram_edge_pTHIS");
	foreach_print_hash("state_diagram_edge_pINPUT");

	foreach_print_array("struct_name");
	foreach_print_array("typedef_name");
	foreach_print_array("stc_filearray");
	foreach_print_array("global_filearray");
	foreach_print_array("stg_filearray");

	foreach_print_undefined_hash("undefined_typedef");
	foreach_print_array("undefined_array");

	foreach_print_hash("ARRAY_SIZE");
	close GLOBAL;

}

sub foreach_print_undefined_hash
{
	my $key;
	my $hash_name;
	my $undefined_hash_name;

	print GLOBAL "UNDEFINED_HASH : ================================================\n	\$$undefined_hash_name \{ $hash_name \} = $$undefined_hash_name{$hash_name}\n";
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
	$ARRAY_SIZE{$name} = $cnt - 1;
	for(my $i = 0 ; $i < $cnt ; $i++){
		print GLOBAL "ARRAY : \$$name \[ $i \] = $$name[$i]\n";
	}
}

# processing중에 필요한 global variable
our $typedef_member_count=0;
our $temp;
our $temp1;
our $temp2;
our $temp3;
our $temp4;
our $temp5;
our $temp6;
our $temp7;
our $temp8;
our $temp9;
our @temp;


my $upr;
my $in_typedef = 0;
my $typedef = "";
my $typedef_cr = "";
my $typedef_org = "";
my $typedef_short = "";
my $FileNameFirst;
my $yh_members_lis;
my $yh_members_o;
my $yh_members_c;
my $yh_members_pc;
my $yh_member_pcs;
my @yh_member_pcs;
my $inc_filelist = "";
my $cfile_filelist = "";
my $sprocfile_filelist = "";
my $line="";
my $line_prt="";
my $def="";
my $short;
my $line_short;
my $iterate;
my $stg_key_hash;
our $flat_typedef_contents;
my $text_parse_linefeed;
my $text_parse_formfeed;
my $text_parse_state;
my $text_parse_token;
my $undefined_name;
my $undefined_typedef_name;
my @temp_vars;
my $temp_vars;
my $vertex_name;
my $tmp_vertex_name;
my $tmp_vertex_msg;
my $temp_argu1;
my $temp_argu2;
my $temp_argu3;
my $temp_argu4;
my $temp_argu5;
my $prev_line;
my $for_prev_line;
my $temp_line;
my $state_diagram_vertex_name = "";
my $tag_define_name = "";
my $tag_auto_define_name = "";
my $tag_auto_define_start_num ;
my $state_diagram_vertex_start_num ;
my $tag_auto_string_define_name = "";
my $tag_auto_string_define_start_num ;
my $tag_flow_name = "";
my $tag_flow_struct = "";
my $state_diagram_edge_name = "";
my $state_diagram_edge_struct = "";
my $tag_indicator = 0;
my $current_state ;
my $msg ;
my $if_var_type ;
my $if_var ;
my $if_val_type ;
my $if_val ;
my $next_state ;
my $action ;
my $sharp_start = 0 ;
my $error;
my $bit_sum = 0;
my $bit_type = "";
my $bit_line = "";
my $tag_key = 0;
my $tag_key_lines = "";
my $case_ignore = "";
my $parsing_case_ignore = "";
my $analysis_typedef_lines = "";
my $analysis_line = "";
my %STG_PARM;
my %STG_PAR_ARRAY_NAME;
my %STG_PAR_ARRAY_VALUE;

my $Second; 
my $Minute; 
my $Hour; 
my $Day; 
my $Month; 
my $Year;
my $WeekDay; 
my $DayOfYear;
my $IsDST;


sub Ichange
{
	my $iterate_key;
	my $iterate_value;
	my $iterate_hash_name;
	my $iterate_lines = "";
	my $in;
	my $in_start;
	my $in_end;
	my $iterate_cnt = 0;
	my $stcI_filename_input ;
	my $stcI_filename_output ;
	my $stcI_output_dir;
	my $stcI_for;
	my $stcI_extension="";
	my $stcI_filepostfix="";
	my $stcI_fileprefix="";
	my $stcI_lines = "";
	my @stcI_lines;
	my $stcfilename="";
	my $tmpstcfilename="";
	my $tttime;
	my $ddtime;

	$stcI_filename_input = shift @_;
	$stcI_output_dir = shift @_;

	print_fp("\n\n\nIchange $stcI_filename_input\n",STDOUT,DBG);
	open(STCI_INPUT , "<$stcI_filename_input");

($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "structg : Ichange START ($stcI_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n", TIME_DBG);
$tttime = $Hour * 3600 + $Minute * 60 + $Second;

	while ($in = <STCI_INPUT>) {
		if($in =~ /^stcI_HASH\s*\:\s*(\w+)\s*$/){
			$stcI_for = $1;
		} elsif($in =~ /^stcI_EXTENSION\s*\:\s*(\w+)\s*$/){
			$stcI_extension = $1;
		} elsif($in =~ /^stcI_FILEPOSTFIX\s*\:\s*(\w+)\s*$/){
			$stcI_filepostfix = $1;
		} elsif($in =~ /^stcI_FILEPREFIX\s*\:\s*([^\s]+)\s*$/){
			$stcI_fileprefix = $1;
		} else {
			$stcI_lines .= $in;
		}
	}
	print_fp("stcI_HASH : $stcI_for\n",STDOUT,DBG);
	print_fp("stcI_EXTENSION : $stcI_extension\n",STDOUT,DBG);
	print_fp("stcI_FILEPOSTFIX : $stcI_filepostfix\n",STDOUT,DBG);
	print_fp("stcI_FILEPREFIX : $stcI_fileprefix\n",STDOUT,DBG);
	foreach $temp (keys %$stcI_for){
		$tmpstcfilename = "$temp" . "$stcI_filepostfix";
		$stcfilename = "$stcI_fileprefix" . "$temp" . "$stcI_filepostfix";
		print_fp("STCI tmp OUTPUT FileName :  $tmpstcfilename\n",STDOUT,DBG);
		open(STCI_OUTPUT , ">$outputdir/tmp/$tmpstcfilename\.stc");
		print STCI_OUTPUT "FileName : $stcfilename\.$stcI_extension\n";
		print "FileName : $stcfilename\.$stcI_extension\n";
		@stcI_lines = split("\n",$stcI_lines);
		foreach my $ttt (@stcI_lines){
#print "ttt $ttt\n";
			if($ttt =~ /^SetI\s*\:/){
#print "A0 $ttt\n";
				$ttt =~ s/KEY/$temp/g;
				$ttt =~ s/VALUE/$$stcI_for{$temp}/g;
#print "A1 $ttt\n";
				$ttt = replace_var_with_value($ttt);
				$ttt =~ s/^SetI/Set/;
#print "A2 $ttt\n";
				print STCI_OUTPUT "$ttt\n";
			} else {
				print STCI_OUTPUT "$ttt\n";
			}
		}
		close(STCI_OUTPUT);
		Cchange("$outputdir/tmp/$tmpstcfilename\.stc","","","stcI");			# OUTPUT안에 저장하고, makefile에도 넣어라.
	}
	close(STCI_INPUT);

($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
$ddtime = ($Hour * 3600 + $Minute * 60 + $Second) - $tttime;
print_fp( "structg Ichange duration ($ddtime) : Ichange END ($stcI_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);

}

sub Cchange
{
	my $iterate_key;
	my $iterate_value;
	my $iterate_var_name;
	my $iterate_var_type;
	my $iterate_lines = "";
	my $in;
	my $in_start;
	my $in_end;
	my $iterate_cnt = 0;
	my $stc_filename_input ;
	my $stc_filename_output ;
	my $stc_debug ;
	my $stc_output_dir;
	my %local_set;
	my $tttime;
	my $ddtime;
	my $cchange_start_time;

	$stc_filename_input = shift @_;
	$stc_output_dir = shift @_;
	$stc_filename_output = shift @_;
	$stc_debug = shift @_;
	#
	#방법 1. 
	# 쌍을 알기위해서 recusive를 사용하게 되고,
	# 그 안에서 나온 결과를 이용하여
	# 실제 들아갈 값을 찾는 것은 loop를 계속 돌며, ITERATOR가 없을때까지 수행을 하면 된다. 
	#  	loop를 돌때는 ITERATOR가 한번 발견되면 그 규칙을 끝까지 지키는 것을 원칙으로 한다.
	# 그리고, 나머지 loop들도 돌면서 처리를 계속한다. 
	#
	# recusive모양은 찾는 것은 좋으나, 거꾸로 풀면서 가면 위에서 지정한 loop의 argument를 사용할수 없기에 loop를 더 추가한 것이다.
	#
	#방법 2.
	# ITERATOR에 대한 변수를 두어 처음부터 잡아서 해당 것의 끝까지 저장을 한다.
	# ITERATOR A start
	# 	AAA
	# 	ITERATOR B start
	# 		BBB
	#   B End
	# A End
	# 라고 할때, 위의 4줄을 모두 한 변수에 집어 넣는다. (AAA ~ B End)
	# ITERATOR A의 규칙대로 대치를 시킨다. (복수의 line을 뽑아내어 변수에 저장)
	# 대치시킨 결과를 Cchange() 에서 하는 것 처럼 또 돌려준다. 
	# ITERATOR B ~ B End까지를 또 풀어준다.
	#
	# operation 우선순위
	#  ITERATE 가 제일 먼저 처리 된다.
	#  그 후에 , +<+$...+>+ 이 처리가 된다.  co_log_main.c안에서  Get_HashoData를 참조하시요.
	print_fp("Cchange $stc_filename_input\n",STDOUT,DBG);
	open(INPUTC , "<$stc_filename_input");

if($stc_debug eq "STC"){
($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "structg : Cchange START ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);
$tttime = $Hour * 3600 + $Minute * 60 + $Second;
$cchange_start_time = $Hour * 3600 + $Minute * 60 + $Second;
}

	if($stc_filename_output ne ""){
		$stg_stc_file{$stc_filename_output} = $stc_filename_output;
		print_fp("STC FileName 1 : stg_stc_file : $stg_stc_file{$stc_filename_output} : $stc_filename_output\n",STDOUT,DBG);
		open(OUTPUTC , ">$outputdir/$stc_output_dir/$stc_filename_output");
		if( ($stc_filename_output =~ /\.c\s*$/) || ($stc_filename_output =~ /\.cpp\s*$/) || ($stc_filename_output =~ /\.pc\s*$/) ){	
			#print "INCLUDE1\n";
			print OUTPUTC "\n#include \"$FileName\"\n\n\n";		# .c안에서는 되는데 .l에서 문제가 발생함.
		} else {
			#NONE#
			# .l일때는 처음에 include를 선언하면 error가 발생한다.
		}
		if($stc_output_dir eq ""){
			if($stc_filename_output =~ /\.c/){
				$filelist{$stc_filename_output} = "CFILE";
			}
		}
	}

	while ($in = <INPUTC>) {
		if($in =~ /^FileName\s*\:\s*(\S+)\s*$/){
			$stc_filename_output = $1;
			$stg_stc_file{$1} = $1;
			print_fp("STC FileName 2 : stg_stc_file : $stg_stc_file{$1} : $stc_filename_output\n",STDOUT,DBG);
			open(OUTPUTC , ">$outputdir/$stc_output_dir/$stc_filename_output");
			if( ($stc_filename_output =~ /\.c\s*$/) || ($stc_filename_output =~ /\.cpp\s*$/) || ($stc_filename_output =~ /\.pc\s*$/) ){	
				#print "INCLUDE2\n";
				print OUTPUTC "\n#include \"$FileName\"\n\n\n";		# .c안에서는 되는데 .l에서 문제가 발생함.
			} else {
				#NONE#
				# .l일때는 처음에 include를 선언하면 error가 발생한다.
			}
			if($stc_output_dir eq ""){
				if($stc_filename_output =~ /\.c/){
					$filelist{$stc_filename_output} = "CFILE";
				} elsif($stc_filename_output =~ /\.l/){
					$filelist{$stc_filename_output} = "LEXFILE";
					$temp = $stc_filename_output;
					if($temp =~ /(.*)\/(.*).l/){
						$temp = "lex\.$2\.c";
					} else {
						$temp =~ s/(.*)\.l/lex\.$1\.c/;
					}
					$filelist{$temp} = "CFILE";
				}
			} else {
				if($stc_filename_output =~ /\.c/){
					$filelist{"$stc_output_dir" . "/" . "$stc_filename_output"} = "CFILE";
				} elsif($stc_filename_output =~ /\.l/){
					$filelist{"$stc_output_dir" . "/" . "$stc_filename_output"} = "LEXFILE";
					$temp = $stc_filename_output;
					if($temp =~ /(.*)\/(.*).l/){
						$temp = "lex\.$2\.c";
					} else {
						$temp =~ s/(.*)\.l/lex\.$1\.c/;
					}
					$filelist{"$temp"} = "CFILE";
				}
			}
			next;
		} elsif($in =~ /^Lex_Compile_Option\s*\:\s*(.*)/){		# Compile_Option : -i   (flex 에서 case ignore)
			$temp = "$stc_output_dir" . "/" . "$stc_filename_output";
			$lex_option{$temp} = $1;
			next;
		} elsif($in =~ /^Set\s*\:\s*(\w+)\s*\=\s*(\w+)/){		# Set: A = B 
			my $temp_set_var = $1;
			my $temp_set_value = $2;
#print DBG "LLL $iterate_comments : $1  $2\n";
			$$1 = $2;
#print DBG "LLL $iterate_comments : [$1] [$2] \n";
			#CCHANGE_DEBUG print DBG "SET : $1 = $2\n";
			#  이게 SET하는 것이 잘 안되는군.... 다음 방법은 될까?  <- set을 잘못하여 시험함.
			# 위의 방법 1과 아래의 방법 2 모두 잘 처리됨.
##			if($temp_set_var eq "iterate_comments" ){
##				print OUTPUTC "[$1] [$2]\n";
##				if("OFF" eq $temp_set_value){
##					#$iterate_comments = "OFF";
##				} else {
##					#$iterate_comments = "ON";
##				}
##			}
##			# 첫번째의 위방법은 이상하게 한 번만 Set되고 되지 않는다. 
##			# 두번째인 비교를 하여 직접 값을 써주는 것은 가능하다. ㅁ
			$undefined_name = "stc_Set_var_$stc_filename_output";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$temp_set_var} = "$temp_set_value";
			$local_set{$temp_set_var} = $temp_set_value;
			next;
		} elsif($in =~ /^Set\s*\:\s*(\w+)\s*\{\s*(\w+)\s*\}\s*\=\s*(\w+)/){		# Set: A{B} = C
			print "SET : ERROR $1 $2 $3\n";
			my $temp_set_var = $1;
			my $temp_set_hash = $2;
			my $temp_set_value = $3;
#print DBG "LLL $iterate_comments : $1  $2 $3\n";
			$$1{$2} = $3;
#print DBG "LLL $iterate_comments : [$1] [$2]  $3\n";
			#CCHANGE_DEBUG print DBG "SET :  $1 \{ $2 \} = $3\n";
			#$undefined_name = "stc_Set_var_$stc_filename_output";
			#$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			#$$undefined_name{"$temp_set_var" . "$temp_set_hash"} = "$temp_set_value";
			next;
		}

		foreach $temp (keys %local_set){			# local 하게 Set: 된 것들에 대해서 대치 (replacement)를 시켜주는 곳이다.
			if(   ($in =~ /Set :/)   and
				($in =~ /\{ASSOCIATION_TABLENAME\}/) ){
				#print "IN $temp $local_set{$temp} : $in\n";
				#$in =~ s/$temp/$local_set{$temp}/g;
				#print "IN2 $iterate_cnt $temp $local_set{$temp} : $in\n";
			}
			$in =~ s/$temp/$local_set{$temp}/g;
		}

#print_fp("Line 1 icnt=$iterate_cnt : $in",DBG);
		if(0 == $iterate_cnt){
			$in = replace_var_with_value($in);
		}
#print_fp("Line 2 icnt=$iterate_cnt : $in",DBG);

		if ($in =~ /^\s*ITERATE\s+([%@&])(\S+)\s+\+<<\+\s+(\S+)\s+(\S+)/){
			if(0 == $iterate_cnt){
				$in_start = $in;
#ITERATOR_DEBUG print DBG "Mstart $1 $2 $3 $4\n"; 
				($iterate_var_type , $iterate_var_name , $iterate_key , $iterate_value) = ($1,$2,$3 , $4);
			} else {
				$iterate_lines .= $in;
			}
			$iterate_cnt ++;
#ITERATOR_DEBUG print DBG "$iterate_cnt : $in";
		} elsif ($in =~ /^(.*)\+>>\+/){
			$iterate_cnt--;
#ITERATOR_DEBUG print DBG "$iterate_cnt : $in";
			if(0 == $iterate_cnt){
if($stc_debug eq "STC"){
($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
$ddtime = ($Hour * 3600 + $Minute * 60 + $Second) - $tttime;
$tttime = $Hour * 3600 + $Minute * 60 + $Second;
print_fp( "structg ($ddtime) : Cchange ITERATE START 1 ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);
}
				$in_end = $in;
#ITERATOR_DEBUG print DBG "iterate_comments [" . $iterate_comments . "]\n";
				if( "ON" eq $iterate_comments){
					$temp1=$in_start;
					$temp2=$iterate_lines;
					$temp3=$in_end;
					# /** */ 으로 묶는 안에 /* */이 있으면 안되므로 <* *>으로 변환을 시켜주는 것이다.  
					$temp1 =~ s/\/\*/\<\*/g;
					$temp1 =~ s/\*\//\*\>/g;
					$temp2 =~ s/\/\*/\<\*/g;
					$temp2 =~ s/\*\//\*\>/g;
					$temp2 =~ s/NOTEQUAL/notifequal/g;
					$temp2 =~ s/IFEQUAL/ifequal/g;
					$temp3 =~ s/\/\*/\<\*/g;
					$temp3 =~ s/\*\//\*\>/g;
					#ITERATOR_DEBUG print_fp("\/\*\*\n$temp1$temp2$temp3\*\/\n",DBG,OUTPUTC);
				}
				$iterate_lines = Iterator_recursion($iterate_var_type , $iterate_var_name,$iterate_key,$iterate_value,$iterate_lines);
				#ITERATOR_DEBUG  print DBG "RETURN \$iterate_lines = \n\[\n$iterate_lines\n\]\n";
				#$iterate_lines =~ s/\+<\+\s*\$(\S+)\s*\+>\+/$$1/g;		# 	+<+$stg_hash_del_timeout+>+ ==> 10

if($stc_debug eq "STC"){
($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
$ddtime = ($Hour * 3600 + $Minute * 60 + $Second) - $tttime;
$tttime = $Hour * 3600 + $Minute * 60 + $Second;
print_fp( "structg ($ddtime) : Cchange ITERATE recursion END 1 ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);
}

				# 이런식으로 처리하면 많은 %값들을 만들지 않아도 되며, define같은 값들을 지저분하게 군데군데 만들어줄 필요가 없다. 
#print DBG "Set Hash 10 : $iterate_lines\n";
if(1){
				my $iter_lena = length($iterate_lines);
				my $iterate_lines_org = $iterate_lines;
				$iterate_lines ="";
				for(my $itt = 0;$itt <= $iter_lena ; $itt += 10000){
					$iterate_lines .= replace_var_with_value(substr($iterate_lines_org, $itt, 10000));
				}

				$temp = length($iterate_lines);
				$iterate_lines = replace_var_with_value($iterate_lines);
				
if($stc_debug eq "STC"){
($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
$ddtime = ($Hour * 3600 + $Minute * 60 + $Second) - $tttime;
$tttime = $Hour * 3600 + $Minute * 60 + $Second;
print_fp( "structg ($ddtime) : Cchange ITERATE <-> REPLACE END ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);
}

} else {
				$iterate_lines = replace_var_with_value($iterate_lines);
}
#print DBG "Set Hash 11 : $iterate_lines\n";


if(1){
	my $iter_len = length($iterate_lines);
	my $iterate_lines_org = $iterate_lines;
	$iterate_lines ="";
	for(my $itt = 0;$itt <= $iter_len ; $itt += 10000){
		$iterate_lines .= iterate_equal(substr($iterate_lines_org, $itt, 10000));
	}

	$iterate_lines = iterate_equal($iterate_lines);
	$iterate_lines =~ s/STG_SHARP_/\#/g;
	
if($stc_debug eq "STC"){
	($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
	$Month++;
	$Year += 1900;
	$ddtime = ($Hour * 3600 + $Minute * 60 + $Second) - $tttime;
	$tttime = $Hour * 3600 + $Minute * 60 + $Second;
	print_fp( "structg ($ddtime) : Cchange ITERATE REPLACE <-> EQUAL END 3 ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);
}

	print_fp("$iterate_lines\n" , OUTPUTC);

} else { 		# if(1)
				@temp = split('\n',$iterate_lines);
				my $ifequal_start = 0;
				my $ifequal_one="";
				my $ifequal_two="";
				my $ifequal_action="";
				my $is_ifequal = 0;
#print DBG "Cchange IFEQUAL NOTEQUAL<<\n$iterate_lines\n>>\n";
				foreach $temp (@temp){
					if($temp =~ /^\s*IFEQUAL\s*\(\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*\)\s*#\{(.*)/){
						$ifequal_start = 1;
						$ifequal_one = $1;
						$ifequal_two = $2;
						$ifequal_action = $3;
						$is_ifequal = 1;
						print DBG "IFEQUAL 1>>> $ifequal_start [$ifequal_one] [$ifequal_two] $ifequal_action\n";
					} elsif($temp =~ /^\s*NOTEQUAL\s*\(\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*\)\s*#\{(.*)/){
						$ifequal_start = 1;
						$ifequal_one = $1;
						$ifequal_two = $2;
						$ifequal_action = $3;
						$is_ifequal = 0;
						print DBG "NOTEQUAL 1>>> $ifequal_start [$ifequal_one] [$ifequal_two] $ifequal_action\n";
					} elsif($temp =~ /^\s*IFEQUAL\s*\(\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*\)\s*(.*)/){
						$ifequal_one = $1;
						$ifequal_two = $2;
						$ifequal_action = $3;
						print DBG "IFEQUAL 0>>> $ifequal_start [$ifequal_one] [$ifequal_two] $ifequal_action\n";
						if($ifequal_one eq $ifequal_two){	# 같으면 IFEQUAL이므로 처리
							print DBG "IFEQUAL 0.5>>> $ifequal_start [$ifequal_one] [$ifequal_two] $ifequal_action\n";
							$ifequal_action =~ s/STG_SHARP_/\#/g;
							print_fp("$ifequal_action\n" , OUTPUTC,DBG);
						} else {
							# NONE
						}
					} elsif($temp =~ /^\s*NOTEQUAL\s*\(\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*\)\s*(.*)/){
						$ifequal_one = $1;
						$ifequal_two = $2;
						$ifequal_action = $3;
						print DBG "NOTEQUAL 0>>> $ifequal_start [$ifequal_one] [$ifequal_two] $ifequal_action\n";
						if($ifequal_one ne $ifequal_two){	# 다르면  NOTEQUAL이므로 처리
							print DBG "NOTEQUAL 0.5>>> $ifequal_start [$ifequal_one] [$ifequal_two] $ifequal_action\n";
							$ifequal_action =~ s/STG_SHARP_/\#/g;
							print_fp("$ifequal_action\n" , OUTPUTC,DBG);
						} else {
							# NONE
						}
					} elsif($temp =~ /^(.*)\}#.*$/){
						print DBG "IFEQUAL 3>>> [$ifequal_start] $ifequal_action\n";
						if($ifequal_start == 0){
							print "Syntax Error : You don't have the exact count of braces. #\{  \}# \n";
							die $error = 401;
						} else {
							$ifequal_start = 0;
							$ifequal_action .= "\n$1";
							if( ($is_ifequal == 1) && ($ifequal_one eq $ifequal_two) ){	# 같으면 IFEQUAL이므로 처리
								print DBG "IFEQUAL 3.5>>> $ifequal_action\n";
								$ifequal_action =~ s/STG_SHARP_/\#/g;
								print_fp("$ifequal_action\n" , OUTPUTC,DBG);
							} elsif( ($is_ifequal == 0) && ($ifequal_one ne $ifequal_two) ){	#  다른면 IFEQUAL이므로 처리
								print DBG "NOTEQUAL 3.7>>> $ifequal_action\n";
								$ifequal_action =~ s/STG_SHARP_/\#/g;
								print_fp("$ifequal_action\n" , OUTPUTC,DBG);
							} else {
								# NONE
							}
						}
					} else {
						if($ifequal_start == 1){
							print DBG "IFEQUAL 2>>> $temp\n";
							$ifequal_action .= "\n$temp";
						} else {
							print DBG "IFEQUAL 0>>> $temp\n";
							$temp =~ s/STG_SHARP_/\#/g;
							print_fp("$temp\n",OUTPUTC,DBG);;
						}
					}
				}
}		#if(0)
				$iterate_lines = "";
#print DBG "Mend \n"; 
			} else {			# if(0 == $iterate_cnt)
				$iterate_lines .= $in;
			} 					#if(0 == $iterate_cnt)
		} 
		else {
			if(0 == $iterate_cnt){
				print_fp($in, OUTPUTC);
			} else {
				$iterate_lines .= $in;
			}
		} 
	}
	close(INPUTC);
	close(OUTPUTC);

if($stc_debug eq "STC"){
($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
$ddtime = ($Hour * 3600 + $Minute * 60 + $Second) - $cchange_start_time;
print_fp( "structg Cchange duration ($ddtime) : Cchange END ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);
}

}

sub  iterate_equal(){
	my $iterate_lines="";
	my $ifequal_one="";
	my $ifequal_two="";
	my $ifequal_parm="";

	$iterate_lines = shift @_;

	$iterate_lines =~ s/#(\s*PARSING_RULE\s*:[^#]*)#/--$1--/g;
	#ITERATOR_DEBUG   print DBG "1111RETURN \$iterate_lines = \n\[\n$iterate_lines\n\]\n";
	# $iterate_lines 에는 +<+...+>+ 등의 문자가 없음 위에서 모두 해결된 것임. (값들만 들어감)
	while(					# while 1
		($iterate_lines =~ /\s*NOTEQUAL\s*\(([^\)]*)\)\s*#\{([^#]*)\}#\s*\n/)
		|| ($iterate_lines =~ /\s*IFEQUAL\s*\(([^\)]*)\)\s*#\{([^#]*)\}#\s*\n/)
		|| ($iterate_lines =~ /\s*NOTEQUAL\s*\(\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*\)([^#\n]*)\n/)
		|| ($iterate_lines =~ /\s*IFEQUAL\s*\(\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*\)([^#\n]*)\n/)
		){
		$iterate_lines =~ s/\n/\{\{\{\{1234\}\}\}\}/g;
	
		while($iterate_lines =~ /\s*NOTEQUAL\s*\(([^\)]*)\)\s*#\{([^#]*)\}#\s*\{\{\{\{1234\}\}\}\}/){
			my @ifequal_parm;
			my $ifequal_parm_cnt;
			my $ifequal_is_true = "TRUE";
			$ifequal_parm = $1;
			$temp = $2;
			if($ifequal_parm =~ /\|\|/){
				if($ifequal_parm =~ /\&\&/){ print "ERROR : || 와 &&을 함께 쓸수 없음.\n";   die $error = 12301; }
				@ifequal_parm = split('\|\|',$ifequal_parm);
				$ifequal_parm_cnt = @ifequal_parm;
				$ifequal_is_true = "TRUE";
				for(my $i=0;$i<$ifequal_parm_cnt;$i++){
					if($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_one = $1;
						$ifequal_two = $2;
						if($ifequal_one eq $ifequal_two){
							$ifequal_is_true = "FALSE";
						} 
					} elsif($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_two = $1;
						if($ifequal_one eq $ifequal_two){
							$ifequal_is_true = "FALSE";
						} 
					} else {
						print "ERROR : NOEQUAL $ifequal_parm\n"; die $error = 12302; 
					}
				}
			} elsif($ifequal_parm =~ /\&\&/){
				if($ifequal_parm =~ /\|\|/){ print "ERROR : || 와 &&을 함께 쓸수 없음.\n";   die $error = 12303; }
				@ifequal_parm = split('&&',$ifequal_parm);
				$ifequal_parm_cnt = @ifequal_parm;
				$ifequal_is_true = "FALSE";
				for(my $i=0;$i<$ifequal_parm_cnt;$i++){
					if($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_one = $1;
						$ifequal_two = $2;
						if($ifequal_one ne $ifequal_two){
							$ifequal_is_true = "TRUE";
						} 
					} elsif($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_two = $1;
						if($ifequal_one ne $ifequal_two){
							$ifequal_is_true = "TRUE";
						} 
					} else {
						print "ERROR : NOEQUAL $ifequal_parm\n"; die $error = 12304; 
					}
				}
			} else {
				if($ifequal_parm =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
					$ifequal_one = $1;
					$ifequal_two = $2;
					if($ifequal_one ne $ifequal_two){
						$ifequal_is_true = "TRUE";
					}  else {
						$ifequal_is_true = "FALSE";
					}
				}
			}
			#ITERATOR_DEBUG   print DBG "GETIF1 NOTEQUAL : $ifequal_is_true :$ifequal_parm ";
			if($ifequal_is_true eq "TRUE"){
				$iterate_lines =~ s/(\s*)NOTEQUAL\s*\(([^\)]*)\)\s*#\{([^#]*)\}#\s*\{\{\{\{1234\}\}\}\}/$1$temp\{\{\{\{1234\}\}\}\}/;
			} else {
				$iterate_lines =~ s/(\s*)NOTEQUAL\s*\(([^\)]*)\)\s*#\{([^#]*)\}#\s*\{\{\{\{1234\}\}\}\}//;
			}
			#ITERATOR_DEBUG   print DBG "GETIF1 NOTEQUAL  : $temp\n";
		}
		# $temp는 print 해보기 위함임
		$temp = $iterate_lines;
		$temp =~ s/\{\{\{\{1234\}\}\}\}/\n/g;
		#ITERATOR_DEBUG   print DBG "GETIF1---- \$iterate_lines = \n\[\n$temp\n\]\n";
	
		while($iterate_lines =~ /\s*IFEQUAL\s*\(([^\)]*)\)\s*#\{([^#]*)\}#\s*\{\{\{\{1234\}\}\}\}/){
			my @ifequal_parm;
			my $ifequal_parm_cnt;
			my $ifequal_is_true = "FALSE";
			$ifequal_parm = $1;
			$temp = $2;
			if($ifequal_parm =~ /\|\|/){
				if($ifequal_parm =~ /\&\&/){ print "ERROR : || 와 &&을 함께 쓸수 없음.\n";   die $error = 12311; }
				@ifequal_parm = split('\|\|',$ifequal_parm);
				$ifequal_parm_cnt = @ifequal_parm;
				$ifequal_is_true = "FALSE";
				for(my $i=0;$i<$ifequal_parm_cnt;$i++){
					if($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_one = $1;
						$ifequal_two = $2;
						if($ifequal_one eq $ifequal_two){
							$ifequal_is_true = "TRUE";
						} 
					} elsif($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_two = $1;
						if($ifequal_one eq $ifequal_two){
							$ifequal_is_true = "TRUE";
						} 
					} else {
						print "ERROR : IFEQUAL $ifequal_parm\n"; die $error = 12312; 
					}
				}
			} elsif($ifequal_parm =~ /\&\&/){
				if($ifequal_parm =~ /\|\|/){ print "ERROR : || 와 &&을 함께 쓸수 없음.\n";   die $error = 12313; }
				@ifequal_parm = split('&&',$ifequal_parm);
				$ifequal_parm_cnt = @ifequal_parm;
				$ifequal_is_true = "TRUE";
				for(my $i=0;$i<$ifequal_parm_cnt;$i++){
					if($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_one = $1;
						$ifequal_two = $2;
						if($ifequal_one ne $ifequal_two){
							$ifequal_is_true = "FALSE";
						} 
					} elsif($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_two = $1;
						if($ifequal_one ne $ifequal_two){
							$ifequal_is_true = "FALSE";
						} 
					} else {
						print "ERROR : IFEQUAL $ifequal_parm\n"; die $error = 12314; 
					}
				}
			} else {
				if($ifequal_parm =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
					$ifequal_one = $1;
					$ifequal_two = $2;
					if($ifequal_one ne $ifequal_two){
						$ifequal_is_true = "FALSE";
					}  else {
						$ifequal_is_true = "TRUE";
					}
				}
			}
			#ITERATOR_DEBUG   print DBG "GETIF2 IFEQUAL : $ifequal_is_true :$ifequal_parm ";
			if($ifequal_is_true eq "TRUE"){
				$iterate_lines =~ s/(\s*)IFEQUAL\s*\(([^\)]*)\)\s*#\{([^#]*)\}#\s*\{\{\{\{1234\}\}\}\}/$1$temp\{\{\{\{1234\}\}\}\}/;
			} else {
				$iterate_lines =~ s/(\s*)IFEQUAL\s*\(([^\)]*)\)\s*#\{([^#]*)\}#\s*\{\{\{\{1234\}\}\}\}//;
			}
			#ITERATOR_DEBUG   print DBG "GETIF2 IFEQUAL  : $temp\n";
		}
		# $temp는 print 해보기 위함임.
		$temp = $iterate_lines;
		$temp =~ s/\{\{\{\{1234\}\}\}\}/\n/g;
		#ITERATOR_DEBUG   print DBG "GETIF2---- \$iterate_lines = \n\[\n$temp\n\]\n";
	
		$iterate_lines =~ s/\{\{\{\{1234\}\}\}\}/\n/g;
	
		while($iterate_lines =~ /\s*NOTEQUAL\s*\(([^\)]*)\)([^#\n]*)\n/){
			my @ifequal_parm;
			my $ifequal_parm_cnt;
			my $ifequal_is_true = "TRUE";
			$ifequal_parm = $1;
			$temp = $2;
			if($ifequal_parm =~ /\|\|/){
				if($ifequal_parm =~ /\&\&/){ print "ERROR : || 와 &&을 함께 쓸수 없음.\n";   die $error = 12331; }
				@ifequal_parm = split('\|\|',$ifequal_parm);
				$ifequal_parm_cnt = @ifequal_parm;
				$ifequal_is_true = "TRUE";
				for(my $i=0;$i<$ifequal_parm_cnt;$i++){
					if($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_one = $1;
						$ifequal_two = $2;
						if($ifequal_one eq $ifequal_two){
							$ifequal_is_true = "FALSE";
						} 
					} elsif($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_two = $1;
						if($ifequal_one eq $ifequal_two){
							$ifequal_is_true = "FALSE";
						} 
					} else {
						print "ERROR : NOTEQUAL $ifequal_parm\n"; die $error = 12332; 
					}
				}
			} elsif($ifequal_parm =~ /\&\&/){
				if($ifequal_parm =~ /\|\|/){ print "ERROR : || 와 &&을 함께 쓸수 없음.\n";   die $error = 12333; }
				@ifequal_parm = split('&&',$ifequal_parm);
				$ifequal_parm_cnt = @ifequal_parm;
				$ifequal_is_true = "FALSE";
				for(my $i=0;$i<$ifequal_parm_cnt;$i++){
					if($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_one = $1;
						$ifequal_two = $2;
						if($ifequal_one ne $ifequal_two){
							$ifequal_is_true = "TRUE";
						} 
					} elsif($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_two = $1;
						if($ifequal_one ne $ifequal_two){
							$ifequal_is_true = "TRUE";
						} 
					} else {
						print "ERROR : NOTEQUAL $ifequal_parm\n"; die $error = 12334; 
					}
				}
			} else {
				if($ifequal_parm =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
					$ifequal_one = $1;
					$ifequal_two = $2;
					if($ifequal_one ne $ifequal_two){
						$ifequal_is_true = "TRUE";
					}  else {
						$ifequal_is_true = "FALSE";
					}
				}
			}
			#ITERATOR_DEBUG   print DBG "GETIF3 NOTEQUAL : $ifequal_is_true :$ifequal_parm ";
			if($ifequal_is_true eq "TRUE"){
				$iterate_lines =~ s/(\s*)NOTEQUAL\s*\(([^\)]*)\)([^#\n]*)\n/\n$1$temp\{\{\{\{1234\}\}\}\}/;
			} else {
				$iterate_lines =~ s/(\s*)NOTEQUAL\s*\(([^\)]*)\)([^#\n]*)\n//;
			}
			#ITERATOR_DEBUG   print DBG "GETIF3 NOTEQUAL  : $temp\n";
		}
		# $temp는 print 해보기 위함임.
		$temp = $iterate_lines;
		$temp =~ s/\{\{\{\{1234\}\}\}\}/\n/g;
		#ITERATOR_DEBUG   print DBG "GETIF3---- \$iterate_lines = \n\[\n$temp\n\]\n";
	
		while($iterate_lines =~ /\s*IFEQUAL\s*\(([^\)]*)\)([^#\n]*)\n/){
			my @ifequal_parm;
			my $ifequal_parm_cnt;
			my $ifequal_is_true = "FALSE";
			$ifequal_parm = $1;
			$temp = $2;
			if($ifequal_parm =~ /\|\|/){
				if($ifequal_parm =~ /\&\&/){ print "ERROR : || 와 &&을 함께 쓸수 없음.\n";   die $error = 12341; }
				@ifequal_parm = split('\|\|',$ifequal_parm);
				$ifequal_parm_cnt = @ifequal_parm;
				$ifequal_is_true = "FALSE";
				for(my $i=0;$i<$ifequal_parm_cnt;$i++){
					if($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_one = $1;
						$ifequal_two = $2;
						if($ifequal_one eq $ifequal_two){
							$ifequal_is_true = "TRUE";
						} 
					} elsif($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_two = $1;
						if($ifequal_one eq $ifequal_two){
							$ifequal_is_true = "TRUE";
						} 
					} else {
						print "ERROR : IFEQUAL $ifequal_parm\n"; die $error = 12342; 
					}
				}
			} elsif($ifequal_parm =~ /\&\&/){
				if($ifequal_parm =~ /\|\|/){ print "ERROR : || 와 &&을 함께 쓸수 없음.\n";   die $error = 12343; }
				@ifequal_parm = split('&&',$ifequal_parm);
				$ifequal_parm_cnt = @ifequal_parm;
				$ifequal_is_true = "TRUE";
				for(my $i=0;$i<$ifequal_parm_cnt;$i++){
					if($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_one = $1;
						$ifequal_two = $2;
						if($ifequal_one ne $ifequal_two){
							$ifequal_is_true = "FALSE";
						} 
					} elsif($ifequal_parm[$i] =~ /\s*([^ \t\{\}\,\(\)#]*)\s*/){
						$ifequal_two = $1;
						if($ifequal_one ne $ifequal_two){
							$ifequal_is_true = "FALSE";
						} 
					} else {
						print "ERROR : IFEQUAL $ifequal_parm\n"; die $error = 12344; 
					}
				}
			} else {
				if($ifequal_parm =~ /\s*([^ \t\{\}\,\(\)#]*)\s*\,\s*([^ \t\{\}\,\(\)#]*)\s*/){
					$ifequal_one = $1;
					$ifequal_two = $2;
					if($ifequal_one ne $ifequal_two){
						$ifequal_is_true = "FALSE";
					}  else {
						$ifequal_is_true = "TRUE";
					}
				}
			}
			#ITERATOR_DEBUG   print DBG "GETIF4 IFEQUAL : $ifequal_is_true :$ifequal_parm ";
			if($ifequal_is_true eq "TRUE"){
				$iterate_lines =~ s/(\s*)IFEQUAL\s*\(([^\)]*)\)([^#\n]*)\n/\n$1$temp\{\{\{\{1234\}\}\}\}/;
			} else {
				$iterate_lines =~ s/(\s*)IFEQUAL\s*\(([^\)]*)\)([^#\n]*)\n//;
			}
			#ITERATOR_DEBUG   print DBG "GETIF4 IFEQUAL  : $temp\n";
		}
		# $temp는 print 해보기 위함임.
		$temp = $iterate_lines;
		$temp =~ s/\{\{\{\{1234\}\}\}\}/\n/g;
		#ITERATOR_DEBUG   print DBG "GETIF4---- \$iterate_lines = \n\[\n$temp\n\]\n";
	
		$iterate_lines =~ s/\{\{\{\{1234\}\}\}\}/\n/g;
		#ITERATOR_DEBUG   print DBG "RETURN--- \$iterate_lines = \n\[\n$iterate_lines\n\]\n";
	}		# while 1

	#$iterate_lines =~ s/STG_SHARP_/\#/g;
	#print_fp("$iterate_lines\n" , OUTPUTC);
	#if($iterate_lines =~ /(IFEQUAL.*)/){ print ": $1 \n: IFEQUAL .. #{ }#일때 }# 뒤에 문자가 오면 안됨\n"; print ": #{ }# 안에 # 문자가 오면 안됨.\n";  die $error = 612348;}

	return $iterate_lines;
}

sub Iterator_recursion
{
	my $iterate_var_type;
	my $iterate_var_name;
	my $iterate_key;
	my $iterate_value;
	my $iterate_lines;
	my $result = "";
	my $in;
	my $iterate_cnt = 0;
	my @lines;

	($iterate_var_type , $iterate_var_name , $iterate_key , $iterate_value, $iterate_lines) = @_;
	#print_fp( "O : @_\n", OUTPUTC);
#print_fp( "C : $iterate_var_type , $iterate_var_name , $iterate_key , $iterate_value\n", DBG);

#print DBG "C : Iterator_recursion : \$iterate_lines = $iterate_lines ]]]\n";

	if($iterate_var_type eq "\%"){
		foreach $stg_key_hash (reverse sort keys %$iterate_var_name){
			$temp = $iterate_lines;
			$temp =~ s/$iterate_key/$stg_key_hash/g;
			$temp =~ s/$iterate_value/$$iterate_var_name{$stg_key_hash}/g;
			$result .= $temp;
		}
	} elsif($iterate_var_type eq "\@"){
		my $my_cnt;
		$my_cnt = @$iterate_var_name;
		#ITERATOR_DEBUG print DBG "--> ARRAY : $iterate_var_name  size =  $my_cnt\n";
		for(my $i = 0 ; $i < $my_cnt ; $i++){
			#ITERATOR_DEBUG print DBG "array : \$$iterate_var_name \[ $i \] = $$iterate_var_name[$i]\n";
			$temp = $iterate_lines;
			$temp =~ s/$iterate_key/$i/g;
			$temp =~ s/$iterate_value/$$iterate_var_name[$i]/g;
			$result .= $temp;
		}
	} elsif($iterate_var_type eq "\&"){
		my $my_cnt;
		$my_cnt = @$iterate_var_name;
		#ITERATOR_DEBUG print DBG "--> REVERSE ARRAY : $iterate_var_name  size =  $my_cnt\n";
		for(my $i = $my_cnt - 1 ; $i >= 0 ; $i--){
			#ITERATOR_DEBUG print DBG "REVERSE array : \$$iterate_var_name \[ $i \] = $$iterate_var_name[$i]\n";
			$temp = $iterate_lines;
			$temp =~ s/$iterate_key/$i/g;
			$temp =~ s/$iterate_value/$$iterate_var_name[$i]/g;
			$result .= $temp;
		}
	} else {
		print "ERROR : unknown iterate var type  : $iterate_var_type\n";
		die $error = 500;
	}
#print DBG "C : Iterator_recursion : \$result = $result ]]]\n";

	$iterate_lines = "";
	if($result =~ /\s*ITERATE\s+([%@])(\S+)\s+\+<<\+\s+(\S+)\s+(\S+)/){ 
		@lines = split("\n",$result);
		$result = "";
		foreach my $it_line (@lines){
			if ($it_line =~ /^\s*ITERATE\s+([%@])(\S+)\s+\+<<\+\s+(\S+)\s+(\S+)/){  
#print DBG "Set Hash 20 : $iterate_lines \n";
				$it_line = replace_var_with_value($it_line);
#print DBG "Set Hash 21 : $iterate_cnt : $it_line\n";
				$it_line =~ /^\s*ITERATE\s+([%@])(\S+)\s+\+<<\+\s+(\S+)\s+(\S+)/;  
				if(0 == $iterate_cnt){
#print  DBG "Sstart $1 $2 $3\n"; 
					($iterate_var_type , $iterate_var_name , $iterate_key , $iterate_value) = ($1,$2,$3,$4);
				} else {
					$iterate_lines .= $it_line . "\n";
				}
				$iterate_cnt ++;
			}
			elsif ($it_line =~ /^(.*)\+>>\+/){
#print DBG "SUB_ITERATE : $iterate_cnt : $it_line\n";
				$iterate_cnt--;
				if(0 == $iterate_cnt){
					$iterate_lines = Iterator_recursion($iterate_var_type , $iterate_var_name,$iterate_key,$iterate_value,$iterate_lines);
#print  DBG "Send result 30 :: $iterate_lines\n"; 
					#$iterate_lines = replace_var_with_value($iterate_lines);
					$result .= $iterate_lines;
					#print OUTPUTC "SUB RETURN \$iterate_lines = \n\[\n$iterate_lines\n\]\n";
#print  DBG "Send result 31 :: $result\n"; 
					$iterate_lines = "";
				} else {
					$iterate_lines .= $it_line . "\n";
				}
			} 
			else {
#print DBG "SUB_ITERATE 40 : $iterate_cnt : $it_line\n";
				if(0 == $iterate_cnt){
					$it_line = replace_var_with_value($it_line);
#print DBG "SUB_ITERATE 41 : $iterate_cnt : $it_line\n";
					$result .= $it_line . "\n";
				} else {
					$iterate_lines .= $it_line . "\n";
#print DBG "TTT : \$iterate_lines = $iterate_lines ]]]\n";
				}
			} 
		}
	} 
	return $result;
}

sub replace_var_with_value
{
	my $replace_in;
	my $in_cnt = 0;
	$replace_in = shift @_;

			if(   ($replace_in =~ /Set :/)   and
				($replace_in =~ /\{ASSOCIATION_TABLENAME\}/) ){
				print "replace IN : $replace_in\n";
			}
	while(
		($replace_in =~ s/\+<\+\s*\$([\w\d\.]+)\s*\+>\+/$$1/)		# 	+<+$stg_hash_del_timeout+>+ ==> 10
		|| ($replace_in =~ s/\+<\+\s*\$([\w\d\.]+)\s*\[\s*(\d*)\s*\]\s*\+>\+/$$1[$2]/)	# +<+$typedef_name[54]+>+  ==> COMBI_Accum
		|| ($replace_in =~ s/\+<\+\s*\$([\w\d\.]+)\s*\{\s*([\w\d\<\>\{\}\:\.\"\-\>\=]*)\s*\}\s*\+>\+/$$1{"$2"}/) 	# +<+$HASH_KEY_TYPE{uiIP}+>+ ==> IP4
	){
		while($replace_in =~ /(\d+)\s*\+\+\+\+/){		# 	++++     1을 더해 준다. 
			my $temp_num;
			$temp_num = $1;
			$temp_num++;
			$replace_in =~ s/\d+\s*\+\+\+\+/$temp_num/;
		}
		while($replace_in =~ /(\d+)\s*\-\-\-\-/){		# 	++++     1을 빼준다.
			my $temp_num;
			$temp_num = $1;
			$temp_num--;
			$replace_in =~ s/\d+\s*\-\-\-\-/$temp_num/;
		}
		$in_cnt ++;
		#print DBG "Set Hash replace2 in_cnt=$in_cnt: $replace_in \n";
	}			# +<+$type{+<+$HASH_KEY_TYPE{uiIP}+>+}+>+  ==> int

	$in_cnt = 0;
	while(
		($replace_in =~ /Set\s*\:\s*(\w+)\s*\{\s*([^\s}]+)\s*\}\s*\=\s*\"(.*)\"\s*\n/)   # SET HASH
	){
		$in_cnt ++;
		if($replace_in =~ s/Set\s*\:\s*(\w+)\s*\{\s*([^\s}]+)\s*\}\s*\=\s*\"(.*)\"\s*\n//){   # SET HASH
			$$1{$2} = $3;
			#print DBG "Set Hash replace1 in_cnt=$in_cnt: $1 $2 $3\n";
		}
	}
	return $replace_in;
}

# function.upr의 내용대로 subroutine에 대해서도 같은 방식의 주석을 단다.
#/** save_typedef function.
# *
# *  typedef struct ... { ... } ...; 을 입력받아 enc/dec/print같은 해당 코드들을 자동 생성시켜준다.
# *
# *  @param  $typedef  typedef struct ... { ... } ...; 을 입력받아
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl을 변형하여 flat....h 를 만든 화일
# *
# *  @exception  nested structure를  내부에 정의한 것은 처리 안됨.
# *  @note      +Note+
# **/
sub save_typedef
{
	my $parms;
	my $typedef_name="";
	my $member_vars;
	my @member_vars;
	my $member_type;
	my $member_name;
	my $printPre;
	my $member_array_name;
	my $member_array_size;
	my $struct_name;
	my $function_def;

	$parms = shift @_;
	print DBG "\^SAVESAVEsave_typedef : $parms\n";
	
	### typedef struct TTT { ...} ...; 일때 TTT의 struct 이름을 찾기 위함.
	if($parms =~ /^\s*typedef\s+struct\s+([\w\s]+)\{/){ 
		$struct_name = $1;
		push @struct_name , $struct_name;
		#print DBG "save_typedef struct \$struct_name : $struct_name\n"; 
		#print DBG "save_typedef struct \@struct_name : @struct_name\n"; 
	}
	### typedef struct ... { ...} TTT; 일때 TTT의 typedef 이름을 찾기 위함.
	if($parms =~ /\}\s+(\w+)\s*\;/){ 
		$typedef_name = $1;
		push @typedef_name , $typedef_name;
		#print DBG "save_typedef typedef \$typedef_name : $typedef_name\n"; 
		#print DBG "save_typedef typedef \@typedef_name : @typedef_name\n"; 
	}
	unless($parms =~ s/typedef\s+struct\s+([\w\s]+)\{//){ die $error = 1;}
	unless($parms =~ s/\}\s+(\w+)\s*\;//){ die $error = 2;}
	
	### encode file의 header를 정의
	$typedef_enc_func{$typedef_name} = $typedef_name . $primitives{"ENC"};
	### encode file안의  function들에 대한 주석 정의
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$typedef_enc_func{$typedef_name}/;
				$upr =~ s/\+Intro\+/Encoding Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/규칙에 틀린 곳을 찾아주세요./;
				$upr =~ s/\+Note\+/structg.pl로 만들어진 자동 코드/;
				if($upr =~ /\+Param\+/){
					print ENC " * \@param *pstTo 		: To Pointer\n";
					print ENC " * \@param *pstFrom 	: From Pointer\n";
				} else {
					print ENC $upr;
				}
			}
			close UPR;
    ### encode file안의 function이름 정의  : void  type이름_enc(to,from)
	$function_def = "void $typedef_enc_func{$typedef_name}"."($typedef_name *pstTo , $typedef_name *pstFrom)";
	$function_def{$typedef_enc_func{$typedef_name}} = $function_def;
	print_fp ("$function_def\{\n",DBG,ENC);


    ### decode file의 header를 정의
	$typedef_dec_func{$typedef_name} = $typedef_name . $primitives{"DEC"};
     ### decode file안의  function들에 대한 주석 정의
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$typedef_dec_func{$typedef_name}/;
				$upr =~ s/\+Intro\+/Decoding Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/규칙에 틀린 곳을 찾아주세요./;
				$upr =~ s/\+Note\+/structg.pl로 만들어진 자동 코드/;
				if($upr =~ /\+Param\+/){
					print DEC " * \@param *pstTo 		: To Pointer\n";
					print DEC " * \@param *pstFrom 	: From Pointer\n";
				} else {
					print DEC $upr;
				}
			}
			close UPR;
    ### decode file안의 function이름 정의  : void  type이름_dec(to,from)
	$function_def = "void $typedef_dec_func{$typedef_name}"."($typedef_name *pstTo , $typedef_name *pstFrom)";
	$function_def{$typedef_dec_func{$typedef_name}} = $function_def;
	print_fp ("$function_def\{\n",DBG,DEC);


    ### print file의 header를 정의
	$typedef_prt_func{$typedef_name} = $typedef_name . $primitives{"PRT"};
	$typedef_fpp_func{$typedef_name} = $typedef_name . $primitives{"FPP"};
     ### print file안의  function들에 대한 주석 정의
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$typedef_prt_func{$typedef_name}/;
				$upr =~ s/\+Intro\+/Printing Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/규칙에 틀린 곳을 찾아주세요./;
				$upr =~ s/\+Note\+/structg.pl로 만들어진 자동 코드/;
				if($upr =~ /\+Param\+/){
					print PRT " * \@param *pcPrtPrefixStr 	: Print Prefix String\n";
					print PRT " * \@param *pthis 		: Print변수 Pointer\n";
				} else {
					print PRT $upr;
				}
			}
			close UPR;
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$typedef_fpp_func{$typedef_name}/;
				$upr =~ s/\+Intro\+/Printing Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/규칙에 틀린 곳을 찾아주세요./;
				$upr =~ s/\+Note\+/structg.pl로 만들어진 자동 코드/;
				if($upr =~ /\+Param\+/){
					print FPP " * \@param *fp 	:  file pointer\n";
					print FPP " * \@param *pthis 		: Print변수 Pointer\n";
				} else {
					print FPP $upr;
				}
			}
			close UPR;
	### print file안의 function이름 정의  : void  type이름_prt(this)
	$function_def = "void $typedef_prt_func{$typedef_name}"."(S8 *pcPrtPrefixStr, $typedef_name *pthis)";
	$function_def{$typedef_prt_func{$typedef_name}} = $function_def;
	print_fp ("$function_def\{\n",DBG,PRT);
	print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis = %p" . "\\n\",pcPrtPrefixStr, pthis)\;\n",DBG,PRT);
	## 여기까지가 typdef struct xxx  { } yyy; 의 기본적인 모양을 다룬 부분이다. 

	$function_def = "void $typedef_fpp_func{$typedef_name}"."(FILE *fp, $typedef_name *pthis)";
	$function_def{$typedef_fpp_func{$typedef_name}} = $function_def;
	print_fp ("$function_def\{\n",DBG,FPP);


	
	## $$trtr이라고 하면 $parms로 수행되는지 확인하는 것임 (OK)
	#$trtr = "parms";
	#print "trtr = $trtr\n";
	#print "\$$trtr = $$trtr\n \$error = $error\n";

	## { } 안의 것들을 ;을 기분으로 분리 시킨다.
    ### member  변수들 대로 분리 함.
    ### 각 member 변수들에 대한 처리를 하는 routine이다.
    ### foreach 로 각 변수를 받아서
    ###     struct로 시작하면 (struct A B) 형식
    ###         3개의 요소이며, enc/dec에서는 pointer로 가정하여 0으로 처리
    ###     일반적인 (A B) 형식
    ###         pointer일 경우          // null
    ###         [] 으로 선언될 경우     // null
    ###         [??] size가  포함된 경우    // enc/dec/prt에서 for 문을 돌며 처리
    ###         int a; 와 같이 일반적인 경우    // typedef로 앞에 정의된 것이면 해당 함수를 call
	###			()이 포함된 것을 함수로 취급 	// enc/dec/prt에서 no processing
	###											// U8 (*func)(char*,....); 처리 가능
    ### 위 경우들에 대해서 처리해 준다.
    ###
	@member_vars = split(";",$parms);
	#print "var : @member_vars\n";
	foreach $member_vars (@member_vars){
		#print "KK : [$member_vars]\n";
		#print DBG "member_vars 1 = $member_vars\n";
		$member_vars =~ s/\%.*\%//g;
		$member_vars =~ s/\#.*\#//g;
		#print DBG "member_vars 2 = $member_vars\n";
		## 앞의 \s를 없앤다. (white space)
		$member_vars =~ s/\s*(\w[\w\s]*\w)/$1/;
		#print DBG "member_vars 3 = $member_vars\n";
		#print "KK : [$member_vars]\n";


		if($member_vars =~ /^\s*BIT(\d+)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*$/){ # BIT인 경우
			#print DBG "MEMBER BIT $1 $2 $3 $4 $5\n";
			my $bit_tot = $1;
			my $bit_name = $2;
			my $bit_cnt = $3;
			my $bit_struct = $4;
			my $bit_comment = $5;
			my @bit_array;

			$bit_sum += $bit_cnt;
			$bit_line  .= "$member_vars\n";
			$bit_type = "U$bit_tot";	# U8  U16  U32

			if($bit_sum >= $bit_tot){
				@bit_array = split("\n",$bit_line);
				print_fp("\t"x1 . "/* $bit_line */\n",DBG,ENC,DEC,PRT,FPP);
				print_fp("\t"x1 . "pstTo->$bit_struct\_A = $type_enc_func{$bit_type}(pstFrom->$bit_struct\_A)\;\n",DBG,ENC,DEC);
				print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$bit_struct\.A : $bit_tot = 0x%x" .  "\\n\",pcPrtPrefixStr,pthis->$bit_struct\_A" . ")\;\n",DBG,PRT);
				foreach $temp_vars (@bit_array){
					if($temp_vars =~ /^\s*$/) { next; }
					if($temp_vars =~ /^\s*BIT(\d+)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*$/){
						$bit_tot = $1;
						$bit_name = $2;
						$bit_cnt = $3;
						$bit_struct = $4;
						$bit_comment = $5;
						print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$bit_struct\.B\.$bit_name : $bit_cnt = \%d" .  "\\n\",pcPrtPrefixStr,pthis->$bit_struct\_B\_$bit_name" . ")\;\n",DBG,PRT);
						#print "\#define $bit_struct" . "_B_$2			$bit_struct\.B\.$2\n";
					}
				}
				$bit_sum = 0;
				$bit_line = "";		# 끝이 \n이 아님.
			} 
			next;
		} elsif($member_vars =~ /\(.*\)/){
			print "()()() : $member_vars\n";
			next; 
		}

		if( $member_vars =~ /^struct/){ 	 ## struct로 시작하는 것일 경우 
			print_fp("\t"x1 . "/* $member_vars */\n",DBG,ENC,DEC,PRT,FPP);
			## struct 뒤의 2개를 떼어냄 
			## 선언의 @(struct_name)에 
			if($member_vars =~ /struct\s+(\S+)\s+(\S+)/){
				$member_type = $1;
				$member_name = $2;
				## pointe *일 경우 : 값을 변환하는 것은 생략 - 0 으로 채움 
				#print DBG "struct [$member_type] [$member_name]\n";
				if($member_name =~ s/^\*+//){
					print_fp("\t"x1 . "pstTo->$member_name = 0\;\n",DBG,ENC,DEC);
					print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$member_name = $type_printV{structp}" . "\\n\",pcPrtPrefixStr,$type_printM{structp}" . "(pthis->$member_name))\;\n",DBG,PRT);
				}
				#변수들이 정의가 다 된 것이다.
				# 이 안에서만 정의를 하면 될 것이다.  
				## push한 값을 현재는 사용하지 않는다.
			}
		} else {							## U8 , U16 또는 typedef로 선언한 것으로 시작하는 경우 
			if($member_vars =~ /(\S+)\s+(\S+.*$)/){
				print_fp("\t"x1 . "/* $member_vars */\n",DBG,ENC,DEC,PRT,FPP);
				$member_type = $1;
				$member_name = $2;
				#print DBG "def [$member_type] [$member_name]\n";

				if($member_name =~ s/^\*+//){ ## pointer *일 경우 : 값을 변환하는 것은 생략 - 0 으로 채움 
					print_fp("\t"x1 . "pstTo->$member_name = 0\;\n",DBG,ENC,DEC);
					print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$member_name = $type_printV{U32}"."\\n\",pcPrtPrefixStr,$type_printM{U32}"."(pthis->$member_name))\;\n",DBG,PRT);
				} elsif($member_name =~ /(\w+)\s*\[\s*(\S*)\s*\]\s*/){	##  [] array로 선언될때의 처리
					$member_array_name = $1;
					$member_array_size = $2;
					$member_array_size =~ s/\s//;
#print "A0 $typedef_name , $member_type , $member_name , $table_log{$typedef_name} , $typedef{$member_type}\n";
					if( (not ($typedef_name =~ /^Short_/)) && ($table_log{$typedef_name} ne "") && ($typedef{$member_type} eq "")){
#print "A1 $typedef_name , $member_type , $member_name , $table_log{$typedef_name} , $typedef{$member_type}\n";
						$undefined_name = "save_typedef_member";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						if($$undefined_name{$member_array_name}){
							if($$undefined_name{$member_array_name} ne $member_type){
								print "ERROR : $typedef_name $member_type $member_array_name  != $$undefined_name{$member_array_name}\n";
								die $error = 301;
							}
						}
						$$undefined_name{$member_array_name} = $member_type;
						$undefined_name = "save_typedef_member_array";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$member_array_name} = "*";
	
						$undefined_name = "save_typedef_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{"TYPEDEF_$typedef_name"} = $typedef_name;

						$undefined_name = "save_typedef_name_$typedef_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$member_array_name} = $member_type;
						$undefined_name = "save_typedef_name_$typedef_name" . "_array";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$member_array_name} = $member_type;
						$undefined_name = "save_typedef_member_$member_array_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$typedef_name} = $member_type;
						$undefined_name = "save_typedef_member_arr_size_$member_array_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$typedef_name} = $member_array_size;
					}

					#print DBG "var [$member_array_name] [$member_array_size]\n";
					if(not $member_array_size ){
						print_fp("\t"x1 . "pstTo->$member_array_name = 0;\n",DBG,ENC,DEC);
						print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$member_name = $type_printV{U32}" . 
								"\\n\",pcPrtPrefixStr,$type_printM{U32}" . "(pthis->$member_name))\;\n",DBG,PRT);
						print_fp("\t"x1 . "FILEPRINT(fp,\"$type_printV{U32}" . 
								"$file_delimiter\",$type_printM{U32}" . "(pthis->$member_name))\;\n",DBG,FPP);
					} else {
						if(("U8" eq $member_type) || ("S8" eq $member_type) || ("STRING" eq $member_type)){
							print_fp("\t"x1 . "{ int iIndex;\n",DBG,ENC,DEC);
							print_fp("\t"x2 . "for(iIndex = 0;iIndex < $member_array_size;iIndex++){\n",DBG,ENC,DEC);
							if($type_twin_func{$member_type}){
								print_fp("\t"x3 .  "$type_enc_func{$member_type}(" .  "pstTo->$member_array_name" . "[iIndex] ," .  "pstFrom->$member_array_name" . "[iIndex])\;\n",DBG,ENC,DEC);
							} else {
								print_fp("\t"x3 . "pstTo->$member_array_name" . "[iIndex] = $type_enc_func{$member_type}(" . "pstFrom->$member_array_name" . "[iIndex])\;\n",DBG,ENC,DEC);
							}
							print_fp("\t"x2 . "}\n",DBG,ENC,DEC);
							print_fp("\t"x1 . "}\n",DBG,ENC,DEC);
							print_fp("\t"x1 . "pthis->$member_array_name" . "[$member_array_size - 1] = 0;\n",DBG,PRT,FPP);
							print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$member_array_name" . " = \%s" . "\\n\" ,pcPrtPrefixStr,pthis->$member_array_name)\;\n",DBG,PRT);
							print_fp("\t"x1 . "FILEPRINT(fp,\"" . "\%s" . "$file_delimiter\" ,pthis->$member_array_name)\;\n",DBG,FPP);
						} else {
							print_fp("\t"x1 . "{ int iIndex;\n",DBG,ENC,DEC,PRT);
							print_fp("\t"x2 . "for(iIndex = 0;iIndex < $member_array_size;iIndex++){\n",DBG,ENC,DEC,PRT);
							if($type_twin_func{$member_type}){
								print_fp("\t"x3 .  "$type_enc_func{$member_type}(" .  "pstTo->$member_array_name" . "[iIndex] ," .  "pstFrom->$member_array_name" . "[iIndex])\;\n",DBG,ENC,DEC);
							} else {
								print_fp("\t"x3 . "pstTo->$member_array_name" . "[iIndex] = $type_enc_func{$member_type}(" . "pstFrom->$member_array_name" . "[iIndex])\;\n",DBG,ENC,DEC);
							}
							if($typedef_prt_func{$member_type}){
								#print_fp("\t"x3 . "[][][] $typedef_prt_func{$member_type}" . "(pcPrtPrefixStr, &(pthis->$member_array_name" . "[iIndex]));\n" ,DBG,PRT);
								print_fp("\t"x3 . "$typedef_prt_func{$member_type}" . "(pcPrtPrefixStr, &(pthis->$member_array_name" . "[iIndex]));\n" ,DBG,PRT);
							} else {
								#print_fp("\t"x3 . "[][][] FPRINTF(LOG_LEVEL,\"_%s : pthis->$member_array_name" . "[\%4d] = $type_printV{$member_type}" . "\\n\" ,pcPrtPrefixStr,iIndex, $type_printM{$member_type}" . "(pthis->$member_array_name)" . "[iIndex])\;\n",DBG,PRT);
								print_fp("\t"x3 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$member_array_name" . "[\%4d] = $type_printV{$member_type}" . "\\n\" ,pcPrtPrefixStr,iIndex, $type_printM{$member_type}" . "(pthis->$member_array_name)" . "[iIndex])\;\n",DBG,PRT);
							}
							print_fp("\t"x2 . "}\n",DBG,ENC,DEC,PRT);
							print_fp("\t"x1 . "}\n",DBG,ENC,DEC,PRT);
						}
					}
				} else {	## pointer와 array가 아닌 일반적인 선언 처리
#print "B0 $typedef_name , $member_type , $member_name , $table_log{$typedef_name} , $typedef{$member_type}\n";
					if( (not ($typedef_name =~ /^Short_/)) && ($table_log{$typedef_name} ne "") && ($typedef{$member_type} eq "")){
#print "B1 $typedef_name , $member_type , $member_name , $table_log{$typedef_name} , $typedef{$member_type}\n";
						$undefined_name = "save_typedef_member";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						if($$undefined_name{$member_name}){
							if($$undefined_name{$member_name} ne $member_type){
								print "ERROR : $typedef_name $member_type $member_name  != $$undefined_name{$member_name}\n";
								die $error = 302;
							}
						}
						$$undefined_name{$member_name} = $member_type;
	
						$undefined_name = "save_typedef_name_$typedef_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$member_name} = $member_type;
						$undefined_name = "save_typedef_member_$member_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$typedef_name} = $member_type;
					}
					if($type{$member_type}){
						if($type_twin_func{$member_type}){
							print_fp("\t"x1 .  "$type_enc_func{$member_type}(" .  "pstTo->$member_name" . " , " .  "pstFrom->$member_name" . ")\;\n",DBG,ENC,DEC);
						} else {
							print_fp("\t"x1 . "pstTo->$member_name = $type_enc_func{$member_type}(pstFrom->$member_name)\;\n",DBG,ENC,DEC);
						}

						if($type_printPre{$member_type}){
						###$type_printPre{"STIME"} = "S8 STG_PrintPre[1024]\; strftime(STG_PrintPre, 1024, "%Y %m-%d %H:%M %S", localtime((time_t *)&+STIME+))\;";
						###$type_printM{"STIME"} = "STG_PrintPre";
						###$type_printV{"STIME"} = "\%s";
						###$type_define{"STIME"} = "time_t";
						###	print_fp("\t\{    $type_printPre{$member_type}  $member_type   $member_name\n",DBG,PRT);
							$printPre = $type_printPre{$member_type};
							$printPre =~ s/\+$member_type\+/pthis->$member_name/g;
							print_fp("\t\{    $printPre \n",DBG,PRT,FPP);
							print_fp("\t"x2 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$member_name = $type_printV{$member_type}" . "\\n\",pcPrtPrefixStr,$type_printM{$member_type}" . ")\;\n",DBG,PRT);
							print_fp("\t"x2 . "FILEPRINT(fp,\"$type_printV{$member_type}" . "$file_delimiter\",$type_printM{$member_type}" . ")\;\n",DBG,FPP);
							print_fp("\t\}\n",DBG,PRT,FPP);
						} else{
							print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$member_name = $type_printV{$member_type}" . "\\n\",pcPrtPrefixStr,$type_printM{$member_type}" . "(pthis->$member_name))\;\n",DBG,PRT);
print_fp("\t"x1 . "FILEPRINT(fp,\"$type_printV{$member_type}" . "$file_delimiter\",$type_printM{$member_type}" . "(pthis->$member_name))\;\n",DBG,FPP);
						}
					} else {
						if($typedef_enc_func{$member_type}){
							print_fp("\t"x1 . "$typedef_enc_func{$member_type}" . "(&(pstTo->$member_name) , &(pstFrom->$member_name));\n" ,DBG,ENC);
						} else {
							print_fp("\/*Warning Other: [$member_type] could NOT find.*\/\n",STDOUT,DBG,ENC);
							print_fp("\t"x1 . "$typedef_enc_func{$member_type}" . "(&(pstTo->$member_name) , &(pstFrom->$member_name));\n" ,DBG,ENC);
						}
						if($typedef_dec_func{$member_type}){
							print_fp("\t"x1 . "$member_type" . "_Dec(&(pstTo->$member_name) , &(pstFrom->$member_name));\n" ,DBG,DEC);
						} else {
							print_fp("\/*Warning Other: [$member_type] could NOT find.*\/\n",STDOUT,DBG,ENC);
							print_fp("\t"x1 . "$member_type" . "_Enc(&(pstTo->$member_name) , &(pstFrom->$member_name));\n" ,DBG,DEC);
						}
						if($typedef_prt_func{$member_type}){
							print_fp("\t"x1 . "$typedef_prt_func{$member_type}" . "(pcPrtPrefixStr, &(pthis->$member_name));\n" ,DBG,PRT);
print_fp("\t"x1 . "$typedef_fpp_func{$member_type}" . "(fp, &(pthis->$member_name));\n" ,DBG,FPP);
						} else {
							print_fp("\/*Warning Other: [$member_type] could NOT find.*\/\n",STDOUT,DBG,ENC);
							print_fp("\t"x1 . "$member_type" . "_Prt(pcPrtPrefixStr, &(pthis->$member_name));\n" ,DBG,PRT);
print_fp("\t"x1 . "$member_type" . "_CILOG(fp, &(pthis->$member_name));\n" ,DBG,FPP);
						}
					}
				}
				push @$typedef_name , "$1 $2";
				#변수들이 정의가 다 된 것이다.
				# 이 안에서만 정의를 하면 될 것이다.  
				## push한 값을 현재는 사용하지 않는다.
			}
		}
	}
	print_fp("\t"x1 . "FILEPRINT(fp,\"" . "\\n" . "\" )\;\n",DBG,FPP);
	print_fp("}\n",DBG,ENC,DEC,PRT,FPP);
	if(not $typedef_name =~ /$shortprefix/){
		++$typedef_def_cnt;
		my $hex = sprintf '0x%x' ,$typedef_def_cnt;
		print OUTH "\#define STG_DEF_$typedef_name		$typedef_def_cnt		/* Hex( $hex ) */\n";
		$typedef_def_cnt{$typedef_name} = $typedef_def_cnt;
		$typedef_def_cnt{$flatprefix . $typedef_name} = $typedef_def_cnt;
		if($typedef_def_num{$typedef_def_cnt} ne ""){
			print "ERROR : ($typedef_name : $typedef_def_cnt) typedef struct DEFINITION # was already allocated to $typedef_def_num{$typedef_def_cnt}\.\n";
			die $error = 9369;
		} else {
			$typedef_def_num{$typedef_def_cnt} = $typedef_name;
		}
		print OUTH "\#define $typedef_name"."_SIZE sizeof($typedef_name)\n\n";
	}
}

sub analysis_typedef
{
	my $parms;
	my $typedef_name="";
	my $member_vars;
	my @member_vars;
	my $member_type;
	my $member_name;
	my $member_full_name;
	my $member_pointer;
	my $printPre;
	my $member_array = "NO";
	my $member_array_name;
	my $member_array_size;
	my $struct_name;
	my $function_def;
	my $analysis_tag_define = "";
	my $cilog_hidden = "";
	my $checking_value = "";
	my $member_bit_type = "";
	my $member_bit_name = "";
	my $member_bit_bits = "";
	my $member_bit_group = "";
	my $member_sb_parsing_value = "";

	$parms = shift @_;
#print DBG "\^ANALYSIS_TYPEDEF : $parms\n";
	
	### typedef struct TTT { ...} ...; 일때 TTT의 struct 이름을 찾기 위함.
	if($parms =~ /^\s*typedef\s+struct\s+([\w\s]+)\{/){ 
		$struct_name = $1;
		print DBG "^ANALYSIS_TYPEDEF struct \$struct_name : $struct_name\n"; 
	}
	### typedef struct ... { ...} TTT; 일때 TTT의 typedef 이름을 찾기 위함.
	if($parms =~ /\}\s+(\w+)\s*\;/){ 
		$typedef_name = $1;
		print DBG "^ANALYSIS_TYPEDEF typedef \$typedef_name : $typedef_name\n"; 
		while( $parms =~ /\@\s*STG_TYPEDEF\s*:\s*(\w+)\s*:([^@]*)\@/){
			$parms =~ s/\@\s*STG_TYPEDEF\s*:\s*(\w+)\s*:([^@]*)\@//;
			print DBG "STG_TYPEDEF $typedef_name $1 $2 \n";
			$undefined_name = "ANALYSIS_$typedef_name\_STG_TYPEDEF";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$1} = $2;
			$undefined_name = "ANALYSIS_$1\_STG_TYPEDEF";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$typedef_name} = $2;
		};
	}
	unless($parms =~ s/typedef\s+struct\s+([\w\s]+)\{//){ die $error = 1;}
	unless($parms =~ s/\}\s+(\w+)\s*\;//){ die $error = 2;}

	$undefined_name = "ANALYSIS_TYPEDEF";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$typedef_name} = $struct_name;
	
	## { } 안의 것들을 ;을 기분으로 분리 시킨다.
    ### member  변수들 대로 분리 함.
    ### 각 member 변수들에 대한 처리를 하는 routine이다.
    ### foreach 로 각 변수를 받아서
    ###     struct로 시작하면 (struct A B) 형식
    ###         3개의 요소이며, enc/dec에서는 pointer로 가정하여 0으로 처리
    ###     일반적인 (A B) 형식
    ###         pointer일 경우          // null
    ###         [] 으로 선언될 경우     // null
    ###         [??] size가  포함된 경우    // enc/dec/prt에서 for 문을 돌며 처리
    ###         int a; 와 같이 일반적인 경우    // typedef로 앞에 정의된 것이면 해당 함수를 call
	###			()이 포함된 것을 함수로 취급 	// enc/dec/prt에서 no processing
	###											// U8 (*func)(char*,....); 처리 가능
    ### 위 경우들에 대해서 처리해 준다.
    ###
	@member_vars = split("\n",$parms);
	
	my $comments_start_cnt = 0;
	my $comments_end_cnt = 0;
	my $complete_line = "";
	foreach $member_vars (@member_vars){
		my $table_comments = "";
		$analysis_tag_define = "";
		$member_type = "";
		$member_name = "";
		$member_full_name = "";
		$member_array = "NO";
		$member_pointer = "NO";
		$member_array_name = "";
		$member_array_size = "";
		$cilog_hidden = "NO";
		$checking_value = "";
		$member_bit_type = "";
		$member_bit_name = "";
		$member_bit_bits = "";
		$member_bit_group = "";
		$member_sb_parsing_value = "";

		$temp = $member_vars;
		while($temp =~ /\/\*/){
			$temp =~ s/\/\*//;
			$comments_start_cnt++;
		};
		while($temp =~ /\*\//){
			$temp =~ s/\*\///;
			$comments_end_cnt++;
		};

		#ALAYSIS_DEBUG print DBG "ANALYSIS : [$member_vars : $comments_start_cnt : $comments_end_cnt]\n";
		if($comments_start_cnt > $comments_end_cnt){
			$complete_line = $complete_line . "\n$member_vars";
			next;
		} else {
			#ALAYSIS_DEBUG print DBG "ANALYSIS : [$comments_start_cnt : $comments_end_cnt : $complete_line]\n";
			$comments_start_cnt = 0;
			$comments_end_cnt = 0;
			$complete_line = $complete_line . "\n$member_vars";
			$member_vars = $complete_line;
			$complete_line = "";
		}
		

		delete @STG_PARM{keys %STG_PARM};
		delete @STG_PAR_ARRAY_VALUE{keys %STG_PAR_ARRAY_VALUE};
		delete @STG_PAR_ARRAY_NAME{keys %STG_PAR_ARRAY_NAME};
		while( $member_vars =~ /\@\s*STG_PARM\s*:\s*(\w+)\s*:([^@]*)\@/){
			$member_vars =~ s/\@\s*STG_PARM\s*:\s*(\w+)\s*:([^@]*)\@//;
			#ALAYSIS_DEBUG print DBG "STG_PARM $1 $2 : $member_vars\n";
			$STG_PARM{$1} = $2;
		};
		while( $member_vars =~ /\@\s*STG_PAR_ARRAY\s*:\s*(\w+)\s*:\s*(\d+)\s*:([^@]*)\@/){		# STG_PAR_ARRAY:이름:번호:값
			$member_vars =~ s/\@\s*STG_PAR_ARRAY\s*:\s*(\w+)\s*:\s*(\d+)\s*:([^@]*)\@//;
			#ALAYSIS_DEBUG print DBG "STG_PAR_ARRAY $1 $2 $3 : $member_vars \n";
			$STG_PAR_ARRAY_VALUE{$2} = $3;
			$STG_PAR_ARRAY_NAME{$2} = $1;
		};
		if($member_vars =~ /\/\*\*<([^\/]+)\*\// ){
			$table_comments = $1;
		}
		#ALAYSIS_DEBUG print DBG "ANALYSIS : COMMENTS [$table_comments]\n";
		$member_vars =~ s/\%.*\%//g;
		$member_vars =~ s/\#.*\#//g;
		$member_vars =~ s/\/\*.+\*\///g;    # 주석문 삭제
		if($member_vars =~ s/<\s*TAG_DEFINE\s*:\s*(\w+)\s*>\s*//){
			$analysis_tag_define = $1;
		}
		if($member_vars =~ s/\@\s*CILOG_HIDDEN\s*\@//){
			$cilog_hidden = "YES";
		}
		if($member_vars =~ s/\@\s*SB_PARSING\s*\{([^}@]*)\}\s*\@//){
			$member_sb_parsing_value = $1;
			$member_sb_parsing_value =~ s/\+\+STNAME_SB\+\+/$typedef_name/g;
			$undefined_name = "SB_PARSING";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$typedef_name} = $typedef_name;

			$undefined_name = "SB_PARSING_$typedef_name";
			$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
			push @$undefined_name , "$member_sb_parsing_value";
		}
		if($member_vars =~ s/\@\s*CHECKING_VALUE\s*:\s*([^@]*)\s*\@//){
			$checking_value = $1;
			$checking_value =~ s/\s//g;
		}
		#ALAYSIS_DEBUG print DBG "member_vars 2 : $typedef_name : TAG $analysis_tag_define : VARS $member_vars\n";
		## 앞의 \s를 없앤다. (white space)
		if ($member_vars =~ /\s*(BIT\d*)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*\;/){
			#ALAYSIS_DEBUG print DBG "member_BIT $1   $2   $3   $4\n";
			$member_type = $1;
			$member_name = "$4\_B_$2";	#  = $member_bit_group _B_ $member_bit_name
			$member_bit_type = $1;
			$member_bit_name = $2;
			$member_bit_bits = $3;
			$member_bit_group = $4;

			$undefined_name = "ANALYSIS_ARRAY_$typedef_name\_BIT_NAME_$member_bit_group";
			$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
			push @$undefined_name , "$member_bit_name";

			$undefined_name = "ANALYSIS_ARRAY_$typedef_name\_BIT_BITS_$member_bit_group";
			$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
			push @$undefined_name , "$member_bit_bits";

			$undefined_name = "ANALYSIS_ARRAY_$typedef_name\_BIT_TYPE_$member_bit_group";
			$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
			push @$undefined_name , "$member_bit_type";

			$undefined_name = "ANALYSIS_$typedef_name\_BIT";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_bit_group} = $member_type;
		} elsif($member_vars =~ /\s*(\w+)\s+([^:;]+)/){
			$member_type = $1;
			$member_name = $2;
			$member_name =~ s/\s//g;
		}
		
		$member_full_name = $member_name;
		if($member_name =~ /\([^()]*\)\s*\([^()]*\)/){ next;}
		if(not $member_name){ next;}

		#ALAYSIS_DEBUG print DBG "member_vars 3 : TYPE $member_type : NAME $member_name\n";
		if($member_name =~ s/\*//){
			$member_pointer = "YES";
		}
		if($member_name =~ /(\w+)\s*\[\s*(\S*)\s*\]\s*/){	##  [] array로 선언될때의 처리
			$member_array = "YES";
			$member_array_name = $1;
			$member_array_size = $2;
			$member_name = $1;
		}
		#ALAYSIS_DEBUG print DBG "member_vars 4 : TYPE $member_type : NAME $member_name : ARRAY $member_array : SIZE $member_array_size\n";

		if($member_sb_parsing_value){
			# 나중에 type을 원할때 sb_parsing rule이 정의된 line들에 대한 것을 사용하게 한다.
		}

		$undefined_name = "ANALYSIS_ARRAY_$typedef_name";
		$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
		push @$undefined_name , "$member_name";
		$undefined_name = "ANALYSIS_$typedef_name";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$member_name} = $member_type;
		$undefined_name = "ANALYSIS_$typedef_name\_type";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$member_name} = $member_type;
			$undefined_name = "ANALYSIS_$typedef_name\_member_full";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_name} = $member_full_name;
			$undefined_name = "ANALYSIS_$typedef_name\_pointer";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_name} = $member_pointer;
			$undefined_name = "ANALYSIS_$typedef_name\_array";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_name} = $member_array;
			$undefined_name = "ANALYSIS_$typedef_name\_array_size";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_name} = $member_array_size;
			$undefined_name = "ANALYSIS_$typedef_name\_tag_define";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_name} = $analysis_tag_define;
			$undefined_name = "ANALYSIS_$typedef_name\_CHECK";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_name} = $checking_value;
			$undefined_name = "ANALYSIS_$typedef_name\_CILOG_HIDDEN";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_name} = $cilog_hidden;
			$undefined_name = "ANALYSIS_$typedef_name\_COMMENTS";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_name} = "\/** $member_type    $member_full_name  : HIDDEN = " . "$cilog_hidden *\/";
			$undefined_name = "ANALYSIS_$typedef_name\_TABLE_COMMENTS";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_name} = $table_comments;
			foreach $temp (keys %STG_PARM) {
				#ALAYSIS_DEBUG print DBG "$type{member_type} : STG_PARM { $temp } = \"$STG_PARM{$temp}\"\n";
				$undefined_name = "ANALYSIS_$typedef_name\_STG_PARM";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$temp} = $temp;
				$undefined_name = "ANALYSIS_$typedef_name\_STG_PARM_$temp";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$member_name} = $STG_PARM{$temp};
			}
			foreach $temp (keys %STG_PAR_ARRAY_VALUE){
				#ALAYSIS_DEBUG print DBG "$temp: STG_PAR_ARRAY_NAME { $temp } = \"$STG_PAR_ARRAY_NAME{$temp}\"\n";
				$undefined_name = "ANALYSIS_$typedef_name\_STG_PAR_ARRAY";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$STG_PAR_ARRAY_NAME{$temp}} = $STG_PAR_ARRAY_VALUE{$temp};
				$undefined_name = "ANALYSIS_$typedef_name\_STG_PAR_ARRAY_MEMBER_$STG_PAR_ARRAY_NAME{$temp}";
				$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
				$$undefined_name[$temp] = $member_name;
				$undefined_name = "ANALYSIS_$typedef_name\_STG_PAR_ARRAY_VALUE_$STG_PAR_ARRAY_NAME{$temp}";
				$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
				$$undefined_name[$temp] = $STG_PAR_ARRAY_VALUE{$temp};
				$undefined_name = "ANALYSIS_$typedef_name\_STG_PAR_ARRAY_NEXT_$STG_PAR_ARRAY_NAME{$temp}";
				$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
				$$undefined_name[$temp] = $temp + 1;
			}

		if($type{$member_type}){
			## 간단히 하기 위해서 U8 , S8 은 String Array만이 존재한다.
			## U8 , S8 의 그냥 선언은 없는 것으로 보는 것이 좋을 것이다. 
			if($cilog_hidden eq "NO"){
				$undefined_name = "ANALYSIS_ARRAY_CILOG_TABLE_$typedef_name";
				$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
				push @$undefined_name , "$member_name";
			}
			if($type_printPre{$member_type}){
				$printPre = $type_printPre{$member_type};
				$printPre =~ s/\+$member_type\+/pthis->$member_name/g;
				$undefined_name = "ANALYSIS_$typedef_name\_PrintPreAction";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$member_name} = $printPre;
				$undefined_name = "ANALYSIS_$typedef_name\_PrintFormat";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$member_name} = $type_printV{$member_type};
				$undefined_name = "ANALYSIS_$typedef_name\_PrintValue";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$member_name} = $type_printM{$member_type};
			} else {
				$undefined_name = "ANALYSIS_$typedef_name\_PrintFormat";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$member_name} = $type_printV{$member_type};
				$undefined_name = "ANALYSIS_$typedef_name\_PrintValue";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$member_name} = "pthis->$member_name";
				$undefined_name = "ANALYSIS_$typedef_name\_PrintValueFunc";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$member_name} = $type_printM{$member_type};
			}
			if( ($cilog_hidden eq "NO") && ($checking_value ne "") ){
				$undefined_name = "ANALYSIS_$typedef_name\_CHECKING_VALUE";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$member_name} = "YES";
				my @check_vars;
#print "Check : $checking_value\n";
				@check_vars = split(",",$checking_value);
				foreach $temp (@check_vars) {
#print "Check temp : $temp\n";
					## define된 값일 경우에는 숫자로 바꿔줄 것이다.
					if($temp =~ /^([^~]+)~(.+)$/){		# A ~ B 까지.. 1개랑 mapping되는 것도 A ~ A 로 표시해야 한다. 
						$temp1 = $1;
						$temp2 = $2;
#print "Check1 : $temp1\n";
						if( not ($temp1 =~ /(\d+)/) ){
							if($define_digit{$temp1}){
								$temp1 = $define_digit{$temp1};
							} else {
								print "ERROR : $temp1 is not defined.\n";
								die $error = 444;
							}
						}
#print "Check2 : $temp2\n";
						if( not ($temp2 =~ /(\d+)/) ){
							if($define_digit{$temp2}){
								$temp2 = $define_digit{$temp2};
							} else {
								print "ERROR : $temp2 is not defined.\n";
								die $error = 445;
							}
						}
						$undefined_name = "ANALYSIS_$typedef_name\_CHECKING_VALUE_RANGE_$member_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp1} = "$temp2";
					} elsif($temp =~ /^([^~]+)~$/){		# A~ 이면 A이상이면 가능
						$temp1 = $1;
#print "Check3 : $temp1\n";
						if( not ($temp1 =~ /(\d+)/) ){
							if($define_digit{$temp1}){
								$temp1 = $define_digit{$temp1};
							} else {
								print "ERROR : $temp1 is not defined.\n";
								die $error = 444;
							}
						}
						$undefined_name = "ANALYSIS_$typedef_name\_CHECKING_VALUE_RANGE_$member_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp1} = "";
					} else {							# ~이 없다면 문자 string으로 인식 할 것이다. 
						$undefined_name = "ANALYSIS_$typedef_name\_CHECKING_VALUE_STRING_$member_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp} = length($temp);
					}
# ??? LIST를 Gourping하여 그 값을 대표적으로 사용하게 하는 것을 마드러야  할 것이다. 
				}
			}
		} elsif($typedef{$member_type}){
			$undefined_name = "ANALYSIS_$typedef_name\_TYPEDEF_func";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$member_name} = $member_type;
		} else {
			print_fp("()()() : $typedef_name : unknown $member_vars\n",DBG,STDOUT);
		}

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

# function.upr의 내용대로 subroutine에 대해서도 같은 방식의 주석을 단다.
#/** flat_save_typedef function.
# *
# *  typedef struct ... { ... } ...; 을 입력받아 enc/dec/print같은 해당 코드들을 자동 생성시켜준다.
# *
# *  @param  $typedef  typedef struct ... { ... } ...; 을 입력받아
# *
# *  @return    void
# *  @see       structg.pl : structg.pl을 변형하여 flat....h 를 만든 화일
# *
# *  @exception  nested structure를  내부에 정의한 것은 처리 안됨.
# *  @note      +Note+
# **/
sub flat_save_typedef
{
	my $parms;
	my $parm_member_type;
	my $member_type;
	my $member_name;
	my $yh_tablename;
	my $typedef_name;
	my $table_field_name;
	my @member_vars;
	my $member_vars;
	my $member_array_size;
	my $member_array_name;
	my $struct_name;
	my $error;

	$flat_typedef_contents = "";
	$parms = shift @_;
	#print DBG "^flat_save_typedef : $parms\n";
	if($parms =~ /void\s+\*/)
	{
		return ;
	}
	if($parms =~ /typedef\s+struct\s+([\w\s]+)\{/){ 
		$struct_name = $1;
		print DBG "FLAT : struct \$struct_name : $struct_name\n"; 
		while($parms =~ /struct\s*$struct_name/){
			$parms =~ s/struct\s*$struct_name/struct $flatprefix$struct_name/;
		};
		push @struct_name , $flatprefix . $struct_name;
	}
	if($parms =~ /\}\s+(\w+)\s*\;/){ 
		$typedef_name = $1;
		push @typedef_name , $flatprefix . $typedef_name;
		print DBG "FLAT : typedef \$typedef_name : $typedef_name\n"; 
	}
	## typedef struct ... { 과 끝의 } ....; 을 없앤다.
	unless($parms =~ s/typedef\s+struct\s+([\w\s]+)\{//){ die $error = 3;}
	unless($parms =~ s/\}\s+(\w+)\s*\;//){ die $error = 4;}
	#print DBG "flat_save_typedef | MEMBER : $parms\n";
	
            open(UPR,"<flat.upr");
            while($upr = <UPR>){
                $upr =~ s/\+FileName\+/$FlatFileName/;
                $upr =~ s/\+NTAF_ST_NAME\+/$struct_name/;
                $upr =~ s/\+NTAM_ST_NAME\+/$flatprefix$struct_name/;
                $upr =~ s/\+NTAF_TD_NAME\+/$typedef_name/;
                $upr =~ s/\+NTAM_TD_NAME\+/$flatprefix$typedef_name/;
                print FLATH $upr;
            }
            close UPR;
	print_fp ("typedef struct $flatprefix$struct_name {\n",DBG,FLATH);
	$typedef{$typedef_name} = "$flatprefix$typedef_name";
	$typedef_contents{$typedef_name} = $parms;
	## 여기까지가 typedef struct xxx  { } yyy; 의 기본적인 모양을 다룬 부분이다. 

	### ProC file의 header를 정의
	$typedef_enc_func{$typedef_name} = $typedef_name . $primitives{"ENC"};

	
	## $$trtr이라고 하면 $parms로 수행되는지 확인하는 것임 (OK)
	#$trtr = "parms";
	#print "trtr = $trtr\n";
	#print "\$$trtr = $$trtr\n \$error = $error\n";

	## { } 안의 것들을 ;을 기준으로 분리 시킨다. 
	@member_vars = split(";",$parms);
	#print "var : @member_vars\n";
	$typedef_member_count = 0;
	foreach $member_vars (@member_vars){
		#print "KK : [$member_vars]\n";
		## 앞(^)의 \s를 없앤다. (white space)
		$member_vars =~ s/\%.*\%//g;
		$member_vars =~ s/\#.*\#//g;
		$member_vars =~ s/\s*(\w[\w\s]*\w)/$1/;
		#print "KK : [$member_vars]\n";

		if($member_vars =~ /^\s*BIT(\d+)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*$/){ # BIT인 경우
			print DBG "FLAT MEMBER BIT $1 $2 $3 $4 $5\n";
			my $bit_tot = $1;
			my $bit_name = $2;
			my $bit_cnt = $3;
			my $bit_struct = $4;
			my $bit_comment = $5;
			my @bit_array;

			$bit_sum += $bit_cnt;
			$bit_line  .= "$member_vars\n";
			$bit_type = "U$bit_tot";	# U8  U16  U32

			if($bit_sum >= $bit_tot){
				$typedef_member_count ++;
				print_fp("\t"x1 . "	$bit_type	$bit_struct;	/**< $bit_line */\n",DBG,FLATH);
				$flat_typedef_contents .= "$bit_type 	$bit_struct\_A\;";
				$bit_sum = 0;
				$bit_line = "";		# 끝이 \n이 아님.
			} 
			next;
		}

		if( $member_vars =~ /^struct/){ 	 ## struct로 시작하는 것일 경우 
			$typedef_member_count ++;
			$temp = $member_vars;
			$temp =~ s/\/\*/\<\</;
			$temp =~ s/\*\//>>/;
			print_fp("\t"x1 . "$member_vars\; 	\/\*\*< $temp \*\/\n",DBG,FLATH);
			$flat_typedef_contents .= "$member_vars\;";
		} else {							## U8 , U16 또는 typedef로 선언한 것으로 시작하는 경우 
			if($member_vars =~ /(\S+)\s+(\S+.*$)/){
				$typedef_member_count ++;
				$member_type = $1;
				$member_name = $2;
				#print DBG "def [$member_type] [$member_name]\n";

				if($member_name =~ /^\*/){ ## pointer *일 경우 : 값을 변환하는 것은 생략 - 0 으로 채움 
					if($typedef{$member_type}){
						print_fp("\t"x1 . "$typedef{$member_type} 	$member_name;	/**< $member_vars */\n",DBG,FLATH);
						$flat_typedef_contents .= "$typedef{$member_type} 	$member_name\;";
					} else {
						print_fp("\t"x1 . "$member_vars; 	/**< $member_vars */\n",DBG,FLATH);
						$flat_typedef_contents .= "$member_vars\;";
					}
				} elsif($member_name =~ /(\w+)\s*\[(\s*[\w]*\s*)\]\s*/){	##  [] array로 선언될때의 처리
					$member_array_name = $1;
					$member_array_size = $2;
					if($typedef{$parm_member_type}){ 	### [] 이면서 typdef struct이면 처리 못함.
						#print DBG "var \$member_array_name [$member_array_name] : \$member_array_size [$member_array_size]\n";
						print_fp("\t"x1 . "/**< $member_type::$member_vars */\n",DBG,FLATH);
						print_fp("\t"x1 . "Warning : 사용하면 DB에서 처리하기 곤란함. 어떻게 변경해야 하는지 의견을 주세요;\n",DBG,FLATH);
					} else { 		### [] 인데 U8과 같은 structure가 아닌 경우 
						print_fp("\t"x1 . "$member_vars; 	/**< $member_vars */\n",DBG,FLATH);
						$flat_typedef_contents .= "$member_vars\;";
					}
				} else {	## pointer와 array가 아닌 일반적인 선언 처리
					if($typedef{$member_type}){
						#print_fp("\t"x1 . "$typedef_contents{$member_type};  /**< $member_vars */\n",DBG,FLATH);
						$typedef_member_count --;
						$Not_flat_table{$typedef_name} = "YES";
						expansion_member($member_name . $expansionprefix , $typedef_contents{$member_type},$member_type);
					} else {
						print_fp("\t"x1 . "$member_vars; 	/**< $member_vars */\n",DBG,FLATH);
						$flat_typedef_contents .= "$member_vars\;";
					}
				}
			}
		}
	}
	print_fp("} $flatprefix$typedef_name ;\n",DBG,FLATH);
	$flat_typedef_contents{$typedef_name} = $flat_typedef_contents;
	print FLATH "\#define $flatprefix$typedef_name"."_SIZE sizeof($flatprefix$typedef_name)\n\n";
			open(UPR,"<pc.upr");
			$table_field_name = "" ;
			for(my $i = 1 ; $i <= $typedef_member_count ; $i++){
				$table_field_name .= ":v$i, "
			}
			$typedef_member_count{$typedef_name} = $typedef_member_count;
			$typedef_member_count{$flatprefix . $typedef_name} = $typedef_member_count;
			$flat_function_def{"DBInsert_"."$typedef{$typedef_name}"} = "int DBInsert_"."$typedef{$typedef_name}"."(int dCount, $typedef{$typedef_name} *pstData, char *pszName, int *pdErrRow)";
			while($upr = <UPR>){
				$yh_tablename = $typedef{$typedef_name};
				$yh_tablename =~ s/$flatprefix//;
				if($yh_tablename =~ /^\s*STAT\s*/){
					$upr =~ s/\+SmallTableName\+/$yh_tablename/;
				} else {
					my $yh_tablename_temp;
					$yh_tablename_temp = $yh_tablename . "_\%s";
					$upr =~ s/\+SmallTableName\+/$yh_tablename_temp/;
					$upr =~ s/\+SmallTableName_a\+/$yh_tablename/;
				}
				$upr =~ s/\+TableName\+/$typedef{$typedef_name}/;
				$upr =~ s/\+Intro\+/DB함수 : $typedef{$typedef_name}을 DB에 넣는 함수/;
				$upr =~ s/\+DB_Table_Field_Name\+/$table_field_name/;
				$upr =~ s/\+Function_Definition\+/$flat_function_def{"DBInsert_"."$typedef{$typedef_name}"}/;
				$upr =~ s/\+HEADER\+/$FlatFileName/;
				print ProC $upr;
			}
			close UPR;
}

# function.upr의 내용대로 subroutine에 대해서도 같은 방식의 주석을 단다.
#/** expansion_member function.
# *
# *  typedef struct _st_AAA { int a; } stAAA;
# *  typedef struct _st_BBB { int b; stAAA a; } stBBB;
# *  stBBB를 flat할때 stAAA의 내용을 여기에 펼쳐야 한다.
# *  이때 stAAA a; 를 prefix a_를 붙여서 러치를 한다.
# *  recursive 함수로써 prefix를 계속 붙여 갈수 있다.
# *  선언되는 순서는 앞에 미리 정의된 것들만을 사용하여야 한다.
# *
# *  @param  $parm_member_prefix    a_ (이와 같은 name의 prefix를 더함)
# *  @param  $parm_member_contents    stAAA의 내용이 여기에 들어감
# *  @param  $parm_member_comment    어떤 것에서 nested되는 것인지 주석에 표시하기 위해서
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl을 변형하여 flat....h 를 만든 화일
# *
# *  @exception  nested structure를  내부에 정의한느 것은 처리 안됨.
# *  @note      +Note+
# **/
sub	expansion_member
{
	my $parm_member_prefix;
	my $parm_member_contents;
	my $parm_member_comment;
	my @parm_member_vars;
	my $parm_member_vars;
	my $parm_member_vars_org;
	my $parm_member_type;
	my $parm_member_name;
	my $parm_member_array_name;
	my 	$parm_member_array_size;

	#print DBG "expansion_member | parms : @_\n";
	$parm_member_prefix = shift @_;
	$parm_member_contents = shift @_;
	$parm_member_comment = shift @_;
	#print FLATH "parms : $parm_member_comment\n";

	## { } 안의 것들을 ;을 기분으로 분리 시킨다. 
	@parm_member_vars = split(";",$parm_member_contents);
	#print "var : @member_vars\n";
	foreach $parm_member_vars (@parm_member_vars){
		$parm_member_vars =~ s/\s*(\w[\w\s]*\w)/$1/;
		$parm_member_vars_org = $parm_member_vars ;
		$parm_member_vars =~ s/(\*+)/$1$parm_member_prefix/;
		#print DBG "\$parm_member_vars : $parm_member_vars\n";

		if($parm_member_vars =~ /^\s*BIT(\d+)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*$/){ # BIT인 경우
			#print DBG "PARM FLAT MEMBER BIT $1 $2 $3 $4 $5\n";
			my $bit_tot = $1;
			my $bit_name = $2;
			my $bit_cnt = $3;
			my $bit_struct = $4;
			my $bit_comment = $5;
			my @bit_array;

			$bit_sum += $bit_cnt;
			$bit_line  .= "$parm_member_vars\n";
			$bit_type = "U$bit_tot";	# U8  U16  U32

			if($bit_sum >= $bit_tot){
				$typedef_member_count ++;
				print_fp("\t"x1 . "	$bit_type	$parm_member_prefix$bit_struct;	/**< $bit_line */\n",DBG,FLATH);
				$flat_typedef_contents .= "$bit_type 	$parm_member_prefix$bit_struct\_A\;";
				$bit_sum = 0;
				$bit_line = "";		# 끝이 \n이 아님.
			} 
			next;
		}

		if( $parm_member_vars =~ /^struct/){ 	 ## struct로 시작하는 것일 경우 
			$typedef_member_count ++;
			print_fp("\t"x1 . "$parm_member_vars; 	/**< $parm_member_comment :: $parm_member_vars_org */\n",DBG,FLATH);
			$flat_typedef_contents .= "$parm_member_vars\;";
		} else {							## U8 , U16 또는 typedef로 선언한 것으로 시작하는 경우 
			if($parm_member_vars =~ /(\S+)\s+(\S+.*$)/){
				$typedef_member_count ++;
				$parm_member_type = $1;
				$parm_member_name = $2;
				#print DBG "expansion_member | def [$parm_member_type] [$parm_member_name]\n";

				if($parm_member_name =~ /^\*/){ ## pointer *일 경우 : 값을 변환하는 것은 생략 - 0 으로 채움 
					print_fp("\t"x1 . "$parm_member_type 	$parm_member_name;	/**< $parm_member_comment :: $parm_member_vars_org */\n",DBG,FLATH);
					$flat_typedef_contents .= "$parm_member_type 	$parm_member_name\;";
				} elsif($parm_member_name =~ /(\w+)\s*\[(\s*[\w]*\s*)\]\s*/){	##  [] array로 선언될때의 처리
					$parm_member_array_name = $1;
					$parm_member_array_size = $2;
					if($typedef{$parm_member_type}){ 	### [] 이면서 typdef struct이면 처리 못함.
						#print DBG "expansion_member | var \$parm_member_array_name [$parm_member_array_name] : \$parm_member_array_size [$parm_member_array_size]\n";
						print_fp("\t"x1 . "/** Warning : $parm_member_type::$parm_member_vars */\n",STDOUT,DBG,FLATH);
						print_fp("\t"x1 . "Warning : 사용하면 DB에서 처리하기 곤란함. 어떻게 변경해야 하는지 의견을 주세요;\n",STDOUT,DBG,FLATH);
					} else { 		### [] 인데 U8과 같은 structure가 아닌 경우 
						print_fp("\t"x1 . "$parm_member_type 	$parm_member_prefix$parm_member_name; 	/**< $parm_member_comment :: $parm_member_vars_org */\n",DBG,FLATH);
						$flat_typedef_contents .= "$parm_member_type 	$parm_member_prefix$parm_member_name\;";
					}
				} else {	### pointer와 array가 아닌 일반적인 선언 처리
					if($typedef{$parm_member_type}){ 	###  typedef struct로 정의된 Type일 경우
						#print DBG "expansion_member | $typedef_contents{$parm_member_type};  /**< $parm_member_type::$parm_member_vars */\n";
						$typedef_member_count --;
						expansion_member("$parm_member_prefix"."$parm_member_name".$expansionprefix, $typedef_contents{$parm_member_type},"$parm_member_comment  :: $parm_member_type");
					} else {							### typedef로 U8과 같은 structure가 아닌 경우 
						print_fp("\t"x1 . "$parm_member_type 	$parm_member_prefix$parm_member_name; 	/**< $parm_member_comment :: $parm_member_vars_org */\n",DBG,FLATH);
						$flat_typedef_contents .= "$parm_member_type 	$parm_member_prefix$parm_member_name\;";
					}
				}
			}
		}
	}
}

# function.upr의 내용대로 subroutine에 대해서도 같은 방식의 주석을 단다.
#/** stg_hash_key2 function.
# *
# *		NTAM 자동화 1차를 위한 함수 
# *
# *  (순서 B) - 완료 
# *  STG_HASH_KEY typedef struct ... 라는 것을 받아서 
# *  STG_HASH_KEY를 뗀 것을 save_typedef , flat_save_typedef로 보내어 처리를 한후에, 
# *  2개씩을 짝지어 처리 다시 save_typedef , flat_save_typedef로 보내어 code를 자동으로 만들어주어야 할 것이다.
# *  KEY와 DATA로 분리를 함. 
# *  
# *  (순서 C) - 코드 준비 완료
# *  +HASH_INIT+ 으로 정의 된 부분에 초기화를 수행하게 만들 것이며, 
# *  선언되는 순서는 앞에 미리 정의된 것들만을 사용하여야 한다.
# *	
# *	 (순서 A) - 완료
# *	 ID를 define하게 하여 structure마다 자동으로 define값을 가지게 만들어야 할 것이다. STRUCTURE TYPE이 될 것이다.  
# *	 switch에서 case부분을 이것으로 처리를 해야하며, 각각에 대해서 어떤 값을 어떻게 바꾸지는지는 upr로 처리를 해야할 것이다.  
# *  TIME64 처리
# *  
# *  일반적으로 stg_hash_key2를 이용하면
# *  기본적으로 한줄의 내용으로 위에서 선언한 것 중에서 한개를 골라 HASH의 KEY로 사용하는 방법이다.
# * 이렇게 하여 HASH KEY는 맨 뒤에 선언되어지고 , 그 것을 앞에서 사용할수 있다는 것이다. 
# *
# *  @param  $parm_member_prefix    a_ (이와 같은 name의 prefix를 더함)
# *  @param  $parm_member_contents    stAAA의 내용이 여기에 들어감
# *  @param  $parm_member_comment    어떤 것에서 nested되는 것인지 주석에 표시하기 위해서
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl을 변형하여 flat....h 를 만든 화일
# *
# *  @exception  nested structure를  내부에 정의한느 것은 처리 안됨.
# *  @note      +Note+
# **/
sub stg_hash_key2
{
	my $parm_typedef_org;
	my $parm_typedef;
	my $parms;
	my $typedef_name;
	my $error;
	my @members;
	my @members_type;
	my @members_name;
	my $cnt;
	my $member_typedef;
	my $function_def;

	$typedef_name = shift @_;
	print DBG "stg_hash_key2 : \$typedef_name = $typedef_name\n";

	$parm_typedef = $parm_typedef_org;

	$parms = $typedef_contents{$typedef_name};;
	print DBG "stg_hash_key2 : \$typedef_contents = $parms\n";

	@members = split(";",$parms);
	$cnt = @members;
	$cnt--;		# 맨뒤의 ; 의 뒤는 없으므로 이것은 제외를 시켜주어야함.
	print DBG "stg_hash_key | \@members = @members : cnt = $cnt\n";
	for(my $i = 0 ; $i < $cnt ; $i++){
		my $member_stat;
		$members[$i] =~ s/^\s*//g;
	   	$member_stat = $members[$i];
		if($member_stat =~ /(\S+)\s+(\S+.*$)/){
			$members_type[$i] = $1;
			$members_name[$i] = $2;
			$members_name[$i] =~ s/^\s*//g;
			print_fp("stg_hash_key | \[$member_stat\]  : \[$members_type[$i]\]   \[$members_name[$i]\]\n",DBG);
		}
		if($members_name[$i] =~ /(\w+)\s*\[(\s*[\w]*\s*)\]\s*/){	##  [] array로 선언될때의 처리
			$members_name[$i] = $1;
			print_fp("stg_hash_key | $members_type[$i]   $members_name[$i]\n",DBG);
		}
	}

	for(my $i = 0 ; $i < $cnt-1 ; $i++){
		my $basic_name;
		# 2개씩의 structure
		$basic_name = "$members_name[$i+1]_$members_name[$i]";
		$stg_key_hashs{$basic_name} = "STG_$basic_name";
		$member_typedef = "typedef struct _st_$basic_name \{ \n";
		$member_typedef .= "\tU32 		uiCommand\; \n";
		$member_typedef .= "\t$members[$i+1]\;\n";
		$member_typedef .= "\t$members[$i]\; \n";
		$member_typedef .= "\} STG_$basic_name \;\n";

		$undefined_name = "HASH_KEY";
		$undefined_typedef{$undefined_name} = "HASH_HASH_KEY";
		$$undefined_name{$members_name[$i+1]} = "$basic_name";

		$undefined_name = "HASH_KEY_TYPE";
		$undefined_typedef{$undefined_name} = "HASH_HASH_KEY_TYPE";
		$$undefined_name{$members_name[$i+1]} = "$members_type[$i+1]";

		$undefined_name = "HASH_KEY_IS";
		$undefined_typedef{$undefined_name} = "HASH_HASH_KEY_IS";
		$$undefined_name{$members_name[$i+1]} = "$type_is{$members_type[$i+1]}";
		print_fp("\#define		STG_HASH_KEY_$basic_name" . "_IS(XXX)		$type_is{$members_type[$i+1]} \(XXX\)\n", DBG,OUTH);

		$undefined_name = $basic_name . "_MEMBER";
		$undefined_typedef{$undefined_name} = "HASH_$basic_name";
		$$undefined_name{$members_name[$i+1]} = "$members_type[$i+1]";
		$$undefined_name{$members_name[$i]} = "$members_type[$i]";

		$undefined_name = $basic_name . "_MEMBER_KEY";
		$undefined_typedef{$undefined_name} = "HASH_$basic_name";
		$$undefined_name{$members_name[$i+1]} = "$members_type[$i+1]";

		if($i == 0){
			$undefined_name = "HASH_KEY_FIRST";
			$undefined_typedef{$undefined_name} = "HASH_HASH_KEY_FIRST";
			$$undefined_name{$members_name[$i+1]} = "$basic_name";
		} 
		else {
			$undefined_name = "HASH_KEY_OTHER";
			$undefined_typedef{$undefined_name} = "HASH_HASH_KEY_OTHER";
			$$undefined_name{$members_name[$i+1]} = "$basic_name";
		}

		print_fp("stg_hash_key | \[$i\] $member_typedef\n",DBG);
		print_fp("/** \@brief NTAM Corelation 자동 코드 - STG_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);

		# 2개 중에 key가 되는 structure (KEY)
		$member_typedef = "typedef struct _st_key_$members_name[$i+1]_$members_name[$i] \{ \n";
		$member_typedef .= "\t$members[$i+1]\;\n";
		$member_typedef .= "} STG_KEY_$members_name[$i+1]_$members_name[$i] \;\n";
		print_fp("stg_hash_key | \[$i\] $member_typedef\n",DBG);
		print_fp("/** \@brief NTAM Corelation 자동 코드 - STG_KEY_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);

		# 2개중에 data가 되는 부분으로 TimerId가 추가 된다. (DATA)
		$member_typedef = "typedef struct _st_data_$members_name[$i+1]_$members_name[$i] \{ \n";
		#$member_typedef .= "\t$members[$i+1]\;\n";
		#for(my $j = 0 ; $j < $cnt ; $j++){
		#	$member_typedef .= "\t$members[$j]\;\n";
		#}
		$member_typedef .= "\t$typedef_name		stgCoInfo\;\n";
		$member_typedef .= "\tU64			$stg_hash_timer_name\; \n";
		if($i == 0){
			foreach my $temp_typedef (keys %table_log){
					$member_typedef .= "\tU16 		usCnt$temp_typedef\;\n";
					$member_typedef .= "\tU16 		usIsDone$temp_typedef\;\n";
					$member_typedef .= "\t$temp_typedef 	*p$temp_typedef\;\n";
			}
			$stg_hash_first_data = "STG_DATA_$members_name[$i+1]_$members_name[$i]";
			$stg_hash_first_key = "$members_name[$i+1]"; 
			$stg_hash_first_key_name = "$members_name[$i+1]_$members_name[$i]";
			$stg_hash_first_key_type = "$members_type[$i+1]";
			$stg_hash_first_key_is = "$type_is{$members_type[$i+1]}";
			foreach my $temp_typedef (keys %combi_typedef){
				$member_typedef .= "\t$temp_typedef 	$staticprefix$temp_typedef\;\n";
			}
			foreach my $temp_typedef (keys %stat_typedef){
				$member_typedef .= "\t$temp_typedef 	$staticprefix$temp_typedef\;\n";
			}
		}
		$member_typedef .= "} STG_DATA_$members_name[$i+1]_$members_name[$i] \;\n";
		print_fp("stg_hash_key | \[$i\] $member_typedef\n",DBG);
		print_fp("/** \@brief NTAM Corelation 자동 코드 - STG_DATA_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);
	}

	### combination file의 header를 정의
	my $set_combi_func = "Set_Combination_Once";
	open(COMBI , ">$outputdir/HD/$set_combi_func" . "\.c");
	$filelist{"HD/$set_combi_func" . "\.c"} = "CFILE";
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_combi_func\.c/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
				$upr =~ s/\+ToDo\+/library를 만들기 위한 Makefile을 만들자/;
				$upr =~ s/\+Intro\+/COMBINATION typedef를 위한 functions/;
				$upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
				print COMBI $upr;
			}
			close UPR;
		print_fp("\#include \"$FileName\"\n",COMBI);
		### combiode file안의  function들에 대한 주석 정의
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$set_combi_func/;
				$upr =~ s/\+Intro\+/Set Combination Values Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/규칙에 틀린 곳을 찾아주세요./;
				$upr =~ s/\+Note\+/structg.pl로 만들어진 자동 코드/;
				if($upr =~ /\+Param\+/){
					print COMBI " * \@param *p$stg_hash_first_data 		: DATA Pointer\n";
				} else {
					print COMBI $upr;
				}
			}
			close UPR;

    ### combiode file안의 function이름 정의  : void  type이름_combi(to,from)
	$function_def = "void $set_combi_func"."($stg_hash_first_data *p$stg_hash_first_data)";
	$typedef_combi_func{$set_combi_func} = $set_combi_func;
	$function_def{$set_combi_func} = $function_def;
	print_fp ("$function_def\{\n\t$stg_hash_first_data *pthis = p$stg_hash_first_data\;\n",DBG,COMBI);
	foreach my $temp_typedef (keys %table_log){
		if($temp_typedef =~ /^$prefix_logdb_table/){		# LOG_
			print_fp("\t$temp_typedef 	*p$temp_typedef \= p$stg_hash_first_data" . "->" . "p$temp_typedef\;\n",DBG,COMBI);
		}
	}
	foreach my $combi_typedef (keys %combi_typedef){
		print_fp("\t$combi_typedef		*p$combi_typedef \= \&\( p$stg_hash_first_data" . "->". "$staticprefix$combi_typedef \)\;\n" ,DBG,COMBI);
	}
	print_fp("\n\n",DBG,COMBI);
	foreach my $combi_typedef (values %combi_typedef){
		$combi_typedef =~ s/\;/\;\n\t/g;
		print_fp("\n\t$combi_typedef" ,DBG,COMBI);
	}
	print_fp ("\n\}\n",DBG,COMBI);

			open(UPR,"<footer.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_combi_func\.c/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
				$upr =~ s/\+ToDo\+/Makefile을 만들자/;
				$upr =~ s/\+Intro\+/COMBINATION typedef/;
				$upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
				print COMBI $upr;
			}
			close UPR;
	close COMBI;

	### combination file의 header를 정의
	my $set_accumulate_func = "Set_Combination_Accumulate";
	open(ACCUM , ">$outputdir/HD/$set_accumulate_func" . "\.c");
		$filelist{"HD/$set_accumulate_func" . "\.c"} = "CFILE";
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_accumulate_func\.c/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
				$upr =~ s/\+ToDo\+/library를 만들기 위한 Makefile을 만들자/;
				$upr =~ s/\+Intro\+/ACCUMULATION typedef를 위한 functions/;
				$upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
				print ACCUM $upr;
			}
			close UPR;
		print_fp("\#include \"$FileName\"\n",ACCUM);
		### combiode file안의  function들에 대한 주석 정의
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$set_accumulate_func/;
				$upr =~ s/\+Intro\+/Set Accumulation Values Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/규칙에 틀린 곳을 찾아주세요./;
				$upr =~ s/\+Note\+/structg.pl로 만들어진 자동 코드/;
				if($upr =~ /\+Param\+/){
					print ACCUM " * \@param *p$stg_hash_first_data 		: DATA Pointer\n";
				} else {
					print ACCUM $upr;
				}
			}
			close UPR;

    ### combiode file안의 function이름 정의  : void  type이름_combi(to,from)
	foreach my $accum_typedef (keys %table){
		if($accum_typedef =~ /^$prefix_logdb_table/){		# LOG_
			$function_def = "void Set_" . $accum_typedef . "_COMBI_Accumulate($stg_hash_first_data *p$stg_hash_first_data,$accum_typedef *pMsg)";
			$typedef_combi_func{"Set_" . $accum_typedef . "_COMBI_Accumulate"} = "Set_" . $accum_typedef . "_COMBI_Accumulate";
			$function_def{"Set_" . $accum_typedef . "_COMBI_Accumulate"} = $function_def;
			print_fp ("$function_def\{\n",DBG,ACCUM);
			if($combi_accumulate_typedef{"p" . $accum_typedef}){
				foreach my $temp_typedef (keys %table_log){
					print_fp("\t$temp_typedef 	*p$temp_typedef \= p$stg_hash_first_data" . "->" . "p$temp_typedef\;\n",DBG,ACCUM);
				}
				print_fp("\n",DBG,ACCUM);
				foreach my $combi_typedef (keys %combi_typedef){
					print_fp("\t$combi_typedef		*p$combi_typedef \= \&\( p$stg_hash_first_data" . "->". "$staticprefix$combi_typedef \)\;\n" ,DBG,ACCUM);
				}
				print_fp("\n",DBG,ACCUM);
				#foreach my $stat_typedef (keys %stat_typedef){
				#	print_fp("\t$stat_typedef		*p$stat_typedef \= \&\( pSTAT_ALL" . "->". "$staticprefix$stat_typedef \)\;\n" ,DBG,ACCUM);
				#}
				#print_fp("\n\n\n",DBG,ACCUM);
				foreach my $key (keys %combi_accumulate){
					if($combi_accumulate{$key} =~ /\s*p$accum_typedef/){
						my $value ;
						$value = $combi_accumulate{$key};
						$value =~ s/p$accum_typedef/pMsg/g;
						print_fp("\t$key \+\= $value\;\n" ,DBG,ACCUM);
#						print_fp("\t$key" . "_MsgCnt \+\+\;\n" ,DBG,ACCUM);
					}
				}
			}
			print_fp("$combi_inc{$accum_typedef}" ,DBG,ACCUM);
			print_fp ("\n\}\n\n",DBG,ACCUM);
		}
	}

			open(UPR,"<footer.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_accumulate_func\.c/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
				$upr =~ s/\+ToDo\+/Makefile을 만들자/;
				$upr =~ s/\+Intro\+/ACCUMNATION typedef/;
				$upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
				print ACCUM $upr;
			}
			close UPR;
	close ACCUM;
}

# function.upr의 내용대로 subroutine에 대해서도 같은 방식의 주석을 단다.
#/** stg_hash_key function.
# *
# *		NTAM 자동화 1차를 위한 함수 
# *
# *  (순서 B) - 완료 
# *  STG_HASH_KEY typedef struct ... 라는 것을 받아서 
# *  STG_HASH_KEY를 뗀 것을 save_typedef , flat_save_typedef로 보내어 처리를 한후에, 
# *  2개씩을 짝지어 처리 다시 save_typedef , flat_save_typedef로 보내어 code를 자동으로 만들어주어야 할 것이다.
# *  KEY와 DATA로 분리를 함. 
# *  
# *  (순서 C) - 코드 준비 완료
# *  +HASH_INIT+ 으로 정의 된 부분에 초기화를 수행하게 만들 것이며, 
# *  선언되는 순서는 앞에 미리 정의된 것들만을 사용하여야 한다.
# *	
# *	 (순서 A) - 완료
# *	 ID를 define하게 하여 structure마다 자동으로 define값을 가지게 만들어야 할 것이다. STRUCTURE TYPE이 될 것이다.  
# *	 switch에서 case부분을 이것으로 처리를 해야하며, 각각에 대해서 어떤 값을 어떻게 바꾸지는지는 upr로 처리를 해야할 것이다.  
# *  TIME64 처리
# *
# *  @param  $parm_member_prefix    a_ (이와 같은 name의 prefix를 더함)
# *  @param  $parm_member_contents    stAAA의 내용이 여기에 들어감
# *  @param  $parm_member_comment    어떤 것에서 nested되는 것인지 주석에 표시하기 위해서
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl을 변형하여 flat....h 를 만든 화일
# *
# *  @exception  nested structure를  내부에 정의한느 것은 처리 안됨.
# *  @note      +Note+
# **/
sub stg_hash_key_org
{
	my $parm_typedef_org;
	my $parm_typedef;
	my $parms;
	my $struct_name;
	my $typedef_name;
	my $error;
	my @members;
	my @members_type;
	my @members_name;
	my $cnt;
	my $member_typedef;
	my $function_def;

	$parm_typedef_org = shift @_;
	$parm_typedef = $parm_typedef_org;
	print DBG "stg_hash_key : $parm_typedef_org\n";
	$parm_typedef =~ s/^\s*STG_HASH_KEY\s*//;
	flat_save_typedef($parm_typedef);
	save_typedef($parm_typedef);

	$parms = $parm_typedef_org;
	if($parms =~ /typedef\s+struct\s+([\w\s]+)\{/){ 
		$struct_name = $1;
		print DBG "stg_hash_key : struct \$struct_name : $struct_name\n"; 
	}
	if($parms =~ /\}\s+(\w+)\s*\;/){ 
		$typedef_name = $1;
		print DBG "stg_hash_key : typedef \$typedef_name : $typedef_name\n"; 
	}
	## typedef struct ... { 과 끝의 } ....; 을 없앤다.
	unless($parms =~ s/typedef\s+struct\s+([\w\s]+)\{//){ die $error = 5;}
	unless($parms =~ s/\}\s+(\w+)\s*\;//){ die $error = 6;}

	@members = split(";",$parms);
	$cnt = @members;
	$cnt--;		# 맨뒤의 ; 의 뒤는 없으므로 이것은 제외를 시켜주어야함.
	print DBG "stg_hash_key | \@members = @members : cnt = $cnt\n";
	for(my $i = 0 ; $i < $cnt ; $i++){
		my $member_stat;
		$members[$i] =~ s/^\s*//g;
	   	$member_stat = $members[$i];
		if($member_stat =~ /(\S+)\s+(\S+.*$)/){
			$members_type[$i] = $1;
			$members_name[$i] = $2;
			$members_name[$i] =~ s/^\s*//g;
			print_fp("stg_hash_key | \[$member_stat\]  : \[$members_type[$i]\]   \[$members_name[$i]\]\n",DBG);
		}
		if($members_name[$i] =~ /(\w+)\s*\[(\s*[\w]*\s*)\]\s*/){	##  [] array로 선언될때의 처리
			$members_name[$i] = $1;
			print_fp("stg_hash_key | $members_type[$i]   $members_name[$i]\n",DBG);
		}
	}

	for(my $i = 0 ; $i < $cnt-1 ; $i++){
		my $basic_name;
		my $undefined_name;
		# 2개씩의 structure
		$basic_name = "$members_name[$i+1]_$members_name[$i]";
		$stg_key_hashs{$basic_name} = "STG_$basic_name";
		$member_typedef = "typedef struct _st_$basic_name \{ \n";
		$member_typedef .= "\tU32 		uiCommand\; \n";
		$member_typedef .= "\t$members[$i+1]\;\n";
		$member_typedef .= "\t$members[$i]\; \n";
		$member_typedef .= "\} STG_$basic_name \;\n";

		$undefined_name = "HASH_KEY";
		$undefined_typedef{$undefined_name} = "HASH_HASH_KEY";
		$$undefined_name{$members_name[$i+1]} = "$basic_name";

		$undefined_name = "HASH_KEY_TYPE";
		$undefined_typedef{$undefined_name} = "HASH_HASH_KEY_TYPE";
		$$undefined_name{$members_name[$i+1]} = "$members_type[$i+1]";

		$undefined_name = $basic_name . "_MEMBER";
		$undefined_typedef{$undefined_name} = "HASH_$basic_name";
		$$undefined_name{$members_name[$i+1]} = "$members_type[$i+1]";
		$$undefined_name{$members_name[$i]} = "$members_type[$i]";

		$undefined_name = $basic_name . "_MEMBER_KEY";
		$undefined_typedef{$undefined_name} = "HASH_$basic_name";
		$$undefined_name{$members_name[$i+1]} = "$members_type[$i+1]";

		if($i == 0){
			$undefined_name = "HASH_KEY_FIRST";
			$undefined_typedef{$undefined_name} = "HASH_HASH_KEY_FIRST";
			$$undefined_name{$members_name[$i+1]} = "$basic_name";
		} 
		else {
			$undefined_name = "HASH_KEY_OTHER";
			$undefined_typedef{$undefined_name} = "HASH_HASH_KEY_OTHER";
			$$undefined_name{$members_name[$i+1]} = "$basic_name";
		}

		print_fp("stg_hash_key | \[$i\] $member_typedef\n",DBG);
		print_fp("/** \@brief NTAM Corelation 자동 코드 - STG_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);

		# 2개 중에 key가 되는 structure (KEY)
		$member_typedef = "typedef struct _st_key_$members_name[$i+1]_$members_name[$i] \{ \n";
		$member_typedef .= "\t$members[$i+1]\;\n";
		$member_typedef .= "} STG_KEY_$members_name[$i+1]_$members_name[$i] \;\n";
		print_fp("stg_hash_key | \[$i\] $member_typedef\n",DBG);
		print_fp("/** \@brief NTAM Corelation 자동 코드 - STG_KEY_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);

		# 2개중에 data가 되는 부분으로 TimerId가 추가 된다. (DATA)
		$member_typedef = "typedef struct _st_data_$members_name[$i+1]_$members_name[$i] \{ \n";
		#$member_typedef .= "\t$members[$i+1]\;\n";
		#for(my $j = 0 ; $j < $cnt ; $j++){
		#	$member_typedef .= "\t$members[$j]\;\n";
		#}
		$member_typedef .= "\t$typedef_name		stgCoInfo\;\n";
		$member_typedef .= "\tU64			$stg_hash_timer_name\; \n";
		if($i == 0){
			foreach my $temp_typedef (keys %table_log){
					$member_typedef .= "\tU16 		usCnt$temp_typedef\;\n";
					$member_typedef .= "\tU16 		usIsDone$temp_typedef\;\n";
					$member_typedef .= "\t$temp_typedef 	*p$temp_typedef\;\n";
			}
			$stg_hash_first_data = "STG_DATA_$members_name[$i+1]_$members_name[$i]";
			$stg_hash_first_key = "$members_name[$i+1]";
			foreach my $temp_typedef (keys %combi_typedef){
				$member_typedef .= "\t$temp_typedef 	$staticprefix$temp_typedef\;\n";
			}
		}
		$member_typedef .= "} STG_DATA_$members_name[$i+1]_$members_name[$i] \;\n";
		print_fp("stg_hash_key | \[$i\] $member_typedef\n",DBG);
		print_fp("/** \@brief NTAM Corelation 자동 코드 - STG_DATA_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);
	}

	# 2개중에 data가 되는 부분으로 TimerId가 추가 된다. (DATA)
	#$member_typedef = "typedef struct STG_$struct_name"."_DATA \{ \n";
	#for(my $j = 0 ; $j < $cnt ; $j++){
	#$member_typedef .= "\t$members[$j]\;\n";
	#}
	#$member_typedef .= "\tU64			$stg_hash_timer_name\; \n} STG_$typedef_name"."_DATA \;\n";
	#print_fp("stg_hash_key | $member_typedef\n",DBG);
	#print_fp("/** \@brief NTAM Corelation 자동 코드 - STG_$typedef_name"."_DATA \n  \@see $FileName\n*/\n",DBG,OUTH);
	#print_fp("$member_typedef",DBG,OUTH);
	#$member_typedef =~ s/\n//g;
	#flat_save_typedef($member_typedef);
	#save_typedef($member_typedef);

}

# function.upr의 내용대로 subroutine에 대해서도 같은 방식의 주석을 단다.
#/** stg_association function.
# *
# *		NTAM 자동화 2차를 위한 함수 
# *
# * DURATION , EQUAL , AVERAGE 의 내용을 만들어 사용할 것이며, 다른 Table의 내용을 가지고 사용한다.
# * 제일 기본이되는 call을 위한 structure에는 각 LOG들의 첫번째 msg들만 들어가게 된다. 
# * 이 첫번째 메시지들 간의 값들의 관계로 새로운 Combination Table을 구성하게 되는 것이다.  
# *
# * TIME64 DURATION64 	FieldName ( 1st Parm : TIME64 , 2nd Parm : TIME64);	/// 1st , 2nd사이의 차이 (1st - 2nd)
# * STIME  DURATION32 	FieldName ( 1st Parm : STIME , 2nd Parm : STIME );	/// 1st , 2nd사이의 차이 (1st - 2nd)
# * TIME64 ABSDURATION64 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd사이의 차이 abs(1st - 2nd)
# * STIME  ABSDURATION32 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd사이의 차이 abs(1st - 2nd)
# * (x)    EQUAL 		FieldName ( 1st Parm);				/// 1st Parm을 그대로 사용
# * U32    AVERAGE 	FieldName ( 1st Parm : U32 , 2nd Parm : U32);	/// 1st / 2nd
# *
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl을 변형하여 flat....h 를 만든 화일
# *
# *  @exception  nested structure를  내부에 정의한느 것은 처리 안됨.
# *  @note      +Note+
# **/
sub stg_association
{
	my $parm_typedef_org;
	my $parm_typedef;
	my $parms;
	my $new_typedef = "";
	my $struct_name;
	my $typedef_name;
	my @members;
	my $new_func_members = "";

	$parm_typedef = shift @_;
	$parm_typedef_org = $parm_typedef;
	print DBG "stg_association: $parm_typedef_org\n";
	$parm_typedef =~ s/^\s*STG_ASSOCIATION\s*//;
	$parms = $parm_typedef;

	if($parms =~ /\s*typedef\s+struct\s+([\w\s]+)\{/){ 
		$struct_name = $1;
		print DBG "stg_association: struct \$struct_name : $struct_name\n"; 
	}

	if($parms =~ /\}\s*(\w+)\s*\;/){ 
		$typedef_name = $1;
		print STDOUT "stg_association: typedef \$typedef_name : $typedef_name\n"; 
	}

	my $prev_ltype = "";
	my $prev_lname_full = "";

	@members = split("\n",$parms);
	foreach my $str (@members){
		print DBG "ASSO : $str\n";
		my $is_association_type = 0;
		my $is_alternative_association = 0;
		my $ltype;
		my $lname;
		my $lname_full;
		my $lfunc;
		my $lpri;
		my $laction;
		my $lcomments = "";
		my $larray = "";
		my $lcheck = "";
		if( $str =~ /^\s*(\S+)\s+(\S+)\s*:\s*([^:;]*)\s*:\s*([^:;]*)\s*\;\s*(.*)$/ ){
			$is_association_type = 1;
			$ltype = $1;
			$lname_full = $2;
			$lfunc = $3;
			$lpri = $4;
			$laction = "";
			$lcomments = $5;
		} 
		if($str =~ /^\s*(\S+)\s+(\S+)\s*:\s*([^:;]*)\s*:\s*([^:;]*)\s*:\s*([^:;]*)\s*\;\s*(.*)$/){
			$is_association_type = 1;
			$ltype = $1;
			$lname_full = $2;
			$lfunc = $3;
			$lpri = $4;
			$laction = $5;
			$lcomments = $6;
		}
		if( $str =~ /^\s*ALTERNATIVE_ASSOCIATION\s*:\s*([^:;]*)\s*:\s*([^:;]*)\s*\;\s*(.*)$/ ){
			$is_alternative_association = 1;
			$is_association_type = 1;
			$ltype = $prev_ltype;
			$lname_full = $prev_lname_full;
			$lfunc = $1;
			$lpri = $2;
			$laction = "";
			$lcomments = $3;
		} 
		if($str =~ /^\s*ALTERNATIVE_ASSOCIATION\s*:\s*([^:;]*)\s*:\s*([^:;]*)\s*:\s*([^:;]*)\s*\;\s*(.*)$/){
			$is_alternative_association = 1;
			$is_association_type = 1;
			$ltype = $prev_ltype;
			$lname_full = $prev_lname_full;
			$lfunc = $1;
			$lpri = $2;
			$laction = $3;
			$lcomments = $4;
		}

		$prev_ltype = $ltype;
		$prev_lname_full = $lname_full;
		
		if($lname_full =~ /(\w+)\s*\[\s*(\w+)\s*\]/){
			$lname = $1;
			$larray = $2;
			$lcheck = "[0]";		# check시 이 값을 check함으로써 여기에 값이 있는지를 확인하기 위해서 
		} else {
			$lname = $lname_full;
		}
			
		if($is_association_type == 1){
			$lfunc =~ s/\)\s*$//g;
			$lcomments =~ s/^\s*//g;
			if($is_alternative_association == 1){
				print_fp("\t\t\/\*\*< ALTERNATIVE ASSOCIATION $ltype	$lname_full\;	 : $lfunc : $lpri : $laction \*\/ $lcomments\n" ,OUTH,DBG);
			} else {
				print_fp("\t$ltype	$lname_full\;	\/\*\*< $lfunc : $lpri : $laction \*\/ $lcomments\n" ,OUTH,DBG);
			}
			$new_typedef .= "$ltype  $lname_full\;";

			if($lfunc =~ /STG_ACCUMULATE\s*\(\s*(\S+)\s*\-\>\s*(\S+)/){
				my $lfrom_st = $1;
				my $lfrom_mem = $2;
				$lfrom_st =~ s/^\s*\&?p?//;
				#print_fp("\tU32	$lname"."_MsgCnt\; \/\*\*< $ltype	$lname\; 's count \*\/ $4\n" ,OUTH,DBG);
				#$new_typedef .= "U32		$lname" . "_MsgCnt \;";
				print DBG "STG_ACCUMULATE-- \[$1\] \[$2\] \n";

				$undefined_name = "ASSOCIATION_ACCUMULATE";			#$ASSOCIATION_ACCUMULATE{CALL}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$typedef_name} = "$typedef_name";

				$undefined_name = "ASSOCIATION_$typedef_name";		#$ASSOCIATION_ACCUMULATE_CALL{LOG_COMMON}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lfrom_st} = "$lfrom_st";

				$undefined_name = "ASSOCIATION_ACCUMULATE_$typedef_name";		#$ASSOCIATION_ACCUMULATE_CALL{LOG_COMMON}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lfrom_st} = "$lfrom_st";

				$undefined_name = "ASSOCIATION_ACCUMULATE_$typedef_name\_$lfrom_st";		#$ASSOCIATION_ACCUMULATE_CALL_LOG_COMMON{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$lname";

				$undefined_name = "ASSOCIATION_ACCUMULATE_$typedef_name\_$lfrom_st\_struct";		#$ASSOCIATION_ACCUMULATE_CALL_LOG_COMMON_struct{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$lfrom_st";

				$undefined_name = "ASSOCIATION_ACCUMULATE_$typedef_name\_$lfrom_st\_member";		#$ASSOCIATION_ACCUMULATE_CALL_LOG_COMMON_member{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$lfrom_mem";

				$undefined_name = "ASSOCIATION_ACCUMULATE_$typedef_name\_$lfrom_st\_type";		#$ASSOCIATION_ACCUMULATE_CALL_LOG_COMMON_type{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$ltype";

				$undefined_name = "ASSOCIATION_ACCUMULATE_$typedef_name\_$lfrom_st\_func";		#$ASSOCIATION_ACCUMULATE_CALL_LOG_COMMON_func{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "pthis->$lname += p$lfrom_st->$lfrom_mem;";

				$undefined_name = "ASSOCIATION_ACCUMULATE_$typedef_name\_$lfrom_st\_pri";		#$ASSOCIATION_ACCUMULATE_CALL_LOG_COMMON_pri{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$lpri";

				$undefined_name = "ASSOCIATION_ACCUMULATE_$typedef_name\_$lfrom_st\_action"; #$ASSOCIATION_ACCUMULATE_ACCUMULATE_CALL_LOG_COMMON_action{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$laction";

				$undefined_name = "ASSOCIATION_ACCUMULATE_$typedef_name\_$lfrom_st\_comments";		#$ASSOCIATION_ACCUMULATE_CALL_LOG_COMMON_comments{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$lcomments";

				$undefined_name = "ASSOCIATION_ACCUMULATE_$typedef_name\_$lfrom_st\_check";		#$ASSOCIATION_ACCUMULATE_CALL_LOG_COMMON_check{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "pthis->$lname$lcheck";
			}
			elsif($lfunc =~ /STG_INC\s*\(\s*(\S+)/){
				my $l1;
				$l1 = $1;
				$l1 =~ s/^\s*&?p//;
				$undefined_name = "ASSOCIATION_INC";			#$ASSOCIATION_INC{CALL}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$typedef_name} = "$typedef_name";

				$undefined_name = "ASSOCIATION_$typedef_name";		#$ASSOCIATION_INC_CALL{LOG_COMMON}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$l1} = "$l1";

				$undefined_name = "ASSOCIATION_INC_$typedef_name";		#$ASSOCIATION_INC_CALL{LOG_COMMON}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$l1} = "$l1";

				$undefined_name = "ASSOCIATION_INC_$typedef_name\_$l1";		#$ASSOCIATION_INC_CALL_LOG_COMMON{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$lname";

				$undefined_name = "ASSOCIATION_INC_$typedef_name\_$l1\_struct";		#$ASSOCIATION_INC_CALL_LOG_COMMON{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$l1";

				$undefined_name = "ASSOCIATION_INC_$typedef_name\_$l1\_type";		#$ASSOCIATION_INC_CALL_LOG_COMMON{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$ltype";

				$undefined_name = "ASSOCIATION_INC_$typedef_name\_$l1\_func";		#$ASSOCIATION_INC_CALL_LOG_COMMON{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "pthis->$lname++; ";

				$undefined_name = "ASSOCIATION_INC_$typedef_name\_$l1\_pri";		#$ASSOCIATION_INC_CALL_LOG_COMMON{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$lpri";

				$undefined_name = "ASSOCIATION_INC_$typedef_name\_$l1\_action";		#$ASSOCIATION_INC_CALL_LOG_COMMON{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$laction";

				$undefined_name = "ASSOCIATION_INC_$typedef_name\_$l1\_comments";		#$ASSOCIATION_INC_CALL_LOG_COMMON{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "$lcomments";

				$undefined_name = "ASSOCIATION_INC_$typedef_name\_$l1\_check";		#$ASSOCIATION_INC_CALL_LOG_COMMON{$lname}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$lname} = "pthis->$lname$lcheck";
			} else {			# ASSOCIATION_OTHERS
				my $l_st_name = "";
				$temp = $lfunc;
				while($temp =~ s/(\w+)\s*->//){
					my $ltypename;
					$ltypename = $1;
					$ltypename =~ s/^\s*&?p//;
					if($ltypename eq "this"){
						next;
					}
					if($l_st_name eq ""){
						$l_st_name = $ltypename;
						next;
					}
					if($l_st_name ne $ltypename){
						print STDERR "이 줄에는 pthis와 $l_st_name 만이 사용가능합니다. $1은 이 줄에서는 사용안됨\n";
						exit 1;
					}
				}
				if($larray eq ""){
					if($lfunc =~ /STG_Equal\s*\((.*)/){
						$lfunc = "pthis->$lname = $1\ /* $lfunc */;";
					} else {
						$lfunc .= ", &\(pthis->$lname\) \)\;";
					}
				} else {
					if($lfunc =~ /STG_Equal\s*\((.*)/){
						$lfunc = "memcpy(pthis->$lname , $1 , $larray \)\;  /* $lfunc */";
					} else {
						$lfunc .= ", \(pthis->$lname\) \)\;";
					}
				}
				$undefined_name = "ASSOCIATION_OTHERS";			#$ASSOCIATION_OTHERS{CALL}
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$typedef_name} = "$typedef_name";

				if($l_st_name ne ""){
					$undefined_name = "ASSOCIATION_OTHERS";			#$ASSOCIATION_OTHERS{CALL}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$typedef_name} = "$typedef_name";

					$undefined_name = "ASSOCIATION_$typedef_name";		#$ASSOCIATION_OTHERS_CALL{LOG_COMMON}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$l_st_name} = "$l_st_name";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name";		#$ASSOCIATION_OTHERS_CALL{LOG_COMMON}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$l_st_name} = "$l_st_name";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_$l_st_name";		#$ASSOCIATION_OTHERS_ CALL_ LOG_COMMON{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$lname";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_$l_st_name\_struct";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON _struct{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$l_st_name";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_$l_st_name\_type";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON _type{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$ltype";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_$l_st_name\_func";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON _func{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$lfunc";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_$l_st_name\_pri";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$lpri";
	
					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_$l_st_name\_action";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$laction";
	
					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_$l_st_name\_comments";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$lcomments";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_$l_st_name\_check";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "pthis->$lname$lcheck";
				} else {		# pthis
					$undefined_name = "ASSOCIATION_OTHERS";			#$ASSOCIATION_OTHERS{CALL}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$typedef_name} = "$typedef_name";

					# 추후 이것을 풀면 pthis도 그냥 structure로 취급이 되어져서 
					# 항시 수행되는 모습으로 만들수 있다. 여기서는 pthis를 따로 취급하기 위해서 list에 넣지 않는 것이다.
					#$undefined_name = "ASSOCIATION_OTHERS_$typedef_name";		#$ASSOCIATION_OTHERS_CALL{LOG_COMMON}
					#$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					#$$undefined_name{pthis} = "pthis";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_pthis";		#$ASSOCIATION_OTHERS_ CALL_ LOG_COMMON{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$lname";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_pthis\_struct";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON _struct{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "pthis";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_pthis\_type";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON _type{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$ltype";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_pthis\_func";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON _func{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$lfunc";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_pthis\_pri";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$lpri";
	
					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_pthis\_action";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$laction";
	
					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_pthis\_comments";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "$lcomments";

					$undefined_name = "ASSOCIATION_OTHERS_$typedef_name\_pthis\_check";		#$ASSOCIATION_OTHERS_CALL_LOG_COMMON{$lname}
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$lname} = "pthis->$lname$lcheck";
				}
			}
		} else {
			print_fp("$str\n",OUTH,DBG);
			$new_typedef .= $str;
		}
		$new_typedef =~ s/\/\*.+\*\///g;    # 주석문 삭제
	}

	flat_save_typedef($new_typedef);
	# save_typedef안으로 갈때는 주석문이 있으면 안됨.
	save_typedef($new_typedef);
}

# function.upr의 내용대로 subroutine에 대해서도 같은 방식의 주석을 단다.
#/** stg_stat_table function.
# *
# *		NTAM 자동화 2차를 위한 함수 
# *
# * DURATION , EQUAL , AVERAGE 의 내용을 만들어 사용할 것이며, 다른 Table의 내용을 가지고 사용한다.
# * 제일 기본이되는 call을 위한 structure에는 각 LOG들의 첫번째 msg들만 들어가게 된다. 
# * 이 첫번째 메시지들 간의 값들의 관계로 새로운 Combination Table을 구성하게 되는 것이다.  
# *
# * TIME64 DURATION64 	FieldName ( 1st Parm : TIME64 , 2nd Parm : TIME64);	/// 1st , 2nd사이의 차이 (1st - 2nd)
# * STIME  DURATION32 	FieldName ( 1st Parm : STIME , 2nd Parm : STIME );	/// 1st , 2nd사이의 차이 (1st - 2nd)
# * TIME64 ABSDURATION64 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd사이의 차이 abs(1st - 2nd)
# * STIME  ABSDURATION32 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd사이의 차이 abs(1st - 2nd)
# * (x)    EQUAL 		FieldName ( 1st Parm);				/// 1st Parm을 그대로 사용
# * U32    AVERAGE 	FieldName ( 1st Parm : U32 , 2nd Parm : U32);	/// 1st / 2nd
# *
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl을 변형하여 flat....h 를 만든 화일
# *
# *  @exception  nested structure를  내부에 정의한느 것은 처리 안됨.
# *  @note      +Note+
# **/
sub stg_stat_table
{
	my $parm_typedef_org;
	my $parm_typedef;
	my $parms;
	my $new_typedef = "";
	my $struct_name;
	my $typedef_name;
	my @members;
	my $new_func_members = "";

	$parm_typedef = shift @_;
	$parm_typedef_org = $parm_typedef;
	print DBG "stg_stat_table : $parm_typedef_org\n";
	$parm_typedef =~ s/^\s*STG_STAT_TABLE\s*//;
	$parms = $parm_typedef;

	if($parms =~ /\s*typedef\s+struct\s+([\w\s]+)\{/){ 
		$struct_name = $1;
		print DBG "stg_stat_table : struct \$struct_name : $struct_name\n"; 
	}

	if($parms =~ /\}\s*(\w+)\s*\;/){ 
		$typedef_name = $1;
		print DBG "stg_stat_table : typedef \$typedef_name : $typedef_name\n"; 
	}

	@members = split("\n",$parms);
	foreach my $str (@members){
		if($str =~ /^\s*(\S+)\s+(\S+)\s*\:(.*)\;(.*)$/){
			my $ltype;
			my $ltemp;
			my $lname;
			#print DBG "\[$1\] \[$2\]  \[$3\]  \[$4\]\n";
			print_fp("\t$1	$2\;	\/\*\*< $3 \*\/ $4\n" ,OUTH,DBG);
			$new_typedef .= "$1  $2\;";
			$ltype = $2;
			$lname = $2;
			$ltemp = $3;
			$ltemp =~ s/\)\s*$//g;
			$ltemp =~ s/^\s*//g;
			if($ltemp =~ /STG_ACCUMULATE\s*\((\w+)\-\>(.*)/){
				#print_fp("\tU32	$lname"."_MsgCnt\; \/\*\*< $ltype	$lname\; 's count \*\/ $4\n" ,OUTH,DBG);
				#$new_typedef .= "U32		$lname" . "_MsgCnt \;";
				print DBG "STG_ACCUMULATE-- \[$1\] \[$2\]   $new_typedef\n";
				$stat_accumulate{"p" . $typedef_name . "->$lname"} = $1 . "->" . $2;
				$stat_accumulate_typedef{$1} = $1;
				$stat_accumulate_typedef{$1} =~ s/^p//;
			}
			elsif($ltemp =~ /STG_INC\s*\((\w+)/){
				my $l1;
				$l1 = $1;
				$l1 =~ s/^p//;
				$stat_inc{$l1} .= "\tp" . $typedef_name . "->$lname ++\;\n";
			} else {
				$new_func_members .= "$ltemp, &\(p\+STG_STAT_TYPEDEF\+\->$lname\) \)\;";
			}
		} else {
			print_fp("$str\n",OUTH,DBG);
			$new_typedef .= $str;
		}
	}

	$new_func_members =~ s/\+STG_STAT_TYPEDEF\+/$typedef_name/g;
	print DBG "\$new_func_members = $new_func_members\n";
	$stat_typedef{$typedef_name} = $new_func_members;		# stg_stat_table 에서 수행 func들을 삽입하고, stg_hash_key()안에서 이를 사용하여 .c 화일을 만든다. 

	flat_save_typedef($new_typedef);
	save_typedef($new_typedef);
}


# function.upr의 내용대로 subroutine에 대해서도 같은 방식의 주석을 단다.
#/** stg_combination_table function.
# *
# *		NTAM 자동화 2차를 위한 함수 
# *
# * DURATION , EQUAL , AVERAGE 의 내용을 만들어 사용할 것이며, 다른 Table의 내용을 가지고 사용한다.
# * 제일 기본이되는 call을 위한 structure에는 각 LOG들의 첫번째 msg들만 들어가게 된다. 
# * 이 첫번째 메시지들 간의 값들의 관계로 새로운 Combination Table을 구성하게 되는 것이다.  
# *
# * TIME64 DURATION64 	FieldName ( 1st Parm : TIME64 , 2nd Parm : TIME64);	/// 1st , 2nd사이의 차이 (1st - 2nd)
# * STIME  DURATION32 	FieldName ( 1st Parm : STIME , 2nd Parm : STIME );	/// 1st , 2nd사이의 차이 (1st - 2nd)
# * TIME64 ABSDURATION64 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd사이의 차이 abs(1st - 2nd)
# * STIME  ABSDURATION32 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd사이의 차이 abs(1st - 2nd)
# * (x)    EQUAL 		FieldName ( 1st Parm);				/// 1st Parm을 그대로 사용
# * U32    AVERAGE 	FieldName ( 1st Parm : U32 , 2nd Parm : U32);	/// 1st / 2nd
# *
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl을 변형하여 flat....h 를 만든 화일
# *
# *  @exception  nested structure를  내부에 정의한느 것은 처리 안됨.
# *  @note      +Note+
# **/
sub stg_combination_table
{
	my $parm_typedef_org;
	my $parm_typedef;
	my $parms;
	my $new_typedef = "";
	my $struct_name;
	my $typedef_name;
	my @members;
	my $new_func_members = "";

	$parm_typedef = shift @_;
	$parm_typedef_org = $parm_typedef;
	print DBG "stg_combination_table : $parm_typedef_org\n";
	$parm_typedef =~ s/^\s*STG_COMBINATION_TABLE\s*//;
	$parms = $parm_typedef;

	if($parms =~ /\s*typedef\s+struct\s+([\w\s]+)\{/){ 
		$struct_name = $1;
		print DBG "stg_combination_table : struct \$struct_name : $struct_name\n"; 
	}

	if($parms =~ /\}\s*(\w+)\s*\;/){ 
		$typedef_name = $1;
		print DBG "stg_combination_table : typedef \$typedef_name : $typedef_name\n"; 
	}

	@members = split("\n",$parms);
	foreach my $str (@members){
		if($str =~ /^\s*(\S+)\s+(\S+)\s*\:(.*)\;(.*)$/){
			my $ltype;
			my $ltemp;
			my $lname;
			#print DBG "\[$1\] \[$2\]  \[$3\]  \[$4\]\n";
			print_fp("\t$1	$2\;	\/\*\*< $3 \*\/ $4\n" ,OUTH,DBG);
			$new_typedef .= "$1  $2\;";
			$ltype = $2;
			$lname = $2;
			$ltemp = $3;
			$ltemp =~ s/\)\s*$//g;
			$ltemp =~ s/^\s*//g;
			if($ltemp =~ /STG_ACCUMULATE\s*\((\w+)\-\>(.*)/){
				#print_fp("\tU32	$lname"."_MsgCnt\; \/\*\*< $ltype	$lname\; 's count \*\/ $4\n" ,OUTH,DBG);
				#$new_typedef .= "U32		$lname" . "_MsgCnt \;";
				print DBG "STG_ACCUMULATE-- \[$1\] \[$2\]   $new_typedef\n";
				$combi_accumulate{"p" . $typedef_name . "->$lname"} = $1 . "->" . $2;
				$combi_accumulate_typedef{$1} = $1;
				$combi_accumulate_typedef{$1} =~ s/^p//;
			}
			elsif($ltemp =~ /STG_INC\s*\((\w+)/){
				my $l1;
				print DBG "SSSTG_INC $1\n";
				$l1 = $1;
				$l1 =~ s/^p//;
				$combi_inc{$l1} .= "\tp" . $typedef_name . "->$lname ++\;\n";
			} else {
				$new_func_members .= "$ltemp, &\(p\+STG_COMBI_TYPEDEF\+\->$lname\) \)\;";
			}
		} else {
			print_fp("$str\n",OUTH,DBG);
			$new_typedef .= $str;
		}
	}

	$new_func_members =~ s/\+STG_COMBI_TYPEDEF\+/$typedef_name/g;
	print DBG "\$new_func_members = $new_func_members\n";
	$combi_typedef{$typedef_name} = $new_func_members;		# stg_combination_table 에서 수행 func들을 삽입하고, stg_hash_key()안에서 이를 사용하여 .c 화일을 만든다. 

	flat_save_typedef($new_typedef);
	save_typedef($new_typedef);
}

sub state_diagram_vertex_undefined 
{
	my $tab_cnt =  int((47 - length($tmp_vertex_name)) /4);

	if($temp_argu2 =~ s/^\s*\(\s*(\d+)\s*\)(.*)/\t\t\/* NUM: $1 *\/$2/){
		$state_diagram_vertex_start_num = $1;
	}  
	print DBG "state_diagram_vertex_undefined $temp_argu2 :  $line\n";
	
	$define_digit{$tmp_vertex_name} = $state_diagram_vertex_start_num;
	if($line =~ s/\@ABB:(\S*)\@//){
		print DBG "TTTT $1 $line\n";
		$abbreviation_define_name{$tmp_vertex_name} = $1;
		$temp_argu2 =~ s/\@ABB:(\S*)\@/\/* abbreviation_name:$1 *\/\t/;
	} else {
		$abbreviation_define_name{$tmp_vertex_name} = $tmp_vertex_name;
	}
	$temp = $temp_argu2;
	$temp =~ s/\/\*/\<\</;
	$temp =~ s/\*\//>>/;
	if($temp eq ""){
		$line = "\#define $tmp_vertex_name" . "\t"x$tab_cnt . "  $state_diagram_vertex_start_num";
	} else {
		$line = "\#define $tmp_vertex_name" . "\t"x$tab_cnt . "  $state_diagram_vertex_start_num		/* $temp */";
	}
	if($in_typedef == 1) {
		$typedef_org .= $line . "\n";
	} else {
		print OUTH "$line\n";
	}

	$undefined_name = "STATE_DIAGRAM_VERTEX_$state_diagram_vertex_name";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$tmp_vertex_name} = $state_diagram_vertex_start_num;
	
	$undefined_name = "STATE_DIAGRAM_VERTEX_$state_diagram_vertex_name\_$tmp_vertex_name";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{msg} = $tmp_vertex_msg;

	$undefined_name = "STATE_DIAGRAM_VERTEX_msg_$state_diagram_vertex_name\_$tmp_vertex_name";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$tmp_vertex_msg} = $tmp_vertex_msg;

	$undefined_name = "TAG_DEF_ALL_$state_diagram_vertex_name";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$tmp_vertex_name} = $state_diagram_vertex_start_num;
	
	$undefined_name = "TAG_DEF_ALL_NUM_$state_diagram_vertex_name";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$state_diagram_vertex_start_num} = $tmp_vertex_name;
	
	$undefined_name = "TAG_AUTO_DEF_$state_diagram_vertex_name";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$tmp_vertex_name} = $state_diagram_vertex_start_num;
	
	$temp = $line;
	#$temp = s/\/\*/\/\</g;
	#$temp = s/\*\//\>\//g;
	$temp =~ s/\#define//;
	$TAG_DEFINE{$state_diagram_vertex_name} .= "*\t" . $temp . "\n";
	$TAG_DEFINE{$state_diagram_vertex_name} =~ s/\/\*.+\*\///g;    # 주석문 삭제

	$state_diagram_vertex_start_num++;
}

sub tag_auto_define_undefined 
{
	my $tab_cnt =  int((47 - length($temp_argu1)) /4);

	if($temp_argu2 =~ s/^\s*\(\s*(\d+)\s*\)(.*)/\t\t\/* NUM: $1 *\/$2/){
		$tag_auto_define_start_num = $1;
	}  
	print DBG "tag_auto-define_undefined $temp_argu2 :  $line\n";
	
	$define_digit{$temp_argu1} = $tag_auto_define_start_num;
	if($line =~ s/\@ABB:(\S*)\@//){
		print DBG "TTTT $1 $line\n";
		$abbreviation_define_name{$temp_argu1} = $1;
		$temp_argu2 =~ s/\@ABB:(\S*)\@/\/* abbreviation_name:$1 *\/\t/;
	} else {
		$abbreviation_define_name{$temp_argu1} = $temp_argu1;
	}
	$temp = $temp_argu2;
	$temp =~ s/\/\*/\<\</;
	$temp =~ s/\*\//>>/;
	if($temp eq ""){
		$line = "\#define $temp_argu1" . "\t"x$tab_cnt . "  $tag_auto_define_start_num";
	} else {
		$line = "\#define $temp_argu1" . "\t"x$tab_cnt . "  $tag_auto_define_start_num		/* $temp */";
	}
	if($in_typedef == 1) {
		$typedef_org .= $line . "\n";
	} else {
		print OUTH "$line\n";
	}
	
	$undefined_name = "TAG_DEF_ALL_$tag_auto_define_name";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$temp_argu1} = $tag_auto_define_start_num;
	
	$undefined_name = "TAG_DEF_ALL_NUM_$tag_auto_define_name";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$tag_auto_define_start_num} = $temp_argu1;
	
	$undefined_name = "TAG_AUTO_DEF_$tag_auto_define_name";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$temp_argu1} = $tag_auto_define_start_num;
	
	$temp = $line;
	#$temp = s/\/\*/\/\</g;
	#$temp = s/\*\//\>\//g;
	$temp =~ s/\#define//;
	$TAG_DEFINE{$tag_auto_define_name} .= "*\t" . $temp . "\n";
	$TAG_DEFINE{$tag_auto_define_name} =~ s/\/\*.+\*\///g;    # 주석문 삭제

	$tag_auto_define_start_num++;
}

sub flow_undefined {
	print DBG "DDD>>>> [$current_state] $msg [$if_var_type] $if_var [$if_val_type] $if_val [$next_state] $action\n";

	$undefined_name = "FLOW";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$tag_flow_name} = "$tag_flow_struct";
	
	$undefined_name = "FLOW_$tag_flow_name" . "_STATE";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$current_state} = $current_state;
	
	$if_var =~ s/^\s*//g;
	$if_val =~ s/^\s*//g;
	$undefined_name = "FLOW_$tag_flow_name" . "_STATE_$current_state";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{name} = $current_state;
	$$undefined_name{msg} = $msg;
	$$undefined_name{"if_var_type"} = $if_var_type;
	$$undefined_name{"if_var"} = $if_var;
	$$undefined_name{"if_val"} = $if_val;
	$$undefined_name{"if_val_type"} = $if_val_type;
	$$undefined_name{action} = $action;
	$$undefined_name{"next"} = $next_state;
# // pINPUT-> 으로 시작하는 것에 대해서 Get_Member_ 으로 하는 것을 완전히 없앰.
#if($if_var =~ /^pINPUT\s*->\s*/){
#$temp = $if_var;
#$temp =~ s/^pINPUT\s*->\s*//;
#if($if_var_type eq "D"){
#print DBG "if_var_member $if_var $temp\n";
#if($temp =~ /\s*(\w+)\s*([\/\*]+.*)\s*$/){
#$$undefined_name{"if_var_member_var"} = $1;
#$$undefined_name{"if_var_member_opr"} = $2;
#$temp = $1;
#} else {
#$$undefined_name{"if_var_member_var"} = $temp;
#}
#}
		## if_var_member_var 은 operand 의 앞의 것과 pINPUT-> 의 뒤의 것만을 지칭한 것이다.
		##  예전의 code에서는 중요한 값이었지만. 지금은 중요하지 않다.
		## 향후에 이 값들을 사용할지 몰라서 남겨두는 것이다.
#$$undefined_name{"if_var_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#} 
	$$undefined_name{"if_var_member"} = $if_var;
#if($if_val =~ /^pINPUT\s*->\s*/){
#$temp = $if_val;
#$temp =~ s/^pINPUT\s*->\s*//;
		## if_val_member_var로 마찬가지로 사용하지는 않디만, 혹시 몰라 그냥 남겨두는 것이다.
#$$undefined_name{"if_val_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#} 
	$$undefined_name{"if_val_member"} = $if_val;
	
	if($if_val_type eq "Y"){
		$undefined_name = "FLOW_$tag_flow_name" . "_STATE_$current_state" . "_Y_if_val";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		#print "if_val [$if_val]\n";
		if($if_val =~ /\s*(\d+)\s*-\s*(\d+)/){
			#print "kkk-->  $1 $2\n";
			for($temp=$1 ; $temp <= $2 ; $temp++){
				$$undefined_name{$temp} = $if_val;
			}
		} else {
			$$undefined_name{$if_val} = $if_val;
		}
		$undefined_name = "FLOW_$tag_flow_name" . "_STATE_$current_state" . "_Y_current";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		if($if_val =~ /\s*(\d+)\s*-\s*(\d+)/){
			#print "kkk-->  $1 $2\n";
			for($temp=$1 ; $temp <= $2 ; $temp++){
				$$undefined_name{$temp} = $current_state;
			}
		} else {
			$$undefined_name{$if_val} = $current_state;
		}
		$undefined_name = "FLOW_$tag_flow_name" . "_STATE_$current_state" . "_Y_next";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		if($if_val =~ /\s*(\d+)\s*-\s*(\d+)/){
			#print "kkk-->  $1 $2\n";
			for($temp=$1 ; $temp <= $2 ; $temp++){
				$$undefined_name{$temp} = $next_state;
			}
		} else {
			$$undefined_name{$if_val} = $next_state;
		}
	}
	if($if_val_type eq "N"){
		$undefined_name = "FLOW_$tag_flow_name" . "_STATE_$current_state" . "_N_if_val";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$if_val} = $if_val;
		$undefined_name = "FLOW_$tag_flow_name" . "_STATE_$current_state" . "_N_current";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$if_val} = $current_state;
		$undefined_name = "FLOW_$tag_flow_name" . "_STATE_$current_state" . "_N_next";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$if_val} = $next_state;
	}
	
	$undefined_name = "FLOW_$tag_flow_name" . "_DIRECTION";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{"FLOW_$tag_flow_name" . "_DIR_$current_state" . "_2_$next_state"} = $current_state;
	
	$undefined_name = "FLOW_$tag_flow_name" . "_DIR_$current_state" . "_2_$next_state";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{"msg"} = $msg;
	$$undefined_name{"current_state"} = $current_state;
	$$undefined_name{"if_var_type"} = $if_var_type;
	$$undefined_name{"if_var"} = $if_var;
	$$undefined_name{"if_val_type"} = $if_val_type;
	$$undefined_name{"if_val"} = $if_val;
	$$undefined_name{"next_state"} = $next_state;
	$$undefined_name{"action"} = $action;

	$undefined_name = "FLOW_$tag_flow_name" . "_EDGE";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{"FLOW_$tag_flow_name" . "_EDGE_$current_state" . "_CONDITION_$if_val_type\_$if_val"} = $next_state;

	$undefined_name = "FLOW_$tag_flow_name" . "_EDGE_$current_state" . "_CONDITION_$if_val_type\_$if_val";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{"msg"} = $msg;
	$$undefined_name{"current_state"} = $current_state;
	$$undefined_name{"if_var_type"} = $if_var_type;
	$$undefined_name{"if_var"} = $if_var;
	$$undefined_name{"if_val_type"} = $if_val_type;
	$$undefined_name{"if_val"} = $if_val;
	$$undefined_name{"next_state"} = $next_state;
	$$undefined_name{"action"} = $action;
#if($if_var =~ /^pINPUT\s*->\s*/){
#$temp = $if_var;
#$temp =~ s/^pINPUT\s*->\s*//;
#if($if_var_type eq "D"){
#print DBG "if_var_member $if_var $temp\n";
#if($temp =~ /\s*(\w+)\s*([\/\*]+.*)\s*$/){
#$$undefined_name{"if_var_member_var"} = $1;
#$$undefined_name{"if_var_member_opr"} = $2;
#$temp = $1;
#} else {
#$$undefined_name{"if_var_member_var"} = $temp;
#}
#}
		## if_val_member_var로 마찬가지로 사용하지는 않디만, 혹시 몰라 그냥 남겨두는 것이다.
		$$undefined_name{"if_var_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#}
	$$undefined_name{"if_var_member"} = $if_var;
#if($if_val =~ /^pINPUT\s*->\s*/){
#$temp = $if_val;
#$temp =~ s/^pINPUT\s*->\s*//;
### if_val_member_var로 마찬가지로 사용하지는 않디만, 혹시 몰라 그냥 남겨두는 것이다.
#$$undefined_name{"if_val_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#} 
	$$undefined_name{"if_val_member"} = $if_val;
	
	$undefined_name = "FLOW_$tag_flow_name" . "_VERTEX_$current_state";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$next_state} = $current_state;
}

sub state_diagram_edge_undefined {
	print DBG "state_diagram_edge_undefined>>>> [$current_state]  -  [$if_var_type] $if_var [$if_val_type] $if_val [$next_state] $action\n";

	$undefined_name = "STATE_DIAGRAM_EDGE";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$state_diagram_edge_name} = "$state_diagram_edge_struct";
	
	$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_STATE";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{$current_state} = $current_state;
	
	$if_var =~ s/^\s*//g;
	$if_val =~ s/^\s*//g;
	$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_STATE_$current_state";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{name} = $current_state;
	$$undefined_name{"if_var_type"} = $if_var_type;
	$$undefined_name{"if_var"} = $if_var;
	$$undefined_name{"if_val"} = $if_val;
	$$undefined_name{"if_val_type"} = $if_val_type;
	$$undefined_name{action} = $action;
	$$undefined_name{"next"} = $next_state;
# // pINPUT-> 으로 시작하는 것에 대해서 Get_Member_ 으로 하는 것을 완전히 없앰.
#if($if_var =~ /^pINPUT\s*->\s*/){
#$temp = $if_var;
#$temp =~ s/^pINPUT\s*->\s*//;
#if($if_var_type eq "D"){
#print DBG "if_var_member $if_var $temp\n";
#if($temp =~ /\s*(\w+)\s*([\/\*]+.*)\s*$/){
#$$undefined_name{"if_var_member_var"} = $1;
#$$undefined_name{"if_var_member_opr"} = $2;
#$temp = $1;
#} else {
#$$undefined_name{"if_var_member_var"} = $temp;
#}
#}
		## if_var_member_var 은 operand 의 앞의 것과 pINPUT-> 의 뒤의 것만을 지칭한 것이다.
		##  예전의 code에서는 중요한 값이었지만. 지금은 중요하지 않다.
		## 향후에 이 값들을 사용할지 몰라서 남겨두는 것이다.
#$$undefined_name{"if_var_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#} 
	$$undefined_name{"if_var_member"} = $if_var;
#if($if_val =~ /^pINPUT\s*->\s*/){
#$temp = $if_val;
#$temp =~ s/^pINPUT\s*->\s*//;
		## if_val_member_var로 마찬가지로 사용하지는 않디만, 혹시 몰라 그냥 남겨두는 것이다.
#$$undefined_name{"if_val_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#} 
	$$undefined_name{"if_val_member"} = $if_val;
	
	if($if_val_type eq "Y"){
		$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_STATE_$current_state" . "_Y_if_val";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		#print "if_val [$if_val]\n";
		if($if_val =~ /\s*(\d+)\s*-\s*(\d+)/){
			#print "kkk-->  $1 $2\n";
			for($temp=$1 ; $temp <= $2 ; $temp++){
				$$undefined_name{$temp} = $if_val;
			}
		} else {
			$$undefined_name{$if_val} = $if_val;
		}
		$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_STATE_$current_state" . "_Y_current";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		if($if_val =~ /\s*(\d+)\s*-\s*(\d+)/){
			#print "kkk-->  $1 $2\n";
			for($temp=$1 ; $temp <= $2 ; $temp++){
				$$undefined_name{$temp} = $current_state;
			}
		} else {
			$$undefined_name{$if_val} = $current_state;
		}
		$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_STATE_$current_state" . "_Y_next";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		if($if_val =~ /\s*(\d+)\s*-\s*(\d+)/){
			#print "kkk-->  $1 $2\n";
			for($temp=$1 ; $temp <= $2 ; $temp++){
				$$undefined_name{$temp} = $next_state;
			}
		} else {
			$$undefined_name{$if_val} = $next_state;
		}
	}
	if($if_val_type eq "N"){
		$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_STATE_$current_state" . "_N_if_val";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$if_val} = $if_val;
		$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_STATE_$current_state" . "_N_current";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$if_val} = $current_state;
		$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_STATE_$current_state" . "_N_next";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$if_val} = $next_state;
	}
	
	$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_DIRECTION";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{"STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_DIR_$current_state" . "_2_$next_state"} = $current_state;
	
	$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_DIR_$current_state" . "_2_$next_state";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{"current_state"} = $current_state;
	$$undefined_name{"if_var_type"} = $if_var_type;
	$$undefined_name{"if_var"} = $if_var;
	$$undefined_name{"if_val_type"} = $if_val_type;
	$$undefined_name{"if_val"} = $if_val;
	$$undefined_name{"next_state"} = $next_state;
	$$undefined_name{"action"} = $action;

	$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_EDGE";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{"STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_EDGE_$current_state" . "_CONDITION_$if_val_type\_$if_val"} = $next_state;

	$undefined_name = "STATE_DIAGRAM_EDGE_$state_diagram_edge_name" . "_EDGE_$current_state" . "_CONDITION_$if_val_type\_$if_val";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{"current_state"} = $current_state;
	$$undefined_name{"if_var_type"} = $if_var_type;
	$$undefined_name{"if_var"} = $if_var;
	$$undefined_name{"if_val_type"} = $if_val_type;
	$$undefined_name{"if_val"} = $if_val;
	$$undefined_name{"next_state"} = $next_state;
	$$undefined_name{"action"} = $action;
#if($if_var =~ /^pINPUT\s*->\s*/){
#$temp = $if_var;
#$temp =~ s/^pINPUT\s*->\s*//;
#if($if_var_type eq "D"){
#print DBG "if_var_member $if_var $temp\n";
#if($temp =~ /\s*(\w+)\s*([\/\*]+.*)\s*$/){
#$$undefined_name{"if_var_member_var"} = $1;
#$$undefined_name{"if_var_member_opr"} = $2;
#$temp = $1;
#} else {
#$$undefined_name{"if_var_member_var"} = $temp;
#}
#}
		## if_val_member_var로 마찬가지로 사용하지는 않디만, 혹시 몰라 그냥 남겨두는 것이다.
		$$undefined_name{"if_var_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#}
	$$undefined_name{"if_var_member"} = $if_var;
#if($if_val =~ /^pINPUT\s*->\s*/){
#$temp = $if_val;
#$temp =~ s/^pINPUT\s*->\s*//;
### if_val_member_var로 마찬가지로 사용하지는 않디만, 혹시 몰라 그냥 남겨두는 것이다.
#$$undefined_name{"if_val_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#} 
	$$undefined_name{"if_val_member"} = $if_val;
}

sub stat_function {
	my $function_def;
	### stat file의 header를 정의
	my $set_stat_file = "Set_Stat_Accumulate";
	open(STATACCUM , ">$outputdir/HD/$set_stat_file" . "\.c");
	$filelist{"HD/$set_stat_file" . "\.c"} = "CFILE";
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_stat_file\.c/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
				$upr =~ s/\+ToDo\+/library를 만들기 위한 Makefile을 만들자/;
				$upr =~ s/\+Intro\+/STAT typedef를 위한 functions/;
				$upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
				print STATACCUM $upr;
			}
			close UPR;
		print_fp("\#include \"$FileName\"\n",STATACCUM);

if(keys %stat_typedef){
		foreach my $accum_typedef (keys %table_log){
			### combiode file안의 function이름 정의  : void  type이름_combi(to,from)
			$function_def = "void Set_" . $accum_typedef . "_STAT_Accumulate($accum_typedef *pMsg , STAT_ALL *pSTAT_ALL)";
			$typedef_stat_func{"Set_" . $accum_typedef . "_STAT_Accumulate"} = "Set_" . $accum_typedef . "_STAT_Accumulate";
			$function_def{"Set_" . $accum_typedef . "_STAT_Accumulate"} = $function_def;
			### statode file안의  function들에 대한 주석 정의
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$accum_typedef\_STAT_Accmulate/;
				$upr =~ s/\+Intro\+/Set Stat Values Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/규칙에 틀린 곳을 찾아주세요./;
				$upr =~ s/\+Note\+/structg.pl로 만들어진 자동 코드/;
				if($upr =~ /\+Param\+/){
					print STATACCUM " * \@param *p$stg_hash_first_data 		: DATA Pointer\n";
				} else {
					print STATACCUM $upr;
				}
			}
			close UPR;

			print_fp ("$function_def\{\n",DBG,STATACCUM);
			if($stat_accumulate_typedef{"p" . $accum_typedef}){
#foreach my $temp_typedef (keys %table_log){
#	print_fp("\t$temp_typedef 	*p$temp_typedef \= p$stg_hash_first_data" . "->" . "p$temp_typedef\;\n",DBG,STATACCUM);
#}
#print_fp("\n",DBG,STATACCUM);
#foreach my $combi_typedef (keys %combi_typedef){
#	print_fp("\t$combi_typedef		*p$combi_typedef \= \&\( p$stg_hash_first_data" . "->". "$staticprefix$combi_typedef \)\;\n" ,DBG,STATACCUM);
#}
#print_fp("\n",DBG,STATACCUM);
				foreach my $stat_typedef (keys %stat_typedef){
					print_fp("\t$stat_typedef		*p$stat_typedef \= \&\( pSTAT_ALL" . "->". "$staticprefix$stat_typedef \)\;\n" ,DBG,STATACCUM);
				}
				print_fp("\n\n\n",DBG,STATACCUM);
				foreach my $key (keys %stat_accumulate){
					if($stat_accumulate{$key} =~ /\s*p$accum_typedef/){
						my $value ;
						$value = $stat_accumulate{$key};
						$value =~ s/p$accum_typedef/pMsg/g;
						print_fp("\t$key \+\= $value\;\n" ,DBG,STATACCUM);
					}
				}
			}
			print_fp("$stat_inc{$accum_typedef}" ,DBG,STATACCUM);
			print_fp ("\n\}\n\n",DBG,STATACCUM);
		}

		open(UPR,"<footer.upr");
		while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_stat_file\.c/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
				$upr =~ s/\+ToDo\+/Makefile을 만들자/;
				$upr =~ s/\+Intro\+/STAT typedef/;
				$upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
				print STATACCUM $upr;
		}
		close UPR;
}
	close STATACCUM;

	### stat file의 header를 정의
	my $set_stat_file = "Set_Stat_Once";
	open(STATONCE , ">$outputdir/HD/$set_stat_file" . "\.c");
	$filelist{"HD/$set_stat_file" . "\.c"} = "CFILE";
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_stat_file\.c/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
				$upr =~ s/\+ToDo\+/library를 만들기 위한 Makefile을 만들자/;
				$upr =~ s/\+Intro\+/STAT typedef를 위한 functions/;
				$upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
				print STATONCE $upr;
			}
			close UPR;
		print_fp("\#include \"$FileName\"\n",STATONCE);

		foreach my $set_stat_func (keys %stat_typedef){
			### statode file안의  function들에 대한 주석 정의
			my $stat_func_name;
			$stat_func_name = "Set_" . $set_stat_func . "_Once";
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$stat_func_name/;
				$upr =~ s/\+Intro\+/Set Stat Values Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/규칙에 틀린 곳을 찾아주세요./;
				$upr =~ s/\+Note\+/structg.pl로 만들어진 자동 코드/;
				if($upr =~ /\+Param\+/){
					print STATONCE " * \@param *p$stg_hash_first_data 		: DATA Pointer\n";
				} else {
					print STATONCE $upr;
				}
			}
			close UPR;

    		### statode file안의 function이름 정의  : void  type이름_stat(to,from)
			$function_def = "void $stat_func_name"."($set_stat_func *p$set_stat_func)";
			$typedef_stat_func{$stat_func_name} = $stat_func_name;
			$function_def{$stat_func_name} = $function_def;
			print_fp ("$function_def\{\n",DBG,STATONCE);
			print_fp("\t$set_stat_func *pthis = p$set_stat_func\;\n",DBG,STATONCE);
			#print_fp("\t$stg_hash_first_data *pthis = p$stg_hash_first_data\;\n",DBG,STATONCE);
			#foreach my $temp_typedef (keys %table_log){
			#	if($temp_typedef =~ /^$prefix_logdb_table/){		# LOG_
			#		print_fp("\t$temp_typedef 	*p$temp_typedef \= p$stg_hash_first_data" . "->" . "p$temp_typedef\;\n",DBG,STATONCE);
			#	}
			#}
			#foreach my $stat_typedef (keys %stat_typedef){
			#	print_fp("\t$stat_typedef		*p$stat_typedef \= \&\( p$stg_hash_first_data" . "->". "$staticprefix$stat_typedef \)\;\n" ,DBG,STATONCE);
			#}
			#print_fp("\n\n",DBG,STATONCE);
			$stat_typedef{$set_stat_func} =~ s/\;/\;\n\t/g;
			print_fp("\t$stat_typedef{$set_stat_func}\n" ,DBG,STATONCE);
			print_fp ("\n\}\n",DBG,STATONCE);
		}

		open(UPR,"<footer.upr");
		while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_stat_file\.c/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
				$upr =~ s/\+ToDo\+/Makefile을 만들자/;
				$upr =~ s/\+Intro\+/STAT typedef/;
				$upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
				print STATONCE $upr;
		}
		close UPR;
	close STATONCE;
}

sub sql_typedef
{
	my $main_sql_typedef;
	my $sub_sql_typedef;
	my $sub_sql_short_typedef;
	my $sub_sql_comments;
	my $up_sql_typedef;
	my $sql_member_cnt;
	my $sql_member_name;
	my $sql_member_short_name;
	my $sql_member_type;
	my $sql_cilog_hidden;
	my $sql_tab_cnt;

	$main_sql_typedef = shift @_;
	$up_sql_typedef = shift @_;
	$sub_sql_typedef = shift @_;
	$sub_sql_short_typedef = shift @_;
	$sub_sql_comments = shift @_;
	$sql_tab_cnt = shift @_;

	$temp = "ANALYSIS_ARRAY_$sub_sql_typedef";
	$sql_member_cnt = @$temp;
	print_fp("\t"x$sql_tab_cnt . "111 : main $main_sql_typedef : up $up_sql_typedef : low $sub_sql_typedef : S $sub_sql_short_typedef : TAB $sql_tab_cnt : C $sub_sql_comments :  CNT $sql_member_cnt\n",DBG);
	for(my $i = 0 ; $i < $sql_member_cnt ; $i++){
		$temp = "ANALYSIS_ARRAY_$sub_sql_typedef";
		$sql_member_name = "$$temp[$i]";

		$temp = "ANALYSIS_$sub_sql_typedef\_STG_PARM_SHORT_NAME";
		if($$temp{$sql_member_name}){
			$sql_member_short_name = "$sub_sql_short_typedef" . "$$temp{$sql_member_name}";
		} else {
			$sql_member_short_name = "$sub_sql_short_typedef" . "$sql_member_name";
		}
		 $sql_member_short_name =~ s/$shortremoveprefix//g;

		$temp = "ANALYSIS_$sub_sql_typedef\_type";
		$sql_member_type = $$temp{$sql_member_name};
		$temp = "ANALYSIS_$sub_sql_typedef\_CILOG_HIDDEN";
		$sql_cilog_hidden = $$temp{$sql_member_name};
		print_fp("\t"x$sql_tab_cnt . "[$i] : main $main_sql_typedef : up $up_sql_typedef : low $sub_sql_typedef : T $sql_member_type , V $sql_member_name : S $sql_member_short_name\n",DBG);

		if($type{$sql_member_type}){
			print_fp("\t"x$sql_tab_cnt . "1 : main $main_sql_typedef : up $up_sql_typedef : low $sub_sql_typedef : T $sql_member_type , V $sql_member_name\n",DBG);
			$undefined_name = "SQL_ARRAY_$main_sql_typedef";
			$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
			push @$undefined_name , "$sql_member_short_name";

			if($sql_cilog_hidden eq "NO"){
				$undefined_name = "SQL_ARRAY_CILOG_TABLE_$main_sql_typedef";
				$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
				push @$undefined_name , "$sql_member_short_name";
			}

			$undefined_name = "SQL_$main_sql_typedef";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			if($$undefined_name{$sql_member_short_name} ne "") { print_fp("ERROR : main $main_sql_typedef : up $up_sql_typedef : low $sub_sql_typedef : T $sql_member_type , V $sql_member_name : S $sql_member_short_name\n",DBG,STDOUT); die $error = 45239; }
			$$undefined_name{$sql_member_short_name} = $sql_member_type;

			$undefined_name = "SQL_$main_sql_typedef\_type";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $sql_member_type;

			$undefined_name = "SQL_$main_sql_typedef\_SHORT_NAME";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $sql_member_short_name;

			if($sql_tab_cnt == 0){	# nested된 것은 이름을 넣어주어야 할지 불투명
				$undefined_name = "SQL_$main_sql_typedef\_FULL_NAME";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$sql_member_name} = $sql_member_short_name;
			}


			my $sql_array = "";
			my $sql_array_size = "";

			$temp = "ANALYSIS_$sub_sql_typedef\_pointer";
			$undefined_name = "SQL_$main_sql_typedef\_pointer";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};

			$temp = "ANALYSIS_$sub_sql_typedef\_array";
			$undefined_name = "SQL_$main_sql_typedef\_array";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};
			$sql_array = $$temp{$sql_member_name};

			$temp = "ANALYSIS_$sub_sql_typedef\_array_size";
			$undefined_name = "SQL_$main_sql_typedef\_array_size";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};
			$sql_array_size = $$temp{$sql_member_name};

			$temp = "ANALYSIS_$sub_sql_typedef\_member_full";
			$undefined_name = "SQL_$main_sql_typedef\_member_full";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			if($sql_array eq "YES"){
					$$undefined_name{$sql_member_short_name} = "$sql_member_short_name\[$sql_array_size\]";
			} else {
					$$undefined_name{$sql_member_short_name} = "$sql_member_short_name";
			}

			$temp = "ANALYSIS_$sub_sql_typedef\_tag_define";
			$undefined_name = "SQL_$main_sql_typedef\_tag_define";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};

			$temp = "ANALYSIS_$sub_sql_typedef\_CHECK";
			$undefined_name = "SQL_$main_sql_typedef\_CHECK";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};

			$temp = "ANALYSIS_$sub_sql_typedef\_CILOG_HIDDEN";
			$undefined_name = "SQL_$main_sql_typedef\_CILOG_HIDDEN";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};

			$temp = "ANALYSIS_$sub_sql_typedef\_COMMENTS";
			$undefined_name = "SQL_$main_sql_typedef\_COMMENTS";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};

			$temp = "ANALYSIS_$sub_sql_typedef\_TABLE_COMMENTS";
			$undefined_name = "SQL_$main_sql_typedef\_TABLE_COMMENTS";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = "$$temp{$sql_member_name}" . " | $sub_sql_comments";

			$temp1 = "ANALYSIS_$sub_sql_typedef\_STG_PARM";
			foreach $temp (keys %$temp1) {
				$undefined_name = "SQL_$main_sql_typedef\_STG_PARM";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$temp} = $temp;
				$temp2 = "ANALYSIS_$sub_sql_typedef\_STG_PARM_$temp";
				foreach $temp3 (keys %$temp2) {
					$temp4 = "ANALYSIS_$sub_sql_typedef\_STG_PARM_$temp";
					$undefined_name = "SQL_$main_sql_typedef\_STG_PARM_$temp";
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$sql_member_short_name} = $$temp4{$sql_member_name};
				}
			}

			if($sql_tab_cnt == 0){
				$temp1 = "ANALYSIS_$sub_sql_typedef\_STG_PAR_ARRAY";
				foreach $temp2 (keys %$temp1){
					$undefined_name = "SQL_$main_sql_typedef\_STG_PAR_ARRAY";
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$temp2} = $$temp1{$temp2};

					$temp3 = "ANALYSIS_$sub_sql_typedef\_STG_PAR_ARRAY_MEMBER_$temp2";
					$temp9 = @$temp3;
					for(my $jj = 0 ; $jj < $temp9 ; $jj++){
						$undefined_name = "SQL_$main_sql_typedef\_STG_PAR_ARRAY_MEMBER_$temp2";
						$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
						$temp4 = "ANALYSIS_$sub_sql_typedef\_STG_PARM_SHORT_NAME";
						if($$temp4{$$temp3[$jj]}){
							$$undefined_name[$jj] = $$temp4{$$temp3[$jj]};
						} else {
							$$undefined_name[$jj] = $$temp3[$jj];
						}
					}

					$temp3 = "ANALYSIS_$sub_sql_typedef\_STG_PAR_ARRAY_VALUE_$temp2";
					$temp9 = @$temp3;
					for(my $jj = 0 ; $jj < $temp9 ; $jj++){
						$undefined_name = "SQL_$main_sql_typedef\_STG_PAR_ARRAY_VALUE_$temp2";
						$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
						$$undefined_name[$jj] = $$temp3[$jj];
					}

					$temp3 = "ANALYSIS_$sub_sql_typedef\_STG_PAR_ARRAY_NEXT_$temp2";
					$temp9 = @$temp3;
					for(my $jj = 0 ; $jj < $temp9 ; $jj++){
						$undefined_name = "SQL_$main_sql_typedef\_STG_PAR_ARRAY_NEXT_$temp2";
						$undefined_typedef{$undefined_name} = "ARRAY_$undefined_name";
						$$undefined_name[$jj] = $$temp3[$jj];
					}

				}
			}

			$temp = "ANALYSIS_$sub_sql_typedef\_PrintPreAction";
			$undefined_name = "SQL_$main_sql_typedef\_PrintPreAction";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};
			$temp = "ANALYSIS_$sub_sql_typedef\__PrintFormat";
			$undefined_name = "SQL_$main_sql_typedef\_PrintFormat";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};
			$temp = "ANALYSIS_$sub_sql_typedef\_PrintValue";
			$undefined_name = "SQL_$main_sql_typedef\_PrintValue";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};
			$temp = "ANALYSIS_$sub_sql_typedef\_PrintValueFunc";
			$undefined_name = "SQL_$main_sql_typedef\_PrintValueFunc";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};

			$temp = "ANALYSIS_$sub_sql_typedef\_CHECKING_VALUE";
			$undefined_name = "SQL_$main_sql_typedef\_CHECKING_VALUE";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};
			$temp1 = "ANALYSIS_$sub_sql_typedef\_CHECKING_VALUE_RANGE_$sql_member_name";
			foreach $temp (keys %$temp1) {
				$undefined_name = "SQL_$main_sql_typedef\_CHECKING_VALUE_RANGE_$sql_member_short_name";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$temp} = $$temp1{$temp};
			}
			$temp1 = "ANALYSIS_$sub_sql_typedef\_CHECKING_VALUE_STRING_$sql_member_name";
			foreach $temp (keys %$temp1) {
				$undefined_name = "SQL_$main_sql_typedef\_CHECKING_VALUE_STRING_$sql_member_short_name";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$temp} = $$temp1{$temp};
			}

		} elsif($typedef{$sql_member_type}){
			$temp = "ANALYSIS_$sub_sql_typedef\_TYPEDEF_func";
			$undefined_name = "SQL_$main_sql_typedef\_TYPEDEF_func";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$sql_member_short_name} = $$temp{$sql_member_name};


			print_fp("\t"x$sql_tab_cnt . "2 : main $main_sql_typedef : up $up_sql_typedef : low $sub_sql_typedef : T $sql_member_type , V $sql_member_name : S $sql_member_short_name\n",DBG);
			$temp = "ANALYSIS_$sub_sql_typedef\_TABLE_COMMENTS";
			sql_typedef($main_sql_typedef,$sub_sql_typedef,$sql_member_type,$sql_member_short_name, $$temp{$sql_member_name},$sql_tab_cnt+1);
		} else {
			print_fp("\t"x$sql_tab_cnt . "()()() : main $main_sql_typedef : up $up_sql_typedef : low $sub_sql_typedef : unknown $sql_member_type , $sql_member_name\n",DBG);
		}
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

###  _main_  __MAIN__ 
 
#TT# $temp = "#A{ a TotalName }A#  Length   }A#";
#TT# print "temp = [$temp]\n";
#TT# if($temp =~ /\#A\{\s*([^#]*)\s*\}A\#/){
#TT# 	print "[$1]\n";
#TT# }
#TT# $temp = "#B{ TotalName 한글\n TTTb #C{ 돌아삔다. CCCCC \n GGGG \n}C#  Length }B#";
#TT# if($temp =~ /\#(\w+)\{([\s\S\n]*)\}(\w+)\#/){
#TT# 	print "TT [$1] =$2= [$3]\n";
#TT# 	$temp = $2;
#TT# }
#TT# if($temp =~ s/\#(\w+)\{([\s\S\n]*)\}(\w+)\#//){
#TT# 	print "tt = [$temp]\n";
#TT# 	print "TT [$1] =$2= [$3]\n";
#TT# 	$temp = $2;
#TT# }
#TT# if($temp =~ /\#(\w+)\{([\s\S\n]*)\}(\w+)\#/){
#TT# 	print "TT [$1] =$2= [$3]\n";
#TT# 	$temp = $2;
#TT# }


### structg.pl hash.stg과  같이 INPUT file의 이름을 받게 하였음.
### input file은 한개를 만든 것으로 한다.  (나주에 합쳐야 하는 것은 추구 고려)
my $argcnt = @ARGV;
if($argcnt != 2) {
	print "invalid argument : $argcnt\n";
	print "will be used default value : @ARGV\n";
	$inputfilename = "userfile.stg";
	$outputdir = "OUTPUT";
} else {
	$inputfilename = shift @ARGV;
	$outputdir = shift @ARGV;
}

open(TIME_DBG,">TIME.TXT");

($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "structg : START - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);

mkdir $outputdir;
mkdir "$outputdir/STC";
mkdir "$outputdir/tmp";
mkdir "$outputdir/HD";
mkdir "$outputdir/tmp/DB";

print "INPUT : $inputfilename   ->   OUTPUT_DIR : $outputdir\n";

if($inputfilename =~ /\.stgL/){
	print "$inputfilename\n";
	open(STGL , "<$inputfilename");
	while($line = <STGL>){
		chop($line);
		if($line =~ /^\#/){
			next;
		}
		#print "in : $in\n";
		if ($line =~ /^\s*FileName\s*\:\s*(\S+)\s*$/){  ### FileName으로 stg -> h를 위한 이름  (FileName = ...)
			$FileName = $1;
			print "STGL : \$FileName = $FileName\n";
			next;
		}
		if ($line =~ /^\s*STG_FileName\s*\:\s*(\S+)\s*$/){  ### FileName으로 .stc -> .c를 위한 이름  (FileName = ...)
			$inputfilename = "$outputdir/$1";
			print "STGL OUTPUT _STG : $inputfilename\n";
			next;
		}
		push @stg_filearray , $line;
	}
	close STGL;

	open(STG,">$inputfilename");
	print STG "FileName : $FileName\n";
	foreach $temp (@stg_filearray){
		print ">> $temp\n";
		open(LSTG, "<$temp");
		while($line = <LSTG>){
			if ($line =~ /^\s*FileName\s*\:\s*(\S+)\s*$/){  ### FileName으로 stg -> h를 위한 이름  (FileName = ...)
				next;
			}
			if ($line =~ /^\s*STC_FileName\s*\:\s*(.*)\s*$/){  ### FileName으로 .stc -> .c를 위한 이름  (FileName = ...)
				@temp = split(",",$1);
				push @stc_filearray , @temp;
				next;
			}
			print STG $line;
		}
		close LSTG;
	}
	close STG;
}

print "=============================\n";



open(DBG,">DEBUG.TXT");
open(PRT , ">$outputdir/HD/HD_PRT" . ".c");
open(FPP , ">$outputdir/HD/HD_CILOG" . ".c");
	$filelist{"HD/HD_PRT" . ".c"} = "CFILE";
	$filelist{"HD/HD_CILOG" . ".c"} = "CFILE";
open(ENC , ">$outputdir/HD/HD_ENC" . ".c");
	$filelist{"HD/HD_ENC" . ".c"} = "CFILE";
open(DEC , ">$outputdir/HD/HD_DEC" . ".c");
	$filelist{"HD/HD_DEC" . ".c"} = "CFILE";

open(ProC , ">$outputdir/tmp/DB/DB_ProC" . ".pc");
	#$filelist{"DB/DB_ProC" . ".pc"} = "ProC";
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/DB_ProC.pc/;
				$upr =~ s/\+Warning\+/NTAM용으로 만드는 앞에 flat_st 가 모두 들어갈 것이다./;
				$upr =~ s/\+ToDo\+//;
				print ProC $upr;
			}
			close UPR;

### STG : 확장자 stg를 가지는 INPUT FILE
print "structg.pl inputfilename : $inputfilename\n";
open(STG , "<$inputfilename");


### primitives로는 encode , decode , print 말고 또 뭐가있는가? 
### encode , decode , print로만 동작함.
$primitives{"ENC"} = "_Enc";
$primitives{"DEC"} = "_Dec";
$primitives{"PRT"} = "_Prt";
$primitives{"FPP"} = "_CILOG";


while ($line = <STG>) {
	$analysis_line = $line;
	delete @STG_PARM{keys %STG_PARM};
	while( $line =~ /\@\s*STG_PARM\s*:\s*(\S+)\s*:([^@]*)\@/){
		$line =~ s/\@\s*STG_PARM\s*:\s*(\S+)\s*:([^@]*)\@//;
		$STG_PARM{$1} = $2;
	};
	if($line =~ /\@\s*DEF_NUM\s*:\s*(\d+)\s*\@/){
		$typedef_def_cnt = int($1) - 1;
	}
	$line =~ s/\@[^@]*\@//g;		## CILOG_HIDDEN , CHECKING_VALUE등을 없애줌. 단지 analysis_line에서만 처리해주게 됨.
	$case_ignore = "NO";
	$parsing_case_ignore = "NO";
	#print "TTT  ; $line\n";
	if ($line =~ /^\#\#/){  
		print "Comments: $line";
		next;
	}
	if($line =~ s/\$CASE_IGNORE\$//){
		$case_ignore = "YES";
		print "CASE_IGNORE: $line";
	}
	if($line =~ s/\$PARSING_CASE_IGNORE\$//){
		$parsing_case_ignore = "YES";
		print "PARSING_CASE_IGNORE: $line";
	}
	if ($line =~ /^\s*STG_HASH_TIMER\s*(\S+)\s*(\S+)\s*\;/){  
		$stg_hash_timer_type = $1;
		$stg_hash_timer_name = $2;
		next;
	}
	if ($line =~ /^\s*STG_HASH_SESS_TIMEOUT\s*(\S+)\s*\;/){  
		$stg_hash_sess_timeout = $1;
		next;
	}
	if ($line =~ /^\s*STG_HASH_DEL_TIMEOUT\s*(\S+)\s*\;/){  
		$stg_hash_del_timeout = $1;
		next;
	}
	if ($line =~ /^\s*STG_HASH_SIZE\s*(\S+)\s*\;/){  
		$stg_hash_size = $1;
		next;
	}
	if ($line =~ /^\s*STG_HASH_KEY\s*(\w+)\s*\;/){  
		$stg_hash_key = $1;
		stg_hash_key2($stg_hash_key);
		next;
	}
	if ($line =~ /^\s*SET_DEF_START_NUM\s*\:\s*(\d*)\s*$/){  ### DEF_NUM의 start시간 
		$typedef_def_cnt = int($1);
		print STDOUT "typedef_def_start_num = $typedef_def_cnt\n";
		next;
	}
	if ($line =~ /^\s*STC_FileName\s*\:\s*(.*)\s*$/){  ### FileName으로 .stc -> .c를 위한 이름  (FileName = ...)
		my $stc_filename;
		$stc_filename = $1;
		print DBG "\$stc_filenames = $stc_filename\n";
		$stc_filename =~ s/\s//g;
		print DBG "\$stc_filenames = $stc_filename\n";
		@stc_filearray = split(",",$stc_filename);
		next;
	}
	if ($line =~ /^\s*GLOBAL_FileName\s*\:\s*(.*)\s*$/){  ### FileName으로 .stc -> .c를 위한 이름  (FileName = ...)
		my $global_filename;
		$global_filename = $1;
		print DBG "\$global_filenames = $global_filename\n";
		$global_filename =~ s/\s//g;
		print DBG "\$global_filenames = $global_filename\n";
		@global_filearray = split(",",$global_filename);
		next;
	}
	if($line =~ /\<\s*TAG_KEY\s*\>/){
		$tag_key = 1;
		next;
	} elsif($line =~ /\<\s*\/TAG_KEY\s*\>/){
		$tag_key = 0;
		next;
	}
	if ($line =~ /^\s*FileName\s*\:\s*(\S+)\s*$/){  ### FileName으로 stg -> h를 위한 이름  (FileName = ...)
		$FileName = $1; 
		print "\$FileName = $FileName\n";
		### OUTH stg->h로 하는 output file  : OUTPUT .H
		open(OUTH,">$outputdir/$FileName");
		$temp = $FileName;
		$temp =~ s/\./\_/;
		print OUTH "\#ifndef	__" . $temp . "__\n";
		print OUTH "\#define	__" . $temp . "__\n";
		$filelist{$FileName} = "INC";
	print_fp("\#include \"$FileName\"\n",ENC);
	print_fp("\#include \"$FileName\"\n",DEC);
	print_fp("\#include \"$FileName\"\n",PRT);
	print_fp("\#include \"$FileName\"\n",FPP);

			### header.upr(generic header form for doxygen)
			### 생성되는 각 file의 앞 부분에 삽입할 일반적 내용
			###
			###   변수들을 +...+ 으로 정의하여 사용한다. 바꿔주는 부분은 아래와 같은 방식을 따른다.
			### header.upr을 읽어서 .h file의 file header 부분을 장식한다.
			### $upr =~ s/\+ToDo\+/Makefile을 만들자/;  식으로 필요한 부분들을 대치 시키면 되게 설계를 한 것이다.
			### *.upr 마다 각지 다른 내용으로 대치가 될수 있기에  함수화 시키지 못하였다.
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$FileName/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
				$upr =~ s/\+ToDo\+/Makefile을 만들자/;
				$upr =~ s/\+Intro\+/hash header file/;
				$upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
				print OUTH $upr;
			}
			close UPR;

			open(UPR,"<define.upr");
			while($upr = <UPR>){
				print OUTH $upr;
			}
			close UPR;
			print OUTH "\n\n\n\n/* code gen에서 자동으로 정의되는 type들.\n*/\n";
			print OUTH "\#ifndef __TYPEDEF_H__\n";
			print OUTH "\#define __TYPEDEF_H__\n";
			foreach my $def (sort keys %type_define){
				print OUTH "\#define	\t $def   \t $type_define{$def}\n";
			}
			print OUTH "\#endif\n";


		### flat header를 만들기 위한 filename
		### flat 이란  nested structure를 쫙 펼친 것이라 생각하면 된다.
		### NTAM에서 사용하는 structure 모양때문에 만드는 것인데
		### 이것은 flat_hdr_gen.pl에서 사용하는 것이다.
		###
		### 일반 적으로 nested structure를 사용하지 않았다면
		###    flat_hdr_gen.pl을 이용할 필요가 없으며
		###    이 flat이라는 가정도 필요치 않다.
		$FlatFileName = "flat_$FileName";
        open(FLATH,">$outputdir/$FlatFileName");
		$filelist{$FlatFileName} = "INC";
            open(UPR,"<header.upr");
            while($upr = <UPR>){
                $upr =~ s/\+FileName\+/$FlatFileName/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
                $upr =~ s/\+ToDo\+/Makefile을 만들자/;
                $upr =~ s/\+Intro\+/hash header file/;
                $upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
                print FLATH $upr;
            }
            close UPR;

        ### flat??.h 에서 $FileName (*.h) 를 include한다. 
		$temp = $FileName;
		$temp =~ s/\./_/g;
		print_fp("\#ifndef _$temp\_h_\n",FLATH);
		print_fp("\#define _$temp\_h_\n",FLATH);
		print_fp("\#include \"$FileName\"\n",FLATH);
		print_fp("\#pragma pack(1)\n",FLATH);
		next; 
	}

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

		$undefined_name = "TAG_DEF_ALL";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		if($$undefined_name{$tag_define_name} ne ""){
			print STDERR "ERROR : TAG_DEFINE_START의 이름이 중복됨 : $tag_define_name\n";
		} else {
			$$undefined_name{$tag_define_name} = $tag_define_name;
		}

		$undefined_name = "TAG_DEF";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$tag_define_name} = $tag_define_name;

		print OUTH "\/\*\* TAG_DEFINE_START : $tag_define_name \*\/\n";

		next;
	}
	if ($line =~ /^\s*\<TAG_DEFINE_END\s*\:\s*(\w+)\s*\>/){
		print DBG "TAG $line : name = $1\n";
		$tag_define_name = "";
		next;
	}
	if ( $line =~ /^\s*\#define\s+(\w+)\s+(\d+)/ ){
		my $define_var = $1;
		my $define_val = $2;
		$define_digit{$define_var} = $define_val;
		print DBG "\#define \[$define_var\] \[$define_val\]\n";

		if ( $tag_define_name ne "" ){
			foreach $temp (keys %STG_PARM) {
				$undefined_name = "TAG_DEF_ALL_$tag_define_name\_STG_PARM";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$temp} = $temp;
				$undefined_name = "TAG_DEF_ALL_$tag_define_name\_STG_PARM_$temp";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$define_var} = $STG_PARM{$temp};
				$undefined_name = "TAG_DEF_ALL_STG_PARM_$temp";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$define_var} = $STG_PARM{$temp};
			}
			$undefined_name = "TAG_DEF_ALL_$tag_define_name";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$define_var} = $define_val;

			$undefined_name = "TAG_DEF_ALL_NUM_$tag_define_name";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{"$define_val"} = "$define_var";

			$undefined_name = "TAG_DEF_$tag_define_name";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$define_var} = $define_val;

			$temp = $line;
			$temp =~ s/\#define//;
			$TAG_DEFINE{$tag_define_name} .= "*\t" . $temp . "\n";
			$TAG_DEFINE{$tag_define_name} =~ s/\/\*.+\*\///g;    # 주석문 삭제
		}
		if($in_typedef == 1) {
			$typedef_org .= $line . "\n";
		} else {
			print OUTH "$line\n";
		}
		next;
	}
	if ($line =~ /^\s*\<\s*TAG_AUTO_STRING_DEFINE_START\s*\:\s*(\w+)\s*\(\s*(\S+)\s*\)\s*\>/){ 
		print DBG "TAG AUTO STRING $line : name = $1 $2\n";
		$tag_auto_string_define_name = $1;
		$tag_auto_string_define_start_num = $2;

		$undefined_name = "TAG_DEF_ALL";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		if($$undefined_name{$tag_auto_string_define_name} ne ""){
			print STDERR "ERROR : TAG_AUTO_STRING_DEFINE_START의 이름이 중복됨 : $tag_auto_string_define_name\n";
		} else {
			$$undefined_name{$tag_auto_string_define_name} = $tag_auto_string_define_name;
		}

		$undefined_name = "TAG_AUTO_STRING_DEF";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$tag_auto_string_define_name} = $tag_auto_string_define_name;
		if($case_ignore eq "YES"){
			$undefined_name = "TAG_AUTO_STRING_DEF_CASE_IGNORE";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$tag_auto_string_define_name} = $case_ignore;
		}
		print OUTH "\/\*\* TAG_AUTO_STRING_DEFINE_START : $tag_auto_string_define_name ($tag_auto_string_define_start_num) \*\/\n";
		next;
	}
	if ($line =~ /^\s*\<TAG_AUTO_STRING_DEFINE_END\s*\:\s*(\w+)\s*\>/){
		print DBG "TAG AUTO STRING $line : name = $1\n";
		$tag_auto_string_define_name = "";
		next;
	}
	if (($tag_auto_string_define_name ne "") && ($line =~ /^\s*(\S+)\s+(\S+)\s*(.*)$/) ){
		my $tag_str;
		my $tag_def;
		my $tag_comments;
		$undefined_name = "TAG_AUTO_STRING_DEF_CASE_IGNORE";
		$tag_str = $1;
		if($$undefined_name{$tag_auto_string_define_name} eq "YES"){
			$tag_str =  lc($tag_str);
		} 
		$tag_def = $2;
		$tag_comments = $3;
		$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$tag_str} = $tag_def;

		### DUAL용으로 Level에 따른 DATA를 만든다.
		$temp = "";
		$temp2 = "";
		my $num_str = "";
		my $strlen = length($tag_str);
		for(my $i = 0; $i < $strlen ; $i++){
			my $cc;
			my $orc;
			$cc = substr $tag_str , $i , 1;
			$orc = ord $cc;
			$num_str .= "_$orc";
		}
		for(my $i = 0; $i < $strlen ; $i++){
			my $cc;
			my $orc;
			my $ncc;
			my $norc;
			$cc = substr $tag_str , $i , 1;
			$orc = ord $cc;
			$temp .= "_$cc";
			$temp2 .= "_$orc";
			$temp3 = substr $tag_str , ($i+1) , ($strlen-$i-1);
#print "TAG_DUAL $temp  ,$temp2   ,$temp3\n";
			# 가져야 할 내용들
##  ???_L0 {숫자a} = a
##  ???_L0_숫자a_substr {a를 뺀 string } = 전체 string
##  ???_L0_숫자a {다음문자의 숫자} = 문자
## 		 다음문자의 숫자가 0 이면 끝이므로 return값을 넣어줌 
			$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$orc} = "_$orc";
			$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i\_char";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$orc} = "$cc";

			$num_str =~ s/^_\d+//g;			## 숫자로 처리하는 것의 첫번째 ascii 숫자 제거
			$ncc = substr $tag_str , $i+1 , 1;
			$norc = ord $ncc;
			$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2\_char";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			if($norc == 0){
				$$undefined_name{$norc} = $tag_def;
			} else {
				$$undefined_name{$norc} = $ncc;
			}

			$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2\_string";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			my $tab_i;
			$tab_i = 4 + $i*2;
			$$undefined_name{0} .= "\n" . "\t"x$tab_i . "*  $tag_str";


			if($norc == 0){
				$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2\_matched";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$norc} = $tag_def;

				$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2\_num_matched";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$norc} = $tag_def;
			} else {
				$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$norc} = "$temp2\_$norc";

				$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2\_substr";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$temp3} = $tag_str;

				$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2\_num_substr";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$num_str} = $temp3;

				$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2\_substr_size";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$temp3} = length($temp3);

				$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2\_num_substr_size";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$num_str} = length($temp3);

				$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2\_matched";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$temp3} = $tag_def;

				$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i$temp2\_num_matched";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$num_str} = $tag_def;
			}

		}

		if($tag_comments =~ s/^\s*\(\s*(\d+)\s*\)(.*)/\t\t\/* NUM:$1 *\/$2/){
			$tag_auto_string_define_start_num = $1;
		}  

		if($define_digit{$tag_def} eq ""){
			my $tab_cnt =  int((47 - length($tag_def)) /4);
			$define_digit{$tag_def} = $tag_auto_string_define_start_num;
			$line = "\#define $tag_def" . "\t"x$tab_cnt . "  $tag_auto_string_define_start_num		\/* $tag_str *\/ $tag_comments";
			print DBG "$line\n";
			if($in_typedef == 1) {
				$typedef_org .= $line . "\n";
			} else {
				print OUTH "$line\n";
			}
	
			$undefined_name = "TAG_DEF_ALL_$tag_auto_string_define_name";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$tag_def} = $tag_auto_string_define_start_num;

			$undefined_name = "TAG_DEF_ALL_NUM_$tag_auto_string_define_name";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$tag_auto_string_define_start_num} = $tag_def;
	
			$undefined_name = "TAG_AUTO_STRING_DEF_$tag_auto_string_define_name";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$tag_def} = $tag_auto_string_define_start_num;
	
			$temp = $line;
			$temp =~ s/\#define//;
			$TAG_DEFINE{$tag_auto_string_define_name} .= "*\t" . $temp . "\n";
			$TAG_DEFINE{$tag_auto_string_define_name} =~ s/\/\*.+\*\///g;    # 주석문 삭제

			$tag_auto_string_define_start_num++;
		} else {
			my $tab_cnt =  int((47 - length($tag_def)) /4);
			$line = "\/*      $tag_def" . "\t"x$tab_cnt . "$tag_str  \( $define_digit{$tag_def} \)*\/";
			if($in_typedef == 1) {
				$typedef_org .= $line . "\n";
			} else {
				print OUTH "$line\n";
			}
		}
		foreach $temp (keys %STG_PARM) {
			$undefined_name = "TAG_DEF_ALL_$tag_auto_string_define_name\_STG_PARM";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$temp} = $temp;
			$undefined_name = "TAG_DEF_ALL_$tag_auto_string_define_name\_STG_PARM_$temp";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$tag_def} = $STG_PARM{$temp};
			$undefined_name = "TAG_DEF_ALL_STG_PARM_$temp";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$tag_def} = $STG_PARM{$temp};
		}
		next;
	}
	if ($line =~ /^\s*\<\s*TAG_AUTO_DEFINE_START\s*\:\s*(\w+)\s*\(\s*(\S+)\s*\)\s*\>/){ 
		print DBG "TAG $line : name = $1 $2\n";
		$tag_auto_define_name = $1;
		$tag_auto_define_start_num = $2;

		$undefined_name = "TAG_DEF_ALL";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		if($$undefined_name{$tag_auto_define_name} ne ""){
			print STDERR "ERROR : TAG_AUTO_DEFINE_START의 이름이 중복됨 : $tag_auto_define_name\n";
		} else {
			$$undefined_name{$tag_auto_define_name} = $tag_auto_define_name;
		}

		$undefined_name = "TAG_AUTO_DEF";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$tag_auto_define_name} = $tag_auto_define_name;
		print OUTH "\/\*\* TAG_AUTO_DEFINE_START : $tag_auto_define_name ($tag_auto_define_start_num) \*\/\n";
		next;
	}
	if ($line =~ /^\s*\<TAG_AUTO_DEFINE_END\s*\:\s*(\w+)\s*\>/){
		print DBG "TAG $line : name = $1\n";
		$tag_auto_define_name = "";
		next;
	}
	if (($tag_auto_define_name ne "")){
		$line =~ /^\s*(\w+)\s*(.*)$/;
		$temp_argu1 = $1;
		$temp_argu2 = $2;
		#TAG_DEBUG print DBG "LINE = $line\n";

	 	if($line =~ /#([^#]*)#\s*$/){
			$vertex_name = $temp_argu1;
			$action = $1;
			tag_auto_define_undefined();
			#TAG_FLOW_DEBUG print DBG "action = $action\n";

			$undefined_name = "TAG_DEF_ALL_$tag_auto_define_name\_VERTEX_Action";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$vertex_name} = $action;
		} elsif($line =~ /#{(.*)$/){
			$vertex_name = $temp_argu1;
			$action = $1;
			$sharp_start = 1; 
			tag_auto_define_undefined();
			#TAG_FLOW_DEBUG print DBG "action start = $action\n";
		} elsif($sharp_start == 1){
			#TAG_FLOW_DEBUG print DBG "no action $sharp_start = $line\n";
			if($line =~ /(.*)\}#\s*$/){
				$action .= "\n$1";
				#TAG_FLOW_DEBUG print DBG "action_end = $action\n";
				$sharp_start = 0;

				$undefined_name = "TAG_DEF_ALL_$tag_auto_define_name\_VERTEX_Action";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$vertex_name} = $action;
			} else {
				$action .= "\n$line";
			}
		} else {
			#TAG_FLOW_DEBUG print DBG "no action $sharp_start = $line\n";
			tag_auto_define_undefined();
		}
		foreach $temp (keys %STG_PARM) {
			$undefined_name = "TAG_DEF_ALL_$tag_auto_define_name\_STG_PARM";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$temp} = $temp;
			$undefined_name = "TAG_DEF_ALL_$tag_auto_define_name\_STG_PARM_$temp";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$temp_argu1} = $STG_PARM{$temp};
			$undefined_name = "TAG_DEF_ALL_STG_PARM_$temp";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$temp_argu1} = $STG_PARM{$temp};
		}
		next;
	}
	if ($line =~ /^\s*\<\s*TAG_FLOW_START\s*\:\s*(\w+)\s*\(\s*(.+)\s*\)\s*\>/){ 
		#TAG_FLOW_DEBUG print DBG "TAG_FLOW $line : name = $1\n";
		$tag_flow_name = $1;
		$temp = $2;
		$tag_flow_name{$tag_flow_name} = $temp;
		print "tt $temp\n";
		$temp =~ /pTHIS\s*-\s*(\w+)/;
		print "tt $1\n";
		$tag_flow_pTHIS{$tag_flow_name} = $1;
		$tag_flow_struct =$1;
		$temp =~ /pINPUT\s*-\s*(\w+)/;
		$tag_flow_pINPUT{$tag_flow_name} = $1;
		if($typedef{$tag_flow_pTHIS{$tag_flow_name}} eq ""){ print "tag_flow_start's management structure  don't exist upper.\n$line - $tag_flow_pTHIS{$tag_flow_name}\n";   die $error = 541; } 
		#if($typedef{$tag_flow_pINPUT{$tag_flow_name}} eq ""){ print "tag_flow_start's management structure  don't exist upper.\n$line - $tag_flow_pINPUT{$tag_flow_name}\n";   die $error = 542; } 
		next;
	}
	if ($line =~ /^\s*\<TAG_FLOW_END\s*\:\s*(\w+)\s*\>/){
		#TAG_FLOW_DEBUG print DBG "TAG_FLOW $line : name = $1\n";
		$tag_flow_name = "";
		next;
	}
	if ( ($tag_flow_name ne "") &&
		 ($line =~ /^\s*%\s*(\w+)\s*:\s*(\w+)\s*:\s*\(\s*(\w+)\s*\)\s*(\S+)\s*:\s*\(\s*(\w+)\s*\)\s*([^#:]*)\s*:\s*(\w+)\s*%/) )
	{
		$current_state = $1;
		$msg = $2;
		$if_var_type = $3;
		$if_var = $4;
		$if_val_type = $5;
		$if_val = $6;
		$next_state = $7;
#print "var : $if_var\n";

	 	if($line =~ /#([^#]*)#\s*$/){
			$action = $1;
			flow_undefined();
			#TAG_FLOW_DEBUG print DBG "action = $action\n";
		}
		if($line =~ /#{(.*)$/){
			$action = $1;
			$sharp_start = 1; 
			#TAG_FLOW_DEBUG print DBG "action start = $action\n";
		}

		#TAG_FLOW_DEBUG print DBG "\FLOW \[$1\] \[$2\] $3 $4 $5 $6 $7 \#$8\#\n";
		next;
	} elsif( ($tag_flow_name ne "") && ($sharp_start == 1) ){
		if($line =~ /(.*)\}#\s*$/){
			$action .= "\n$1";
			flow_undefined();
			#TAG_FLOW_DEBUG print DBG "action_end = $action\n";
			$sharp_start = 0;

		} else {
			$action .= "\n$line";
		}
		next;
	}
	if ($line =~ /^\s*\<\s*STATE_DIAGRAM_VERTEX\s*\:\s*(\w+)\s*\(\s*(\S+)\s*\)\s*\>/){ 
		print DBG "STATE_DIAGRM_VERTEX $line : name = $1 $2\n";
		$state_diagram_vertex_name = $1;
		$state_diagram_vertex_start_num = $2;

		$undefined_name = "TAG_DEF_ALL";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		if($$undefined_name{$state_diagram_vertex_name} ne ""){
			print STDERR "ERROR : STATE_DIAGRAM_VERTEX - TAG_AUTO_DEFINE_START의 이름이 중복됨 : $state_diagram_vertex_name\n";
		} else {
			$$undefined_name{$state_diagram_vertex_name} = $state_diagram_vertex_name;
		}

		$undefined_name = "TAG_AUTO_DEF";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$state_diagram_vertex_name} = $state_diagram_vertex_name;

		$undefined_name = "STATE_DIAGRAM_VERTEX";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$state_diagram_vertex_name} = $state_diagram_vertex_name;
		print OUTH "\/\*\* STATE_DIAGRAM_VERTEX : $state_diagram_vertex_name ($state_diagram_vertex_start_num) \*\/\n";
		next;
	}
	if ($line =~ /^\s*\<\/STATE_DIAGRAM_VERTEX\s*\:\s*(\w+)\s*\>/){
		print DBG "\/STATE_DIAGRAM_VERTEX END $line : name = $1\n";
		$state_diagram_vertex_name = "";
		next;
	}
	if (($state_diagram_vertex_name ne "")){
		$line =~ /^\s*(\w+)\s*:\s*(\w+)\s*([^:]*)$/;
		if($line =~ /^\s*(\w+)\s*:\s*(\w+)\s*([^:]*)$/){
			$tmp_vertex_name = $1;
			$tmp_vertex_msg = $2;
			$temp_argu2 = $3;
		}
		#TAG_DEBUG print DBG "LINE = $line : $1 : $2 : $3\n";

	 	if($line =~ /#([^#]*)#\s*$/){
			$action = $1;
			state_diagram_vertex_undefined();
			#TAG_FLOW_DEBUG print DBG "action = $action\n";

			$undefined_name = "STATE_DIAGRAM_VERTEX_$state_diagram_vertex_name\_VERTEX_Action";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$tmp_vertex_name} = $action;
		} elsif($line =~ /#{(.*)$/){
			$action = $1;
			$sharp_start = 1; 
			state_diagram_vertex_undefined();
			#TAG_FLOW_DEBUG print DBG "action start = $action\n";
		} elsif($sharp_start == 1){
			#TAG_FLOW_DEBUG print DBG "no action $sharp_start = $line\n";
			if($line =~ /([^#]*)\}#[^#]*$/){
				$action .= "\n$1";
				#TAG_FLOW_DEBUG print DBG "action_end : $tmp_vertex_name = $action\n";
				$sharp_start = 0;

				$undefined_name = "STATE_DIAGRAM_VERTEX_$state_diagram_vertex_name\_VERTEX_Action";
				$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
				$$undefined_name{$tmp_vertex_name} = $action;
			} else {
				$action .= "\n$line";
			}
		} else {
			$action = "";
			#TAG_FLOW_DEBUG print DBG "no action $sharp_start = $line\n";
			state_diagram_vertex_undefined();
		}
		foreach $temp (keys %STG_PARM) {
			$undefined_name = "TAG_DEF_ALL_$state_diagram_vertex_name\_STG_PARM";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$temp} = $temp;
			$undefined_name = "TAG_DEF_ALL_$state_diagram_vertex_name\_STG_PARM_$temp";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$state_diagram_vertex_name} = $STG_PARM{$temp};
			$undefined_name = "TAG_DEF_ALL_STG_PARM_$temp";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$state_diagram_vertex_name} = $STG_PARM{$temp};
			$undefined_name = "STATE_DIAGRAM_VERTEX_$state_diagram_vertex_name\_STG_PARM";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$temp} = $temp;
			$undefined_name = "STATE_DIAGRAM_VERTEX_$state_diagram_vertex_name\_STG_PARM_$temp";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$state_diagram_vertex_name} = $STG_PARM{$temp};
			$undefined_name = "STATE_DIAGRAM_VERTEX_STG_PARM_$temp";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$state_diagram_vertex_name} = $STG_PARM{$temp};
		}
		next;
	}
	if ($line =~ /^\s*\<\s*STATE_DIAGRAM_EDGE\s*\:\s*(\w+)\s*\(\s*(.+)\s*\)\s*\>/){ 
		#TAG_FLOW_DEBUG print DBG "TAG_FLOW $line : name = $1\n";
		$state_diagram_edge_name = $1;
		$temp = $2;
		$state_diagram_edge_name{$state_diagram_edge_name} = $temp;
		print "tt $temp\n";
		$temp =~ /pTHIS\s*-\s*(\w+)/;
		$state_diagram_edge_struct =$1;
		print "tt $1\n";
		$state_diagram_edge_pTHIS{$state_diagram_edge_name} = $state_diagram_edge_struct;
		$temp =~ /pINPUT\s*-\s*(\w+)/;
		$state_diagram_edge_pINPUT{$state_diagram_edge_name} = $1;
		if($typedef{$state_diagram_edge_pTHIS{$state_diagram_edge_name}} eq ""){ print "state_diagram_edge_start's management structure  don't exist upper.\n$line - $state_diagram_edge_pTHIS{$state_diagram_edge_name}\n";   die $error = 541; } 
		#if($typedef{$state_diagram_edge_pINPUT{$state_diagram_edge_name}} eq ""){ print "state_diagram_edge_start's management structure  don't exist upper.\n$line - $state_diagram_edge_pINPUT{$state_diagram_edge_name}\n";   die $error = 542; } 
		next;
	}
	if ($line =~ /^\s*\<\/STATE_DIAGRAM_EDGE\s*\:\s*(\w+)\s*\>/){
		#TAG_FLOW_DEBUG print DBG "TAG_FLOW $line : name = $1\n";
		$state_diagram_edge_name = "";
		next;
	}
	if ( ($state_diagram_edge_name ne "") &&
		 ($sharp_start == 0) &&
		 ($line =~ /^\s*%\s*(\w+)\s*:\s*\(\s*(\w+)\s*\)\s*(\S+)\s*:\s*\(\s*(\w+)\s*\)\s*([^#:]*)\s*:\s*(\w+)\s*%/) )
	{
		$current_state = $1;
		$if_var_type = $2;
		$if_var = $3;
		$if_val_type = $4;
		$if_val = $5;
		$next_state = $6;
#print "var : $if_var\n";

	 	if($line =~ /#([^#]*)#\s*$/){
			$action = $1;
			state_diagram_edge_undefined();
			#TAG_FLOW_DEBUG print DBG "action = $action\n";
		} elsif($line =~ /#{(.*)$/){
			$action = $1;
			$sharp_start = 1; 
			#TAG_FLOW_DEBUG print DBG "action start = $action\n";
		} elsif( not ($line =~ /#/)){
			$action = "";
			state_diagram_edge_undefined();
		}

		#TAG_FLOW_DEBUG print DBG "\FLOW \[$1\] \[$2\] $3 $4 $5 $6 $7 \#$8\#\n";
		next;
	} elsif( ($state_diagram_edge_name ne "") && ($sharp_start == 1) ){
		if($line =~ /(.*)\}#\s*$/){
			$action .= "\n$1";
			state_diagram_edge_undefined();
			#TAG_FLOW_DEBUG print DBG "action_end = $action\n";
			$sharp_start = 0;
		} else {
			$action .= "\n$line";
		}
		next;
	}
	if ($line =~ /typedef\s+struct\s+\w+\s*{/){  $in_typedef = 1 ; }		# ... typedef struct .. 로써 
	if ($line =~ /^\s*\}\s*(\w+)\s*\;/){  $in_typedef = 2; }


	### //... 시작하는 주석을 /*  ... */ 형태로 바꿔줌
	### /// A --> /**	A		*/
	if($line =~ s/\/\/\/\</\/\*\*\</){ $line .= "\*\/ "; }
	### //  A --> /*	A		*/  http:// 등이 있어서 지워주면 안된다.
	### 기본을 ///< 을 사용하거나 , /* 을 사용하는 것을 기본으로 한다. 
	#if ($line =~ s/\/\//\/\*/){ $line .= "\*\/ "; }
	$line_prt = $line . "\n";
	#T_DEBUG
	print  DBG "PPP  [$in_typedef] : $line\n";
	
	$short = "";
	if($in_typedef == 0) {
		print OUTH $line_prt;
	}
	if($in_typedef == 1) {
		if($line =~ /^\s*LINEFEED\s+(.*)$/){
			$text_parse_linefeed = $1;
			#TEXT_PARSE_DEBUG print DBG "LINEFEED = " . $text_parse_linefeed . "\n";
			next;
		}
		if($line =~ /^\s*FORMFEED\s+(.*)$/){
			$text_parse_formfeed = $1;
			#TEXT_PARSE_DEBUG print DBG "FORMFEED = " . $text_parse_formfeed . "\n";
			next;
		}
		if($line =~ /^\s*STATE\s+(.*)$/){
			$text_parse_state .= $1 . "#^#^#^#";
			#TEXT_PARSE_DEBUG print DBG "STATE = " . $text_parse_state . "\n";
			next;
		}
		if($line =~ /^\s*TOKEN\s+(.*)$/){
			$text_parse_token .= $1 . "#^#^#^#";
			#TEXT_PARSE_DEBUG print DBG "TOKEN = " . $text_parse_token . "\n";
			next;
		}
		if($line =~ s/^\s*ALTERNATIVE_RULE\s+(.*)$/$1/){
			#TEXT_PARSE_DEBUG print DBG  "TK ALTERNATIVE_RULE = " . $line . "\n";
			$prev_line =~ s/^(.*;).*$/$1/;
			#TEXT_PARSE_DEBUG print  DBG "ALTERNATIVE : [[$prev_line]] : $line\n";
			$line =~ s/\/\*.+\*\///g;
			#$typedef_cr .= " " . $prev_line . " " . $line . "\n";
			$typedef_cr .= "ALTERNATIVE_RULE " . $line . "\n";
			$typedef_cr =~ s/\/\*.+\*\///g;
			$temp = $line;
			$temp =~ s/\#//g;
			$temp =~ s/\</\{\{/g;
			$temp =~ s/\>/\}\}/g;
			$typedef_org .= "\t"x3 . "\/**< ALTERNATIVE_RULE : $temp *\/\n";
			next;
		}

		$analysis_line =~ s/\%\s*(.*)\s*\%/ \@STG_PARM\:SHORT_NAME\:$1\@ /;
		$analysis_typedef_lines .= $analysis_line;

		if($tag_key == 1){
			$temp = $line;
#TAG_KEY_DEBUG print DBG "A0 $line\n";
			$temp =~ s/<TAG_[^>]*>//g;
			if($temp =~ /^(\s*\w+\s*[^;:]+)[:;](.*)$/) {
				$tag_key_lines .= "\t" . $1 . "\;\n";
#TAG_KEY_DEBUG print DBG "A1 $tag_key_lines\n";
			}
		}

		if($line =~ /\%.*\%/){			## SHORT 이름을 골라낸다.
			$line =~ s/\%\s*(.*)\s*\%//;
			$short = $1;
			$line_prt = $line . "\n";
			#SHORT_DEBUG print DBG "shortname - " . $short . "\n result = $line\n";
		} 
		if($line =~ /\#.*\#/){			## TEXT_PARSING에서 RULE을 골라낸다. PARSING_RULE (.h를 만드는 print문을 위해서)
			## $line_prt ($typedef_org만을 변경 : print하는 것만  doc으로 처리)
			$temp = $line;
			$temp =~ s/\<(\w+)\>/\{\{$1\}\}/g;
			$temp1 = $temp;
			$temp1 =~ s/\/\*/\<\</g;
			$temp1 =~ s/\*\//\>\>/g;
			$temp =~ s/\#([^\#]*)\#//; # 주석처리 변경
			$line_prt = $temp .  "	\/\*\*< [$temp1] \*\/" . "\n";
			#TEXT_PARSE_DEBUG print DBG "PRT ## 처리 line = " . $line . "\n result = $line_prt\n";
		} 

		## Short 처리를 위한 각 line에 대한 분석
		if($line =~ /^\s*(\w+)\s+(\w+)\s*\[\s*(\d+)\s*\]\s*\;/){	##  [16] array로 선언될때의 처리
			#print DBG "=$1 =$2 =$3\n";
			if($short eq ""){ $short = $2; }
			if($typedef{$1}){
				$line_short = "\t$shortprefix$1		$short\[$3\]\;\n";
			}
			else {
				$line_short = "\t$1		$short\[$3\]\;\n";
			}
			#SHORT_DEBUG print DBG "\$line_short = $line_short";
		} 
		elsif($line =~ /^\s*(\w+)\s+(\w+)\s*\[\s*(\w+)\s*\]\s*\;/){	##  [MAX_DEF] array로 선언될때의 처리
			#SHORT_DEBUG print DBG "=$1 =$2 =$3 \+$define_digit{$3}\n";
			if($short eq ""){ $short = $2; }
			if($typedef{$1}){
				$line_short = "\t$shortprefix$1		$short\[$define_digit{$3}\]\;\n";
			} else {
				$line_short = "\t$1		$short\[$define_digit{$3}\]\;\n";
			}
			#SHORT_DEBUG print DBG "\$line_short = $line_short";
		} 
		elsif($line =~ /^\s*(\w+)\s+(\w+)\s*\;/){			## U32 RespCode;
			#SHORT_DEBUG print DBG "=$1 =$2\n";
			if($short eq ""){ $short = $2; }
			if($typedef{$1}){
				$line_short = "\t$shortprefix$1	$short\;\n";
			} else {
				$line_short = "\t$1	$short\;\n";
			}
			#SHORT_DEBUG print DBG "\$line_short = $line_short";
		}
		elsif($line =~ /^\s*(\w+)\s+(\w+)\s*\:.*\;/){		## STG_HASHKEY	stgCoInfo : if(pthis) STG_Equal(pthis->stgCoInfo);	
			#SHORT_DEBUG print DBG "=$1 =$2\n";
			if($short eq ""){ $short = $2; }
			if($typedef{$1}){
				$line_short = "\t$shortprefix$1	$short\;\n";
			} else {
				$line_short = "\t$1	$short\;\n";
			}
		}
		elsif($line =~ /^\s*(\w+)\s+<\s*TAG_DEFINE\s*\:\s*(\w+)>\s*(\w+)\s*([;:].*)$/){		##  U32		<TAG_DEFINE:RespCode>RespCode;	
			my $tag_name;
			#TAG_DEBUG print DBG "TAG_DEFINE =$1 =$2 =$3 =$4\n";
			$tag_name = $2;
			if($short eq ""){ $short = $3; }
			if($typedef{$1}){
				$line_short = "\t$shortprefix$1	$short\;\n";
			} else {
				$line_short = "\t$1	$short\;\n";
			}
			$line = "\t$1 \t$3$4";
			$undefined_name = "TAG_DEFINE_MAPPING";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$line} = "$tag_name";
			$temp = $line;
			$temp =~ /\#([^\#]*)\#/;
			$temp1 = $1;
			$temp1 =~ s/\</\{\{/g;
			$temp1 =~ s/\>/\}\}/g;
			$temp =~ s/\#([^\#]*)\#/\/**< [$temp1] *\//;
			$line_prt = "\/**< <TAG_DEFINE:$tag_name>\n$TAG_DEFINE{$tag_name}*\/\n$temp\n";
			#TAG_DEBUG print DBG "\$line_short = $line_short";
			#TAG_DEBUG print DBG "\$TAG line= $line";
			#TAG_DEBUG print DBG "\$TAG line_prt = $line_prt";
			$line .= " \#\*--TAG_DEFINE_TAGNAME:--:$tag_name--\*\#";
#print "$line\n";
		}
		elsif($line =~ /^\s*BIT(\d+)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*\;\s*(.*)$/){
			#BIT_DEBUG print DBG "BIT $1 $2 $3 $4 $5\n";
			my $bit_tot = $1;
			my $bit_name = $2;
			my $bit_cnt = $3;
			my $bit_struct = $4;
			my $bit_comment = $5;
			my @bit_array;

			$bit_sum += $bit_cnt;
			$bit_line  .= "$line\n";
			$bit_type = "U$bit_tot";	# U8  U16  U32

			if($bit_sum >= $bit_tot){
				@bit_array = split("\n",$bit_line);
				print OUTH "\#define $bit_struct" . "_A			$bit_struct\.A\n";
						$typedef_org .= "	union {\n";
						$typedef_org .= "		$bit_type	A\;\n";
						$typedef_org .= "		struct {\n";
						$typedef_org .= "#ifdef __BIG_ENDIAN__\n";
						$typedef_short .= "\t$bit_type 	$bit_struct\;\n";
				foreach $temp_vars (@bit_array){
					if($temp_vars =~ /^\s*$/) { next; }
					if($temp_vars =~ /^\s*BIT(\d+)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*\;\s*(.*)$/){
						$bit_tot = $1;
						$bit_name = $2;
						$bit_cnt = $3;
						$bit_struct = $4;
						$bit_comment = $5;
						#BIT_DEBUG print DBG "BITTT $1 $2 $3 $4 $5\n";
						print OUTH "\#define $bit_struct" . "_B_$2			$bit_struct\.B\.$2\n";
						$typedef .= " $temp_vars";
						$typedef =~ s/\/\*.+\*\///g;
						$typedef_cr .= " " . $temp_vars . "\n";
						$typedef_cr =~ s/\/\*.+\*\///g;    # 주석문 삭제
						$typedef_org .= "			$bit_type  $bit_name\:$bit_cnt\;   	$bit_comment\n";
						#BIT_DEBUG print DBG "DBG_TYPEDEF BIT($line) ==> \n$typedef\n";
						#BIT_DEBUG print DBG "DBG_TYPEDEF_CR BIT($line) ==> \n$typedef_cr\n";
						#BIT_DEBUG print DBG "DBG_TYPEDEF_ORG BIT($line_prt) ==> \n$typedef_org\n";
						#BIT_DEBUG print DBG "DBG_TYPEDEF_SHORT BIT($line_short) ==> \n$typedef_short\n";
					}
				}
						$typedef_org .= "#else /* __BIG_ENDIAN__ */\n";
				foreach $temp_vars (reverse @bit_array){
					if($temp_vars =~ /^\s*$/) { next; }
					if($temp_vars =~ /^\s*BIT(\d+)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*\;\s*(.*)$/){
						$bit_tot = $1;
						$bit_name = $2;
						$bit_cnt = $3;
						$bit_struct = $4;
						$bit_comment = $5;
						$typedef_org .= "			$bit_type  $bit_name\:$bit_cnt\;   	$bit_comment\n";
					}
				}
						$typedef_org .= "#endif /* __BIG_ENDIAN__ */\n";
						$typedef_org .= "		} B\;\n";
						$typedef_org .= "	} $bit_struct\;\n";
				$prev_line = "";
				$line_short = "";

				$bit_sum = 0;
				$bit_line = "";		# 끝이 \n이 아님.
				#$bit_prt = "";		# 끝이 \n
				#$bit_short = "";		# 끝이 \n
				next;
			} else {
				next;
			}
		}
		

		if($line =~ /typedef\s+struct\s+(\w+)\s*\{/){ 
			#TYPEDEF_DEBUG print DBG "vvvstruct $1\n";
			$line_short = "typedef struct $shortprefix" . $1 . "\ {\n";
			print DBG "\$line_short = $line_short";
		}

		$prev_line = $line;
		$typedef .= " " . $line;
		$typedef_cr .= " " . $line . "\n";
		$typedef_cr =~ s/\/\*.+\*\///g;    # 주석문 삭제
		$typedef_org .= $line_prt;
		$typedef_short .= $line_short;
		#TYPEDEF_DEBUG print DBG "DBG_TYPEDEF ($line) ==> \n$typedef\n";
		#TYPEDEF_DEBUG print DBG "DBG_TYPEDEF_CR ($line) ==> \n$typedef_cr\n";
		#TYPEDEF_DEBUG print DBG "DBG_TYPEDEF_ORG ($line_prt) ==> \n$typedef_org\n";
		#TYPEDEF_DEBUG print DBG "DBG_TYPEDEF_SHORT ($line_short) ==> \n$typedef_short\n";
		#TYPEDEF_DEBUG print DBG "short \$line_short ==> \n$line_short";
		$line_short = "";
		### /* ... */ 주석을 삭제
		## 주석처리 때문에 $typedef는 \n 이 들어가지 않는 것으로 만들어져야 한다.
		## 이를 해결하기 위해서는 어떻게 해야 할까?
		## $typedef_cr을 만들어야 할 것으로 보인다.
		$typedef =~ s/\/\*.+\*\///g;
	} 

	if($in_typedef == 2) {
		## 분석을 위해서 새로 만들어두는 것이다. 
		## save_typedef()의 한계를 극복하기 위해서 다시 만들어진 부분이다.
		## save_typedef()는 그냥 사용하고 그 이후에 추가되는 것들만 이것을 이용하여 처리하게 된다.
		$analysis_typedef_lines .= $analysis_line;
		analysis_typedef($analysis_typedef_lines);
		$analysis_typedef_lines = "";

		my $TYPEDEF_NAME;
		if($line =~ /^\s*\}\s*(\w+)\s*\;/){ 
			#TYPEDEF_DEBUG print DBG "^^^typedef $1\n";
			$TYPEDEF_NAME = $1;
			$line_short = "} $shortprefix$1 \;\n";
		}

		$typedef .= " " . $line;
		$typedef_org .= $line_prt;
		$typedef_short .= $line_short;
		print DBG "[2] result null \$typedef = $typedef\n";
		print DBG "[2] result org \$typedef_org = $typedef_org\n";
		print DBG "[2] result short \$typedef_short = $typedef_short\n";



		#if($typedef =~ /\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/){
		#		print "STG_COMMON CTYPEDEF $1\n";
		#	print "STG_COMMON $typedef\n";
		#	$typedef =~ s/\<\s*STG_COMMON\s*\:\s*(\w+)\s*\>/$1/g;
		#	print "STG_COMMON $typedef\n";
		#}


		#print "BBB : $typedef\n";
		### typedef struct ... { ....} ... ; 까지 되는 구문을 뽑아내가 되는 것이다.
		### $typedef에는 typedef struct ... { ....} ... ;  형태의 string이 포함된다.
		### save_typedef에서 각 typedef에 대한 작업을 처리해준다.
		$typedef_short =~ s/\n//g;
		flat_save_typedef($typedef_short); 		# short save typedef
		#save_typedef($typedef_short); 
#print DBG "Process_typedef = $typedef\n";

		if($typedef =~ /^\s*typedef\s+struct/){ 
			print_fp( "TABLE_NORMAL $TYPEDEF_NAME\n",DBG);
			print OUTH $typedef_org;
			flat_save_typedef($typedef); 
			save_typedef($typedef); 
		} elsif($typedef =~ /^\s*STG_LOG_TEXT_PARSING\s+typedef\s+struct/){ 
			my $from;
			$typedef_org =~ s/^\s*STG_LOG_TEXT_PARSING\s*//g; 

			print OUTH $typedef_org;

			print_fp( "STG LOG TEXT PARSING $TYPEDEF_NAME\n",DBG);
			$table{$TYPEDEF_NAME} = "LOG";
			$table_log{$TYPEDEF_NAME} = "LOG";
			$typedef =~ s/^\s*STG_LOG_TEXT_PARSING\s*//g; 
			flat_save_typedef($typedef); 
			save_typedef($typedef); 
#print DBG "TTTT_TTTT\n";
			$typedef_cr =~ s/^\s*STG_LOG_TEXT_PARSING\s+typedef\s+struct\s*.*\{\s*//; 
#print DBG "TTTT_TTTT DBG_TYPEDEF_CR ==> $typedef_cr\n";

			$undefined_name = "LEX_LINEFEED";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$TYPEDEF_NAME} = "$text_parse_linefeed";

			$undefined_name = "LEX_FORMFEED";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$TYPEDEF_NAME} = "$text_parse_formfeed";

			$undefined_name = "LEX_STATE";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$TYPEDEF_NAME} = $text_parse_state;

			$undefined_name = "LEX_TOKEN";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$TYPEDEF_NAME} .= $text_parse_token;

			$undefined_name = "LEX_CONTENTS";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$TYPEDEF_NAME} = "$typedef_cr";

			$undefined_typedef_name = "UNDEFINED_typedef_" . $TYPEDEF_NAME;
			$undefined_typedef{$undefined_typedef_name} = "HASH_" . $undefined_typedef_name;
			$$undefined_typedef_name{"LEX_LINEFEED"} = "$text_parse_linefeed";
			$$undefined_typedef_name{"LEX_FORMFEED"} = "$text_parse_formfeed";
			$$undefined_typedef_name{"LEX_STATE"} = $text_parse_state;
			$$undefined_typedef_name{"LEX_TOKEN"} = $text_parse_token;
			$$undefined_typedef_name{"LEX_CONTENTS"} = $typedef_cr;

			## token의 결과 
			$undefined_name = "LEX_TOKEN_RESULT";
			$from = "LEX_TOKEN";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$temp = $$from{$TYPEDEF_NAME};
			$temp =~ s/\#\^\#\^\#\^\#/\n/g;			## delimiter로 #^#^#^# 을 사용함. 
			$$undefined_name{$TYPEDEF_NAME} = $temp;
			$$undefined_typedef_name{"LEX_TOKEN_RESULT"} = $temp;

			## STATE에 대한 처리  
			#### STATE 정의 부분
			#### STATE 관련 처리 RULE 부분
			$temp = $text_parse_state;
			$temp =~ s/\#\^\#\^\#\^\#/\n/g;			## delimiter로 #^#^#^# 을 사용함. 
			@temp_vars = split("\n",$temp);
			foreach $temp_vars (@temp_vars){
				print DBG "TT:^^: \$temp_vars = $temp_vars\n";	
				if($temp_vars =~ /^\s*(\w+)\:\^\^\:(\w+)\s+(.*)$/){			# delimiter로 :^^: 사용 
					# ==> KK [REQ_HDR] [GET] [^[ \t]*GET[ \t]+]
					#TEXT_PARSE_DEBUG print DBG "KKKK [$1] [$2] [$3]\n";

					# ==> $LOG_KUN_TXTPARSE { REQ_HDR } =  LOG_KUN_TXTPARSE_STATE_REQ_HDR
					$undefined_name = "TXTPARSE";
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{"$TYPEDEF_NAME" . "_$1"} = $TYPEDEF_NAME;

					if($parsing_case_ignore eq "YES"){
						$undefined_name = "TXTPARSE_CASE_IGNORE";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{"$TYPEDEF_NAME" . "_$1"} = "YES";
					}

					$undefined_name = $TYPEDEF_NAME . "_TXTPARSE";
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$1} = $TYPEDEF_NAME . "_$1" . "_TXTPARSE_STATE";

					# ==> $LOG_KUN_TXTPARSE_STATE_REQ_HDR { GET } = ^[ \t]*GET[ \t]+
					$undefined_name = $TYPEDEF_NAME . "_$1". "_TXTPARSE_STATE";
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$2} = $3;

					$undefined_name = $TYPEDEF_NAME . "_$1". "_TXTPARSE_STATE" . "_$2";
					$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
					$$undefined_name{$3} = $2;

					# %s 로 하는 STATE 선언부는 $LOG_KUN_TXTPARSE_STATE_REQ_HDR의 KEY들을 나열하면 되는 것이다. 
				} else {
					print_fp("TEXT_PARSING : STATE statement ERROR: $temp_vars\n",STDOUT,DBG);
				}
			}

			## RULE에 대한 처리 --> U32		RespCode;			#PARSING:^^:RESP_HDR:^^:<HTTP>{DIGIT}# 
			#### U32 Respcode; 와 같은 선언부 이 값에 나온 내용을 Set
			#### RULE --> #~~~# 
			@temp_vars = split("\n",$typedef_cr);
			foreach $temp_vars (@temp_vars){
				my $which = "FIRST";
				my $define_tag_name="";
				#TEXT_PARSE_DEBUG print DBG "RULE A : $temp_vars\n";

				if($temp_vars =~ /^\s*$/){
					next;
				}

				if($temp_vars =~ s/\#\s*LAST\s*\#//){
					$which = "LAST";	
				} elsif($temp_vars =~ s/\#\s*FIRST\s*\#//){
					$which = "FIRST";	
				}
				if($temp_vars =~ s/\#\*--TAG_DEFINE_TAGNAME:--:(\S*)--\*\#//){
					$define_tag_name = $1;
				} else {
					$define_tag_name = "";
				}
				if($temp_vars =~ s/^\s*ALTERNATIVE_RULE\s+(.*)$/$1/){
					my $declare;
					$for_prev_line =~ /^(.*;).*$/;
					$declare = $1;
					$temp_vars = $declare . " " . "$temp_vars";
					#TEXT_PARSE_DEBUG print  DBG "FOR_ALTERNATIVE : $temp_vars\n";
					# 여기서 처리되는 ALTERNATIVE로 되어진 부분은 아래의 실제 처리하는 부분에서 
					# 처리 할수 있는 모양으로 바꿔만 주는 것이다.( 아래로 바로 내려가서
					# if($temp_vars =~ /^\s*(\S+)\s+(\S+)\;\s*\#(.*)\#\s*$/){ 에서 연속적으로 처리 
				}
				if($temp_vars =~ /^\s*(\S+)\s+(\S+)\;\s*\#(.*)\#\s*$/){
					my $vartype = $1;
					my $varname = $2;
					my $var_array_size;
					my $cmd_n_rule = $3;

					$for_prev_line = $temp_vars;
					# ==> KK [U8] [host[20]] [PARSING:^^:REQ_HDR:^^:<HOST>{VALUE}]
					#TEXT_PARSE_DEBUG print DBG "KK [$1] [$2] [$3]\n";

					if($varname =~ /\[\s*(\d*)\s*\]/){	##  [] array로 선언될때의 처리
						$var_array_size = $1;
						$varname =~ s/\[\s*(\d*)\s*\]//;
					} elsif($varname =~ /\[\s*(\w*)\s*\]/){	##  [] array로 선언될때의 처리
						$var_array_size = $1;
						if($define_digit{$1} ne ""){$var_array_size = $define_digit{$var_array_size}; }
						$varname =~ s/\[\s*(\w*)\s*\]//;
					}
					#TEXT_PARSE_DEBUG print DBG "TT size = $var_array_size\n";

					if( ($cmd_n_rule =~ /PARSING_RULE\:\^\^\:(\S*)\:\^\^\:([^:]+)\:\^\^\:(\S*)$/)  or
						($cmd_n_rule =~ /PARSING_RULE\:\^\^\:(\S*)\:\^\^\:(.+)$/) ){
						my $temp_TXTPARSE = $1;		# REQ_HDR
						my $temp_RULE = $2;		# <HOST>{VALUE}
						my $temp_action = $3;		# <HOST>{VALUE}
						my $temp_state;			# HOST
						#TEXT_PARSE_DEBUG print DBG "CMD_N_RULE : $cmd_n_rule ==> $temp_action\n";

						my $temp_skiplen;

						$temp_RULE =~ /\<(.*)\>/;
						$temp_state = $1;

						# PP [REQ_HDR] [<HOST>{VALUE}
						#TEXT_PARSE_DEBUG print DBG "PP [$1] [$2]\n";

						# ==>  $LOG_KUN_TXTPARSE_RULE_VAR_TYPE_REQ_HDR { <HOST>{VALUE} } = U8
						if($define_tag_name ne ""){
							$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_DEFINE_TAG";
							$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
							$$undefined_name{$temp_RULE} = $define_tag_name;
							$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_DEFINE_TAG" . "_$temp_state";
							$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
							$$undefined_name{$temp_RULE} = $define_tag_name;
						} else {
							$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_DEFINE_TAG";
							$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
							$$undefined_name{$temp_RULE} = "0";
							$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_DEFINE_TAG" . "_$temp_state";
							$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
							$$undefined_name{$temp_RULE} = "0";
						}

						# ==> $LOG_KUN_TXTPARSE_RULE_REQ_HDR { <HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>SID:{DIGIT} } = <HTTP_PHONE_2G_PHONE_SYSTEM_PARAMETER>SID:{DIGIT}	............
						# -->  $LOG_KUN_TXTPARSE_RULE_REQ_HDR { <HOST>{VALUE} } = <HOST>{VALUE}
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = $temp_RULE;
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE" . "_$temp_state";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = $temp_RULE;

						# ==>  $LOG_KUN_TXTPARSE_RULE_VAR_TYPE_REQ_HDR { <HOST>{VALUE} } = U8
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_VAR_TYPE";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = $vartype;
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_VAR_TYPE" . "_$temp_state";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = $vartype;

						# ==> $LOG_KUN_TXTPARSE_RULE_VAR_NAME_REQ_HDR { <HOST>{VALUE} } = host 
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_VAR_NAME";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = $varname;
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_VAR_NAME" . "_$temp_state";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = $varname;

						# ==> $LOG_KUN_TXTPARSE_RULE_VAR_ARRAY_SIZE_REQ_HDR { <HOST>{VALUE} } = 20
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_ARRAY_SIZE";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = $var_array_size;
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_ARRAY_SIZE" . "_$temp_state";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = $var_array_size;

						# ==> $LOG_KUN_TXTPARSE_RULE_VAR_SIZE_REQ_HDR { <HOST>{VALUE} } = 20
						# STRING일때는 Array size , INTEGER일때는 변수의  size
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_SIZE";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						if($type_set_type{$vartype} eq "STG_STRING"){
							$$undefined_name{$temp_RULE} = $var_array_size;
						} else {
							$$undefined_name{$temp_RULE} = $type_size{$vartype};
						}
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_SIZE" . "_$temp_state";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						if($type_set_type{$vartype} eq "STG_STRING"){
							$$undefined_name{$temp_RULE} = $var_array_size;
						} else {
							$$undefined_name{$temp_RULE} = $type_size{$vartype};
						}

						# ==> $LOG_KUN_TXTPARSE_RULE_SKIP_LENGTH_REQ_HDR { <HOST>{VALUE} } = 0
						$temp_RULE =~ /\>(.*)\{/;
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_SKIP_LENGTH";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = length($1);
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_SKIP_LENGTH" . "_$temp_state";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = length($1);
						$temp_skiplen = length($1);

						# ==> $LOG_KUN_TXTPARSE_RULE_SKIP_LENGTH_REQ_HDR { <HOST>{VALUE} } = 0
						if($temp_action =~ /^[ \t]*$/){
							$temp_action = "";
						}
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_ACTION";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = $temp_action;
						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_ACTION" . "_$temp_state";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp_RULE} = $temp_action;


						# atoi (SET Value)
#						$undefined_name = $TYPEDEF_NAME . "_$temp_TXTPARSE" . "_TXTPARSE_RULE_SET_VALUE";
#						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
#						if($type_set_func{"U32"} eq $type_set_func{$vartype}){
#							$$undefined_name{$temp_RULE} = "
#							pLOG_KUN->$varname = $type_set_func{$vartype} (yytext + $temp_skiplen);
#						} else {
#							$$undefined_name{$temp_RULE} = "
#							yytext[yyleng] = 0;
#							memcpy(pLOG_KUN->$varname, yytext + $temp_skiplen , yyleng - $temp_skiplen +1);
#						}
# 위의 이 부분을 code로 만들려고 하니 , type들에 따라서 매일 해주어야 하는 것들이
# 발생할 것으로 생각이 되어 , Set_Value , Print_Value등을 만들어주어 향후 prt와 Set , Get하는 곳에서 
# 편리하게 쓸수 있게 만들어주는 것이 좋지 않을까 하는 생각이 든다.

					} elsif($cmd_n_rule =~ /COMMAND\:\^\^\:(.+)$/){
						#TEXT_PARSE_DEBUG print DBG "CC [$1]\n";
					} else {
						print_fp("TEXT_PARSING : CMD & RULE ERROR : $cmd_n_rule\n",STDOUT,DBG);
					}

				} else {
					print_fp("TEXT_PARSING : RULE statement (not define rule): $temp_vars\n",DBG);
				}
			}

			$text_parse_linefeed = "";
			$text_parse_formfeed = "";
			$text_parse_state = "";
			$text_parse_token = "";
		} elsif($typedef =~ /^\s*TABLE_LOG\s+typedef\s+struct/){ 
			$typedef_org =~ s/^\s*TABLE_LOG\s*//g; 
			print OUTH $typedef_org;
			print_fp( "TABLE_LOG $TYPEDEF_NAME\n",DBG);
			$table{$TYPEDEF_NAME} = "LOG";
			$table_log{$TYPEDEF_NAME} = "LOG";
			$typedef =~ s/^\s*TABLE_LOG\s*//g; 
			flat_save_typedef($typedef); 
			save_typedef($typedef); 
		} elsif($typedef =~ /^\s*TABLE_CF\s+typedef\s+struct/){ 
			$typedef_org =~ s/^\s*TABLE_CF\s*//g; 
			print OUTH $typedef_org;
			print_fp( "TABLE_CF $TYPEDEF_NAME\n",DBG);
			$table{$TYPEDEF_NAME} = "CF";
			$table_cf{$TYPEDEF_NAME} = "CF";
			$typedef =~ s/^\s*TABLE_CF\s*//g; 
			flat_save_typedef($typedef); 
			save_typedef($typedef); 
		} elsif($typedef =~ /^\s*STG_COMBINATION_TABLE\s+typedef\s+struct/){ 
			print_fp( "TABLE_COMBI $TYPEDEF_NAME\n",DBG);
			$table{$TYPEDEF_NAME} = "COMBI";
			$table_combi{$TYPEDEF_NAME} = "COMBI";
			stg_combination_table($typedef_org);
		} elsif($typedef =~ /^\s*STG_ASSOCIATION\s+typedef\s+struct/){ 
			print_fp( "TABLE_ASSOCIATION $TYPEDEF_NAME \n",DBG);
			$table{$TYPEDEF_NAME} = "ASSOCIATION";
			$table_association{$TYPEDEF_NAME} = "ASSOCIATION";
			$table_log{$TYPEDEF_NAME} = "LOG";
			stg_association($typedef_org);
		} elsif($typedef =~ /^\s*STG_STAT_TABLE\s+typedef\s+struct/){ 
			print_fp( "TABLE_STAT $TYPEDEF_NAME\n",DBG);
			$table{$TYPEDEF_NAME} = "STAT";
			$table_stat{$TYPEDEF_NAME} = "STAT";
			stg_stat_table($typedef_org);
		} elsif($typedef =~ /^\s*STG_HASH_KEY\s+typedef\s+struct/){ 
			print_fp( "TABLE_HASH_KEY $TYPEDEF_NAME\n",DBG);
			$typedef_org =~ s/^\s*STG_HASH_KEY\s*//g; 
			print OUTH $typedef_org;
			$typedef =~ s/^\s*STG_HASH_KEY\s*//g; 
			stg_hash_key_org($typedef);
		} elsif($typedef =~ /^\s*(\w+)\s+typedef\s+struct/){ 
			$undefined_name = $1;
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$TYPEDEF_NAME} = length($1);
			$typedef_org =~ s/^\s*\w+\s+//; 
			$typedef =~ s/^\s*\w+\s+//; 
			print_fp( "SPECIAL_TAG $TYPEDEF_NAME\n",DBG);
			print OUTH $typedef_org;
			flat_save_typedef($typedef); 
			save_typedef($typedef); 
		}


		if($tag_key_lines ne ""){ $TAG_KEY{$TYPEDEF_NAME} = $tag_key_lines; }

		$in_typedef = 0;
		$typedef = "";
		$typedef_cr = "";
		$typedef_org = "";
		$typedef_short = "";
		$tag_key_lines = "";
	}
}

		stat_function;
		print_fp("\#pragma pack(0)\n\n",FLATH);
		print_fp("\#endif\n\n",FLATH);

	foreach $temp (keys %TAG_KEY){
		$typedef =  "";
		print OUTH "typedef struct _st$temp\_tag_key {\n";
		$typedef .= "typedef struct _st$temp\_tag_key {\n";
		print OUTH "$TAG_KEY{$temp}";
		$typedef .= "$TAG_KEY{$temp}";
		print OUTH "} TAG_KEY_$temp \;\n\n";
		$typedef .=  "} TAG_KEY_$temp \;\n\n";
		flat_save_typedef($typedef); 
		save_typedef($typedef); 
	}


	$undefined_name = "ONETIME";
	$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
	$$undefined_name{"1"} = 1;
	


($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "structg : GLOBAL_Pre_STC - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);


#== SQL과 WEB에서 이용할수 있는 값들을 만들어준다.  <<<<<  START
# flat을 대신하는 것으로 보면된다. 
# flow관련 header대신 SQL로 만드는 header를 생성하여야할 것으로 보인다.
	my $ana_name;
	$ana_name = "ANALYSIS_TYPEDEF";
	foreach $temp1 (keys %$ana_name){
		$undefined_name = "SQL_TYPEDEF";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$temp1} = $$ana_name{$temp1};
		$temp4 = "ANALYSIS_$temp1\_STG_TYPEDEF";
		#SQL_DEBUG print  "SQL_$temp1\_STG_TYPEDEF : $temp4 : $ana_name : $temp1 : $$ana_name{$temp1}\n";
		foreach $temp5 (keys %$temp4){
			$undefined_name = "SQL_$temp1\_STG_TYPEDEF";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$temp5} = $$temp4{$temp5};
			$undefined_name = "SQL_$temp5\_STG_TYPEDEF";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$temp1} = $temp1;
		}
		sql_typedef($temp1,$temp1,$temp1,"", "ROOT", 0);
	}
#== SQL과 WEB에서 이용할수 있는 값들을 만들어준다.  >>>>>  END



	print_all_global_var("GLOBAL_pre_global.TXT");
	print "\n\n\n======== GLOBAL START =========\nglobal_filearray : @global_filearray\n";
	foreach my $globalfile (@global_filearray){
		get_all_global_var($globalfile,"FIRST");
	}

	print_all_global_var("GLOBAL.TXT");
($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "structg : SQL - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);


	print "\n\n\n======== STC START =========\nstc_filearray : @stc_filearray\n";
	foreach my $stcfile (@stc_filearray){
		if($stcfile =~ /\.stcI/){
			Ichange($stcfile,"STC");			# OUTPUT안에 저장하고, makefile에도 넣어라.
		} elsif($stcfile =~ /\.stc/){
										# 3번째 인자 : stcL이 아닌 경우는 NULL
			Cchange($stcfile,"STC","","STC");			# OUTPUT안에 저장하고, makefile에도 넣어라.
		}
	}

($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "structg : STC - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);

	my $in;

	print "\n\n======== stc.upr START =========\n";
	open(UPR,"<stc.upr");
	while($in = <UPR>){
		if($in =~ /^\#/){
			next;
		}
		if($in =~ /\.stcI/){
			Ichange($in,"");			# OUTPUT안에 저장하고, makefile에도 넣어라.
		} elsif($in =~ /\.stc/){
										# 3번째 인자 : stcL이 아닌 경우는 NULL
			Cchange($in,"","","STC");			# OUTPUT안에 저장하고, makefile에도 넣어라.
		}
	}
	close UPR;

($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "structg : stc.upr - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);

	print_all_global_var("GLOBAL_post_stc.TXT");

			### OUTH에 STAT관련 structure 모음을 정의한다.
		if((keys %stat_typedef)){	# 한개도 STAT가 없으면 이것을 처리하지 않는다.
			print OUTH "\n\ntypedef struct _st_STAT_ALL {\n";
			foreach $def (keys %stat_typedef){
				print OUTH "\t$def 	$staticprefix$def\;\n";
			}
			print OUTH "\} STAT_ALL \;\n";
		}

			### OUTH에 각 structure들의 type definition # , size와 member들의 수를 정의한다.
			print OUTH "\n\n\n\n/* Define.  DEF_NUM(type definition number)\n*/\n";
			foreach $def (keys %typedef_def_cnt){
				my $hex = sprintf '0x%x' ,$typedef_def_cnt{$def};
				my $tab_cnt =  int((47 - length($def . "_DEF_NUM")) /4);
				print OUTH "\#define		$def" . "_DEF_NUM" . "\t"x$tab_cnt . "  $typedef_def_cnt{$def}			/* Hex ( $hex ) */\n"; 	# stAAA  -> #define STG_DEF_stAAA  10 
			}
			print OUTH "\n\n\n\n/* Define.  MEMBER_CNT(struct안의 member들의수 : flat기준)\n*/\n";
			foreach $def (sort keys %typedef_member_count){
				my $tab_cnt =  int((47 - length($def . "_MEMBER_CNT")) /4);
				print OUTH "\#define		$def" . "_MEMBER_CNT" . "\t"x$tab_cnt . "  $typedef_member_count{$def}\n"; 	# typedef struct안의 member들의 수 (flat기준의수)
			}
			
			### OUTH에 함수들을 정의 한다. extern function_definition
			print OUTH "\n\n\n\n#ifndef __FLAT_VOID__\n";
			print OUTH "/* Extern Function Define.\n*/\n";
			#$function_def{$typedef_enc_func{$typedef_name}} = $function_def;
			foreach $def (sort keys %function_def){
				if(not $def =~ /$shortprefix/){
					print OUTH "extern $function_def{$def}\;\n";
				}
			}
			foreach $def (sort keys %flat_function_def){
				print FLATH "extern $flat_function_def{$def}\;\n";
			}
			print OUTH "#endif  /* __FLAT_VOID__*/\n";



			### Flat file.h에도 footer를 추가
            open(UPR,"<footer.upr");
            while($upr = <UPR>){
                $upr =~ s/\+FileName\+/$FlatFileName/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
                $upr =~ s/\+ToDo\+/Makefile을 만들자/;
                $upr =~ s/\+Intro\+/hash header file/;
                $upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
                print FLATH $upr;
            }
			close UPR;


	### Makefile에 include의 dependancy와 각 c file에 대한 compile등에 대해서 만들어준다.
	### %filelist는 사용되는 file들의 list를 가지고 있다. 
	###    	"INC"   : include .h file (for dependancy checking)
	###		"CFILE" : .c file 		(c compile)
	open(MAKE,">$outputdir/Makefile");
	$inc_filelist = "";
	$cfile_filelist = "";
	my $lex_make;
	foreach my $filename ( sort keys %filelist) { 
		if($filelist{$filename} eq "INC"){
			$inc_filelist .= " $filename";
		}
		if($filelist{$filename} eq "CFILE"){
			if(not $filename =~ /$shortprefix/){
				$cfile_filelist .= " $filename";
			}
		}
		if($filelist{$filename} eq "LEXFILE"){
			my $varname;
			$temp = $filename;
			$temp2 = $temp;
			$varname = "TXTPARSE_CASE_IGNORE";		# if   $TXTPARSE_CASE_IGNORE{..} 을 본다.
			if($temp =~ s/(.*)\/(.*)\.l/lex\.$2\.c/){
				$temp1 = $2;
				print "LEX FILE : $temp : $temp2 ($temp1)\n";
				$lex_make .= "$temp : $temp2\n";
				if($$varname{$temp1} eq "YES"){
					$lex_make .= "\tflex -P$temp1 -i $lex_option{$filename} $temp2\n";
				} else {
					$lex_make .= "\tflex -P$temp1 $lex_option{$filename} $temp2\n";
				}
				$lex_make .= "\t\n";
			} elsif($temp =~ s/(.*)\.l/lex\.$1\.c/){
				$temp1 = $1;
				print "LEX FILE : $temp : $temp2 ($temp1)\n";
				$lex_make .= "$temp : $temp2\n";
				if($$varname{$temp1} eq "YES"){
					$lex_make .= "\tflex -P$temp1 -i $lex_option{$filename} $temp2\n";
				} else {
					$lex_make .= "\tflex -P$temp1 $lex_option{$filename} $temp2\n";
				}
				$lex_make .= "\t\n";
			}
		}
		print  MAKE "\#$filelist{$filename}\t::  $filename\n";
	}
			open(UPR,"<makefile.upr");
			while($upr = <UPR>){
				$upr =~ s/\+INCLUDES\+/-I.\//;
				$upr =~ s/\+SRCS\+/$cfile_filelist/;
				$upr =~ s/\+HDRS\+/$inc_filelist/;
				$upr =~ s/\+LEXS\+/$lex_make/;
				$FileNameFirst = $FileName;
				$FileNameFirst =~ s/\.h//;
				$upr =~ s/\+TARGET\+/libSTG$FileNameFirst\.a/;
				print MAKE $upr;
			}
            close UPR;
	close MAKE;


	### Makefile에 include의 dependancy와 각 c file에 대한 compile등에 대해서 만들어준다.
	### %filelist는 사용되는 file들의 list를 가지고 있다. 
	###    	"INC"   : include .h file (for dependancy checking)
	###		"CFILE" : .c file 		(c compile)
    open(MAKE,">$outputdir/OraMake");
    $inc_filelist = "";
    $cfile_filelist = "";
	$sprocfile_filelist = "";
    foreach my $filename ( sort keys %filelist) {
        if($filelist{$filename} eq "INC"){
            $inc_filelist .= " $filename";
        }
        if($filelist{$filename} eq "CFILE"){
			if(not $filename =~ /$shortprefix/){
            	$cfile_filelist .= " $filename";
			}
        }   
        if($filelist{$filename} eq "ProC"){
			if(not $filename =~ /$shortprefix/){
           		$sprocfile_filelist .= " $filename";
			}
        }   
        print  MAKE "\#$filelist{$filename}\t::  $filename\n";
    }
            open(UPR,"<oramake.upr");
            while($upr = <UPR>){
                $upr =~ s/\+INCLUDES\+/-I.\//;
                $upr =~ s/\+PCSRCS\+/$cfile_filelist $sprocfile_filelist/;
                $upr =~ s/\+HDRS\+/$inc_filelist/;
				$upr =~ s/\+LEXS\+/$lex_make/;
				@yh_member_pcs = split(" ",$sprocfile_filelist);
				$yh_members_o = "";
				$yh_members_pc = "";
				$yh_members_lis = "";
				$yh_members_c = "";
				foreach $yh_member_pcs (@yh_member_pcs){
                	$yh_member_pcs =~ s/\.pc//;
					$yh_members_o .= " $yh_member_pcs\.o";
					$yh_members_pc .= " $yh_member_pcs\.pc";
					$yh_members_lis .= " $yh_member_pcs\.lis";
					$yh_members_c .= " $yh_member_pcs\.c";
				}
               	$upr =~ s/\+PCOBJ\+/$yh_members_o/;
                $upr =~ s/\+PCFILE_C\+/$yh_members_c/;
                $upr =~ s/\+PCFILE_LIS\+/$yh_members_lis/;
				$FileNameFirst = $FileName;
				$FileNameFirst =~ s/\.h//;
                $upr =~ s/\+PCTARGET\+/libSTGPC$FileNameFirst\.a/;
                print MAKE $upr;
            }
            close UPR;
    close MAKE;

	foreach my $key (keys %table){
		my $ret = 0;
		my $comp;
		#print $key . "\n";
		#$comp = "$shortprefix" . "COMBI_";
		#if($key =~ /$comp/){ $ret = 1; }
		#$comp = "$shortprefix" . "LOG_";
		#if($key =~ /$comp/){ $ret = 1; }
		#$comp = "$shortprefix" . "CF_";
		#if($key =~ /$comp/){ $ret = 1; }
$ret = 1;
		if(1 eq $ret){
			my @member_vars;
			$comp = $key;
			$key = $shortprefix . $key;
			#$comp =~ s/^$shortprefix//g;
			print DBG "DB CREATE = " . $key . "\n";
			print DBG $flat_typedef_contents{$key} . "\n";
			open(SQL,">$outputdir/tmp/DB/$comp" . "\.sql");
			if($comp =~ /^\s*STAT\s*/){
				print_fp("create table " . $comp . "\n\(\n" , SQL,DBG);
			}
			else {
				print_fp("create table " . $comp . "\n\(\n" , SQL,DBG);
			}
			@member_vars = split(";",$flat_typedef_contents{$key});
			foreach my $member_vars (@member_vars){
				if($member_vars =~ /\s*(\w+)\s+(\w+)\s*\[(\d*)\]/){	##  [] array로 선언될때의 처리
					my $vartype = $1;
					my $varname = $2;
					my $asize = $3;
					print DBG "=$vartype  $type_define{$vartype}  =$varname  =$type_CREATE{$vartype} \( $asize \) \n";
					$varname =~ s/$shortremoveprefix//g;
					print_fp("\t$varname 	$type_CREATE{$vartype}\($asize\)	\,\n",SQL,DBG);
				} 
				elsif($member_vars =~ /\s*(\w+)\s+(\w+)/){			## []이 없을때의 처리 
					my $vartype = $1;
					my $varname = $2;
					print DBG "=$vartype  $type_define{$vartype}  =$varname  =$type_CREATE{$vartype}\n";
					$varname =~ s/$shortremoveprefix//g;
					$temp = "ANALYSIS_$comp\_STG_PARM_SQL_NUMBER_SIZE";
					print DBG "SQL =$varname  : $temp : $$temp{$varname}\n";
					if($$temp{$varname}){
						print_fp("\t$varname		$type_CREATE{$vartype} ( $$temp{$varname} )	\,\n",SQL,DBG);
					} else {
						print_fp("\t$varname		$type_CREATE{$vartype} ( 10 ) 	\,\n",SQL,DBG);
					}
				}
			}
			$temp = "ANALYSIS_SQL_TABLESPACE_STG_TYPEDEF";
			if($$temp{$comp}){
				print_fp("\tInsertTime		VARCHAR2(14)\n\)\ntablespace $$temp{$comp}\n\;\n" , SQL,DBG);
			} else {
				print_fp("\tInsertTime		VARCHAR2(14)\n\)\ntablespace tcp\n\;\n" , SQL,DBG);
			}
			close(SQL);
		}
	}
close DBG;

			### footer.upr(generic footer form for doxygen)
			### 생성되는 각 file의 끝 부분에 삽입할 일반적 내용
			###
			###   변수들을 +...+ 으로 정의하여 사용한다. 바꿔주는 부분은 아래와 같은 방식을 따른다.
			### footer.upr을 읽어서 .h file의 file footer 부분을 장식한다.
			### $upr =~ s/\+ToDo\+/Makefile을 만들자/;  식으로 필요한 부분들을 대치 시키면 되게 설계를 한 것이다.
			open(UPR,"<footer.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$FileName/;
				$upr =~ s/\+Warning\+/\$type???로 정의된 것들만 사용가능/;
				$upr =~ s/\+ToDo\+/Makefile을 만들자/;
				$upr =~ s/\+Intro\+/hash header file/;
				$upr =~ s/\+Requirement\+/규칙에 틀린 곳을 찾아주세요./;
				print OUTH $upr;
			}
			close UPR;
$temp = $FileName;
$temp =~ s/\./\_/;
print OUTH "\#endif	\/* __" . $temp . "__*\/\n";
close OUTH;

($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "structg : END - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);
close(TIME_DBG)


## NTAM을 위한 것은 한개를 더 돌려서 header file을 한개 더 만드는 것으로 하자.
## NTAM용으로 perl을 한개 더 만들어서, 만든 header file을 stg로 돌리면 같은 값이 나오게만 하면 될 것으로 보인다. 

## 
## $Log: structg.pl,v $
## Revision 1.244  2007/05/31 01:19:04  cjlee
## add the space for indent of tabs
##
## Revision 1.243  2007/05/30 05:27:37  tjryu
## add the space in the define definition
##
## Revision 1.242  2007/04/26 00:27:28  cjlee
## bug : multiple digit in case of ---- ++++
##
## Revision 1.241  2007/04/16 05:34:27  cjlee
## 내용  : Reload the GLOBAL.TXT files
##     Make the ASN PER's init file
##
## Revision 1.240  2007/04/02 13:09:12  cjlee
## add the comments function in the pstg and stg's file
## ex)
## ##Stc_.....
##
## Revision 1.239  2007/03/30 01:14:44  cjlee
## typedef struct 의 번호 Fix 가능
##
## Revision 1.238  2007/03/29 00:43:47  yhshin
## 1.235 원복
##
## Revision 1.235  2007/03/28 11:51:04  cjlee
## *** empty log message ***
##
## Revision 1.234  2007/03/28 01:03:35  cjlee
## state_diagram 예제 추가
##
## Revision 1.233  2007/03/27 12:57:07  cjlee
## state_diagram 추가
##     - 기존의 TAG_FLOW와 같은 기능을 하는 것임.
##     - 새로운 요구사항을 추가하고, 기존의 것도 그대로 지원하기 위해서 STATE_DIAGRAM 으로 새로 만듦
##     - <STATE_DIAGRAM_VERTEX:..> </STATE_DIAGRAM_VERTEX:..>  과
##       <STATE_DIAGRAM_EDGE:..> </STATE_DIAGRAM_EDGE:..> 가 같이 존재해야함
##     - Example : make sd  하면 됨.  (state_diagram.pstg와 아래의 stc들을 이용하게 됨)
##
## Revision 1.232  2007/03/27 01:36:47  cjlee
##  ProC (pc) file들을 OraMake에 제대로 추가 하기 위해서
##
## Revision 1.231  2007/03/26 08:17:21  cjlee
## *** empty log message ***
##
## Revision 1.230  2007/03/23 13:54:12  cjlee
## SQL관련 여러가지 값들 추가
##
## Revision 1.229  2007/03/22 12:20:38  cjlee
## define에도 STG_PARM 가능하게 함
##
## Revision 1.228  2007/03/20 06:38:33  cjlee
## TIME DEBUG를 더 효율적으로
##
## Revision 1.227  2007/03/20 03:30:11  cjlee
## print_all_global_var의 수행위치 바꿈
##
## Revision 1.226  2007/03/20 02:33:36  cjlee
## stc관련 성능 개선
##
## Revision 1.225  2007/03/16 11:07:09  cjlee
## DB라는 이름으로 기존의 flat에서 처리하던 SQL관련 내용들 stc로 만듦
##
## Revision 1.224  2007/03/16 07:21:40  cjlee
## split 문제 해결
##
## Revision 1.223  2007/03/16 06:24:11  cjlee
## *** empty log message ***
##
## Revision 1.222  2007/03/16 00:57:32  cjlee
## IFEQUAL에 2가지 모양가능하게 기능 추가
##
## Revision 1.221  2007/03/15 11:33:24  cjlee
## - IFEQUAL에 || , &&  문법 추가
## 		한 종류만 있어야함.
## - #???_DEBUG 라는 것으로 DBG에 print하는 부분을 상당수 막음.
##
## Revision 1.219  2007/03/15 04:40:22  cjlee
## SQL을 stc보다 먼저 수행 하게 변경
##
## Revision 1.218  2007/03/15 04:11:38  cjlee
## #== SQL과 WEB에서 이용할수 있는 값들을 만들어준다.  <<<<<  START
## #== SQL과 WEB에서 이용할수 있는 값들을 만들어준다.  <<<<<  END
## 	와 이와 관련된 함수 추가
## GLOBAL.TXT에 SQL_ARRAY_{typedef 이름}  으로 부터 시작되는 값들을 산출함.
## SQL  은 Short name 기분으로 산출됨
##
## Revision 1.217  2007/03/13 04:18:43  cjlee
## *** empty log message ***
##
## Revision 1.216  2007/03/13 04:12:05  cjlee
##  Mantis : [해결] 0000312 :  SB_PASING 코딩 줄이기
##
## Revision 1.215  2007/03/12 07:03:04  cjlee
## sql 문제 해결
##
## Revision 1.214  2007/03/09 08:14:49  cjlee
## NotIFEQUAL --> NOTEQAUL 로 수정 (reserved word가 포함되는 구조니깐 골치 아픔)
##
## Revision 1.213  2007/03/09 06:48:29  cjlee
## 다중 IFEQUAL 처리 & inc/dec 기능 추가
##
## Revision 1.212  2007/03/07 05:35:29  cjlee
## ProC (pc)도 file 한개로 수정
##
## Revision 1.211  2007/03/07 05:26:58  cjlee
## *** empty log message ***
##
## Revision 1.210  2007/03/07 05:15:21  cjlee
##  각 file로의 structure의 Prt, Dec , Enc , cilog를 한개씩의 file로 모음
##
## Revision 1.209  2007/03/06 11:46:30  yhshin
## *** empty log message ***
##
## Revision 1.208  2007/03/06 11:44:07  yhshin
## *** empty log message ***
##
## Revision 1.207  2007/03/06 10:36:17  cjlee
## *** empty log message ***
##
## Revision 1.206  2007/03/06 10:20:59  cjlee
## *** empty log message ***
##
## Revision 1.205  2007/03/06 09:42:42  cjlee
## lex관련 error 해결(Makefile)
##
## Revision 1.204  2007/03/06 08:22:41  cjlee
## 내용  : STC HD DB 등으로 directory를 누었음.
##     stcI 의 file들 (기본적으로 default로 들어가는 것들)을 STC아래 생성되게 바꿈
##
## Revision 1.203  2007/03/06 04:27:24  cjlee
## SQL 관련 변수 길이 및 table space 이름 추가
##
## Revision 1.202  2007/03/06 00:10:06  yhshin
## IP4 type U32로
##
## Revision 1.201  2007/03/05 07:56:43  cjlee
## *** empty log message ***
##
## Revision 1.200  2007/03/05 07:54:26  yhshin
## *** empty log message ***
##
## Revision 1.199  2007/03/05 07:47:39  cjlee
## *** empty log message ***
##
## Revision 1.198  2007/03/02 07:21:53  cjlee
## REVERSE ARRAY ITERATOR 추가
##
## Revision 1.197  2007/02/28 01:45:02  cjlee
## ANALYSIS 관련 여러 값 추가 (type , member_full )
## STG_PAR_ARRAY 관련 여러 값 추가 (_NEXT_)
##
## Revision 1.196  2007/02/27 08:01:45  cjlee
## 내용  :  EDGE 수행 변경
## - EDGE를 수행할때 , current_state 2 next_state 로 계산을 했던 것을
## 	--> current_state _CONDITION_  if_value로 하여 조건으로 처리하도록 변경함.
##
## Revision 1.195  2007/02/26 12:21:58  yhshin
## ANALYSIS_\_STG_TYPEDEF 선언
##
## Revision 1.194  2007/02/26 10:41:06  cjlee
## STG_PAR_ARRAY 으로 원하는 변수들을 생성키실수 있게 해줌.
##
## Revision 1.193  2007/02/26 04:24:19  cjlee
## - FileName : ....   을 이용한 다른 directory에 file을 생성 가능
## - stcI_FILEPREFIX : ....   을 이용한 다른 directory에 file을 생성 가능
##
## Revision 1.192  2007/02/23 11:27:19  cjlee
## stc의 결과가 *.c *.cpp *.pc 에만 #include <자신.h> 를 추가히켜줌
##
## Revision 1.191  2007/02/23 05:58:11  cjlee
## bug fix
##
## Revision 1.190  2007/02/22 08:04:02  cjlee
## ONETIME
##
## Revision 1.189  2007/02/21 08:16:08  cjlee
## TABLE_LOG와 같이 앞에 마음대로 선언이 가능하게
## STG_TYPEDEF 의 기능 추가
##
## Revision 1.188  2007/02/20 11:16:19  cjlee
## stcI에 postfix , prefix filename 추가
##
## Revision 1.187  2007/02/20 10:51:09  yhshin
## OraMake 를 위한 // 주석 삭제
##
## Revision 1.186  2007/02/20 10:21:14  cjlee
## SIZE에는 ARRAY의 마지막 번호를...
##
## Revision 1.185  2007/02/20 09:43:18  yhshin
## LEXS
##
## Revision 1.184  2007/02/20 08:43:20  cjlee
## ARRAY_SIZE hash값 추가
##
## Revision 1.183  2007/02/20 07:28:24  cjlee
## *** empty log message ***
##
## Revision 1.182  2007/02/20 07:26:14  cjlee
## *** empty log message ***
##
## Revision 1.181  2007/02/20 07:25:45  cjlee
## *** empty log message ***
##
## Revision 1.180  2007/02/20 07:20:34  cjlee
## 주석처리변경
##
## Revision 1.179  2007/02/20 03:47:09  cjlee
## STG_PARM 기능 추가
##
## Revision 1.178  2007/02/16 04:52:15  cjlee
## FLOW에서 VERTEX와 EDGE로 구분되어 처리됨
##
## Revision 1.177  2007/02/01 01:41:13  cjlee
## 3. 내용  : stc / stcI 의 처리 문제 해결
## - stc input file들에서 stc를 stcI 보다 우선순위를 높게 되어져있고,
## 	stc , stcI를 모두 처리하게 된다.
## - 수정 : stcI를 먼저 처리하고 , stcI가 되면 stc는 하지 않는다.
##
## Revision 1.176  2007/01/16 06:00:02  cjlee
## stcI 에서 file Prefix 기능 추가
##
## Revision 1.175  2007/01/16 01:34:57  cjlee
## BIT 관련 처리 / SB_PARSING 처리 추가
##
## Revision 1.174  2006/11/27 10:50:26  cjlee
## doxygen
##
## Revision 1.173  2006/11/27 06:58:47  cjlee
## *** empty log message ***
##
## Revision 1.172  2006/11/27 06:57:44  cjlee
## doxygen
##
## Revision 1.171  2006/11/27 06:54:22  cjlee
## *** empty log message ***
##
## Revision 1.170  2006/11/16 06:16:20  cjlee
## typedef_def_cnt 초기화 변경 : 100으로 set하였으니 101부터 시작할 것이다.
##
## Revision 1.169  2006/11/15 07:30:57  cjlee
## *** empty log message ***
##
## Revision 1.168  2006/11/15 07:02:32  cjlee
## TAG 내용
## CHECKING_VALUE 내용 을 log_table.html에서 찍기 위해서 (log_table.stc0
##
## lex_option추가   : Lex_Compile_Option
## BODY의 경우 -i option이 필요하기 때문임
##
## Revision 1.167  2006/11/13 08:05:26  cjlee
## - structg.pl
## 	@CHECKING_VALUE:string , string...@
## 	@CHECKING_VALUE:digit~digit , digit~digit...@
## 	를 추가함으로써 CILOG의 값이 제대로 되는지를 check할수 있다.
## - aqua.pstg
## 	예제 추가   $ make aqua
## 	GLOBAL.TXT 가 AQUA2/TOOLS/HandMade 에서 필요함.
##
## Revision 1.166  2006/11/11 08:27:47  cjlee
## TAG_DEF_ALL_NUM_  변수 추가
##
## Revision 1.165  2006/11/11 07:10:56  cjlee
## log_table.html의 문제 해결 (번호가 HIDDEN이 반영되지 않음)
##
## Revision 1.164  2006/11/11 04:35:13  cjlee
## ASSOCIATION 에 ALTERNATIVE_ASSOCIATION을 추가함.
##
## Revision 1.163  2006/11/10 06:50:35  cjlee
##   /*  +<+$TAG_DUAL_STRING_ITKEY_L1IT1VALUE_string{0}+>+   */
##   을 추가하여 debugging을 위한 정보를 넣게 됨.
##
##   CLEX_ITKEY_Depth5() 추가
##
## Revision 1.162  2006/11/10 01:10:07  cjlee
## *** empty log message ***
##
## Revision 1.161  2006/11/09 13:14:28  dark264sh
## *** empty log message ***
##
## Revision 1.160  2006/11/09 10:51:58  dark264sh
## *** empty log message ***
##
## Revision 1.1  2006/11/09 08:14:09  dark264sh
## *** empty log message ***
##
## Revision 1.159  2006/11/09 06:16:35  cjlee
## CLEX 기능 추가
##
## Revision 1.158  2006/11/07 05:33:43  cjlee
## HIDDEN은 찍지 않게
##
## Revision 1.157  2006/11/07 00:52:56  cjlee
## flow에서 GEt_Member_..() 함수를 call하는 부분을 없앰
##
## Revision 1.156  2006/11/03 09:31:44  cjlee
## ANALYSIS_$typedef_name\_TABLE_COMMENTS 이란 GLOBAL 변수 이름 추가
##
## Revision 1.155  2006/11/02 01:17:34  cjlee
## ITERATE에서 HASH(%) 와 ARRAY(@) 모두 되게 추가하였음.
## ARRAY --> cilog.stc를 참조하시요
## 그 외의 *.stc안에는 HASH를 이용하게 되어져있음.
## array를 사용하는 이유 : 순서를 가져야 할때
## array 특징 : KEY는 0..? 하는 index , VALUE가 그 안의 값이다.
##
## Revision 1.154  2006/11/01 09:44:37  cjlee
## PARSING_CASE_IGNORE 추가 : flex의 case insensitive하게 -i option 처리
##
## Revision 1.153  2006/11/01 05:23:42  cjlee
## *** empty log message ***
##
## Revision 1.152  2006/11/01 04:42:22  cjlee
## STRING type추가
##
## Revision 1.151  2006/11/01 01:29:20  cjlee
## - CILOG_HIDDEN 추가 : Dummy 로 찾으면 한개 나올 것입니다. (aqua.pstg)
##    @은 typedef안에서만 특별한 의미를 가짐 (CILOG_HIDDEN)
##    $ 은 전구간에서 특별한 의미를 가짐 (CASE_IGNORE)
## - cilog.stc 추가 (CILOG를 위해서)
## - DiffTIME64 변경
## - STIME찍을때 변경 (0이면 1970년이 아닌 0으로)
## - make tt 추가 (예제를 위해서)
##
## Revision 1.150  2006/10/30 09:00:53  cjlee
## if_var if_val을 어떤 값이든 쓸수 있게 변경
##
## Revision 1.149  2006/10/30 08:43:57  cjlee
## pINPUT으로 fix
##
## Revision 1.148  2006/10/30 00:46:56  cjlee
## CASE_IGNORE적용
##
## Revision 1.147  2006/10/27 06:33:33  cjlee
## flow관련 버그 수정
##
## Revision 1.146  2006/10/27 02:56:55  cjlee
## TAG_FLOW에서 pINPUT , pTHIS로 fix시키며 struct 이름을 받게 변경하였음.
##
## Revision 1.145  2006/10/20 07:53:20  cjlee
## strcmp -> strncmp
##
## Revision 1.144  2006/10/19 08:51:46  cjlee
## *** empty log message ***
##
## Revision 1.143  2006/10/19 04:05:27  cjlee
## tag_auto_define에서 뒤에 (숫자)을 주어도 잘 처리하게 바꿈.
## bug fix
##
## Revision 1.142  2006/10/16 08:47:47  cjlee
## flow 반영중
##
## Revision 1.141  2006/10/13 03:33:18  cjlee
## *** empty log message ***
##
## Revision 1.140  2006/10/13 03:22:38  cjlee
## SVCACTION
##
## Revision 1.139  2006/10/12 06:02:28  cjlee
## STG_Diff64    S64로 선언 해결
##
## Revision 1.138  2006/10/12 02:28:26  cjlee
## TAG_DEF관련 변경
## - TAG_DEF_ALL 로 해서 모든 DEF관련 선은 모았으며
## - TAG_DEF  , TAG_AUTO_DEF , TAG_AUTO_STRING_DEF  로 각기 선언된대로 구별도 해주었으며
## - TAG_AUTO_STRING_SEF의 경우는 2개의 string 쌍을 위해서 TAG_DUAL_STRING으로 정의를 추가하였음.
##
## Revision 1.137  2006/10/10 07:09:11  cjlee
## Compare 추가
##
## Revision 1.136  2006/10/10 02:49:23  cjlee
## *** empty log message ***
##
## Revision 1.135  2006/10/10 01:52:55  cjlee
## *** empty log message ***
##
## Revision 1.134  2006/10/10 01:45:41  cjlee
## *** empty log message ***
##
## Revision 1.133  2006/10/10 01:40:00  cjlee
## FPP 추가 (FILEPRINT
##
## Revision 1.132  2006/10/10 01:34:37  cjlee
## STIME IP4의 print문 변경
##
## Revision 1.131  2006/10/10 01:09:52  cjlee
## FPP 추가 (FILEPRINT) - 기본틀
##
## Revision 1.130  2006/10/10 01:08:48  cjlee
## FPP 추가 (FILEPRINT) - 기본틀
##
## Revision 1.129  2006/10/10 01:03:04  cjlee
## 1.27로 복귀
##
## Revision 1.127  2006/10/02 01:22:00  cjlee
## 버그 수정 : tag_key때문에 TAG_DEFINE관련 정의 사라지는 것 방지
##
## Revision 1.126  2006/09/29 08:56:52  cjlee
## TAG_FLOW에서 범위와 / * 처리 추가 및 범위 지정 가능
## - thisLOG->ResponseCode/1000
## - thisLOG->ResponseCode*1000  의 2가지 operation이 가능하며
## - 300 이란 값 뿐만 아니라 ,  300-400 등의 값의 지정도 가능하다.
##
## Revision 1.125  2006/09/29 06:25:53  cjlee
## *** empty log message ***
##
## Revision 1.124  2006/09/29 02:35:36  cjlee
## STC도 같이 compile되게 OUTPUT/Makefile안에 같이 넣음
##
## Revision 1.123  2006/09/28 02:49:12  cjlee
## NIPADDR -> HIPADDR
##
## Revision 1.122  2006/09/27 00:54:28  cjlee
## *** empty log message ***
##
## Revision 1.121  2006/09/27 00:41:38  cjlee
## tag_key에 대해서도 save_typedef를 돌림
##
## Revision 1.120  2006/09/26 08:01:15  cjlee
## STG_ASSOCIATION관련 compile 완료
##
## Revision 1.119  2006/09/26 07:27:24  cjlee
## STG_ASSOCIATION 추가
## - STG_COMMON -> STG_ASSOCIATION으로 변경
## - pstg.pl에서 <TAG_KEY> 처리 삭제
## - ASSOCIATION을 위한 ASSOCIATION.stcI 기본 추가
##
## Revision 1.118  2006/09/26 01:13:58  dark264sh
## S32, U32를 HEXA값을 찍던 것을 10진수로 찍도록 변경
##
## Revision 1.117  2006/09/25 06:07:04  dark264sh
## dAppLog를 찍기 위해서
## FPRINT(stdout,
## =>
## FPRINT(LOG_LEVEL,
## 로 변경
##
## Revision 1.116  2006/09/21 08:39:06  cjlee
## define에 대한 abbreviation name 제공 : PRINT...함수
##
## Revision 1.115  2006/09/21 07:22:52  cjlee
## URL 및 parameter 처리 완료
##
## Revision 1.114  2006/09/21 05:40:21  cjlee
## METHOD중복삭제
## TAG_DEFINE 관련(AUTO포함) 중복 선언 에러 추가
##
## Revision 1.113  2006/09/21 04:32:29  cjlee
## 1. CHANNEL 값이 제대로 안 나옴.
## 2. HTTP_LOG에서 METHOD와 같이 공통으로 여러개가 들어가게 처
##
## Revision 1.112  2006/09/20 06:01:50  cjlee
## %function_def에 PARSING_RULE관련 ACTION 추가 (처음에 수행도 되게 추가)
##
## Revision 1.111  2006/09/20 01:26:33  cjlee
## ALTERNATIVE_RULE의 여러 형태 처리 완료
##
## Revision 1.110  2006/09/19 02:42:24  cjlee
## WIPI download  시험위한 내용추가
##
## Revision 1.109  2006/09/08 06:14:33  cjlee
## var_array_size에서 %define_digit안에 없으면 이름 그대로 사용하게 함
##
## Revision 1.108  2006/09/08 05:27:42  cjlee
## Configuration File 처리
##
## Revision 1.107  2006/09/07 06:23:46  cjlee
## stcI 관련 추가
##
## Revision 1.106  2006/09/07 00:28:26  cjlee
## debugging
##
## Revision 1.105  2006/09/06 09:14:27  cjlee
## bug 수정 : GET_TAG_DEF... 함수
##
## Revision 1.104  2006/09/06 08:21:12  cjlee
## *** empty log message ***
##
## Revision 1.103  2006/09/06 08:16:25  cjlee
## GET_TAG_DEF 추가
##
## Revision 1.102  2006/09/06 06:56:03  cjlee
## <TAG_KEY> 어디서 사용할수 있게 추가
## structg.pl 에서도 이것을 보면 처리할수 있게 해준다. : 여기서는 .h에만 추가
## pstg.pl 에서도 뒤에 추가해주지만, structg.pl을 또 돌려야 하므로 이 KEY들로 정의된 여러가지 strucuture들의 dec,enc,prt등의 다양한 함수들이 제공되어짐.
##
## Revision 1.101  2006/09/06 01:15:40  cjlee
## reducing the print statement
##
## Revision 1.100  2006/09/06 01:13:30  cjlee
## 디버깅 : membertype이 structure인 경우에는 Get_Member.. 에서 제외 -> 그래야 userfile.stg같은 것의 library compile시 에러 발생하지 않음
##
## Revision 1.99  2006/09/05 06:49:12  cjlee
## TAG_AUTO 관련 처리 완료 : compile 완료
##
## Revision 1.98  2006/09/05 05:46:21  cjlee
## TAG_AUTO_STRING_DEFINE_START  추가
## : STRING  DEFINE문자  로 구성되어지며
##   DEFINE된 것들에 자동으로 번호가 붙으며,
##   STRING 문자 관련된 함수들이 만들어집니다.
##   Print_TAG_STRING_???(debug str , char *string)
##
## Revision 1.97  2006/08/29 04:06:18  cjlee
## BIT 처리 완료 : compile 완료
##
## Revision 1.96  2006/08/29 02:21:31  cjlee
## BIT operation 추가
## 	BIT16			a1 (1 : PING);				/**< TOS의 첫번째 bit */
## 	BIT16			ctime (12 : PING);			/**< TOS 마지막 3개의 bit */
## 	BIT16			b ( 3 : PING);
##
## 결과물 : flat , Dec , Enc , Prt 모두 변형됨
##
## Revision 1.95  2006/08/25 08:33:21  cjlee
## make flow , make test를 모두 가능하게 함.
## 처음에 include를 삽입함 . STC결과가 *.l일 경우는 include를 삽입하지 않음.
##
## Revision 1.94  2006/08/25 07:11:29  cjlee
## LOG_member_Get_func.stc : include L7.h추가 (header는 알아서 추가를 해야 할 것으로 보임)
## 	include를 자동으로 하면 .l 에서는 에러가 발생함.
## makefile.stc : LOG_KUN.stc에서와 같이 .l을 생성시키는 것들에 대해서 자동으로 makefile안에 삽입하게 변경
## 	STC안에서 make echo를 하고 나온 것에 대해서 make .. 하면 실행 화일이 만들어짐
## test.pstg : ME , KUN과 같은 PARSING을 포함하는 것들에 대해서 Makefile까지 자동으로 만들게 함.
## structg.pl :
## 	IFEQUAL과 반대로 수행되는 NOTEQUAL 추가
## 	안의 변수들의 이름이 AAa.l등이 처리되게 바꿈
## 	치환 관련된 부분을 replace_var_with_value 함수로 모음
## 	GLOBAL_Pre_STC.TXT 추가 : STC를 수행하기 전의 global 변수의 값들
##
## Revision 1.93  2006/08/23 01:32:56  cjlee
## *.stc안의 IFEQUAL 뒤의 multi-line 처리 완료
## #{    ...   }# 으로 multi-line 처리
## 기존의 한라인은 IFEQUAL(A,B)  ... 으로 예전과 같이 그냥 사용하면 됨
## multi-line일때만 위의 #{ .. }#을 사용하면됨.  flow.stc안에 예제 추가하였음.
##
## Revision 1.92  2006/08/22 09:17:24  cjlee
## <TAG_FLOW_START:PAGE>에서 action에 대한 multi line 처리 완료
## % .. %   # .. # 한줄일때는 # # 으로 처리
## 여러줄일때는 #{     여러줄    }# 으로 끝을 알림
##
## Revision 1.91  2006/08/22 05:34:26  cjlee
## 2. stg를 multi로 처리할수 있게 수정 stg들의 모음이 있을경우에는 이것들을 쫙 처리할수 있는 stgl을 만들던지 해야 할 것으로 보인다. (입력 file이 stgl 인 경우에는 List로 해석하여 처리하도록 structg.pl 을 수정하면 될 것으로 보인다.) - precompile관련까지 추가를 하는 것이 좋을 것으로 보인다.
## 한개로 모아주는 것이 맞을 것이라 생각된다. FileName으로 .h가 새로 생성이 되는 것이고, stg안에 있는 FileName은 무시 되게 될 것이다.
## test.stg , flow.stg가 있다고 하면 __ FileName은 무시 , STC_FileName 은 합치고 ,
## *.stg에 나온 것들을 FileName.h -> $outputdir/FileName.stg로 모은다. 이 모아진 것을 가지고 처리를 한다.
##
## Revision 1.90  2006/08/22 04:37:29  cjlee
## *.h안에 #ifndef  __filename_h__  을 이용하여 같은 .h를  include해도 문제가 되지 않게 했음.
##
## Revision 1.89  2006/08/22 02:10:11  cjlee
## #define문 처리 변경 : 예전 형식 + TAG있을때로
##
## Revision 1.88  2006/08/22 01:28:31  cjlee
## 1. precomile을 해야하는 것들에 대한 확장자는 .pstg 로 하는 것이 좋을 것으로 보인다. 이것을 하면 확장자가 .stg로 나오게 하면 될 것으로 보인다.
## 	pstg.pl 생성
## 	pstg용 file들 : test.stg -> test.pstg  , aqua.stg -> aqua.pstg
## 	Makefile에 flow , aqua , test  여러기지 추가
##
## Revision 1.87  2006/08/21 10:57:26  cjlee
## Page state diagram TEST main program 완료
##
## Revision 1.86  2006/08/21 07:30:44  cjlee
## PAGE
##
## Revision 1.85  2006/08/21 04:47:23  cjlee
## for PAGE TEST
##
## Revision 1.84  2006/08/21 02:20:17  cjlee
## debugging
##
## Revision 1.83  2006/08/21 01:29:25  cjlee
## $save_typedef에서 member check시 table_log 일때만 다른 type일때 die
##
## Revision 1.82  2006/08/18 10:29:34  cjlee
## stc.upr을 만들어 .stc를 기록하면 OUTPUT밑에 자동으로 생성하게 하는 것 추가
##   예로 LOG_member_Get_func.stc 를 추가
## flow.stc : state_go , print_state등의 함수를 추가했으며, flow.c에  structure에 관계없이 member의 값을 구할수 있는 c++에서 member get함수 사용
## flow.stg : state들에 대한 define값 자동 생성 선언
## structg.pl :
##  - stc.upr을 위한 처리 추가
##  - ITERATE안에서 Set : A { B } = "C" 추가
##  - stc.upr의 것들은 OUTPUT아래 바로 생성되게 함
##  - stc.upr안의 것은 Makefile에 추가하게 함
##  - Set Hash 1 에서만 수행됨.... (수행 순서)
##  - 처리 순서 변경 : Makefile등 만들고 STC처리 --> STC 처리후 Makefile 등을 생성
##  - %save_typedef_member  , %save_typedef_name 추가 생성 : LOG_member_Get_func.stc에서 사용
##
## Revision 1.81  2006/08/17 09:46:37  cjlee
## 화면 print 를 DBG로 변경
##
## Revision 1.80  2006/08/17 09:42:15  cjlee
## PAGE FLOW 관련 기본 모양 완료
## flow.stg / flow.stc 쌍
##
## Revision 1.79  2006/08/16 11:20:42  cjlee
## SET_DEF_START_NUM :     명령어 추가
##
## Revision 1.78  2006/08/16 08:53:46  cjlee
## State Diagram을 제대로 그릴수 있게수정
## structg.pl 에서는 $1, $2의 문법 순서 변경
##
## Revision 1.77  2006/08/16 05:46:07  cjlee
## IFEQUAL 추가
## Flow 그림 추가 : flow.stg , flow_dot.stc
##
## Revision 1.76  2006/08/07 06:41:24  cjlee
## 외부의 것을 차용하는 것도 가능하게함.
## 없으면 Warning : 으로 뿌려주게함.
##
## Revision 1.75  2006/08/07 06:33:57  dark264sh
## no message
##
## Revision 1.74  2006/08/07 06:30:23  cjlee
## 외부의 것을 차용하는 것도 가능하게함.
## 없으면 Warning : 으로 뿌려주게함.
##
## Revision 1.73  2006/08/07 06:27:25  dark264sh
## no message
##
## Revision 1.72  2006/08/01 05:38:53  cjlee
## BODY 완료
##
## Revision 1.71  2006/07/31 12:01:22  cjlee
## integer , string 변환 완료. (각 경우 만족)
## LOG_ME가 제대로 , LOG_KUN은 변경해야 함.
##
## Revision 1.70  2006/07/31 06:39:04  cjlee
## precompile이 되게 함.
## KUN , ME에 대해서 call 관련 structure에 대한 처리 완료
## structg.pl -> input : argv , output : 안의 FileName : 으로 된 것
## structg_precompile1.pl -> input : pre.stg , output : userfile_pre.stg
## make pre --> input : pre.stg , output : userfile_pre.stg
##
## Makefile안을 보면 좀더 상세히 알수 있음.
##
## Revision 1.69  2006/07/28 04:42:25  cjlee
## no message
##
## Revision 1.68  2006/07/27 11:01:04  cjlee
## STG_COMMON 수행전  (설계 까지 완성 : README.TXT)
## LOG_TEXT_PARSING까지 일단 마무리
##
## Revision 1.67  2006/07/27 01:58:29  cjlee
## <TAG_DEFINE_START: ....>  <TAG_DEFINE_END:...> 처리 완료
## 의견: 이런 HTML모양은
##     <TAG_DEFINE:.....>  </TAG_DEFINE>
##
## Revision 1.66  2006/07/26 03:28:36  cjlee
## no message
##
## Revision 1.65  2006/07/26 03:27:32  cjlee
## <TAG_DEFINE_START:AAA>
## #define ....
## .... (숫자만)
## <TAG_DEFINE_END:AAA>
## 로 정의하고
## U32 <AAA>TTT;   이런 식으로 사용하면 주석등이 자동으로 붙는다.
##
## Revision 1.64  2006/07/26 02:20:43  cjlee
## #define이 typedef 안이든 밖이든 모두 처리 가능
##
## Revision 1.63  2006/07/25 06:01:27  cjlee
## no message
##
## Revision 1.62  2006/07/25 04:12:59  cjlee
## *** empty log message ***
##
## Revision 1.61  2006/07/25 04:04:10  cjlee
## *** empty log message ***
##
## Revision 1.59  2006/07/25 01:36:47  dark264sh
## *** empty log message ***
##
## Revision 1.58  2006/07/25 01:19:33  dark264sh
## *** empty log message ***
##
## Revision 1.57  2006/07/24 11:13:16  cjlee
## Set_Value 추가
##
## Revision 1.56  2006/07/24 06:50:53  cjlee
## $iterate_comments = ON/OFF 로써 iterate처리를 한 부분의 주석을 넣을지를 결정
## lex에서는 이 주석부분을 처리하지 못해서
## Lex예제에서는
## SET : iterate_commnets = OFF   ,  ON을 해주는 것이 있다.
##
## Revision 1.55  2006/07/23 23:56:46  cjlee
## MIDC에서 시작 : TEXT Parsing추가. stc style 추가
##
## Revision 1.54  2006/06/14 04:40:32  cjlee
## 변경내용  : STAT관련 처리 변경 (각 structure관련 함수의 인자 및 구조 번경)
##         -  structg.pl
##                 STAT관련 처리 추가 : Once , Accumulate 변경  (인자 및 구조 변경)
##                 stat_function 함수 추가 (Accumualate, Once 파일 / 함수들 생성)
##                 STAT_ALL을 STAT가 정의되어져있을때만 선언하게 됨.
##
## Revision 1.53  2006/06/13 07:45:56  mungsil
## *** empty log message ***
##
## Revision 1.52  2006/06/13 07:35:08  cjlee
## 변경 내용  : STAT관련 처리 변경
## 	table 명 %s 없앰.
## 	accumulate , once 변경 : STAT_ALL 추가
## 	- pc.upr
## 		table명에 %s를 STAT일때만 _%s를 없앰.
## 	-  structg.pl
## 		STAT관련 처리 추가 : Once , Accumulate 변경
## 		_%s 처리 변경 : table명
## 	- userfile.stg
## 		STAT 내용 변경 : ACCU.. .INC에서만 타 table의 내용 사용가능
## 		자체 적인 것 안에서는 pthis만 사용가능
##
## Revision 1.51  2006/06/09 03:31:15  cjlee
## 		STG_STAT_TABLE 추가
## 		STAT관련 결과로 Set_Stat_Once.c 를 더 추가로 내어놓음.
## 		STG_ACCUMULATE , STG_INC추가
##
## Revision 1.50  2006/06/01 06:23:30  cjlee
## flat의 space [] Bug 수정
##
## Revision 1.49  2006/05/30 11:51:58  cjlee
## minor change
##
## Revision 1.48  2006/05/30 07:21:35  cjlee
## Modify for Errror Collection
##
## Revision 1.47  2006/05/29 10:50:01  cjlee
##     -  structg.pl
##         ITERATE 연산자가 +<+ ... +>+ 연산자보다 앞섬
##             ITERATE %HASH_KEY +<<+  ITKEY    ITVALUE
##                 if (+<+$HASH_KEY_IS{ITKEY}+>+(pSTG_HASHKEY->ITKEY) > 0) {
##             이런식으로 ITKEY를 적용한 후에 +<+...+>+ 연산자 수행가능
##
##             # +<+$stg_hash_del_timeout+>+ ==> 10
##             # +<+$typedef_name[54]+>+  ==> COMBI_Accum
##             # +<+$HASH_KEY_TYPE{uiIP}+>+ ==> IP4
##             # +<+$type{+<+$HASH_KEY_TYPE{uiIP}+>+}+>+  ==> int
##         위와 같은 처리를 반복 처리함
##
## Revision 1.46  2006/05/29 07:59:07  mungsil
## structg.pl
##
## Revision 1.45  2006/05/29 05:13:36  cjlee
##     -  NTAM 3차에 대한 적용까지
##         userfile.stg :
##             TABLE_LOG , TABLE_CF ,  STG_COMBINATION_TABLE keyword 사용
##                 TABLE_LOG : DB에 들어갈 테이블이며 계산이 되어짐
##                 TABLE_CF : DB에 들어갈 테이블이지만, call flow관련된 것으로 계산되어지지 않음.
##                 STG_COMBINATION_TABLE : DB에 들어갈 테이블이며 , 내부적으로 생성되는 것
##             STG_HASH_KEY keyword뒤에 위에서 선언한 typedef 이름을 넣으면 그 structure를 KEY Structure로 이용하게 됨.
##         structg.pl :
##             GLOBAL.TXT로 stg의 분석 결과를 저장한 값들을 모아둔 화일을 따로 떼어둠.
##             STC처리 추가  - ITERATE +<<+ ... +>>+ 과 +<+$...+.+  추가
##             undefined_typedef 추가 (our로 정의 되지 않은 모양들에 대한 처리를 위한 부분임)
##
## Revision 1.44  2006/05/26 04:51:27  cjlee
## > our $expansionprefix = "";
## > our $shortremoveprefix = "TTTTT__";
## 기능 추가
## expansionprefix= _ 일때는 AAA_BB가 되는 것이고
## shortremoveprefix의 값으로 %%안에 선언이 되면 그건 찍지 않는 것이다. %TTTTT__%
##
## Revision 1.43  2006/05/25 04:42:43  cjlee
##     - Short Name 처리
##          SQL문 자동 생성 (*.sql) : Short_COMBI_  or Short_TIM_ 모양만을 처리 함.
##          %flat_typdef_contents에 모든 내용 저장
##          *.stg에서 %...% 으로 ShortName 생성 가능 : %..%이 없으면 그냥 기존 이름으로 처리
##     - 각 stg들에 대한 시험 완료 (make까지 수행 완료)
##         hash.stg hashg.stg hasho.stg memg.stg sip.stg timerN.stg userfile.stg
##
## Revision 1.40  2006/05/25 02:23:03  cjlee
## Bug수정
##
## Revision 1.39  2006/05/25 02:00:40  cjlee
## 	- Short Name 처리
## 		 SQL문 자동 생성 (*.sql) : Short_COMBI_  or Short_TIM_ 모양만을 처리 함.
## 		 %flat_typdef_contents에 모든 내용 저장
## 	 	 *.stg에서 %...% 으로 ShortName 생성 가능 : %..%이 없으면 그냥 기존 이름으로 처리
##
## Revision 1.38  2006/05/25 00:18:26  yhshin
## U8 Print 문 수정
##
## Revision 1.37  2006/05/24 23:43:14  yhshin
## X8 type 추가
##
## Revision 1.36  2006/05/24 05:16:40  cjlee
## minor change
##
## Revision 1.35  2006/05/24 05:11:34  cjlee
## *** empty log message ***
##
## Revision 1.34  2006/05/24 05:05:54  cjlee
## /// -> /**
## // -> /*  으로 자동 변경 (주석문안에 ///을 쓰지 마시오)
##
## Revision 1.33  2006/05/24 04:26:43  cjlee
## 	- STIME , MTIME : S32로 변경
## 	- TIME64처리 추가 : STG_DiffTIME64
##
## Revision 1.32  2006/05/24 03:50:48  cjlee
## 	- NTAM 2단계 기능 추가
## 		STG_HASH_KEY - 한개만 존재해야하며 , 맨 마지막에 들어가야 한다.
## 			2개씩 분리하여 key, data를 만들고 , 최과장님의 요구에 따라 DATA는 퉁으로
## 		STG_COMBINATION_TABLE  - 여러개가 가능하며 , p를 앞에 붙여서 pointer로 선언하여야 한다.
## 			DIFF , EQUAL 구현 (Set_Combination_Once)
## 			ACCUMULATION 구현 - 각 TIM_... 메시지가 들어올때마다 축적하게 설
##
## Revision 1.31  2006/05/22 08:05:51  cjlee
## TIMEOUT 시간 설정 (SESS , DEL)
## *_DEF_NUM   : structure 에 따른 define 번호
## *_MEMBER_CNT : 각 structure들안의 member 들의 갯수 (flat기준)
##
## Revision 1.30  2006/05/21 23:59:05  cjlee
## 	- NTAM 자동화 1단계 수행중
## 		STG_HASH_KEY 추가 - 관련 structure들 자동 생성
## 		TIME64 추가 (내부 정의를 해야 하나?
##
## Revision 1.29  2006/05/19 08:35:11  cjlee
## 버그 수정  및
## Golbal 변수들 중에 중요한 것들 print하는 기능 추가
## DEBUG.TXT의 뒷쪽에 찍히게 된다.
##
## Revision 1.28  2006/05/19 06:39:47  cjlee
## 이상한 코드 제거
## use strict "vars" 사용
## STG_HASH_KEYS 를 추가하기 위한 사전 정리 작업
##
## Revision 1.27  2006/05/17 05:02:45  cjlee
## mistype해결  및   libSTGPC....a 를 제대로 고침
##
## Revision 1.26  2006/05/16 07:56:24  yhshin
## flat_ header에 pragma pack 삽입
##
## Revision 1.25  2006/05/10 23:24:39  cjlee
## type_printPre 관련 수정
##
## Revision 1.24  2006/05/10 08:36:00  cjlee
## *** empty log message ***
##
## Revision 1.23  2006/05/10 08:33:54  cjlee
## 64 bit variable이 잘나오게 고침
##
## Revision 1.22  2006/05/10 07:47:32  yhshin
## STGD --> STG
##
## Revision 1.21  2006/05/10 07:29:42  yhshin
## nodebug구분 삭제
##
## Revision 1.20  2006/05/10 06:54:00  cjlee
## U64 , S64 처리 추가 (prt , enc, dec)
##
## Revision 1.19  2006/05/10 01:04:26  yhshin
## U64, S64 추가
##
## Revision 1.18  2006/05/04 02:22:08  yhshin
## tablename 수정
##
## Revision 1.17  2006/05/04 00:04:48  yhshin
## Table명 parameter로 받게
##
## Revision 1.16  2006/05/03 00:30:23  yhshin
## nodebug file추가
##
## Revision 1.15  2006/05/02 08:23:05  yhshin
## struct 두개 사용해도 pc파일 적용됨
##
## Revision 1.14  2006/04/25 04:24:27  cjlee
## STIME type 추가
##
## Revision 1.13  2006/04/19 07:28:16  cjlee
## type OFFSET 추가
##
## Revision 1.12  2006/04/19 07:22:16  cjlee
## define_stg.h 를  결과 *.h에 통합 (한개의 .h사용)
##
## Revision 1.11  2006/04/19 06:56:04  yhshin
## include 추가
##
## Revision 1.10  2006/04/19 06:27:34  yhshin
## OraMake file 생성 추가
##
## Revision 1.9  2006/03/19 04:02:10  yhshin
## flat.upr 적용
##
## Revision 1.8  2006/03/19 01:13:35  yhshin
## makefile.upr 변겨에 따른 변수 추가
##
## Revision 1.2  2006/03/19 01:06:52  yhshin
## make pc용 추가
##
## Revision 1.1  2006/03/19 00:13:28  yhshin
## structg lib add
##
## Revision 1.7  2006/03/11 06:36:06  cjlee
## IP4 추가
##
## Revision 1.6  2006/03/11 06:17:27  cjlee
## project hashg 의 내용이 되게끔 수정을 함.
## cvs co hashg
##
## Revision 1.5  2006/04/06 07:56:18  cjlee
## minor change
##
## Revision 1.4  2006/04/06 06:11:03  cjlee
## arrary 인자 모양에 따른 여러가지 처리
##
## Revision 1.3  2006/04/06 05:00:35  cjlee
## minor change
##
## Revision 1.2  2006/04/06 04:23:55  cjlee
##         : Makefile 자동 생성 (단지 file이름만)
##         : define.upr 처리 (그대로 읽어서 씀)
##         : *.pc file 자동 생성
##         : define_stg.h 안에  extern으로 사용한 함수들 선언
##         : 결과는 OUTPUT directory밑에 생성
##
## Revision 1.1  2006/04/06 00:28:12  cjlee
## code_gen.pl + flat_hdr_gen.pl ==> 한개로 합침:INIT
##
## Revision 1.4  2006/04/03 07:59:30  cjlee
## member variable이 function pointer일때
##
## Revision 1.3  2006/04/03 07:07:45  cjlee
## define_stg.h를 자동생성으로 만듦
##
## Revision 1.2  2006/04/03 03:34:29  cjlee
## add comment
##
## Revision 1.1  2006/03/31 00:59:34  cjlee
## *** empty log message ***
##
##
