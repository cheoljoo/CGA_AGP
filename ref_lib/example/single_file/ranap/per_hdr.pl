#!/usr/bin/perl
##
## $Id: per_hdr.pl,v 1.1 2007/04/04 02:53:29 cjlee Exp $
##


use strict 'vars';


our $glogname;
our $ginputfilename;
our $goutputdir;
our $goutputdir;
our %undefined_typedef;             # ASN_HASH_KEY의 쌍들
our @undefined_array;               # ASN_HASH_KEY의 쌍들
our %gdecode_st;
our %gdecode_st_size;
our %gdecode_st_member;
our $desc_num = 1;
our @desc_def;


sub print_all_global_var
{
	my $global_filename;
	$global_filename = shift @_;

	open(GLOBAL,">$global_filename");
	my $key;
	print GLOBAL  "=============================================\n";
	print GLOBAL  "===== Global Variables ======================\n";
	print GLOBAL  "=============================================\n";

	print GLOBAL  "\$logname = $glogname\n";
	print GLOBAL  "\$inputfilename = $ginputfilename\n";
	print GLOBAL  "\$outputdir = $goutputdir\n";

	foreach_print_hash("gdecode_st");
	foreach_print_hash("gdecode_st_size");
	foreach_print_hash("gdecode_st_member");

	foreach_print_array("desc_def");

	foreach_print_undefined_hash("undefined_typedef");
	foreach_print_array("undefined_array");

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


my $line;
my $undefined_name;
my $pd_name;
my $pd_ai;


my $Second; 
my $Minute; 
my $Hour; 
my $Day; 
my $Month; 
my $Year;
my $WeekDay; 
my $DayOfYear;
my $IsDST;


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
# *  @see       flat_hdr_gen.pl : asng.pl을 변형하여 flat....h 를 만든 화일
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

sub pd_action
{
	my $pda_line = shift @_;
	if($pda_line =~ /stat\s*=\s*(pd_\w+)\s*\((.*)\s*\)\s*\;\s*$/){
		#print "pd_action : $1 ( $2 )\n";
		my $pda_name = $1;
		my $pda_parm = $2;
		$pda_parm =~ s/\s//g;
		my @pda_parm = split(',',$pda_parm);
		if($pda_name eq "pd_ConsUInt8"){
			return "DD_VALUE(desc_tmp,  DEF_U8 , \*($pda_parm[1]) )\;";
		} elsif($pda_name eq "pd_Length"){
			return "DD_VALUE(desc_tmp, DEF_U32 , \*($pda_parm[1]) )\;";
		} elsif($pda_name eq "pd_ConsInteger"){
			return "DD_VALUE(desc_tmp, DEF_S32 , \*($pda_parm[1]) )\;";
		} elsif($pda_name eq "pd_setp"){
			return "// We can not get the value from this function.  Maybe, this role set the buffer for pctxt.";
		} elsif($pda_name eq "pd_UnconsInteger"){
			return "DD_VALUE(desc_tmp, DEF_S32 , \*($pda_parm[1]) )\;";
		} elsif($pda_name eq "pd_OpenType"){
			return "DD_BINARY(desc_tmp, DEF_BINARY , ($pda_parm[1]) , \*($pda_parm[2]))\;";
		} elsif($pda_name eq "pd_DynBitString"){
			return "DD_STRING(desc_tmp, DEF_STRING , ($pda_parm[1]) )\;";
		} elsif($pda_name eq "pd_DynOctetString"){
			return "DD_STRING(desc_tmp, DEF_STRING , ($pda_parm[1]) )\;";
		} elsif($pda_name eq "pd_ObjectIdentifier"){
			return "DD_VALUE(desc_tmp, DEF_S32 , \*($pda_parm[1]) )\;";
		} elsif($pda_name eq "pd_ConsUInt16"){
			return "DD_VALUE(desc_tmp, DEF_U16 , \*($pda_parm[1]) )\;";
		} elsif($pda_name eq "pd_ConsUnsigned"){
			return "DD_VALUE(desc_tmp, DEF_S32 , \*($pda_parm[1]) )\;";
		} elsif($pda_name eq "pd_OctetString"){
			return "DD_STRING(desc_tmp, DEF_STRING , ($pda_parm[2]) )\;";
		} elsif($pda_name eq "pd_BitString"){
			return "DD_STRING(desc_tmp, DEF_STRING , ($pda_parm[2]) )\;";
		} else {
			print "ERROR // CJLEE unknown type : $pda_name";
			return "// CJLEE unknown type : $pda_name";
		}
	}
}

sub check_decode_funcion_name
{
	my $in = shift @_;
	my $prelogname = shift @_;
	my $name = shift @_;
	my $rname;
	
	$rname = "$prelogname" . "_$name";
	#if($in =~ /$rname/){
		#print "$rname : $line";
	#}
	if($in =~ /^$rname\s+(\w+)\s*\[\s*(\w+)\s*\]\s*\;/){
		#print "$rname $1 $2\n";
		$gdecode_st{$1} = $rname;
		$gdecode_st_size{$1} = $2;

		$undefined_name = "$rname";
		$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
		$$undefined_name{$1} = $2;
	} elsif($in =~ /^\s*(\w+)\s*\[\s*(\w+)\s*\]\s*\.\s*(\w+)\s*=\s*(\&\s*asn1PD_\w*)\;/){
		#print DBG "$1 $2 $3 $4\n";
		$temp = "$1\.\.$3";
		$gdecode_st_member{$temp} = $4;
	} 
}

sub do_asn_analysis
{
	my $filename = shift @_;
	my $function_start = 0;
	my $pd_start = 0;
	my $pd_line;
	my $func_context = "";
	my $desc = "";
	my $switch_start = 0;
	my $switch_ai;
	my $switch_line = "";

	open(IN , "<$filename");
	while ($line = <IN>) {
		check_decode_funcion_name($line,$glogname , "ELEMENTARY_PROCEDURE");
		check_decode_funcion_name($line,$glogname , "PROTOCOL_IES");
		check_decode_funcion_name($line,$glogname , "PRIVATE_IES");
		check_decode_funcion_name($line,$glogname , "PROTOCOL_EXTENSION");
		check_decode_funcion_name($line,$glogname , "PROTOCOL_IES_PAIR");
	};
	close (IN);

($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "asng : do_asn_ana - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);

	open(OUT , ">$goutputdir/$filename");
	open(IN , "<$filename");
	while ($line = <IN>) {
		$temp = $line;
		if( ($function_start == 0 ) &&
		    ($line =~ /^(EXTERN\s+\w+\s+asn1PD[^(]*)\((.*)$/) ){
			#print "EXTERN : $1 $2\n";
			$function_start = 1;
			$func_context = "$1 (char *desc ,$2\n";
			$desc = "";
			if($line =~ /asn1PD_(\w+)/){  $desc = $1; }
			if($line =~ /asn1PDTC_(\w+)/){  $desc = $1; }
			if($desc ne ""){
				$desc_num++;
				$desc_def[$desc_num] = $desc;
				#print "DESC : $desc_num : $desc\n";
			}
		} elsif( ($function_start == 1 ) &&
		    ($line =~ /^{\s*$/) ){
			$func_context .= "{ char desc_tmp[200]; sprintf(desc_tmp , \"\%s.$desc_num\",desc);\n\t\{ /* BRACE */\n";
		} elsif( ($function_start == 1 ) &&
		    ($line =~ /^}\s*$/) ){
			$function_start = 0;
			$func_context .= "\t\} /* BRACE */\n$line";
			print OUT "$func_context";
		} elsif($function_start == 1){

			if($line =~ /^(\s*)(switch\s*\(\s*ui\s*\)\s*\{)/){
				$switch_start = 1;
				$switch_ai = $1;
				$switch_line = $line;
			} elsif( ($switch_start == 1) &&
		    	($line =~ /^$switch_ai\}/) ){
				$switch_start = 2;
			} elsif($switch_start == 1){
				$switch_line .= $line;
			} 
	
			if($line =~ s/^(\s*stat\s*=\s*asn1PD[^\(]*)\((.*)/$1\(desc_tmp, $2/){
				#print "A $1 $2\n";
				$func_context .= $line;
				$switch_start = 0;
			} 
			elsif($line =~ /^(\s*stat\s*=\s*)(\w+)(\s*\[\s*\w+\s*\]\s*\.)(\w+)(\s*)\((.*)/){
				$temp = "$2\.\.$4";
				if($gdecode_st_member{$temp} ne ""){
					$line = "$1$2$3$4$5\(desc, $6\n";
					#print "BBB $line : $1 $2 $3 $4 $5\n";
				}
				$func_context .= $line;
			}
			elsif($line =~ /(\s*)(stat\s*=\s*)(pd_\w+)(\s*)\((.*)/){
				$pd_ai = $1;
				$pd_line = "$1$2$3$4\($5";
				$pd_name = $3;
				my $end = $5;
				if($end =~ /\s*\)\s*\;\s*$/){
					$func_context .= "$pd_line\n";
					$pd_start = 0;
					if($pd_line =~ /pvalue/){ 
						$undefined_name = "pd_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$pd_name} = $pd_line;
						if($desc ne ""){
							$func_context .= "$pd_ai\/\/ cjlee $desc_num : $pd_name에 대한 수행 필요 : $pd_line\n";
							$func_context .= "$pd_ai" . pd_action($pd_line) . "\n\n";
						} else {
							$func_context .= "$pd_ai\/\/ CJLEE : $pd_name에 대한 수행 필요 : $pd_line\n";
						}
						#print "$pd_line\n"; 
					}
				} else {
					$pd_start = 1;
				}
			} 
			elsif($pd_start == 1){
				chop($line);
				$pd_line .= $line;
				if($line =~ /\s*\)\s*\;\s*$/){
					$func_context .= "$pd_line\n";
					$pd_start = 0;
					#$pd_line = "";
					if($pd_line =~ /pvalue/){ 
						$undefined_name = "pd_name";
						$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
						$$undefined_name{$pd_name} = $pd_line;
						if($desc ne ""){
							$func_context .= "$pd_ai\/\/ cjlee $desc_num : $pd_name에 대한 수행 필요 : $pd_line\n";
							$func_context .= "$pd_ai" . pd_action($pd_line) . "\n";
						} else {
							$func_context .= "$pd_ai\/\/ CJLEE : $pd_name에 대한 수행 필요 : $pd_line\n";
						}
						#print "$pd_line\n"; 
					}
				}
			} else {
				$func_context .= $line;
			}

			if($switch_start == 2){
				if($switch_line =~ /\*pvalue/){
					if($desc ne ""){
						$func_context .= "$switch_ai\/\/ cjlee $desc_num : \*pvalue의 값을 추가\n";
					} else {
						$func_context .= "$switch_ai\/\/ CJLEE : \*pvalue의 값을 추가\n";
					}
				}
				$switch_start = 0;
			}

		} else {
			print OUT "$line";
		}
	}
	close(IN);
}



###  _main_  __MAIN__ 
 
my $argcnt = @ARGV;
if($argcnt != 2) {
	print "invalid argument : $argcnt\n";
	print "will be used default value : @ARGV\n";
	$ginputfilename = "userfile.asng";
	$goutputdir = "OUTPUT";
} else {
	$ginputfilename = shift @ARGV;
	$goutputdir = shift @ARGV;
}

open(TIME_DBG,">TIME.TXT");
open(DBG,">DEBUG.TXT");

($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
$Month++;
$Year += 1900;
print_fp( "asng : START - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);

mkdir $goutputdir;

print "INPUT : $ginputfilename   ->   OUTPUT_DIR : $goutputdir\n";


	#print "$ginputfilename\n";
	open(ASNL , "<$ginputfilename");
	open(OUTL , ">$goutputdir/$ginputfilename");
	while($line = <ASNL>){
		if( ($line =~ /^(EXTERN\s+\w+\s+asn1PD[^(]*)\((.*)$/) ){
			#print "EXTERN : $1 $2\n";
			$line = "$1 (char *desc ,$2\n";
			print OUTL "$line";
		} else {
			print OUTL "$line";
		}
	}
	close ASNL;
	close OUTL;

	print_all_global_var("GLOBAL.TXT");

close (TIME_DEBUG);
close (DBG);

## 
## $Log: per_hdr.pl,v $
## Revision 1.1  2007/04/04 02:53:29  cjlee
## per_hdr.pl : header의 내용도 바꾸어주는것 추가
## asng.pl : octect , bit string 처리 변경
##
## Revision 1.3  2007/03/30 04:07:16  cjlee
## pd_ 각 함수에 대한 처리
##
## Revision 1.2  2007/03/29 13:57:29  cjlee
## RANAP_DEF.h의 결과 위치 변경
##
## Revision 1.1  2007/03/29 13:52:32  cjlee
## INIT
##
## 
