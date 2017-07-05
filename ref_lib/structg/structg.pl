#!/usr/bin/perl
##
## $Id: structg.pl,v 1.244 2007/05/31 01:19:04 cjlee Exp $
##


use strict 'vars';


# ��� ����� ��� ������ �ϴ� global variable
# sub print_all_global_var  ���� �Ʒ��� �������� ���� ����ش�.
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
our $stg_hash_first_data; 	# ù��° HASH key�� �Ǵ� ������ ���⿡ �Ŵ޸� �͵��� Ȱ���ϱ� ���� DATA structure�� �̸��̴�.  
our $stg_hash_first_key; 
our $stg_hash_first_key_name; 
our $stg_hash_first_key_type; 
our $stg_hash_first_key_is; 
our %lex_option;
our %stg_stc_file;		# �̻��ϰ� �̰͸� global�� ���� �� �����µ� ������ �𸣰���.  ???
our %primitives;
our %type;
our %type_size;
our %type_enc_func;			# NTOH32�϶��� %type_twin_func = 1 , ntohl�϶��� %type_twin_func = 0
our %type_twin_func;		# NTOH32(to,from) ���� ó���ϴ� �� , off�϶��� ntohl ���� ���� return�ϴ� ���� ����Ҷ�
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
our %typedef_contents;		# stAAA���� member��
our %flat_typedef_contents;		# stFlat_stAAA���� member��
our %function_def;			# void stAAA_Enc(_stAAA *pstTo,_stAAA *pstFrom)
our %flat_function_def;			# flat : DB....
our %typedef;				# $typedef{stAAA} = stflat_stAAA
our %typedef_def_cnt;		# stAAA  -> #define STG_DEF_stAAA  10
our %typedef_def_num;		# stAAA  -> #define STG_DEF_stAAA  10   $typedef_def_num{10} = STG_DEF_stAAA
our %typedef_member_count;		# typedef struct���� member���� �� (flat�����Ǽ�)
our %stat_typedef;			# stg_combination_table ���� ���� func���� �����ϰ�, stg_hash_key()�ȿ��� �̸� ����Ͽ� .c ȭ���� �����. 
our %association_typedef;			# stg_combination_table ���� ���� func���� �����ϰ�, stg_hash_key()�ȿ��� �̸� ����Ͽ� .c ȭ���� �����. 
our %combi_typedef;			# stg_combination_table ���� ���� func���� �����ϰ�, stg_hash_key()�ȿ��� �̸� ����Ͽ� .c ȭ���� �����. 
our %stat_accumulate;			# stg_stat���� ������ ���ϴ� �͵��� ���� ���� ���̴�.  
our %stat_accumulate_typedef;			# stg_combination���� ������ ���ϴ� typedef��
our %association_accumulate;			# stg_stat���� ������ ���ϴ� �͵��� ���� ���� ���̴�.  
our %association_accumulate_typedef;			# stg_combination���� ������ ���ϴ� typedef��
our %combi_accumulate;			# stg_combination���� ������ ���ϴ� �͵��� ���� ���� ���̴�.  
our %combi_accumulate_typedef;			# stg_combination���� ������ ���ϴ� typedef��
our %combi_inc;			# stg_combination���� ������ ���ϴ� typedef��
our %stat_inc;			# stg_combination���� ������ ���ϴ� typedef��
our %association_inc;			# stg_combination���� ������ ���ϴ� typedef��
our %define_digit;			# #define  DEF_SIZE_SESSIONID	8  �� �� �͵��� ���
our %table;					# TABLE_?? �� ���� �� �Ͱ� ���� DB�� �����ϴ� structure��  
our %table_log;					# TABLE_?? �� ���� �� �Ͱ� LOG���� ���� DB�� �����ϴ� structure��  
our %table_cf;					# TABLE_?? �� ���� �� �Ͱ� CF���� ���� DB�� �����ϴ� structure��  
our %table_combi;					# TABLE_?? �� ���� �� �Ͱ� COMBINATION���� ���� DB�� �����ϴ� structure��  
our %table_association;					# TABLE_?? �� ���� �� �Ͱ� ASSOCIATION���� ���� DB�� �����ϴ� structure��  
our %table_stat;					# TABLE_?? �� ���� �� �Ͱ� STAT���� ���� DB�� �����ϴ� structure��  
our %Not_flat_table;					# table classes without including the nested typedef structure
our %stg_key_hashs;				# STG_HASH_KEY�� �ֵ�
our %undefined_typedef;				# STG_HASH_KEY�� �ֵ�
our @undefined_array;				# STG_HASH_KEY�� �ֵ�
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
### $FileName (*.h)  �ȿ� ���ǵ� �͵��� Ÿ������ ������ Ư���� �����δ� IP4���� ���� ������� �߰��� �Ҽ� �ִٴ� ���̴�.
### IP4 �� �߽����� �����ϸ�
###     type{"IP4"} = �⺻ � type����
###     _size : byte��
###     _func   : encode , decode�� ������ �Լ��̸�
###     _printV : printf(" ...."   %�� type�� �����ؾ� �ϴ� �κ��� ���
###     _printM : printf("  " , ....)  �ڿ� ������ �־�� �ϴ� �κп� ���� �ϴ� ���
###     _define : .h �ȿ� ���Ե� �����̴�. 
###
### Note : ���� ��  %type�� ������ *.h�� �ڵ����� ����� ���� ������ ���� ( #define      U16     unsigned short )
### Current : �������� �����Ѵٰ� ���ø� �˴ϴ�.
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
### STIME : �� �ð�  (time_t)
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
### MTIME : micro second �ð�
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
### �� �Ʒ��� define�� define.upr�� �����Ͽ� �ִ� �͵� ���� ������ ���δ�.
### �ű⿡�� extern���� �Լ��鵵 ���� �־�� �� ���̴�.

### ���� �ؽ��� �ߵǴ��� �����ϴ� �κ� (OK)
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

# processing�߿� �ʿ��� global variable
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
		Cchange("$outputdir/tmp/$tmpstcfilename\.stc","","","stcI");			# OUTPUT�ȿ� �����ϰ�, makefile���� �־��.
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
	#��� 1. 
	# ���� �˱����ؼ� recusive�� ����ϰ� �ǰ�,
	# �� �ȿ��� ���� ����� �̿��Ͽ�
	# ���� ��ư� ���� ã�� ���� loop�� ��� ����, ITERATOR�� ���������� ������ �ϸ� �ȴ�. 
	#  	loop�� ������ ITERATOR�� �ѹ� �߰ߵǸ� �� ��Ģ�� ������ ��Ű�� ���� ��Ģ���� �Ѵ�.
	# �׸���, ������ loop�鵵 ���鼭 ó���� ����Ѵ�. 
	#
	# recusive����� ã�� ���� ������, �Ųٷ� Ǯ�鼭 ���� ������ ������ loop�� argument�� ����Ҽ� ���⿡ loop�� �� �߰��� ���̴�.
	#
	#��� 2.
	# ITERATOR�� ���� ������ �ξ� ó������ ��Ƽ� �ش� ���� ������ ������ �Ѵ�.
	# ITERATOR A start
	# 	AAA
	# 	ITERATOR B start
	# 		BBB
	#   B End
	# A End
	# ��� �Ҷ�, ���� 4���� ��� �� ������ ���� �ִ´�. (AAA ~ B End)
	# ITERATOR A�� ��Ģ��� ��ġ�� ��Ų��. (������ line�� �̾Ƴ��� ������ ����)
	# ��ġ��Ų ����� Cchange() ���� �ϴ� �� ó�� �� �����ش�. 
	# ITERATOR B ~ B End������ �� Ǯ���ش�.
	#
	# operation �켱����
	#  ITERATE �� ���� ���� ó�� �ȴ�.
	#  �� �Ŀ� , +<+$...+>+ �� ó���� �ȴ�.  co_log_main.c�ȿ���  Get_HashoData�� �����Ͻÿ�.
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
			print OUTPUTC "\n#include \"$FileName\"\n\n\n";		# .c�ȿ����� �Ǵµ� .l���� ������ �߻���.
		} else {
			#NONE#
			# .l�϶��� ó���� include�� �����ϸ� error�� �߻��Ѵ�.
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
				print OUTPUTC "\n#include \"$FileName\"\n\n\n";		# .c�ȿ����� �Ǵµ� .l���� ������ �߻���.
			} else {
				#NONE#
				# .l�϶��� ó���� include�� �����ϸ� error�� �߻��Ѵ�.
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
		} elsif($in =~ /^Lex_Compile_Option\s*\:\s*(.*)/){		# Compile_Option : -i   (flex ���� case ignore)
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
			#  �̰� SET�ϴ� ���� �� �ȵǴ±�.... ���� ����� �ɱ�?  <- set�� �߸��Ͽ� ������.
			# ���� ��� 1�� �Ʒ��� ��� 2 ��� �� ó����.
##			if($temp_set_var eq "iterate_comments" ){
##				print OUTPUTC "[$1] [$2]\n";
##				if("OFF" eq $temp_set_value){
##					#$iterate_comments = "OFF";
##				} else {
##					#$iterate_comments = "ON";
##				}
##			}
##			# ù��°�� ������� �̻��ϰ� �� ���� Set�ǰ� ���� �ʴ´�. 
##			# �ι�°�� �񱳸� �Ͽ� ���� ���� ���ִ� ���� �����ϴ�. ��
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

		foreach $temp (keys %local_set){			# local �ϰ� Set: �� �͵鿡 ���ؼ� ��ġ (replacement)�� �����ִ� ���̴�.
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
					# /** */ ���� ���� �ȿ� /* */�� ������ �ȵǹǷ� <* *>���� ��ȯ�� �����ִ� ���̴�.  
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

				# �̷������� ó���ϸ� ���� %������ ������ �ʾƵ� �Ǹ�, define���� ������ �������ϰ� �������� ������� �ʿ䰡 ����. 
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
						if($ifequal_one eq $ifequal_two){	# ������ IFEQUAL�̹Ƿ� ó��
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
						if($ifequal_one ne $ifequal_two){	# �ٸ���  NOTEQUAL�̹Ƿ� ó��
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
							if( ($is_ifequal == 1) && ($ifequal_one eq $ifequal_two) ){	# ������ IFEQUAL�̹Ƿ� ó��
								print DBG "IFEQUAL 3.5>>> $ifequal_action\n";
								$ifequal_action =~ s/STG_SHARP_/\#/g;
								print_fp("$ifequal_action\n" , OUTPUTC,DBG);
							} elsif( ($is_ifequal == 0) && ($ifequal_one ne $ifequal_two) ){	#  �ٸ��� IFEQUAL�̹Ƿ� ó��
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
	# $iterate_lines ���� +<+...+>+ ���� ���ڰ� ���� ������ ��� �ذ�� ����. (���鸸 ��)
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
				if($ifequal_parm =~ /\&\&/){ print "ERROR : || �� &&�� �Բ� ���� ����.\n";   die $error = 12301; }
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
				if($ifequal_parm =~ /\|\|/){ print "ERROR : || �� &&�� �Բ� ���� ����.\n";   die $error = 12303; }
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
		# $temp�� print �غ��� ������
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
				if($ifequal_parm =~ /\&\&/){ print "ERROR : || �� &&�� �Բ� ���� ����.\n";   die $error = 12311; }
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
				if($ifequal_parm =~ /\|\|/){ print "ERROR : || �� &&�� �Բ� ���� ����.\n";   die $error = 12313; }
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
		# $temp�� print �غ��� ������.
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
				if($ifequal_parm =~ /\&\&/){ print "ERROR : || �� &&�� �Բ� ���� ����.\n";   die $error = 12331; }
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
				if($ifequal_parm =~ /\|\|/){ print "ERROR : || �� &&�� �Բ� ���� ����.\n";   die $error = 12333; }
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
		# $temp�� print �غ��� ������.
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
				if($ifequal_parm =~ /\&\&/){ print "ERROR : || �� &&�� �Բ� ���� ����.\n";   die $error = 12341; }
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
				if($ifequal_parm =~ /\|\|/){ print "ERROR : || �� &&�� �Բ� ���� ����.\n";   die $error = 12343; }
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
		# $temp�� print �غ��� ������.
		$temp = $iterate_lines;
		$temp =~ s/\{\{\{\{1234\}\}\}\}/\n/g;
		#ITERATOR_DEBUG   print DBG "GETIF4---- \$iterate_lines = \n\[\n$temp\n\]\n";
	
		$iterate_lines =~ s/\{\{\{\{1234\}\}\}\}/\n/g;
		#ITERATOR_DEBUG   print DBG "RETURN--- \$iterate_lines = \n\[\n$iterate_lines\n\]\n";
	}		# while 1

	#$iterate_lines =~ s/STG_SHARP_/\#/g;
	#print_fp("$iterate_lines\n" , OUTPUTC);
	#if($iterate_lines =~ /(IFEQUAL.*)/){ print ": $1 \n: IFEQUAL .. #{ }#�϶� }# �ڿ� ���ڰ� ���� �ȵ�\n"; print ": #{ }# �ȿ� # ���ڰ� ���� �ȵ�.\n";  die $error = 612348;}

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
		while($replace_in =~ /(\d+)\s*\+\+\+\+/){		# 	++++     1�� ���� �ش�. 
			my $temp_num;
			$temp_num = $1;
			$temp_num++;
			$replace_in =~ s/\d+\s*\+\+\+\+/$temp_num/;
		}
		while($replace_in =~ /(\d+)\s*\-\-\-\-/){		# 	++++     1�� ���ش�.
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

# function.upr�� ������ subroutine�� ���ؼ��� ���� ����� �ּ��� �ܴ�.
#/** save_typedef function.
# *
# *  typedef struct ... { ... } ...; �� �Է¹޾� enc/dec/print���� �ش� �ڵ���� �ڵ� ���������ش�.
# *
# *  @param  $typedef  typedef struct ... { ... } ...; �� �Է¹޾�
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl�� �����Ͽ� flat....h �� ���� ȭ��
# *
# *  @exception  nested structure��  ���ο� ������ ���� ó�� �ȵ�.
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
	
	### typedef struct TTT { ...} ...; �϶� TTT�� struct �̸��� ã�� ����.
	if($parms =~ /^\s*typedef\s+struct\s+([\w\s]+)\{/){ 
		$struct_name = $1;
		push @struct_name , $struct_name;
		#print DBG "save_typedef struct \$struct_name : $struct_name\n"; 
		#print DBG "save_typedef struct \@struct_name : @struct_name\n"; 
	}
	### typedef struct ... { ...} TTT; �϶� TTT�� typedef �̸��� ã�� ����.
	if($parms =~ /\}\s+(\w+)\s*\;/){ 
		$typedef_name = $1;
		push @typedef_name , $typedef_name;
		#print DBG "save_typedef typedef \$typedef_name : $typedef_name\n"; 
		#print DBG "save_typedef typedef \@typedef_name : @typedef_name\n"; 
	}
	unless($parms =~ s/typedef\s+struct\s+([\w\s]+)\{//){ die $error = 1;}
	unless($parms =~ s/\}\s+(\w+)\s*\;//){ die $error = 2;}
	
	### encode file�� header�� ����
	$typedef_enc_func{$typedef_name} = $typedef_name . $primitives{"ENC"};
	### encode file����  function�鿡 ���� �ּ� ����
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$typedef_enc_func{$typedef_name}/;
				$upr =~ s/\+Intro\+/Encoding Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				$upr =~ s/\+Note\+/structg.pl�� ������� �ڵ� �ڵ�/;
				if($upr =~ /\+Param\+/){
					print ENC " * \@param *pstTo 		: To Pointer\n";
					print ENC " * \@param *pstFrom 	: From Pointer\n";
				} else {
					print ENC $upr;
				}
			}
			close UPR;
    ### encode file���� function�̸� ����  : void  type�̸�_enc(to,from)
	$function_def = "void $typedef_enc_func{$typedef_name}"."($typedef_name *pstTo , $typedef_name *pstFrom)";
	$function_def{$typedef_enc_func{$typedef_name}} = $function_def;
	print_fp ("$function_def\{\n",DBG,ENC);


    ### decode file�� header�� ����
	$typedef_dec_func{$typedef_name} = $typedef_name . $primitives{"DEC"};
     ### decode file����  function�鿡 ���� �ּ� ����
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$typedef_dec_func{$typedef_name}/;
				$upr =~ s/\+Intro\+/Decoding Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				$upr =~ s/\+Note\+/structg.pl�� ������� �ڵ� �ڵ�/;
				if($upr =~ /\+Param\+/){
					print DEC " * \@param *pstTo 		: To Pointer\n";
					print DEC " * \@param *pstFrom 	: From Pointer\n";
				} else {
					print DEC $upr;
				}
			}
			close UPR;
    ### decode file���� function�̸� ����  : void  type�̸�_dec(to,from)
	$function_def = "void $typedef_dec_func{$typedef_name}"."($typedef_name *pstTo , $typedef_name *pstFrom)";
	$function_def{$typedef_dec_func{$typedef_name}} = $function_def;
	print_fp ("$function_def\{\n",DBG,DEC);


    ### print file�� header�� ����
	$typedef_prt_func{$typedef_name} = $typedef_name . $primitives{"PRT"};
	$typedef_fpp_func{$typedef_name} = $typedef_name . $primitives{"FPP"};
     ### print file����  function�鿡 ���� �ּ� ����
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$typedef_prt_func{$typedef_name}/;
				$upr =~ s/\+Intro\+/Printing Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				$upr =~ s/\+Note\+/structg.pl�� ������� �ڵ� �ڵ�/;
				if($upr =~ /\+Param\+/){
					print PRT " * \@param *pcPrtPrefixStr 	: Print Prefix String\n";
					print PRT " * \@param *pthis 		: Print���� Pointer\n";
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
				$upr =~ s/\+Exception\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				$upr =~ s/\+Note\+/structg.pl�� ������� �ڵ� �ڵ�/;
				if($upr =~ /\+Param\+/){
					print FPP " * \@param *fp 	:  file pointer\n";
					print FPP " * \@param *pthis 		: Print���� Pointer\n";
				} else {
					print FPP $upr;
				}
			}
			close UPR;
	### print file���� function�̸� ����  : void  type�̸�_prt(this)
	$function_def = "void $typedef_prt_func{$typedef_name}"."(S8 *pcPrtPrefixStr, $typedef_name *pthis)";
	$function_def{$typedef_prt_func{$typedef_name}} = $function_def;
	print_fp ("$function_def\{\n",DBG,PRT);
	print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis = %p" . "\\n\",pcPrtPrefixStr, pthis)\;\n",DBG,PRT);
	## ��������� typdef struct xxx  { } yyy; �� �⺻���� ����� �ٷ� �κ��̴�. 

	$function_def = "void $typedef_fpp_func{$typedef_name}"."(FILE *fp, $typedef_name *pthis)";
	$function_def{$typedef_fpp_func{$typedef_name}} = $function_def;
	print_fp ("$function_def\{\n",DBG,FPP);


	
	## $$trtr�̶�� �ϸ� $parms�� ����Ǵ��� Ȯ���ϴ� ���� (OK)
	#$trtr = "parms";
	#print "trtr = $trtr\n";
	#print "\$$trtr = $$trtr\n \$error = $error\n";

	## { } ���� �͵��� ;�� ������� �и� ��Ų��.
    ### member  ������ ��� �и� ��.
    ### �� member �����鿡 ���� ó���� �ϴ� routine�̴�.
    ### foreach �� �� ������ �޾Ƽ�
    ###     struct�� �����ϸ� (struct A B) ����
    ###         3���� ����̸�, enc/dec������ pointer�� �����Ͽ� 0���� ó��
    ###     �Ϲ����� (A B) ����
    ###         pointer�� ���          // null
    ###         [] ���� ����� ���     // null
    ###         [??] size��  ���Ե� ���    // enc/dec/prt���� for ���� ���� ó��
    ###         int a; �� ���� �Ϲ����� ���    // typedef�� �տ� ���ǵ� ���̸� �ش� �Լ��� call
	###			()�� ���Ե� ���� �Լ��� ��� 	// enc/dec/prt���� no processing
	###											// U8 (*func)(char*,....); ó�� ����
    ### �� ���鿡 ���ؼ� ó���� �ش�.
    ###
	@member_vars = split(";",$parms);
	#print "var : @member_vars\n";
	foreach $member_vars (@member_vars){
		#print "KK : [$member_vars]\n";
		#print DBG "member_vars 1 = $member_vars\n";
		$member_vars =~ s/\%.*\%//g;
		$member_vars =~ s/\#.*\#//g;
		#print DBG "member_vars 2 = $member_vars\n";
		## ���� \s�� ���ش�. (white space)
		$member_vars =~ s/\s*(\w[\w\s]*\w)/$1/;
		#print DBG "member_vars 3 = $member_vars\n";
		#print "KK : [$member_vars]\n";


		if($member_vars =~ /^\s*BIT(\d+)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*$/){ # BIT�� ���
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
				$bit_line = "";		# ���� \n�� �ƴ�.
			} 
			next;
		} elsif($member_vars =~ /\(.*\)/){
			print "()()() : $member_vars\n";
			next; 
		}

		if( $member_vars =~ /^struct/){ 	 ## struct�� �����ϴ� ���� ��� 
			print_fp("\t"x1 . "/* $member_vars */\n",DBG,ENC,DEC,PRT,FPP);
			## struct ���� 2���� ��� 
			## ������ @(struct_name)�� 
			if($member_vars =~ /struct\s+(\S+)\s+(\S+)/){
				$member_type = $1;
				$member_name = $2;
				## pointe *�� ��� : ���� ��ȯ�ϴ� ���� ���� - 0 ���� ä�� 
				#print DBG "struct [$member_type] [$member_name]\n";
				if($member_name =~ s/^\*+//){
					print_fp("\t"x1 . "pstTo->$member_name = 0\;\n",DBG,ENC,DEC);
					print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$member_name = $type_printV{structp}" . "\\n\",pcPrtPrefixStr,$type_printM{structp}" . "(pthis->$member_name))\;\n",DBG,PRT);
				}
				#�������� ���ǰ� �� �� ���̴�.
				# �� �ȿ����� ���Ǹ� �ϸ� �� ���̴�.  
				## push�� ���� ����� ������� �ʴ´�.
			}
		} else {							## U8 , U16 �Ǵ� typedef�� ������ ������ �����ϴ� ��� 
			if($member_vars =~ /(\S+)\s+(\S+.*$)/){
				print_fp("\t"x1 . "/* $member_vars */\n",DBG,ENC,DEC,PRT,FPP);
				$member_type = $1;
				$member_name = $2;
				#print DBG "def [$member_type] [$member_name]\n";

				if($member_name =~ s/^\*+//){ ## pointer *�� ��� : ���� ��ȯ�ϴ� ���� ���� - 0 ���� ä�� 
					print_fp("\t"x1 . "pstTo->$member_name = 0\;\n",DBG,ENC,DEC);
					print_fp("\t"x1 . "FPRINTF(LOG_LEVEL,\"_%s : pthis->$member_name = $type_printV{U32}"."\\n\",pcPrtPrefixStr,$type_printM{U32}"."(pthis->$member_name))\;\n",DBG,PRT);
				} elsif($member_name =~ /(\w+)\s*\[\s*(\S*)\s*\]\s*/){	##  [] array�� ����ɶ��� ó��
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
				} else {	## pointer�� array�� �ƴ� �Ϲ����� ���� ó��
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
				#�������� ���ǰ� �� �� ���̴�.
				# �� �ȿ����� ���Ǹ� �ϸ� �� ���̴�.  
				## push�� ���� ����� ������� �ʴ´�.
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
	
	### typedef struct TTT { ...} ...; �϶� TTT�� struct �̸��� ã�� ����.
	if($parms =~ /^\s*typedef\s+struct\s+([\w\s]+)\{/){ 
		$struct_name = $1;
		print DBG "^ANALYSIS_TYPEDEF struct \$struct_name : $struct_name\n"; 
	}
	### typedef struct ... { ...} TTT; �϶� TTT�� typedef �̸��� ã�� ����.
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
	
	## { } ���� �͵��� ;�� ������� �и� ��Ų��.
    ### member  ������ ��� �и� ��.
    ### �� member �����鿡 ���� ó���� �ϴ� routine�̴�.
    ### foreach �� �� ������ �޾Ƽ�
    ###     struct�� �����ϸ� (struct A B) ����
    ###         3���� ����̸�, enc/dec������ pointer�� �����Ͽ� 0���� ó��
    ###     �Ϲ����� (A B) ����
    ###         pointer�� ���          // null
    ###         [] ���� ����� ���     // null
    ###         [??] size��  ���Ե� ���    // enc/dec/prt���� for ���� ���� ó��
    ###         int a; �� ���� �Ϲ����� ���    // typedef�� �տ� ���ǵ� ���̸� �ش� �Լ��� call
	###			()�� ���Ե� ���� �Լ��� ��� 	// enc/dec/prt���� no processing
	###											// U8 (*func)(char*,....); ó�� ����
    ### �� ���鿡 ���ؼ� ó���� �ش�.
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
		while( $member_vars =~ /\@\s*STG_PAR_ARRAY\s*:\s*(\w+)\s*:\s*(\d+)\s*:([^@]*)\@/){		# STG_PAR_ARRAY:�̸�:��ȣ:��
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
		$member_vars =~ s/\/\*.+\*\///g;    # �ּ��� ����
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
		## ���� \s�� ���ش�. (white space)
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
		if($member_name =~ /(\w+)\s*\[\s*(\S*)\s*\]\s*/){	##  [] array�� ����ɶ��� ó��
			$member_array = "YES";
			$member_array_name = $1;
			$member_array_size = $2;
			$member_name = $1;
		}
		#ALAYSIS_DEBUG print DBG "member_vars 4 : TYPE $member_type : NAME $member_name : ARRAY $member_array : SIZE $member_array_size\n";

		if($member_sb_parsing_value){
			# ���߿� type�� ���Ҷ� sb_parsing rule�� ���ǵ� line�鿡 ���� ���� ����ϰ� �Ѵ�.
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
			## ������ �ϱ� ���ؼ� U8 , S8 �� String Array���� �����Ѵ�.
			## U8 , S8 �� �׳� ������ ���� ������ ���� ���� ���� ���̴�. 
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
					## define�� ���� ��쿡�� ���ڷ� �ٲ��� ���̴�.
					if($temp =~ /^([^~]+)~(.+)$/){		# A ~ B ����.. 1���� mapping�Ǵ� �͵� A ~ A �� ǥ���ؾ� �Ѵ�. 
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
					} elsif($temp =~ /^([^~]+)~$/){		# A~ �̸� A�̻��̸� ����
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
					} else {							# ~�� ���ٸ� ���� string���� �ν� �� ���̴�. 
						$undefined_name = "ANALYSIS_$typedef_name\_CHECKING_VALUE_STRING_$member_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$temp} = length($temp);
					}
# ??? LIST�� Gourping�Ͽ� �� ���� ��ǥ������ ����ϰ� �ϴ� ���� ���巯��  �� ���̴�. 
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

# function.upr�� ������ subroutine�� ���ؼ��� ���� ����� �ּ��� �ܴ�.
#/** flat_save_typedef function.
# *
# *  typedef struct ... { ... } ...; �� �Է¹޾� enc/dec/print���� �ش� �ڵ���� �ڵ� ���������ش�.
# *
# *  @param  $typedef  typedef struct ... { ... } ...; �� �Է¹޾�
# *
# *  @return    void
# *  @see       structg.pl : structg.pl�� �����Ͽ� flat....h �� ���� ȭ��
# *
# *  @exception  nested structure��  ���ο� ������ ���� ó�� �ȵ�.
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
	## typedef struct ... { �� ���� } ....; �� ���ش�.
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
	## ��������� typedef struct xxx  { } yyy; �� �⺻���� ����� �ٷ� �κ��̴�. 

	### ProC file�� header�� ����
	$typedef_enc_func{$typedef_name} = $typedef_name . $primitives{"ENC"};

	
	## $$trtr�̶�� �ϸ� $parms�� ����Ǵ��� Ȯ���ϴ� ���� (OK)
	#$trtr = "parms";
	#print "trtr = $trtr\n";
	#print "\$$trtr = $$trtr\n \$error = $error\n";

	## { } ���� �͵��� ;�� �������� �и� ��Ų��. 
	@member_vars = split(";",$parms);
	#print "var : @member_vars\n";
	$typedef_member_count = 0;
	foreach $member_vars (@member_vars){
		#print "KK : [$member_vars]\n";
		## ��(^)�� \s�� ���ش�. (white space)
		$member_vars =~ s/\%.*\%//g;
		$member_vars =~ s/\#.*\#//g;
		$member_vars =~ s/\s*(\w[\w\s]*\w)/$1/;
		#print "KK : [$member_vars]\n";

		if($member_vars =~ /^\s*BIT(\d+)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*$/){ # BIT�� ���
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
				$bit_line = "";		# ���� \n�� �ƴ�.
			} 
			next;
		}

		if( $member_vars =~ /^struct/){ 	 ## struct�� �����ϴ� ���� ��� 
			$typedef_member_count ++;
			$temp = $member_vars;
			$temp =~ s/\/\*/\<\</;
			$temp =~ s/\*\//>>/;
			print_fp("\t"x1 . "$member_vars\; 	\/\*\*< $temp \*\/\n",DBG,FLATH);
			$flat_typedef_contents .= "$member_vars\;";
		} else {							## U8 , U16 �Ǵ� typedef�� ������ ������ �����ϴ� ��� 
			if($member_vars =~ /(\S+)\s+(\S+.*$)/){
				$typedef_member_count ++;
				$member_type = $1;
				$member_name = $2;
				#print DBG "def [$member_type] [$member_name]\n";

				if($member_name =~ /^\*/){ ## pointer *�� ��� : ���� ��ȯ�ϴ� ���� ���� - 0 ���� ä�� 
					if($typedef{$member_type}){
						print_fp("\t"x1 . "$typedef{$member_type} 	$member_name;	/**< $member_vars */\n",DBG,FLATH);
						$flat_typedef_contents .= "$typedef{$member_type} 	$member_name\;";
					} else {
						print_fp("\t"x1 . "$member_vars; 	/**< $member_vars */\n",DBG,FLATH);
						$flat_typedef_contents .= "$member_vars\;";
					}
				} elsif($member_name =~ /(\w+)\s*\[(\s*[\w]*\s*)\]\s*/){	##  [] array�� ����ɶ��� ó��
					$member_array_name = $1;
					$member_array_size = $2;
					if($typedef{$parm_member_type}){ 	### [] �̸鼭 typdef struct�̸� ó�� ����.
						#print DBG "var \$member_array_name [$member_array_name] : \$member_array_size [$member_array_size]\n";
						print_fp("\t"x1 . "/**< $member_type::$member_vars */\n",DBG,FLATH);
						print_fp("\t"x1 . "Warning : ����ϸ� DB���� ó���ϱ� �����. ��� �����ؾ� �ϴ��� �ǰ��� �ּ���;\n",DBG,FLATH);
					} else { 		### [] �ε� U8�� ���� structure�� �ƴ� ��� 
						print_fp("\t"x1 . "$member_vars; 	/**< $member_vars */\n",DBG,FLATH);
						$flat_typedef_contents .= "$member_vars\;";
					}
				} else {	## pointer�� array�� �ƴ� �Ϲ����� ���� ó��
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
				$upr =~ s/\+Intro\+/DB�Լ� : $typedef{$typedef_name}�� DB�� �ִ� �Լ�/;
				$upr =~ s/\+DB_Table_Field_Name\+/$table_field_name/;
				$upr =~ s/\+Function_Definition\+/$flat_function_def{"DBInsert_"."$typedef{$typedef_name}"}/;
				$upr =~ s/\+HEADER\+/$FlatFileName/;
				print ProC $upr;
			}
			close UPR;
}

# function.upr�� ������ subroutine�� ���ؼ��� ���� ����� �ּ��� �ܴ�.
#/** expansion_member function.
# *
# *  typedef struct _st_AAA { int a; } stAAA;
# *  typedef struct _st_BBB { int b; stAAA a; } stBBB;
# *  stBBB�� flat�Ҷ� stAAA�� ������ ���⿡ ���ľ� �Ѵ�.
# *  �̶� stAAA a; �� prefix a_�� �ٿ��� ��ġ�� �Ѵ�.
# *  recursive �Լ��ν� prefix�� ��� �ٿ� ���� �ִ�.
# *  ����Ǵ� ������ �տ� �̸� ���ǵ� �͵鸸�� ����Ͽ��� �Ѵ�.
# *
# *  @param  $parm_member_prefix    a_ (�̿� ���� name�� prefix�� ����)
# *  @param  $parm_member_contents    stAAA�� ������ ���⿡ ��
# *  @param  $parm_member_comment    � �Ϳ��� nested�Ǵ� ������ �ּ��� ǥ���ϱ� ���ؼ�
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl�� �����Ͽ� flat....h �� ���� ȭ��
# *
# *  @exception  nested structure��  ���ο� �����Ѵ� ���� ó�� �ȵ�.
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

	## { } ���� �͵��� ;�� ������� �и� ��Ų��. 
	@parm_member_vars = split(";",$parm_member_contents);
	#print "var : @member_vars\n";
	foreach $parm_member_vars (@parm_member_vars){
		$parm_member_vars =~ s/\s*(\w[\w\s]*\w)/$1/;
		$parm_member_vars_org = $parm_member_vars ;
		$parm_member_vars =~ s/(\*+)/$1$parm_member_prefix/;
		#print DBG "\$parm_member_vars : $parm_member_vars\n";

		if($parm_member_vars =~ /^\s*BIT(\d+)\s+(\w+)\s*\(\s*(\d+)\s*\:\s*(\w+)\s*\)\s*$/){ # BIT�� ���
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
				$bit_line = "";		# ���� \n�� �ƴ�.
			} 
			next;
		}

		if( $parm_member_vars =~ /^struct/){ 	 ## struct�� �����ϴ� ���� ��� 
			$typedef_member_count ++;
			print_fp("\t"x1 . "$parm_member_vars; 	/**< $parm_member_comment :: $parm_member_vars_org */\n",DBG,FLATH);
			$flat_typedef_contents .= "$parm_member_vars\;";
		} else {							## U8 , U16 �Ǵ� typedef�� ������ ������ �����ϴ� ��� 
			if($parm_member_vars =~ /(\S+)\s+(\S+.*$)/){
				$typedef_member_count ++;
				$parm_member_type = $1;
				$parm_member_name = $2;
				#print DBG "expansion_member | def [$parm_member_type] [$parm_member_name]\n";

				if($parm_member_name =~ /^\*/){ ## pointer *�� ��� : ���� ��ȯ�ϴ� ���� ���� - 0 ���� ä�� 
					print_fp("\t"x1 . "$parm_member_type 	$parm_member_name;	/**< $parm_member_comment :: $parm_member_vars_org */\n",DBG,FLATH);
					$flat_typedef_contents .= "$parm_member_type 	$parm_member_name\;";
				} elsif($parm_member_name =~ /(\w+)\s*\[(\s*[\w]*\s*)\]\s*/){	##  [] array�� ����ɶ��� ó��
					$parm_member_array_name = $1;
					$parm_member_array_size = $2;
					if($typedef{$parm_member_type}){ 	### [] �̸鼭 typdef struct�̸� ó�� ����.
						#print DBG "expansion_member | var \$parm_member_array_name [$parm_member_array_name] : \$parm_member_array_size [$parm_member_array_size]\n";
						print_fp("\t"x1 . "/** Warning : $parm_member_type::$parm_member_vars */\n",STDOUT,DBG,FLATH);
						print_fp("\t"x1 . "Warning : ����ϸ� DB���� ó���ϱ� �����. ��� �����ؾ� �ϴ��� �ǰ��� �ּ���;\n",STDOUT,DBG,FLATH);
					} else { 		### [] �ε� U8�� ���� structure�� �ƴ� ��� 
						print_fp("\t"x1 . "$parm_member_type 	$parm_member_prefix$parm_member_name; 	/**< $parm_member_comment :: $parm_member_vars_org */\n",DBG,FLATH);
						$flat_typedef_contents .= "$parm_member_type 	$parm_member_prefix$parm_member_name\;";
					}
				} else {	### pointer�� array�� �ƴ� �Ϲ����� ���� ó��
					if($typedef{$parm_member_type}){ 	###  typedef struct�� ���ǵ� Type�� ���
						#print DBG "expansion_member | $typedef_contents{$parm_member_type};  /**< $parm_member_type::$parm_member_vars */\n";
						$typedef_member_count --;
						expansion_member("$parm_member_prefix"."$parm_member_name".$expansionprefix, $typedef_contents{$parm_member_type},"$parm_member_comment  :: $parm_member_type");
					} else {							### typedef�� U8�� ���� structure�� �ƴ� ��� 
						print_fp("\t"x1 . "$parm_member_type 	$parm_member_prefix$parm_member_name; 	/**< $parm_member_comment :: $parm_member_vars_org */\n",DBG,FLATH);
						$flat_typedef_contents .= "$parm_member_type 	$parm_member_prefix$parm_member_name\;";
					}
				}
			}
		}
	}
}

# function.upr�� ������ subroutine�� ���ؼ��� ���� ����� �ּ��� �ܴ�.
#/** stg_hash_key2 function.
# *
# *		NTAM �ڵ�ȭ 1���� ���� �Լ� 
# *
# *  (���� B) - �Ϸ� 
# *  STG_HASH_KEY typedef struct ... ��� ���� �޾Ƽ� 
# *  STG_HASH_KEY�� �� ���� save_typedef , flat_save_typedef�� ������ ó���� ���Ŀ�, 
# *  2������ ¦���� ó�� �ٽ� save_typedef , flat_save_typedef�� ������ code�� �ڵ����� ������־�� �� ���̴�.
# *  KEY�� DATA�� �и��� ��. 
# *  
# *  (���� C) - �ڵ� �غ� �Ϸ�
# *  +HASH_INIT+ ���� ���� �� �κп� �ʱ�ȭ�� �����ϰ� ���� ���̸�, 
# *  ����Ǵ� ������ �տ� �̸� ���ǵ� �͵鸸�� ����Ͽ��� �Ѵ�.
# *	
# *	 (���� A) - �Ϸ�
# *	 ID�� define�ϰ� �Ͽ� structure���� �ڵ����� define���� ������ ������ �� ���̴�. STRUCTURE TYPE�� �� ���̴�.  
# *	 switch���� case�κ��� �̰����� ó���� �ؾ��ϸ�, ������ ���ؼ� � ���� ��� �ٲ��������� upr�� ó���� �ؾ��� ���̴�.  
# *  TIME64 ó��
# *  
# *  �Ϲ������� stg_hash_key2�� �̿��ϸ�
# *  �⺻������ ������ �������� ������ ������ �� �߿��� �Ѱ��� ��� HASH�� KEY�� ����ϴ� ����̴�.
# * �̷��� �Ͽ� HASH KEY�� �� �ڿ� ����Ǿ����� , �� ���� �տ��� ����Ҽ� �ִٴ� ���̴�. 
# *
# *  @param  $parm_member_prefix    a_ (�̿� ���� name�� prefix�� ����)
# *  @param  $parm_member_contents    stAAA�� ������ ���⿡ ��
# *  @param  $parm_member_comment    � �Ϳ��� nested�Ǵ� ������ �ּ��� ǥ���ϱ� ���ؼ�
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl�� �����Ͽ� flat....h �� ���� ȭ��
# *
# *  @exception  nested structure��  ���ο� �����Ѵ� ���� ó�� �ȵ�.
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
	$cnt--;		# �ǵ��� ; �� �ڴ� �����Ƿ� �̰��� ���ܸ� �����־����.
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
		if($members_name[$i] =~ /(\w+)\s*\[(\s*[\w]*\s*)\]\s*/){	##  [] array�� ����ɶ��� ó��
			$members_name[$i] = $1;
			print_fp("stg_hash_key | $members_type[$i]   $members_name[$i]\n",DBG);
		}
	}

	for(my $i = 0 ; $i < $cnt-1 ; $i++){
		my $basic_name;
		# 2������ structure
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
		print_fp("/** \@brief NTAM Corelation �ڵ� �ڵ� - STG_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);

		# 2�� �߿� key�� �Ǵ� structure (KEY)
		$member_typedef = "typedef struct _st_key_$members_name[$i+1]_$members_name[$i] \{ \n";
		$member_typedef .= "\t$members[$i+1]\;\n";
		$member_typedef .= "} STG_KEY_$members_name[$i+1]_$members_name[$i] \;\n";
		print_fp("stg_hash_key | \[$i\] $member_typedef\n",DBG);
		print_fp("/** \@brief NTAM Corelation �ڵ� �ڵ� - STG_KEY_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);

		# 2���߿� data�� �Ǵ� �κ����� TimerId�� �߰� �ȴ�. (DATA)
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
		print_fp("/** \@brief NTAM Corelation �ڵ� �ڵ� - STG_DATA_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);
	}

	### combination file�� header�� ����
	my $set_combi_func = "Set_Combination_Once";
	open(COMBI , ">$outputdir/HD/$set_combi_func" . "\.c");
	$filelist{"HD/$set_combi_func" . "\.c"} = "CFILE";
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_combi_func\.c/;
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
				$upr =~ s/\+ToDo\+/library�� ����� ���� Makefile�� ������/;
				$upr =~ s/\+Intro\+/COMBINATION typedef�� ���� functions/;
				$upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				print COMBI $upr;
			}
			close UPR;
		print_fp("\#include \"$FileName\"\n",COMBI);
		### combiode file����  function�鿡 ���� �ּ� ����
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$set_combi_func/;
				$upr =~ s/\+Intro\+/Set Combination Values Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				$upr =~ s/\+Note\+/structg.pl�� ������� �ڵ� �ڵ�/;
				if($upr =~ /\+Param\+/){
					print COMBI " * \@param *p$stg_hash_first_data 		: DATA Pointer\n";
				} else {
					print COMBI $upr;
				}
			}
			close UPR;

    ### combiode file���� function�̸� ����  : void  type�̸�_combi(to,from)
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
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
				$upr =~ s/\+ToDo\+/Makefile�� ������/;
				$upr =~ s/\+Intro\+/COMBINATION typedef/;
				$upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				print COMBI $upr;
			}
			close UPR;
	close COMBI;

	### combination file�� header�� ����
	my $set_accumulate_func = "Set_Combination_Accumulate";
	open(ACCUM , ">$outputdir/HD/$set_accumulate_func" . "\.c");
		$filelist{"HD/$set_accumulate_func" . "\.c"} = "CFILE";
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_accumulate_func\.c/;
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
				$upr =~ s/\+ToDo\+/library�� ����� ���� Makefile�� ������/;
				$upr =~ s/\+Intro\+/ACCUMULATION typedef�� ���� functions/;
				$upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				print ACCUM $upr;
			}
			close UPR;
		print_fp("\#include \"$FileName\"\n",ACCUM);
		### combiode file����  function�鿡 ���� �ּ� ����
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$set_accumulate_func/;
				$upr =~ s/\+Intro\+/Set Accumulation Values Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				$upr =~ s/\+Note\+/structg.pl�� ������� �ڵ� �ڵ�/;
				if($upr =~ /\+Param\+/){
					print ACCUM " * \@param *p$stg_hash_first_data 		: DATA Pointer\n";
				} else {
					print ACCUM $upr;
				}
			}
			close UPR;

    ### combiode file���� function�̸� ����  : void  type�̸�_combi(to,from)
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
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
				$upr =~ s/\+ToDo\+/Makefile�� ������/;
				$upr =~ s/\+Intro\+/ACCUMNATION typedef/;
				$upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				print ACCUM $upr;
			}
			close UPR;
	close ACCUM;
}

# function.upr�� ������ subroutine�� ���ؼ��� ���� ����� �ּ��� �ܴ�.
#/** stg_hash_key function.
# *
# *		NTAM �ڵ�ȭ 1���� ���� �Լ� 
# *
# *  (���� B) - �Ϸ� 
# *  STG_HASH_KEY typedef struct ... ��� ���� �޾Ƽ� 
# *  STG_HASH_KEY�� �� ���� save_typedef , flat_save_typedef�� ������ ó���� ���Ŀ�, 
# *  2������ ¦���� ó�� �ٽ� save_typedef , flat_save_typedef�� ������ code�� �ڵ����� ������־�� �� ���̴�.
# *  KEY�� DATA�� �и��� ��. 
# *  
# *  (���� C) - �ڵ� �غ� �Ϸ�
# *  +HASH_INIT+ ���� ���� �� �κп� �ʱ�ȭ�� �����ϰ� ���� ���̸�, 
# *  ����Ǵ� ������ �տ� �̸� ���ǵ� �͵鸸�� ����Ͽ��� �Ѵ�.
# *	
# *	 (���� A) - �Ϸ�
# *	 ID�� define�ϰ� �Ͽ� structure���� �ڵ����� define���� ������ ������ �� ���̴�. STRUCTURE TYPE�� �� ���̴�.  
# *	 switch���� case�κ��� �̰����� ó���� �ؾ��ϸ�, ������ ���ؼ� � ���� ��� �ٲ��������� upr�� ó���� �ؾ��� ���̴�.  
# *  TIME64 ó��
# *
# *  @param  $parm_member_prefix    a_ (�̿� ���� name�� prefix�� ����)
# *  @param  $parm_member_contents    stAAA�� ������ ���⿡ ��
# *  @param  $parm_member_comment    � �Ϳ��� nested�Ǵ� ������ �ּ��� ǥ���ϱ� ���ؼ�
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl�� �����Ͽ� flat....h �� ���� ȭ��
# *
# *  @exception  nested structure��  ���ο� �����Ѵ� ���� ó�� �ȵ�.
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
	## typedef struct ... { �� ���� } ....; �� ���ش�.
	unless($parms =~ s/typedef\s+struct\s+([\w\s]+)\{//){ die $error = 5;}
	unless($parms =~ s/\}\s+(\w+)\s*\;//){ die $error = 6;}

	@members = split(";",$parms);
	$cnt = @members;
	$cnt--;		# �ǵ��� ; �� �ڴ� �����Ƿ� �̰��� ���ܸ� �����־����.
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
		if($members_name[$i] =~ /(\w+)\s*\[(\s*[\w]*\s*)\]\s*/){	##  [] array�� ����ɶ��� ó��
			$members_name[$i] = $1;
			print_fp("stg_hash_key | $members_type[$i]   $members_name[$i]\n",DBG);
		}
	}

	for(my $i = 0 ; $i < $cnt-1 ; $i++){
		my $basic_name;
		my $undefined_name;
		# 2������ structure
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
		print_fp("/** \@brief NTAM Corelation �ڵ� �ڵ� - STG_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);

		# 2�� �߿� key�� �Ǵ� structure (KEY)
		$member_typedef = "typedef struct _st_key_$members_name[$i+1]_$members_name[$i] \{ \n";
		$member_typedef .= "\t$members[$i+1]\;\n";
		$member_typedef .= "} STG_KEY_$members_name[$i+1]_$members_name[$i] \;\n";
		print_fp("stg_hash_key | \[$i\] $member_typedef\n",DBG);
		print_fp("/** \@brief NTAM Corelation �ڵ� �ڵ� - STG_KEY_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);

		# 2���߿� data�� �Ǵ� �κ����� TimerId�� �߰� �ȴ�. (DATA)
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
		print_fp("/** \@brief NTAM Corelation �ڵ� �ڵ� - STG_DATA_$members_name[$i+1]_$members_name[$i]\n  \@see $FileName\n*/\n",DBG,OUTH);
		print_fp("$member_typedef",DBG,OUTH);
		$member_typedef =~ s/\n//g;
		#flat_save_typedef($member_typedef);
		save_typedef($member_typedef);
	}

	# 2���߿� data�� �Ǵ� �κ����� TimerId�� �߰� �ȴ�. (DATA)
	#$member_typedef = "typedef struct STG_$struct_name"."_DATA \{ \n";
	#for(my $j = 0 ; $j < $cnt ; $j++){
	#$member_typedef .= "\t$members[$j]\;\n";
	#}
	#$member_typedef .= "\tU64			$stg_hash_timer_name\; \n} STG_$typedef_name"."_DATA \;\n";
	#print_fp("stg_hash_key | $member_typedef\n",DBG);
	#print_fp("/** \@brief NTAM Corelation �ڵ� �ڵ� - STG_$typedef_name"."_DATA \n  \@see $FileName\n*/\n",DBG,OUTH);
	#print_fp("$member_typedef",DBG,OUTH);
	#$member_typedef =~ s/\n//g;
	#flat_save_typedef($member_typedef);
	#save_typedef($member_typedef);

}

# function.upr�� ������ subroutine�� ���ؼ��� ���� ����� �ּ��� �ܴ�.
#/** stg_association function.
# *
# *		NTAM �ڵ�ȭ 2���� ���� �Լ� 
# *
# * DURATION , EQUAL , AVERAGE �� ������ ����� ����� ���̸�, �ٸ� Table�� ������ ������ ����Ѵ�.
# * ���� �⺻�̵Ǵ� call�� ���� structure���� �� LOG���� ù��° msg�鸸 ���� �ȴ�. 
# * �� ù��° �޽����� ���� ������ ����� ���ο� Combination Table�� �����ϰ� �Ǵ� ���̴�.  
# *
# * TIME64 DURATION64 	FieldName ( 1st Parm : TIME64 , 2nd Parm : TIME64);	/// 1st , 2nd������ ���� (1st - 2nd)
# * STIME  DURATION32 	FieldName ( 1st Parm : STIME , 2nd Parm : STIME );	/// 1st , 2nd������ ���� (1st - 2nd)
# * TIME64 ABSDURATION64 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd������ ���� abs(1st - 2nd)
# * STIME  ABSDURATION32 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd������ ���� abs(1st - 2nd)
# * (x)    EQUAL 		FieldName ( 1st Parm);				/// 1st Parm�� �״�� ���
# * U32    AVERAGE 	FieldName ( 1st Parm : U32 , 2nd Parm : U32);	/// 1st / 2nd
# *
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl�� �����Ͽ� flat....h �� ���� ȭ��
# *
# *  @exception  nested structure��  ���ο� �����Ѵ� ���� ó�� �ȵ�.
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
			$lcheck = "[0]";		# check�� �� ���� check�����ν� ���⿡ ���� �ִ����� Ȯ���ϱ� ���ؼ� 
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
						print STDERR "�� �ٿ��� pthis�� $l_st_name ���� ��밡���մϴ�. $1�� �� �ٿ����� ���ȵ�\n";
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

					# ���� �̰��� Ǯ�� pthis�� �׳� structure�� ����� �Ǿ����� 
					# �׽� ����Ǵ� ������� ����� �ִ�. ���⼭�� pthis�� ���� ����ϱ� ���ؼ� list�� ���� �ʴ� ���̴�.
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
		$new_typedef =~ s/\/\*.+\*\///g;    # �ּ��� ����
	}

	flat_save_typedef($new_typedef);
	# save_typedef������ ������ �ּ����� ������ �ȵ�.
	save_typedef($new_typedef);
}

# function.upr�� ������ subroutine�� ���ؼ��� ���� ����� �ּ��� �ܴ�.
#/** stg_stat_table function.
# *
# *		NTAM �ڵ�ȭ 2���� ���� �Լ� 
# *
# * DURATION , EQUAL , AVERAGE �� ������ ����� ����� ���̸�, �ٸ� Table�� ������ ������ ����Ѵ�.
# * ���� �⺻�̵Ǵ� call�� ���� structure���� �� LOG���� ù��° msg�鸸 ���� �ȴ�. 
# * �� ù��° �޽����� ���� ������ ����� ���ο� Combination Table�� �����ϰ� �Ǵ� ���̴�.  
# *
# * TIME64 DURATION64 	FieldName ( 1st Parm : TIME64 , 2nd Parm : TIME64);	/// 1st , 2nd������ ���� (1st - 2nd)
# * STIME  DURATION32 	FieldName ( 1st Parm : STIME , 2nd Parm : STIME );	/// 1st , 2nd������ ���� (1st - 2nd)
# * TIME64 ABSDURATION64 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd������ ���� abs(1st - 2nd)
# * STIME  ABSDURATION32 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd������ ���� abs(1st - 2nd)
# * (x)    EQUAL 		FieldName ( 1st Parm);				/// 1st Parm�� �״�� ���
# * U32    AVERAGE 	FieldName ( 1st Parm : U32 , 2nd Parm : U32);	/// 1st / 2nd
# *
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl�� �����Ͽ� flat....h �� ���� ȭ��
# *
# *  @exception  nested structure��  ���ο� �����Ѵ� ���� ó�� �ȵ�.
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
	$stat_typedef{$typedef_name} = $new_func_members;		# stg_stat_table ���� ���� func���� �����ϰ�, stg_hash_key()�ȿ��� �̸� ����Ͽ� .c ȭ���� �����. 

	flat_save_typedef($new_typedef);
	save_typedef($new_typedef);
}


# function.upr�� ������ subroutine�� ���ؼ��� ���� ����� �ּ��� �ܴ�.
#/** stg_combination_table function.
# *
# *		NTAM �ڵ�ȭ 2���� ���� �Լ� 
# *
# * DURATION , EQUAL , AVERAGE �� ������ ����� ����� ���̸�, �ٸ� Table�� ������ ������ ����Ѵ�.
# * ���� �⺻�̵Ǵ� call�� ���� structure���� �� LOG���� ù��° msg�鸸 ���� �ȴ�. 
# * �� ù��° �޽����� ���� ������ ����� ���ο� Combination Table�� �����ϰ� �Ǵ� ���̴�.  
# *
# * TIME64 DURATION64 	FieldName ( 1st Parm : TIME64 , 2nd Parm : TIME64);	/// 1st , 2nd������ ���� (1st - 2nd)
# * STIME  DURATION32 	FieldName ( 1st Parm : STIME , 2nd Parm : STIME );	/// 1st , 2nd������ ���� (1st - 2nd)
# * TIME64 ABSDURATION64 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd������ ���� abs(1st - 2nd)
# * STIME  ABSDURATION32 	FieldName ( 1st Parm , 2nd Parm);	/// 1st , 2nd������ ���� abs(1st - 2nd)
# * (x)    EQUAL 		FieldName ( 1st Parm);				/// 1st Parm�� �״�� ���
# * U32    AVERAGE 	FieldName ( 1st Parm : U32 , 2nd Parm : U32);	/// 1st / 2nd
# *
# *
# *  @return    void
# *  @see       flat_hdr_gen.pl : structg.pl�� �����Ͽ� flat....h �� ���� ȭ��
# *
# *  @exception  nested structure��  ���ο� �����Ѵ� ���� ó�� �ȵ�.
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
	$combi_typedef{$typedef_name} = $new_func_members;		# stg_combination_table ���� ���� func���� �����ϰ�, stg_hash_key()�ȿ��� �̸� ����Ͽ� .c ȭ���� �����. 

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
	$TAG_DEFINE{$state_diagram_vertex_name} =~ s/\/\*.+\*\///g;    # �ּ��� ����

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
	$TAG_DEFINE{$tag_auto_define_name} =~ s/\/\*.+\*\///g;    # �ּ��� ����

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
# // pINPUT-> ���� �����ϴ� �Ϳ� ���ؼ� Get_Member_ ���� �ϴ� ���� ������ ����.
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
		## if_var_member_var �� operand �� ���� �Ͱ� pINPUT-> �� ���� �͸��� ��Ī�� ���̴�.
		##  ������ code������ �߿��� ���̾�����. ������ �߿����� �ʴ�.
		## ���Ŀ� �� ������ ������� ���� ���ܵδ� ���̴�.
#$$undefined_name{"if_var_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#} 
	$$undefined_name{"if_var_member"} = $if_var;
#if($if_val =~ /^pINPUT\s*->\s*/){
#$temp = $if_val;
#$temp =~ s/^pINPUT\s*->\s*//;
		## if_val_member_var�� ���������� ��������� �ʵ�, Ȥ�� ���� �׳� ���ܵδ� ���̴�.
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
		## if_val_member_var�� ���������� ��������� �ʵ�, Ȥ�� ���� �׳� ���ܵδ� ���̴�.
		$$undefined_name{"if_var_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#}
	$$undefined_name{"if_var_member"} = $if_var;
#if($if_val =~ /^pINPUT\s*->\s*/){
#$temp = $if_val;
#$temp =~ s/^pINPUT\s*->\s*//;
### if_val_member_var�� ���������� ��������� �ʵ�, Ȥ�� ���� �׳� ���ܵδ� ���̴�.
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
# // pINPUT-> ���� �����ϴ� �Ϳ� ���ؼ� Get_Member_ ���� �ϴ� ���� ������ ����.
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
		## if_var_member_var �� operand �� ���� �Ͱ� pINPUT-> �� ���� �͸��� ��Ī�� ���̴�.
		##  ������ code������ �߿��� ���̾�����. ������ �߿����� �ʴ�.
		## ���Ŀ� �� ������ ������� ���� ���ܵδ� ���̴�.
#$$undefined_name{"if_var_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#} 
	$$undefined_name{"if_var_member"} = $if_var;
#if($if_val =~ /^pINPUT\s*->\s*/){
#$temp = $if_val;
#$temp =~ s/^pINPUT\s*->\s*//;
		## if_val_member_var�� ���������� ��������� �ʵ�, Ȥ�� ���� �׳� ���ܵδ� ���̴�.
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
		## if_val_member_var�� ���������� ��������� �ʵ�, Ȥ�� ���� �׳� ���ܵδ� ���̴�.
		$$undefined_name{"if_var_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#}
	$$undefined_name{"if_var_member"} = $if_var;
#if($if_val =~ /^pINPUT\s*->\s*/){
#$temp = $if_val;
#$temp =~ s/^pINPUT\s*->\s*//;
### if_val_member_var�� ���������� ��������� �ʵ�, Ȥ�� ���� �׳� ���ܵδ� ���̴�.
#$$undefined_name{"if_val_member_var"} = "Get_Member_" . $temp . "(type , pLOG)";
#} 
	$$undefined_name{"if_val_member"} = $if_val;
}

sub stat_function {
	my $function_def;
	### stat file�� header�� ����
	my $set_stat_file = "Set_Stat_Accumulate";
	open(STATACCUM , ">$outputdir/HD/$set_stat_file" . "\.c");
	$filelist{"HD/$set_stat_file" . "\.c"} = "CFILE";
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_stat_file\.c/;
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
				$upr =~ s/\+ToDo\+/library�� ����� ���� Makefile�� ������/;
				$upr =~ s/\+Intro\+/STAT typedef�� ���� functions/;
				$upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				print STATACCUM $upr;
			}
			close UPR;
		print_fp("\#include \"$FileName\"\n",STATACCUM);

if(keys %stat_typedef){
		foreach my $accum_typedef (keys %table_log){
			### combiode file���� function�̸� ����  : void  type�̸�_combi(to,from)
			$function_def = "void Set_" . $accum_typedef . "_STAT_Accumulate($accum_typedef *pMsg , STAT_ALL *pSTAT_ALL)";
			$typedef_stat_func{"Set_" . $accum_typedef . "_STAT_Accumulate"} = "Set_" . $accum_typedef . "_STAT_Accumulate";
			$function_def{"Set_" . $accum_typedef . "_STAT_Accumulate"} = $function_def;
			### statode file����  function�鿡 ���� �ּ� ����
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$accum_typedef\_STAT_Accmulate/;
				$upr =~ s/\+Intro\+/Set Stat Values Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				$upr =~ s/\+Note\+/structg.pl�� ������� �ڵ� �ڵ�/;
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
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
				$upr =~ s/\+ToDo\+/Makefile�� ������/;
				$upr =~ s/\+Intro\+/STAT typedef/;
				$upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				print STATACCUM $upr;
		}
		close UPR;
}
	close STATACCUM;

	### stat file�� header�� ����
	my $set_stat_file = "Set_Stat_Once";
	open(STATONCE , ">$outputdir/HD/$set_stat_file" . "\.c");
	$filelist{"HD/$set_stat_file" . "\.c"} = "CFILE";
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$set_stat_file\.c/;
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
				$upr =~ s/\+ToDo\+/library�� ����� ���� Makefile�� ������/;
				$upr =~ s/\+Intro\+/STAT typedef�� ���� functions/;
				$upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				print STATONCE $upr;
			}
			close UPR;
		print_fp("\#include \"$FileName\"\n",STATONCE);

		foreach my $set_stat_func (keys %stat_typedef){
			### statode file����  function�鿡 ���� �ּ� ����
			my $stat_func_name;
			$stat_func_name = "Set_" . $set_stat_func . "_Once";
			open(UPR,"<function.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FunctionName\+/$stat_func_name/;
				$upr =~ s/\+Intro\+/Set Stat Values Function/;
				$upr =~ s/\+Return\+/void/;
				$upr =~ s/\+See\+/$FileName/;
				$upr =~ s/\+Exception\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				$upr =~ s/\+Note\+/structg.pl�� ������� �ڵ� �ڵ�/;
				if($upr =~ /\+Param\+/){
					print STATONCE " * \@param *p$stg_hash_first_data 		: DATA Pointer\n";
				} else {
					print STATONCE $upr;
				}
			}
			close UPR;

    		### statode file���� function�̸� ����  : void  type�̸�_stat(to,from)
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
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
				$upr =~ s/\+ToDo\+/Makefile�� ������/;
				$upr =~ s/\+Intro\+/STAT typedef/;
				$upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
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

			if($sql_tab_cnt == 0){	# nested�� ���� �̸��� �־��־�� ���� ������
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

###  _main_  __MAIN__ 
 
#TT# $temp = "#A{ a TotalName }A#  Length   }A#";
#TT# print "temp = [$temp]\n";
#TT# if($temp =~ /\#A\{\s*([^#]*)\s*\}A\#/){
#TT# 	print "[$1]\n";
#TT# }
#TT# $temp = "#B{ TotalName �ѱ�\n TTTb #C{ ���ƻ��. CCCCC \n GGGG \n}C#  Length }B#";
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


### structg.pl hash.stg��  ���� INPUT file�� �̸��� �ް� �Ͽ���.
### input file�� �Ѱ��� ���� ������ �Ѵ�.  (���ֿ� ���ľ� �ϴ� ���� �߱� ���)
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
		if ($line =~ /^\s*FileName\s*\:\s*(\S+)\s*$/){  ### FileName���� stg -> h�� ���� �̸�  (FileName = ...)
			$FileName = $1;
			print "STGL : \$FileName = $FileName\n";
			next;
		}
		if ($line =~ /^\s*STG_FileName\s*\:\s*(\S+)\s*$/){  ### FileName���� .stc -> .c�� ���� �̸�  (FileName = ...)
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
			if ($line =~ /^\s*FileName\s*\:\s*(\S+)\s*$/){  ### FileName���� stg -> h�� ���� �̸�  (FileName = ...)
				next;
			}
			if ($line =~ /^\s*STC_FileName\s*\:\s*(.*)\s*$/){  ### FileName���� .stc -> .c�� ���� �̸�  (FileName = ...)
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
				$upr =~ s/\+Warning\+/NTAM������ ����� �տ� flat_st �� ��� �� ���̴�./;
				$upr =~ s/\+ToDo\+//;
				print ProC $upr;
			}
			close UPR;

### STG : Ȯ���� stg�� ������ INPUT FILE
print "structg.pl inputfilename : $inputfilename\n";
open(STG , "<$inputfilename");


### primitives�δ� encode , decode , print ���� �� �����ִ°�? 
### encode , decode , print�θ� ������.
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
	$line =~ s/\@[^@]*\@//g;		## CILOG_HIDDEN , CHECKING_VALUE���� ������. ���� analysis_line������ ó�����ְ� ��.
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
	if ($line =~ /^\s*SET_DEF_START_NUM\s*\:\s*(\d*)\s*$/){  ### DEF_NUM�� start�ð� 
		$typedef_def_cnt = int($1);
		print STDOUT "typedef_def_start_num = $typedef_def_cnt\n";
		next;
	}
	if ($line =~ /^\s*STC_FileName\s*\:\s*(.*)\s*$/){  ### FileName���� .stc -> .c�� ���� �̸�  (FileName = ...)
		my $stc_filename;
		$stc_filename = $1;
		print DBG "\$stc_filenames = $stc_filename\n";
		$stc_filename =~ s/\s//g;
		print DBG "\$stc_filenames = $stc_filename\n";
		@stc_filearray = split(",",$stc_filename);
		next;
	}
	if ($line =~ /^\s*GLOBAL_FileName\s*\:\s*(.*)\s*$/){  ### FileName���� .stc -> .c�� ���� �̸�  (FileName = ...)
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
	if ($line =~ /^\s*FileName\s*\:\s*(\S+)\s*$/){  ### FileName���� stg -> h�� ���� �̸�  (FileName = ...)
		$FileName = $1; 
		print "\$FileName = $FileName\n";
		### OUTH stg->h�� �ϴ� output file  : OUTPUT .H
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
			### �����Ǵ� �� file�� �� �κп� ������ �Ϲ��� ����
			###
			###   �������� +...+ ���� �����Ͽ� ����Ѵ�. �ٲ��ִ� �κ��� �Ʒ��� ���� ����� ������.
			### header.upr�� �о .h file�� file header �κ��� ����Ѵ�.
			### $upr =~ s/\+ToDo\+/Makefile�� ������/;  ������ �ʿ��� �κе��� ��ġ ��Ű�� �ǰ� ���踦 �� ���̴�.
			### *.upr ���� ���� �ٸ� �������� ��ġ�� �ɼ� �ֱ⿡  �Լ�ȭ ��Ű�� ���Ͽ���.
			open(UPR,"<header.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$FileName/;
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
				$upr =~ s/\+ToDo\+/Makefile�� ������/;
				$upr =~ s/\+Intro\+/hash header file/;
				$upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
				print OUTH $upr;
			}
			close UPR;

			open(UPR,"<define.upr");
			while($upr = <UPR>){
				print OUTH $upr;
			}
			close UPR;
			print OUTH "\n\n\n\n/* code gen���� �ڵ����� ���ǵǴ� type��.\n*/\n";
			print OUTH "\#ifndef __TYPEDEF_H__\n";
			print OUTH "\#define __TYPEDEF_H__\n";
			foreach my $def (sort keys %type_define){
				print OUTH "\#define	\t $def   \t $type_define{$def}\n";
			}
			print OUTH "\#endif\n";


		### flat header�� ����� ���� filename
		### flat �̶�  nested structure�� �� ��ģ ���̶� �����ϸ� �ȴ�.
		### NTAM���� ����ϴ� structure ��綧���� ����� ���ε�
		### �̰��� flat_hdr_gen.pl���� ����ϴ� ���̴�.
		###
		### �Ϲ� ������ nested structure�� ������� �ʾҴٸ�
		###    flat_hdr_gen.pl�� �̿��� �ʿ䰡 ������
		###    �� flat�̶�� ������ �ʿ�ġ �ʴ�.
		$FlatFileName = "flat_$FileName";
        open(FLATH,">$outputdir/$FlatFileName");
		$filelist{$FlatFileName} = "INC";
            open(UPR,"<header.upr");
            while($upr = <UPR>){
                $upr =~ s/\+FileName\+/$FlatFileName/;
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
                $upr =~ s/\+ToDo\+/Makefile�� ������/;
                $upr =~ s/\+Intro\+/hash header file/;
                $upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
                print FLATH $upr;
            }
            close UPR;

        ### flat??.h ���� $FileName (*.h) �� include�Ѵ�. 
		$temp = $FileName;
		$temp =~ s/\./_/g;
		print_fp("\#ifndef _$temp\_h_\n",FLATH);
		print_fp("\#define _$temp\_h_\n",FLATH);
		print_fp("\#include \"$FileName\"\n",FLATH);
		print_fp("\#pragma pack(1)\n",FLATH);
		next; 
	}

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

		$undefined_name = "TAG_DEF_ALL";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		if($$undefined_name{$tag_define_name} ne ""){
			print STDERR "ERROR : TAG_DEFINE_START�� �̸��� �ߺ��� : $tag_define_name\n";
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
			$TAG_DEFINE{$tag_define_name} =~ s/\/\*.+\*\///g;    # �ּ��� ����
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
			print STDERR "ERROR : TAG_AUTO_STRING_DEFINE_START�� �̸��� �ߺ��� : $tag_auto_string_define_name\n";
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

		### DUAL������ Level�� ���� DATA�� �����.
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
			# ������ �� �����
##  ???_L0 {����a} = a
##  ???_L0_����a_substr {a�� �� string } = ��ü string
##  ???_L0_����a {���������� ����} = ����
## 		 ���������� ���ڰ� 0 �̸� ���̹Ƿ� return���� �־��� 
			$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$orc} = "_$orc";
			$undefined_name = "TAG_DUAL_STRING_$tag_auto_string_define_name\_L$i\_char";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$$undefined_name{$orc} = "$cc";

			$num_str =~ s/^_\d+//g;			## ���ڷ� ó���ϴ� ���� ù��° ascii ���� ����
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
			$TAG_DEFINE{$tag_auto_string_define_name} =~ s/\/\*.+\*\///g;    # �ּ��� ����

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
			print STDERR "ERROR : TAG_AUTO_DEFINE_START�� �̸��� �ߺ��� : $tag_auto_define_name\n";
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
			print STDERR "ERROR : STATE_DIAGRAM_VERTEX - TAG_AUTO_DEFINE_START�� �̸��� �ߺ��� : $state_diagram_vertex_name\n";
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
	if ($line =~ /typedef\s+struct\s+\w+\s*{/){  $in_typedef = 1 ; }		# ... typedef struct .. �ν� 
	if ($line =~ /^\s*\}\s*(\w+)\s*\;/){  $in_typedef = 2; }


	### //... �����ϴ� �ּ��� /*  ... */ ���·� �ٲ���
	### /// A --> /**	A		*/
	if($line =~ s/\/\/\/\</\/\*\*\</){ $line .= "\*\/ "; }
	### //  A --> /*	A		*/  http:// ���� �־ �����ָ� �ȵȴ�.
	### �⺻�� ///< �� ����ϰų� , /* �� ����ϴ� ���� �⺻���� �Ѵ�. 
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

		if($line =~ /\%.*\%/){			## SHORT �̸��� ��󳽴�.
			$line =~ s/\%\s*(.*)\s*\%//;
			$short = $1;
			$line_prt = $line . "\n";
			#SHORT_DEBUG print DBG "shortname - " . $short . "\n result = $line\n";
		} 
		if($line =~ /\#.*\#/){			## TEXT_PARSING���� RULE�� ��󳽴�. PARSING_RULE (.h�� ����� print���� ���ؼ�)
			## $line_prt ($typedef_org���� ���� : print�ϴ� �͸�  doc���� ó��)
			$temp = $line;
			$temp =~ s/\<(\w+)\>/\{\{$1\}\}/g;
			$temp1 = $temp;
			$temp1 =~ s/\/\*/\<\</g;
			$temp1 =~ s/\*\//\>\>/g;
			$temp =~ s/\#([^\#]*)\#//; # �ּ�ó�� ����
			$line_prt = $temp .  "	\/\*\*< [$temp1] \*\/" . "\n";
			#TEXT_PARSE_DEBUG print DBG "PRT ## ó�� line = " . $line . "\n result = $line_prt\n";
		} 

		## Short ó���� ���� �� line�� ���� �м�
		if($line =~ /^\s*(\w+)\s+(\w+)\s*\[\s*(\d+)\s*\]\s*\;/){	##  [16] array�� ����ɶ��� ó��
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
		elsif($line =~ /^\s*(\w+)\s+(\w+)\s*\[\s*(\w+)\s*\]\s*\;/){	##  [MAX_DEF] array�� ����ɶ��� ó��
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
						$typedef_cr =~ s/\/\*.+\*\///g;    # �ּ��� ����
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
				$bit_line = "";		# ���� \n�� �ƴ�.
				#$bit_prt = "";		# ���� \n
				#$bit_short = "";		# ���� \n
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
		$typedef_cr =~ s/\/\*.+\*\///g;    # �ּ��� ����
		$typedef_org .= $line_prt;
		$typedef_short .= $line_short;
		#TYPEDEF_DEBUG print DBG "DBG_TYPEDEF ($line) ==> \n$typedef\n";
		#TYPEDEF_DEBUG print DBG "DBG_TYPEDEF_CR ($line) ==> \n$typedef_cr\n";
		#TYPEDEF_DEBUG print DBG "DBG_TYPEDEF_ORG ($line_prt) ==> \n$typedef_org\n";
		#TYPEDEF_DEBUG print DBG "DBG_TYPEDEF_SHORT ($line_short) ==> \n$typedef_short\n";
		#TYPEDEF_DEBUG print DBG "short \$line_short ==> \n$line_short";
		$line_short = "";
		### /* ... */ �ּ��� ����
		## �ּ�ó�� ������ $typedef�� \n �� ���� �ʴ� ������ ��������� �Ѵ�.
		## �̸� �ذ��ϱ� ���ؼ��� ��� �ؾ� �ұ�?
		## $typedef_cr�� ������ �� ������ ���δ�.
		$typedef =~ s/\/\*.+\*\///g;
	} 

	if($in_typedef == 2) {
		## �м��� ���ؼ� ���� �����δ� ���̴�. 
		## save_typedef()�� �Ѱ踦 �غ��ϱ� ���ؼ� �ٽ� ������� �κ��̴�.
		## save_typedef()�� �׳� ����ϰ� �� ���Ŀ� �߰��Ǵ� �͵鸸 �̰��� �̿��Ͽ� ó���ϰ� �ȴ�.
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
		### typedef struct ... { ....} ... ; ���� �Ǵ� ������ �̾Ƴ��� �Ǵ� ���̴�.
		### $typedef���� typedef struct ... { ....} ... ;  ������ string�� ���Եȴ�.
		### save_typedef���� �� typedef�� ���� �۾��� ó�����ش�.
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

			## token�� ��� 
			$undefined_name = "LEX_TOKEN_RESULT";
			$from = "LEX_TOKEN";
			$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			$temp = $$from{$TYPEDEF_NAME};
			$temp =~ s/\#\^\#\^\#\^\#/\n/g;			## delimiter�� #^#^#^# �� �����. 
			$$undefined_name{$TYPEDEF_NAME} = $temp;
			$$undefined_typedef_name{"LEX_TOKEN_RESULT"} = $temp;

			## STATE�� ���� ó��  
			#### STATE ���� �κ�
			#### STATE ���� ó�� RULE �κ�
			$temp = $text_parse_state;
			$temp =~ s/\#\^\#\^\#\^\#/\n/g;			## delimiter�� #^#^#^# �� �����. 
			@temp_vars = split("\n",$temp);
			foreach $temp_vars (@temp_vars){
				print DBG "TT:^^: \$temp_vars = $temp_vars\n";	
				if($temp_vars =~ /^\s*(\w+)\:\^\^\:(\w+)\s+(.*)$/){			# delimiter�� :^^: ��� 
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

					# %s �� �ϴ� STATE ����δ� $LOG_KUN_TXTPARSE_STATE_REQ_HDR�� KEY���� �����ϸ� �Ǵ� ���̴�. 
				} else {
					print_fp("TEXT_PARSING : STATE statement ERROR: $temp_vars\n",STDOUT,DBG);
				}
			}

			## RULE�� ���� ó�� --> U32		RespCode;			#PARSING:^^:RESP_HDR:^^:<HTTP>{DIGIT}# 
			#### U32 Respcode; �� ���� ����� �� ���� ���� ������ Set
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
					# ���⼭ ó���Ǵ� ALTERNATIVE�� �Ǿ��� �κ��� �Ʒ��� ���� ó���ϴ� �κп��� 
					# ó�� �Ҽ� �ִ� ������� �ٲ㸸 �ִ� ���̴�.( �Ʒ��� �ٷ� ��������
					# if($temp_vars =~ /^\s*(\S+)\s+(\S+)\;\s*\#(.*)\#\s*$/){ ���� ���������� ó�� 
				}
				if($temp_vars =~ /^\s*(\S+)\s+(\S+)\;\s*\#(.*)\#\s*$/){
					my $vartype = $1;
					my $varname = $2;
					my $var_array_size;
					my $cmd_n_rule = $3;

					$for_prev_line = $temp_vars;
					# ==> KK [U8] [host[20]] [PARSING:^^:REQ_HDR:^^:<HOST>{VALUE}]
					#TEXT_PARSE_DEBUG print DBG "KK [$1] [$2] [$3]\n";

					if($varname =~ /\[\s*(\d*)\s*\]/){	##  [] array�� ����ɶ��� ó��
						$var_array_size = $1;
						$varname =~ s/\[\s*(\d*)\s*\]//;
					} elsif($varname =~ /\[\s*(\w*)\s*\]/){	##  [] array�� ����ɶ��� ó��
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
						# STRING�϶��� Array size , INTEGER�϶��� ������  size
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
# ���� �� �κ��� code�� ������� �ϴ� , type�鿡 ���� ���� ���־�� �ϴ� �͵���
# �߻��� ������ ������ �Ǿ� , Set_Value , Print_Value���� ������־� ���� prt�� Set , Get�ϴ� ������ 
# ���ϰ� ���� �ְ� ������ִ� ���� ���� ������ �ϴ� ������ ���.

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


#== SQL�� WEB���� �̿��Ҽ� �ִ� ������ ������ش�.  <<<<<  START
# flat�� ����ϴ� ������ ����ȴ�. 
# flow���� header��� SQL�� ����� header�� �����Ͽ����� ������ ���δ�.
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
#== SQL�� WEB���� �̿��Ҽ� �ִ� ������ ������ش�.  >>>>>  END



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
			Ichange($stcfile,"STC");			# OUTPUT�ȿ� �����ϰ�, makefile���� �־��.
		} elsif($stcfile =~ /\.stc/){
										# 3��° ���� : stcL�� �ƴ� ���� NULL
			Cchange($stcfile,"STC","","STC");			# OUTPUT�ȿ� �����ϰ�, makefile���� �־��.
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
			Ichange($in,"");			# OUTPUT�ȿ� �����ϰ�, makefile���� �־��.
		} elsif($in =~ /\.stc/){
										# 3��° ���� : stcL�� �ƴ� ���� NULL
			Cchange($in,"","","STC");			# OUTPUT�ȿ� �����ϰ�, makefile���� �־��.
		}
	}
	close UPR;

($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "structg : stc.upr - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);

	print_all_global_var("GLOBAL_post_stc.TXT");

			### OUTH�� STAT���� structure ������ �����Ѵ�.
		if((keys %stat_typedef)){	# �Ѱ��� STAT�� ������ �̰��� ó������ �ʴ´�.
			print OUTH "\n\ntypedef struct _st_STAT_ALL {\n";
			foreach $def (keys %stat_typedef){
				print OUTH "\t$def 	$staticprefix$def\;\n";
			}
			print OUTH "\} STAT_ALL \;\n";
		}

			### OUTH�� �� structure���� type definition # , size�� member���� ���� �����Ѵ�.
			print OUTH "\n\n\n\n/* Define.  DEF_NUM(type definition number)\n*/\n";
			foreach $def (keys %typedef_def_cnt){
				my $hex = sprintf '0x%x' ,$typedef_def_cnt{$def};
				my $tab_cnt =  int((47 - length($def . "_DEF_NUM")) /4);
				print OUTH "\#define		$def" . "_DEF_NUM" . "\t"x$tab_cnt . "  $typedef_def_cnt{$def}			/* Hex ( $hex ) */\n"; 	# stAAA  -> #define STG_DEF_stAAA  10 
			}
			print OUTH "\n\n\n\n/* Define.  MEMBER_CNT(struct���� member���Ǽ� : flat����)\n*/\n";
			foreach $def (sort keys %typedef_member_count){
				my $tab_cnt =  int((47 - length($def . "_MEMBER_CNT")) /4);
				print OUTH "\#define		$def" . "_MEMBER_CNT" . "\t"x$tab_cnt . "  $typedef_member_count{$def}\n"; 	# typedef struct���� member���� �� (flat�����Ǽ�)
			}
			
			### OUTH�� �Լ����� ���� �Ѵ�. extern function_definition
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



			### Flat file.h���� footer�� �߰�
            open(UPR,"<footer.upr");
            while($upr = <UPR>){
                $upr =~ s/\+FileName\+/$FlatFileName/;
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
                $upr =~ s/\+ToDo\+/Makefile�� ������/;
                $upr =~ s/\+Intro\+/hash header file/;
                $upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
                print FLATH $upr;
            }
			close UPR;


	### Makefile�� include�� dependancy�� �� c file�� ���� compile� ���ؼ� ������ش�.
	### %filelist�� ���Ǵ� file���� list�� ������ �ִ�. 
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
			$varname = "TXTPARSE_CASE_IGNORE";		# if   $TXTPARSE_CASE_IGNORE{..} �� ����.
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


	### Makefile�� include�� dependancy�� �� c file�� ���� compile� ���ؼ� ������ش�.
	### %filelist�� ���Ǵ� file���� list�� ������ �ִ�. 
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
				if($member_vars =~ /\s*(\w+)\s+(\w+)\s*\[(\d*)\]/){	##  [] array�� ����ɶ��� ó��
					my $vartype = $1;
					my $varname = $2;
					my $asize = $3;
					print DBG "=$vartype  $type_define{$vartype}  =$varname  =$type_CREATE{$vartype} \( $asize \) \n";
					$varname =~ s/$shortremoveprefix//g;
					print_fp("\t$varname 	$type_CREATE{$vartype}\($asize\)	\,\n",SQL,DBG);
				} 
				elsif($member_vars =~ /\s*(\w+)\s+(\w+)/){			## []�� �������� ó�� 
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
			### �����Ǵ� �� file�� �� �κп� ������ �Ϲ��� ����
			###
			###   �������� +...+ ���� �����Ͽ� ����Ѵ�. �ٲ��ִ� �κ��� �Ʒ��� ���� ����� ������.
			### footer.upr�� �о .h file�� file footer �κ��� ����Ѵ�.
			### $upr =~ s/\+ToDo\+/Makefile�� ������/;  ������ �ʿ��� �κе��� ��ġ ��Ű�� �ǰ� ���踦 �� ���̴�.
			open(UPR,"<footer.upr");
			while($upr = <UPR>){
				$upr =~ s/\+FileName\+/$FileName/;
				$upr =~ s/\+Warning\+/\$type???�� ���ǵ� �͵鸸 ��밡��/;
				$upr =~ s/\+ToDo\+/Makefile�� ������/;
				$upr =~ s/\+Intro\+/hash header file/;
				$upr =~ s/\+Requirement\+/��Ģ�� Ʋ�� ���� ã���ּ���./;
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


## NTAM�� ���� ���� �Ѱ��� �� ������ header file�� �Ѱ� �� ����� ������ ����.
## NTAM������ perl�� �Ѱ� �� ����, ���� header file�� stg�� ������ ���� ���� �����Ը� �ϸ� �� ������ ���δ�. 

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
## ����  : Reload the GLOBAL.TXT files
##     Make the ASN PER's init file
##
## Revision 1.240  2007/04/02 13:09:12  cjlee
## add the comments function in the pstg and stg's file
## ex)
## ##Stc_.....
##
## Revision 1.239  2007/03/30 01:14:44  cjlee
## typedef struct �� ��ȣ Fix ����
##
## Revision 1.238  2007/03/29 00:43:47  yhshin
## 1.235 ����
##
## Revision 1.235  2007/03/28 11:51:04  cjlee
## *** empty log message ***
##
## Revision 1.234  2007/03/28 01:03:35  cjlee
## state_diagram ���� �߰�
##
## Revision 1.233  2007/03/27 12:57:07  cjlee
## state_diagram �߰�
##     - ������ TAG_FLOW�� ���� ����� �ϴ� ����.
##     - ���ο� �䱸������ �߰��ϰ�, ������ �͵� �״�� �����ϱ� ���ؼ� STATE_DIAGRAM ���� ���� ����
##     - <STATE_DIAGRAM_VERTEX:..> </STATE_DIAGRAM_VERTEX:..>  ��
##       <STATE_DIAGRAM_EDGE:..> </STATE_DIAGRAM_EDGE:..> �� ���� �����ؾ���
##     - Example : make sd  �ϸ� ��.  (state_diagram.pstg�� �Ʒ��� stc���� �̿��ϰ� ��)
##
## Revision 1.232  2007/03/27 01:36:47  cjlee
##  ProC (pc) file���� OraMake�� ����� �߰� �ϱ� ���ؼ�
##
## Revision 1.231  2007/03/26 08:17:21  cjlee
## *** empty log message ***
##
## Revision 1.230  2007/03/23 13:54:12  cjlee
## SQL���� �������� ���� �߰�
##
## Revision 1.229  2007/03/22 12:20:38  cjlee
## define���� STG_PARM �����ϰ� ��
##
## Revision 1.228  2007/03/20 06:38:33  cjlee
## TIME DEBUG�� �� ȿ��������
##
## Revision 1.227  2007/03/20 03:30:11  cjlee
## print_all_global_var�� ������ġ �ٲ�
##
## Revision 1.226  2007/03/20 02:33:36  cjlee
## stc���� ���� ����
##
## Revision 1.225  2007/03/16 11:07:09  cjlee
## DB��� �̸����� ������ flat���� ó���ϴ� SQL���� ����� stc�� ����
##
## Revision 1.224  2007/03/16 07:21:40  cjlee
## split ���� �ذ�
##
## Revision 1.223  2007/03/16 06:24:11  cjlee
## *** empty log message ***
##
## Revision 1.222  2007/03/16 00:57:32  cjlee
## IFEQUAL�� 2���� ��簡���ϰ� ��� �߰�
##
## Revision 1.221  2007/03/15 11:33:24  cjlee
## - IFEQUAL�� || , &&  ���� �߰�
## 		�� ������ �־����.
## - #???_DEBUG ��� ������ DBG�� print�ϴ� �κ��� ���� ����.
##
## Revision 1.219  2007/03/15 04:40:22  cjlee
## SQL�� stc���� ���� ���� �ϰ� ����
##
## Revision 1.218  2007/03/15 04:11:38  cjlee
## #== SQL�� WEB���� �̿��Ҽ� �ִ� ������ ������ش�.  <<<<<  START
## #== SQL�� WEB���� �̿��Ҽ� �ִ� ������ ������ش�.  <<<<<  END
## 	�� �̿� ���õ� �Լ� �߰�
## GLOBAL.TXT�� SQL_ARRAY_{typedef �̸�}  ���� ���� ���۵Ǵ� ������ ������.
## SQL  �� Short name ������� �����
##
## Revision 1.217  2007/03/13 04:18:43  cjlee
## *** empty log message ***
##
## Revision 1.216  2007/03/13 04:12:05  cjlee
##  Mantis : [�ذ�] 0000312 :  SB_PASING �ڵ� ���̱�
##
## Revision 1.215  2007/03/12 07:03:04  cjlee
## sql ���� �ذ�
##
## Revision 1.214  2007/03/09 08:14:49  cjlee
## NotIFEQUAL --> NOTEQAUL �� ���� (reserved word�� ���ԵǴ� �����ϱ� ��ġ ����)
##
## Revision 1.213  2007/03/09 06:48:29  cjlee
## ���� IFEQUAL ó�� & inc/dec ��� �߰�
##
## Revision 1.212  2007/03/07 05:35:29  cjlee
## ProC (pc)�� file �Ѱ��� ����
##
## Revision 1.211  2007/03/07 05:26:58  cjlee
## *** empty log message ***
##
## Revision 1.210  2007/03/07 05:15:21  cjlee
##  �� file���� structure�� Prt, Dec , Enc , cilog�� �Ѱ����� file�� ����
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
## lex���� error �ذ�(Makefile)
##
## Revision 1.204  2007/03/06 08:22:41  cjlee
## ����  : STC HD DB ������ directory�� ������.
##     stcI �� file�� (�⺻������ default�� ���� �͵�)�� STC�Ʒ� �����ǰ� �ٲ�
##
## Revision 1.203  2007/03/06 04:27:24  cjlee
## SQL ���� ���� ���� �� table space �̸� �߰�
##
## Revision 1.202  2007/03/06 00:10:06  yhshin
## IP4 type U32��
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
## REVERSE ARRAY ITERATOR �߰�
##
## Revision 1.197  2007/02/28 01:45:02  cjlee
## ANALYSIS ���� ���� �� �߰� (type , member_full )
## STG_PAR_ARRAY ���� ���� �� �߰� (_NEXT_)
##
## Revision 1.196  2007/02/27 08:01:45  cjlee
## ����  :  EDGE ���� ����
## - EDGE�� �����Ҷ� , current_state 2 next_state �� ����� �ߴ� ����
## 	--> current_state _CONDITION_  if_value�� �Ͽ� �������� ó���ϵ��� ������.
##
## Revision 1.195  2007/02/26 12:21:58  yhshin
## ANALYSIS_\_STG_TYPEDEF ����
##
## Revision 1.194  2007/02/26 10:41:06  cjlee
## STG_PAR_ARRAY ���� ���ϴ� �������� ����Ű�Ǽ� �ְ� ����.
##
## Revision 1.193  2007/02/26 04:24:19  cjlee
## - FileName : ....   �� �̿��� �ٸ� directory�� file�� ���� ����
## - stcI_FILEPREFIX : ....   �� �̿��� �ٸ� directory�� file�� ���� ����
##
## Revision 1.192  2007/02/23 11:27:19  cjlee
## stc�� ����� *.c *.cpp *.pc ���� #include <�ڽ�.h> �� �߰�������
##
## Revision 1.191  2007/02/23 05:58:11  cjlee
## bug fix
##
## Revision 1.190  2007/02/22 08:04:02  cjlee
## ONETIME
##
## Revision 1.189  2007/02/21 08:16:08  cjlee
## TABLE_LOG�� ���� �տ� ������� ������ �����ϰ�
## STG_TYPEDEF �� ��� �߰�
##
## Revision 1.188  2007/02/20 11:16:19  cjlee
## stcI�� postfix , prefix filename �߰�
##
## Revision 1.187  2007/02/20 10:51:09  yhshin
## OraMake �� ���� // �ּ� ����
##
## Revision 1.186  2007/02/20 10:21:14  cjlee
## SIZE���� ARRAY�� ������ ��ȣ��...
##
## Revision 1.185  2007/02/20 09:43:18  yhshin
## LEXS
##
## Revision 1.184  2007/02/20 08:43:20  cjlee
## ARRAY_SIZE hash�� �߰�
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
## �ּ�ó������
##
## Revision 1.179  2007/02/20 03:47:09  cjlee
## STG_PARM ��� �߰�
##
## Revision 1.178  2007/02/16 04:52:15  cjlee
## FLOW���� VERTEX�� EDGE�� ���еǾ� ó����
##
## Revision 1.177  2007/02/01 01:41:13  cjlee
## 3. ����  : stc / stcI �� ó�� ���� �ذ�
## - stc input file�鿡�� stc�� stcI ���� �켱������ ���� �Ǿ����ְ�,
## 	stc , stcI�� ��� ó���ϰ� �ȴ�.
## - ���� : stcI�� ���� ó���ϰ� , stcI�� �Ǹ� stc�� ���� �ʴ´�.
##
## Revision 1.176  2007/01/16 06:00:02  cjlee
## stcI ���� file Prefix ��� �߰�
##
## Revision 1.175  2007/01/16 01:34:57  cjlee
## BIT ���� ó�� / SB_PARSING ó�� �߰�
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
## typedef_def_cnt �ʱ�ȭ ���� : 100���� set�Ͽ����� 101���� ������ ���̴�.
##
## Revision 1.169  2006/11/15 07:30:57  cjlee
## *** empty log message ***
##
## Revision 1.168  2006/11/15 07:02:32  cjlee
## TAG ����
## CHECKING_VALUE ���� �� log_table.html���� ��� ���ؼ� (log_table.stc0
##
## lex_option�߰�   : Lex_Compile_Option
## BODY�� ��� -i option�� �ʿ��ϱ� ������
##
## Revision 1.167  2006/11/13 08:05:26  cjlee
## - structg.pl
## 	@CHECKING_VALUE:string , string...@
## 	@CHECKING_VALUE:digit~digit , digit~digit...@
## 	�� �߰������ν� CILOG�� ���� ����� �Ǵ����� check�Ҽ� �ִ�.
## - aqua.pstg
## 	���� �߰�   $ make aqua
## 	GLOBAL.TXT �� AQUA2/TOOLS/HandMade ���� �ʿ���.
##
## Revision 1.166  2006/11/11 08:27:47  cjlee
## TAG_DEF_ALL_NUM_  ���� �߰�
##
## Revision 1.165  2006/11/11 07:10:56  cjlee
## log_table.html�� ���� �ذ� (��ȣ�� HIDDEN�� �ݿ����� ����)
##
## Revision 1.164  2006/11/11 04:35:13  cjlee
## ASSOCIATION �� ALTERNATIVE_ASSOCIATION�� �߰���.
##
## Revision 1.163  2006/11/10 06:50:35  cjlee
##   /*  +<+$TAG_DUAL_STRING_ITKEY_L1IT1VALUE_string{0}+>+   */
##   �� �߰��Ͽ� debugging�� ���� ������ �ְ� ��.
##
##   CLEX_ITKEY_Depth5() �߰�
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
## CLEX ��� �߰�
##
## Revision 1.158  2006/11/07 05:33:43  cjlee
## HIDDEN�� ���� �ʰ�
##
## Revision 1.157  2006/11/07 00:52:56  cjlee
## flow���� GEt_Member_..() �Լ��� call�ϴ� �κ��� ����
##
## Revision 1.156  2006/11/03 09:31:44  cjlee
## ANALYSIS_$typedef_name\_TABLE_COMMENTS �̶� GLOBAL ���� �̸� �߰�
##
## Revision 1.155  2006/11/02 01:17:34  cjlee
## ITERATE���� HASH(%) �� ARRAY(@) ��� �ǰ� �߰��Ͽ���.
## ARRAY --> cilog.stc�� �����Ͻÿ�
## �� ���� *.stc�ȿ��� HASH�� �̿��ϰ� �Ǿ�������.
## array�� ����ϴ� ���� : ������ ������ �Ҷ�
## array Ư¡ : KEY�� 0..? �ϴ� index , VALUE�� �� ���� ���̴�.
##
## Revision 1.154  2006/11/01 09:44:37  cjlee
## PARSING_CASE_IGNORE �߰� : flex�� case insensitive�ϰ� -i option ó��
##
## Revision 1.153  2006/11/01 05:23:42  cjlee
## *** empty log message ***
##
## Revision 1.152  2006/11/01 04:42:22  cjlee
## STRING type�߰�
##
## Revision 1.151  2006/11/01 01:29:20  cjlee
## - CILOG_HIDDEN �߰� : Dummy �� ã���� �Ѱ� ���� ���Դϴ�. (aqua.pstg)
##    @�� typedef�ȿ����� Ư���� �ǹ̸� ���� (CILOG_HIDDEN)
##    $ �� ���������� Ư���� �ǹ̸� ���� (CASE_IGNORE)
## - cilog.stc �߰� (CILOG�� ���ؼ�)
## - DiffTIME64 ����
## - STIME������ ���� (0�̸� 1970���� �ƴ� 0����)
## - make tt �߰� (������ ���ؼ�)
##
## Revision 1.150  2006/10/30 09:00:53  cjlee
## if_var if_val�� � ���̵� ���� �ְ� ����
##
## Revision 1.149  2006/10/30 08:43:57  cjlee
## pINPUT���� fix
##
## Revision 1.148  2006/10/30 00:46:56  cjlee
## CASE_IGNORE����
##
## Revision 1.147  2006/10/27 06:33:33  cjlee
## flow���� ���� ����
##
## Revision 1.146  2006/10/27 02:56:55  cjlee
## TAG_FLOW���� pINPUT , pTHIS�� fix��Ű�� struct �̸��� �ް� �����Ͽ���.
##
## Revision 1.145  2006/10/20 07:53:20  cjlee
## strcmp -> strncmp
##
## Revision 1.144  2006/10/19 08:51:46  cjlee
## *** empty log message ***
##
## Revision 1.143  2006/10/19 04:05:27  cjlee
## tag_auto_define���� �ڿ� (����)�� �־ �� ó���ϰ� �ٲ�.
## bug fix
##
## Revision 1.142  2006/10/16 08:47:47  cjlee
## flow �ݿ���
##
## Revision 1.141  2006/10/13 03:33:18  cjlee
## *** empty log message ***
##
## Revision 1.140  2006/10/13 03:22:38  cjlee
## SVCACTION
##
## Revision 1.139  2006/10/12 06:02:28  cjlee
## STG_Diff64    S64�� ���� �ذ�
##
## Revision 1.138  2006/10/12 02:28:26  cjlee
## TAG_DEF���� ����
## - TAG_DEF_ALL �� �ؼ� ��� DEF���� ���� �������
## - TAG_DEF  , TAG_AUTO_DEF , TAG_AUTO_STRING_DEF  �� ���� ����ȴ�� ������ ���־�����
## - TAG_AUTO_STRING_SEF�� ���� 2���� string ���� ���ؼ� TAG_DUAL_STRING���� ���Ǹ� �߰��Ͽ���.
##
## Revision 1.137  2006/10/10 07:09:11  cjlee
## Compare �߰�
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
## FPP �߰� (FILEPRINT
##
## Revision 1.132  2006/10/10 01:34:37  cjlee
## STIME IP4�� print�� ����
##
## Revision 1.131  2006/10/10 01:09:52  cjlee
## FPP �߰� (FILEPRINT) - �⺻Ʋ
##
## Revision 1.130  2006/10/10 01:08:48  cjlee
## FPP �߰� (FILEPRINT) - �⺻Ʋ
##
## Revision 1.129  2006/10/10 01:03:04  cjlee
## 1.27�� ����
##
## Revision 1.127  2006/10/02 01:22:00  cjlee
## ���� ���� : tag_key������ TAG_DEFINE���� ���� ������� �� ����
##
## Revision 1.126  2006/09/29 08:56:52  cjlee
## TAG_FLOW���� ������ / * ó�� �߰� �� ���� ���� ����
## - thisLOG->ResponseCode/1000
## - thisLOG->ResponseCode*1000  �� 2���� operation�� �����ϸ�
## - 300 �̶� �� �Ӹ� �ƴ϶� ,  300-400 ���� ���� ������ �����ϴ�.
##
## Revision 1.125  2006/09/29 06:25:53  cjlee
## *** empty log message ***
##
## Revision 1.124  2006/09/29 02:35:36  cjlee
## STC�� ���� compile�ǰ� OUTPUT/Makefile�ȿ� ���� ����
##
## Revision 1.123  2006/09/28 02:49:12  cjlee
## NIPADDR -> HIPADDR
##
## Revision 1.122  2006/09/27 00:54:28  cjlee
## *** empty log message ***
##
## Revision 1.121  2006/09/27 00:41:38  cjlee
## tag_key�� ���ؼ��� save_typedef�� ����
##
## Revision 1.120  2006/09/26 08:01:15  cjlee
## STG_ASSOCIATION���� compile �Ϸ�
##
## Revision 1.119  2006/09/26 07:27:24  cjlee
## STG_ASSOCIATION �߰�
## - STG_COMMON -> STG_ASSOCIATION���� ����
## - pstg.pl���� <TAG_KEY> ó�� ����
## - ASSOCIATION�� ���� ASSOCIATION.stcI �⺻ �߰�
##
## Revision 1.118  2006/09/26 01:13:58  dark264sh
## S32, U32�� HEXA���� ��� ���� 10������ �ﵵ�� ����
##
## Revision 1.117  2006/09/25 06:07:04  dark264sh
## dAppLog�� ��� ���ؼ�
## FPRINT(stdout,
## =>
## FPRINT(LOG_LEVEL,
## �� ����
##
## Revision 1.116  2006/09/21 08:39:06  cjlee
## define�� ���� abbreviation name ���� : PRINT...�Լ�
##
## Revision 1.115  2006/09/21 07:22:52  cjlee
## URL �� parameter ó�� �Ϸ�
##
## Revision 1.114  2006/09/21 05:40:21  cjlee
## METHOD�ߺ�����
## TAG_DEFINE ����(AUTO����) �ߺ� ���� ���� �߰�
##
## Revision 1.113  2006/09/21 04:32:29  cjlee
## 1. CHANNEL ���� ����� �� ����.
## 2. HTTP_LOG���� METHOD�� ���� �������� �������� ���� ó
##
## Revision 1.112  2006/09/20 06:01:50  cjlee
## %function_def�� PARSING_RULE���� ACTION �߰� (ó���� ���൵ �ǰ� �߰�)
##
## Revision 1.111  2006/09/20 01:26:33  cjlee
## ALTERNATIVE_RULE�� ���� ���� ó�� �Ϸ�
##
## Revision 1.110  2006/09/19 02:42:24  cjlee
## WIPI download  �������� �����߰�
##
## Revision 1.109  2006/09/08 06:14:33  cjlee
## var_array_size���� %define_digit�ȿ� ������ �̸� �״�� ����ϰ� ��
##
## Revision 1.108  2006/09/08 05:27:42  cjlee
## Configuration File ó��
##
## Revision 1.107  2006/09/07 06:23:46  cjlee
## stcI ���� �߰�
##
## Revision 1.106  2006/09/07 00:28:26  cjlee
## debugging
##
## Revision 1.105  2006/09/06 09:14:27  cjlee
## bug ���� : GET_TAG_DEF... �Լ�
##
## Revision 1.104  2006/09/06 08:21:12  cjlee
## *** empty log message ***
##
## Revision 1.103  2006/09/06 08:16:25  cjlee
## GET_TAG_DEF �߰�
##
## Revision 1.102  2006/09/06 06:56:03  cjlee
## <TAG_KEY> ��� ����Ҽ� �ְ� �߰�
## structg.pl ������ �̰��� ���� ó���Ҽ� �ְ� ���ش�. : ���⼭�� .h���� �߰�
## pstg.pl ������ �ڿ� �߰���������, structg.pl�� �� ������ �ϹǷ� �� KEY��� ���ǵ� �������� strucuture���� dec,enc,prt���� �پ��� �Լ����� �����Ǿ���.
##
## Revision 1.101  2006/09/06 01:15:40  cjlee
## reducing the print statement
##
## Revision 1.100  2006/09/06 01:13:30  cjlee
## ����� : membertype�� structure�� ��쿡�� Get_Member.. ���� ���� -> �׷��� userfile.stg���� ���� library compile�� ���� �߻����� ����
##
## Revision 1.99  2006/09/05 06:49:12  cjlee
## TAG_AUTO ���� ó�� �Ϸ� : compile �Ϸ�
##
## Revision 1.98  2006/09/05 05:46:21  cjlee
## TAG_AUTO_STRING_DEFINE_START  �߰�
## : STRING  DEFINE����  �� �����Ǿ�����
##   DEFINE�� �͵鿡 �ڵ����� ��ȣ�� ������,
##   STRING ���� ���õ� �Լ����� ��������ϴ�.
##   Print_TAG_STRING_???(debug str , char *string)
##
## Revision 1.97  2006/08/29 04:06:18  cjlee
## BIT ó�� �Ϸ� : compile �Ϸ�
##
## Revision 1.96  2006/08/29 02:21:31  cjlee
## BIT operation �߰�
## 	BIT16			a1 (1 : PING);				/**< TOS�� ù��° bit */
## 	BIT16			ctime (12 : PING);			/**< TOS ������ 3���� bit */
## 	BIT16			b ( 3 : PING);
##
## ����� : flat , Dec , Enc , Prt ��� ������
##
## Revision 1.95  2006/08/25 08:33:21  cjlee
## make flow , make test�� ��� �����ϰ� ��.
## ó���� include�� ������ . STC����� *.l�� ���� include�� �������� ����.
##
## Revision 1.94  2006/08/25 07:11:29  cjlee
## LOG_member_Get_func.stc : include L7.h�߰� (header�� �˾Ƽ� �߰��� �ؾ� �� ������ ����)
## 	include�� �ڵ����� �ϸ� .l ������ ������ �߻���.
## makefile.stc : LOG_KUN.stc������ ���� .l�� ������Ű�� �͵鿡 ���ؼ� �ڵ����� makefile�ȿ� �����ϰ� ����
## 	STC�ȿ��� make echo�� �ϰ� ���� �Ϳ� ���ؼ� make .. �ϸ� ���� ȭ���� �������
## test.pstg : ME , KUN�� ���� PARSING�� �����ϴ� �͵鿡 ���ؼ� Makefile���� �ڵ����� ����� ��.
## structg.pl :
## 	IFEQUAL�� �ݴ�� ����Ǵ� NOTEQUAL �߰�
## 	���� �������� �̸��� AAa.l���� ó���ǰ� �ٲ�
## 	ġȯ ���õ� �κ��� replace_var_with_value �Լ��� ����
## 	GLOBAL_Pre_STC.TXT �߰� : STC�� �����ϱ� ���� global ������ ����
##
## Revision 1.93  2006/08/23 01:32:56  cjlee
## *.stc���� IFEQUAL ���� multi-line ó�� �Ϸ�
## #{    ...   }# ���� multi-line ó��
## ������ �Ѷ����� IFEQUAL(A,B)  ... ���� ������ ���� �׳� ����ϸ� ��
## multi-line�϶��� ���� #{ .. }#�� ����ϸ��.  flow.stc�ȿ� ���� �߰��Ͽ���.
##
## Revision 1.92  2006/08/22 09:17:24  cjlee
## <TAG_FLOW_START:PAGE>���� action�� ���� multi line ó�� �Ϸ�
## % .. %   # .. # �����϶��� # # ���� ó��
## �������϶��� #{     ������    }# ���� ���� �˸�
##
## Revision 1.91  2006/08/22 05:34:26  cjlee
## 2. stg�� multi�� ó���Ҽ� �ְ� ���� stg���� ������ ������쿡�� �̰͵��� �� ó���Ҽ� �ִ� stgl�� ������� �ؾ� �� ������ ���δ�. (�Է� file�� stgl �� ��쿡�� List�� �ؼ��Ͽ� ó���ϵ��� structg.pl �� �����ϸ� �� ������ ���δ�.) - precompile���ñ��� �߰��� �ϴ� ���� ���� ������ ���δ�.
## �Ѱ��� ����ִ� ���� ���� ���̶� �����ȴ�. FileName���� .h�� ���� ������ �Ǵ� ���̰�, stg�ȿ� �ִ� FileName�� ���� �ǰ� �� ���̴�.
## test.stg , flow.stg�� �ִٰ� �ϸ� __ FileName�� ���� , STC_FileName �� ��ġ�� ,
## *.stg�� ���� �͵��� FileName.h -> $outputdir/FileName.stg�� ������. �� ����� ���� ������ ó���� �Ѵ�.
##
## Revision 1.90  2006/08/22 04:37:29  cjlee
## *.h�ȿ� #ifndef  __filename_h__  �� �̿��Ͽ� ���� .h��  include�ص� ������ ���� �ʰ� ����.
##
## Revision 1.89  2006/08/22 02:10:11  cjlee
## #define�� ó�� ���� : ���� ���� + TAG��������
##
## Revision 1.88  2006/08/22 01:28:31  cjlee
## 1. precomile�� �ؾ��ϴ� �͵鿡 ���� Ȯ���ڴ� .pstg �� �ϴ� ���� ���� ������ ���δ�. �̰��� �ϸ� Ȯ���ڰ� .stg�� ������ �ϸ� �� ������ ���δ�.
## 	pstg.pl ����
## 	pstg�� file�� : test.stg -> test.pstg  , aqua.stg -> aqua.pstg
## 	Makefile�� flow , aqua , test  �������� �߰�
##
## Revision 1.87  2006/08/21 10:57:26  cjlee
## Page state diagram TEST main program �Ϸ�
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
## $save_typedef���� member check�� table_log �϶��� �ٸ� type�϶� die
##
## Revision 1.82  2006/08/18 10:29:34  cjlee
## stc.upr�� ����� .stc�� ����ϸ� OUTPUT�ؿ� �ڵ����� �����ϰ� �ϴ� �� �߰�
##   ���� LOG_member_Get_func.stc �� �߰�
## flow.stc : state_go , print_state���� �Լ��� �߰�������, flow.c��  structure�� ������� member�� ���� ���Ҽ� �ִ� c++���� member get�Լ� ���
## flow.stg : state�鿡 ���� define�� �ڵ� ���� ����
## structg.pl :
##  - stc.upr�� ���� ó�� �߰�
##  - ITERATE�ȿ��� Set : A { B } = "C" �߰�
##  - stc.upr�� �͵��� OUTPUT�Ʒ� �ٷ� �����ǰ� ��
##  - stc.upr���� ���� Makefile�� �߰��ϰ� ��
##  - Set Hash 1 ������ �����.... (���� ����)
##  - ó�� ���� ���� : Makefile�� ����� STCó�� --> STC ó���� Makefile ���� ����
##  - %save_typedef_member  , %save_typedef_name �߰� ���� : LOG_member_Get_func.stc���� ���
##
## Revision 1.81  2006/08/17 09:46:37  cjlee
## ȭ�� print �� DBG�� ����
##
## Revision 1.80  2006/08/17 09:42:15  cjlee
## PAGE FLOW ���� �⺻ ��� �Ϸ�
## flow.stg / flow.stc ��
##
## Revision 1.79  2006/08/16 11:20:42  cjlee
## SET_DEF_START_NUM :     ��ɾ� �߰�
##
## Revision 1.78  2006/08/16 08:53:46  cjlee
## State Diagram�� ����� �׸��� �ְԼ���
## structg.pl ������ $1, $2�� ���� ���� ����
##
## Revision 1.77  2006/08/16 05:46:07  cjlee
## IFEQUAL �߰�
## Flow �׸� �߰� : flow.stg , flow_dot.stc
##
## Revision 1.76  2006/08/07 06:41:24  cjlee
## �ܺ��� ���� �����ϴ� �͵� �����ϰ���.
## ������ Warning : ���� �ѷ��ְ���.
##
## Revision 1.75  2006/08/07 06:33:57  dark264sh
## no message
##
## Revision 1.74  2006/08/07 06:30:23  cjlee
## �ܺ��� ���� �����ϴ� �͵� �����ϰ���.
## ������ Warning : ���� �ѷ��ְ���.
##
## Revision 1.73  2006/08/07 06:27:25  dark264sh
## no message
##
## Revision 1.72  2006/08/01 05:38:53  cjlee
## BODY �Ϸ�
##
## Revision 1.71  2006/07/31 12:01:22  cjlee
## integer , string ��ȯ �Ϸ�. (�� ��� ����)
## LOG_ME�� ����� , LOG_KUN�� �����ؾ� ��.
##
## Revision 1.70  2006/07/31 06:39:04  cjlee
## precompile�� �ǰ� ��.
## KUN , ME�� ���ؼ� call ���� structure�� ���� ó�� �Ϸ�
## structg.pl -> input : argv , output : ���� FileName : ���� �� ��
## structg_precompile1.pl -> input : pre.stg , output : userfile_pre.stg
## make pre --> input : pre.stg , output : userfile_pre.stg
##
## Makefile���� ���� ���� ���� �˼� ����.
##
## Revision 1.69  2006/07/28 04:42:25  cjlee
## no message
##
## Revision 1.68  2006/07/27 11:01:04  cjlee
## STG_COMMON ������  (���� ���� �ϼ� : README.TXT)
## LOG_TEXT_PARSING���� �ϴ� ������
##
## Revision 1.67  2006/07/27 01:58:29  cjlee
## <TAG_DEFINE_START: ....>  <TAG_DEFINE_END:...> ó�� �Ϸ�
## �ǰ�: �̷� HTML�����
##     <TAG_DEFINE:.....>  </TAG_DEFINE>
##
## Revision 1.66  2006/07/26 03:28:36  cjlee
## no message
##
## Revision 1.65  2006/07/26 03:27:32  cjlee
## <TAG_DEFINE_START:AAA>
## #define ....
## .... (���ڸ�)
## <TAG_DEFINE_END:AAA>
## �� �����ϰ�
## U32 <AAA>TTT;   �̷� ������ ����ϸ� �ּ����� �ڵ����� �ٴ´�.
##
## Revision 1.64  2006/07/26 02:20:43  cjlee
## #define�� typedef ���̵� ���̵� ��� ó�� ����
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
## Set_Value �߰�
##
## Revision 1.56  2006/07/24 06:50:53  cjlee
## $iterate_comments = ON/OFF �ν� iterateó���� �� �κ��� �ּ��� �������� ����
## lex������ �� �ּ��κ��� ó������ ���ؼ�
## Lex����������
## SET : iterate_commnets = OFF   ,  ON�� ���ִ� ���� �ִ�.
##
## Revision 1.55  2006/07/23 23:56:46  cjlee
## MIDC���� ���� : TEXT Parsing�߰�. stc style �߰�
##
## Revision 1.54  2006/06/14 04:40:32  cjlee
## ���泻��  : STAT���� ó�� ���� (�� structure���� �Լ��� ���� �� ���� ����)
##         -  structg.pl
##                 STAT���� ó�� �߰� : Once , Accumulate ����  (���� �� ���� ����)
##                 stat_function �Լ� �߰� (Accumualate, Once ���� / �Լ��� ����)
##                 STAT_ALL�� STAT�� ���ǵǾ����������� �����ϰ� ��.
##
## Revision 1.53  2006/06/13 07:45:56  mungsil
## *** empty log message ***
##
## Revision 1.52  2006/06/13 07:35:08  cjlee
## ���� ����  : STAT���� ó�� ����
## 	table �� %s ����.
## 	accumulate , once ���� : STAT_ALL �߰�
## 	- pc.upr
## 		table�� %s�� STAT�϶��� _%s�� ����.
## 	-  structg.pl
## 		STAT���� ó�� �߰� : Once , Accumulate ����
## 		_%s ó�� ���� : table��
## 	- userfile.stg
## 		STAT ���� ���� : ACCU.. .INC������ Ÿ table�� ���� ��밡��
## 		��ü ���� �� �ȿ����� pthis�� ��밡��
##
## Revision 1.51  2006/06/09 03:31:15  cjlee
## 		STG_STAT_TABLE �߰�
## 		STAT���� ����� Set_Stat_Once.c �� �� �߰��� �������.
## 		STG_ACCUMULATE , STG_INC�߰�
##
## Revision 1.50  2006/06/01 06:23:30  cjlee
## flat�� space [] Bug ����
##
## Revision 1.49  2006/05/30 11:51:58  cjlee
## minor change
##
## Revision 1.48  2006/05/30 07:21:35  cjlee
## Modify for Errror Collection
##
## Revision 1.47  2006/05/29 10:50:01  cjlee
##     -  structg.pl
##         ITERATE �����ڰ� +<+ ... +>+ �����ں��� �ռ�
##             ITERATE %HASH_KEY +<<+  ITKEY    ITVALUE
##                 if (+<+$HASH_KEY_IS{ITKEY}+>+(pSTG_HASHKEY->ITKEY) > 0) {
##             �̷������� ITKEY�� ������ �Ŀ� +<+...+>+ ������ ���డ��
##
##             # +<+$stg_hash_del_timeout+>+ ==> 10
##             # +<+$typedef_name[54]+>+  ==> COMBI_Accum
##             # +<+$HASH_KEY_TYPE{uiIP}+>+ ==> IP4
##             # +<+$type{+<+$HASH_KEY_TYPE{uiIP}+>+}+>+  ==> int
##         ���� ���� ó���� �ݺ� ó����
##
## Revision 1.46  2006/05/29 07:59:07  mungsil
## structg.pl
##
## Revision 1.45  2006/05/29 05:13:36  cjlee
##     -  NTAM 3���� ���� �������
##         userfile.stg :
##             TABLE_LOG , TABLE_CF ,  STG_COMBINATION_TABLE keyword ���
##                 TABLE_LOG : DB�� �� ���̺��̸� ����� �Ǿ���
##                 TABLE_CF : DB�� �� ���̺�������, call flow���õ� ������ ���Ǿ����� ����.
##                 STG_COMBINATION_TABLE : DB�� �� ���̺��̸� , ���������� �����Ǵ� ��
##             STG_HASH_KEY keyword�ڿ� ������ ������ typedef �̸��� ������ �� structure�� KEY Structure�� �̿��ϰ� ��.
##         structg.pl :
##             GLOBAL.TXT�� stg�� �м� ����� ������ ������ ��Ƶ� ȭ���� ���� �����.
##             STCó�� �߰�  - ITERATE +<<+ ... +>>+ �� +<+$...+.+  �߰�
##             undefined_typedef �߰� (our�� ���� ���� ���� ���鿡 ���� ó���� ���� �κ���)
##
## Revision 1.44  2006/05/26 04:51:27  cjlee
## > our $expansionprefix = "";
## > our $shortremoveprefix = "TTTTT__";
## ��� �߰�
## expansionprefix= _ �϶��� AAA_BB�� �Ǵ� ���̰�
## shortremoveprefix�� ������ %%�ȿ� ������ �Ǹ� �װ� ���� �ʴ� ���̴�. %TTTTT__%
##
## Revision 1.43  2006/05/25 04:42:43  cjlee
##     - Short Name ó��
##          SQL�� �ڵ� ���� (*.sql) : Short_COMBI_  or Short_TIM_ ��縸�� ó�� ��.
##          %flat_typdef_contents�� ��� ���� ����
##          *.stg���� %...% ���� ShortName ���� ���� : %..%�� ������ �׳� ���� �̸����� ó��
##     - �� stg�鿡 ���� ���� �Ϸ� (make���� ���� �Ϸ�)
##         hash.stg hashg.stg hasho.stg memg.stg sip.stg timerN.stg userfile.stg
##
## Revision 1.40  2006/05/25 02:23:03  cjlee
## Bug����
##
## Revision 1.39  2006/05/25 02:00:40  cjlee
## 	- Short Name ó��
## 		 SQL�� �ڵ� ���� (*.sql) : Short_COMBI_  or Short_TIM_ ��縸�� ó�� ��.
## 		 %flat_typdef_contents�� ��� ���� ����
## 	 	 *.stg���� %...% ���� ShortName ���� ���� : %..%�� ������ �׳� ���� �̸����� ó��
##
## Revision 1.38  2006/05/25 00:18:26  yhshin
## U8 Print �� ����
##
## Revision 1.37  2006/05/24 23:43:14  yhshin
## X8 type �߰�
##
## Revision 1.36  2006/05/24 05:16:40  cjlee
## minor change
##
## Revision 1.35  2006/05/24 05:11:34  cjlee
## *** empty log message ***
##
## Revision 1.34  2006/05/24 05:05:54  cjlee
## /// -> /**
## // -> /*  ���� �ڵ� ���� (�ּ����ȿ� ///�� ���� ���ÿ�)
##
## Revision 1.33  2006/05/24 04:26:43  cjlee
## 	- STIME , MTIME : S32�� ����
## 	- TIME64ó�� �߰� : STG_DiffTIME64
##
## Revision 1.32  2006/05/24 03:50:48  cjlee
## 	- NTAM 2�ܰ� ��� �߰�
## 		STG_HASH_KEY - �Ѱ��� �����ؾ��ϸ� , �� �������� ���� �Ѵ�.
## 			2���� �и��Ͽ� key, data�� ����� , �ְ������ �䱸�� ���� DATA�� ������
## 		STG_COMBINATION_TABLE  - �������� �����ϸ� , p�� �տ� �ٿ��� pointer�� �����Ͽ��� �Ѵ�.
## 			DIFF , EQUAL ���� (Set_Combination_Once)
## 			ACCUMULATION ���� - �� TIM_... �޽����� ���ö����� �����ϰ� ��
##
## Revision 1.31  2006/05/22 08:05:51  cjlee
## TIMEOUT �ð� ���� (SESS , DEL)
## *_DEF_NUM   : structure �� ���� define ��ȣ
## *_MEMBER_CNT : �� structure����� member ���� ���� (flat����)
##
## Revision 1.30  2006/05/21 23:59:05  cjlee
## 	- NTAM �ڵ�ȭ 1�ܰ� ������
## 		STG_HASH_KEY �߰� - ���� structure�� �ڵ� ����
## 		TIME64 �߰� (���� ���Ǹ� �ؾ� �ϳ�?
##
## Revision 1.29  2006/05/19 08:35:11  cjlee
## ���� ����  ��
## Golbal ������ �߿� �߿��� �͵� print�ϴ� ��� �߰�
## DEBUG.TXT�� ���ʿ� ������ �ȴ�.
##
## Revision 1.28  2006/05/19 06:39:47  cjlee
## �̻��� �ڵ� ����
## use strict "vars" ���
## STG_HASH_KEYS �� �߰��ϱ� ���� ���� ���� �۾�
##
## Revision 1.27  2006/05/17 05:02:45  cjlee
## mistype�ذ�  ��   libSTGPC....a �� ����� ��ħ
##
## Revision 1.26  2006/05/16 07:56:24  yhshin
## flat_ header�� pragma pack ����
##
## Revision 1.25  2006/05/10 23:24:39  cjlee
## type_printPre ���� ����
##
## Revision 1.24  2006/05/10 08:36:00  cjlee
## *** empty log message ***
##
## Revision 1.23  2006/05/10 08:33:54  cjlee
## 64 bit variable�� �߳����� ��ħ
##
## Revision 1.22  2006/05/10 07:47:32  yhshin
## STGD --> STG
##
## Revision 1.21  2006/05/10 07:29:42  yhshin
## nodebug���� ����
##
## Revision 1.20  2006/05/10 06:54:00  cjlee
## U64 , S64 ó�� �߰� (prt , enc, dec)
##
## Revision 1.19  2006/05/10 01:04:26  yhshin
## U64, S64 �߰�
##
## Revision 1.18  2006/05/04 02:22:08  yhshin
## tablename ����
##
## Revision 1.17  2006/05/04 00:04:48  yhshin
## Table�� parameter�� �ް�
##
## Revision 1.16  2006/05/03 00:30:23  yhshin
## nodebug file�߰�
##
## Revision 1.15  2006/05/02 08:23:05  yhshin
## struct �ΰ� ����ص� pc���� �����
##
## Revision 1.14  2006/04/25 04:24:27  cjlee
## STIME type �߰�
##
## Revision 1.13  2006/04/19 07:28:16  cjlee
## type OFFSET �߰�
##
## Revision 1.12  2006/04/19 07:22:16  cjlee
## define_stg.h ��  ��� *.h�� ���� (�Ѱ��� .h���)
##
## Revision 1.11  2006/04/19 06:56:04  yhshin
## include �߰�
##
## Revision 1.10  2006/04/19 06:27:34  yhshin
## OraMake file ���� �߰�
##
## Revision 1.9  2006/03/19 04:02:10  yhshin
## flat.upr ����
##
## Revision 1.8  2006/03/19 01:13:35  yhshin
## makefile.upr ���ܿ� ���� ���� �߰�
##
## Revision 1.2  2006/03/19 01:06:52  yhshin
## make pc�� �߰�
##
## Revision 1.1  2006/03/19 00:13:28  yhshin
## structg lib add
##
## Revision 1.7  2006/03/11 06:36:06  cjlee
## IP4 �߰�
##
## Revision 1.6  2006/03/11 06:17:27  cjlee
## project hashg �� ������ �ǰԲ� ������ ��.
## cvs co hashg
##
## Revision 1.5  2006/04/06 07:56:18  cjlee
## minor change
##
## Revision 1.4  2006/04/06 06:11:03  cjlee
## arrary ���� ��翡 ���� �������� ó��
##
## Revision 1.3  2006/04/06 05:00:35  cjlee
## minor change
##
## Revision 1.2  2006/04/06 04:23:55  cjlee
##         : Makefile �ڵ� ���� (���� file�̸���)
##         : define.upr ó�� (�״�� �о ��)
##         : *.pc file �ڵ� ����
##         : define_stg.h �ȿ�  extern���� ����� �Լ��� ����
##         : ����� OUTPUT directory�ؿ� ����
##
## Revision 1.1  2006/04/06 00:28:12  cjlee
## code_gen.pl + flat_hdr_gen.pl ==> �Ѱ��� ��ħ:INIT
##
## Revision 1.4  2006/04/03 07:59:30  cjlee
## member variable�� function pointer�϶�
##
## Revision 1.3  2006/04/03 07:07:45  cjlee
## define_stg.h�� �ڵ��������� ����
##
## Revision 1.2  2006/04/03 03:34:29  cjlee
## add comment
##
## Revision 1.1  2006/03/31 00:59:34  cjlee
## *** empty log message ***
##
##
