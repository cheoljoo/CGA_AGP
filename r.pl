#!/bin/perl

our $tttime;
our $cchange_start_time;
our $outputdir = "OUTPUT";
our %local_var_set;

sub start_time_log {
	my $tmpLogInit = shift @_;
	($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
	$Month++;
	$Year += 1900;
	print_fp( "$tmpLogInit structg : CChange START ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",DBG,TIME_DBG);
	$tttime = $Hour * 3600 + $Minute * 60 + $Second;
	$cchange_start_time = $Hour * 3600 + $Minute * 60 + $Second;
}
sub mid_time_log {
	my $tmpLogInit = shift @_;
	($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
	$Month++;
	$Year += 1900;
	$ddtime = ($Hour * 3600 + $Minute * 60 + $Second) - $tttime;
	$tttime = $Hour * 3600 + $Minute * 60 + $Second;
	print_fp( "$tmpLogInit structg ($ddtime) : CChange ITERATE recursion END 1 ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",DBG,TIME_DBG);
}
sub end_time_log {
	my $tmpLogInit = shift @_;
	($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
	$Month++;
	$Year += 1900;
	$ddtime = ($Hour * 3600 + $Minute * 60 + $Second) - $cchange_start_time;
	print_fp( "$tmpLogInit structg CChange duration ($ddtime) : CChange END ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",DBG,TIME_DBG);
}

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

sub CChange
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
	my $tttime;
	my $ddtime;
	my $cchange_start_time;

	$stc_filename_input = shift @_;
	$stc_output_dir = shift @_;
	$stc_filename_output = shift @_;
	$stc_debug = shift @_;
	print "STC input $stc_filename_input , dir= $stc_output_dir , output= $stc_filename_output , debug= $stc_debug\n";
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
	# 대치시킨 결과를 CChange() 에서 하는 것 처럼 또 돌려준다. 
	# ITERATOR B ~ B End까지를 또 풀어준다.
	#
	# operation 우선순위
	#  ITERATE 가 제일 먼저 처리 된다.
	#  그 후에 , +<+$...+>+ 이 처리가 된다.  co_log_main.c안에서  Get_HashoData를 참조하시요.
	print_fp("CChange $stc_filename_input\n",STDOUT,DBG);
	open(INPUTC , "<$stc_filename_input");

	if($stc_debug eq "DEBUG_ON"){ start_time_log("==time_debug=="); }

	# for make file : but not use yet
	my $comment =  <<END_COMMENT;
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
END_COMMENT


	while ($in = <INPUTC>) {
		if($in =~ /^FileName\s*\:\s*(\S+)\s*$/){
			$stc_filename_output = $1;
			$stg_stc_file{$1} = $1;
			print_fp("STC FileName 2 : stg_stc_file : $stg_stc_file{$1} : $stc_filename_output\n",STDOUT,DBG);
			open(OUTPUTC , ">$outputdir/$stc_output_dir/$stc_filename_output");

			my $comment =  <<END_COMMENT;		# if need this statements , you change to put the values into hash variables.
			if( ($stc_filename_output =~ /\.c\s*$/) || ($stc_filename_output =~ /\.cpp\s*$/) || ($stc_filename_output =~ /\.pc\s*$/) ){	
				#print "INCLUDE2\n";
				print OUTPUTC "\n#include \"$FileName\"\n\n\n";		# .c안에서는 되는데 .l에서 문제가 발생함.
			} else {
				#NONE#
				# .l일때는 처음에 include를 선언하면 error가 발생한다.
			}
END_COMMENT

			# HASH : filelist
			my $tmpDir;
			if($stc_output_dir eq ""){
				$tmpDir = "";
			} else {
				$tmpDir = "$stc_output_dir\/";
			}
			if($stc_filename_output =~ /\.c/){
				$filelist{$tmpDir.$stc_filename_output} = "CFILE";
			} elsif($stc_filename_output =~ /\.l/){
				$filelist{$tmpDir.$stc_filename_output} = "LEXFILE";
				$temp = $stc_filename_output;
				if($temp =~ /(.*)\/(.*).l/){
					$temp = "lex\.$2\.c";
				} else {
					$temp =~ s/(.*)\.l/lex\.$1\.c/;
				}
				$filelist{$tmpDir.$temp} = "CFILE";
			}
			$hashName{filelist} = $stc_filename_output;
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
			$local_var_set{$stc_filename_output}{$temp_set_var} = $temp_set_value;
			$hashName{local_var_set} = "STC Local Set Variable";
			print "$stc_filename_output : $in\n";
			next;
		} elsif($in =~ /^Set\s*\:\s*(\w+)\s*\{\s*(\w+)\s*\}\s*\=\s*(\w+)/){		# Set: A{B} = C
			print "SET : ERROR $1 $2 $3\n";
			my $temp_set_var = $1;
			my $temp_set_hash = $2;
			my $temp_set_value = $3;
#print DBG "LLL $iterate_comments : $1  $2 $3\n";
			#  $hashName is the list of hash variables to print or to write into file.
			$hashName{$1} = $3;
			$$1{$2} = $3;
#print DBG "LLL $iterate_comments : [$1] [$2]  $3\n";
			#CCHANGE_DEBUG print DBG "SET :  $1 \{ $2 \} = $3\n";
			#$undefined_name = "stc_Set_var_$stc_filename_output";
			#$undefined_typedef{$undefined_name} = "HASH_$undefined_name";
			#$$undefined_name{"$temp_set_var" . "$temp_set_hash"} = "$temp_set_value";
			next;
		}


#print_fp("Line 1 icnt=$iterate_cnt : $in",DBG);
		if(0 == $iterate_cnt){
			$in = replace_var_with_value($in);
		}
#print_fp("Line 2 icnt=$iterate_cnt : $in",DBG);

		if ($in =~ /^\s*ITERATE\s+([%@&])(.+)\s+\+<<\+\s+(\S+)\s+(\S+)\s*$/){
			#ITERATOR_DEBUG 
			print DBG "ITERATE Mstart $1 $2 $3 $4\n"; 
			if(0 == $iterate_cnt){
				$in_start = $in;
				($iterate_var_type , $iterate_var_name , $iterate_key , $iterate_value) = ($1,$2,$3 , $4);
			} else {
				$iterate_lines .= $in;
			}
			$iterate_cnt ++;
			#ITERATOR_DEBUG 
			print DBG "ITERATE iterate_cnt $iterate_cnt : $in";
		} elsif ($in =~ /^(.*)\+>>\+/){
			$iterate_cnt--;
			#ITERATOR_DEBUG 
			print DBG "ITERATE iterate_cnt $iterate_cnt : $in";
			if(0 == $iterate_cnt){
				if($stc_debug eq "DEBUG_ON"){ mid_time_log("==MID time_debug=="); }
				$in_end = $in;
				#ITERATOR_DEBUG 
				print DBG "iterate_comments [" . $iterate_comments . "]\n";
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
					#ITERATOR_DEBUG 
					print DBG "\/\*\*\n$temp1$temp2$temp3\*\/\n";
				}
				$iterate_lines = Iterator_recursion($iterate_var_type , \%{$iterate_var_name},$iterate_key,$iterate_value,$iterate_lines);
				#ITERATOR_DEBUG  
				print DBG "RETURN \$iterate_lines = \n\[\n$iterate_lines\n\]\n";
				#$iterate_lines =~ s/\+<\+\s*\$(\S+)\s*\+>\+/$$1/g;		# 	+<+$stg_hash_del_timeout+>+ ==> 10

				if($stc_debug eq "DEBUG_ON"){ mid_time_log("==MID time_debug=="); }

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

					if($stc_debug eq "DEBUG_ON"){ mid_time_log("==MID time_debug 2=="); }

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
	print_fp( "structg ($ddtime) : CChange ITERATE REPLACE <-> EQUAL END 3 ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);
}

	print_fp("$iterate_lines\n" , OUTPUTC);

} else { 		# if(1)
				@temp = split('\n',$iterate_lines);
				my $ifequal_start = 0;
				my $ifequal_one="";
				my $ifequal_two="";
				my $ifequal_action="";
				my $is_ifequal = 0;
#print DBG "CChange IFEQUAL NOTEQUAL<<\n$iterate_lines\n>>\n";
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
print_fp( "structg CChange duration ($ddtime) : CChange END ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",TIME_DBG);
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

sub getHashRef {
	my ($name) = @_;        # gCan{9}
	my $first;
	print "F " . $name . "\n";
	$name =~ s/([^\{]+)//;
	$first = $1;
	my $hn = \%{$first};
	print "F " . $hn . "\n";
	while($name =~ s/^\{([^\}]*)\}//){
		my $uu = $1;
		$hn = $hn->{$uu};
		print "G " . $uu . "   $hn\n";
	}

	print "I " . $hn . "\n";
	return $hn;
}

sub Iterator_recursion
{
	my $iterate_var_type;
	my $iterate_ref_hash;
	my $iterate_key;
	my $iterate_value;
	my $iterate_lines;
	my $result = "";
	my $in;
	my $iterate_cnt = 0;
	my @lines;

	($iterate_var_type , $iterate_ref_hash , $iterate_key , $iterate_value, $iterate_lines) = @_;
	#print_fp( "O : @_\n", OUTPUTC);
print DBG "RC : $iterate_var_type , $iterate_ref_hash , $iterate_key , $iterate_value\n";

print DBG "RC : Iterator_recursion : \$iterate_lines = $iterate_lines ]]]\n";

	if($iterate_var_type eq "\%"){
		print DBG "RC : HASH Iterator_recursion : \$iterate_ref_hash = $iterate_ref_hash ]]]\n";
		#$tmp1 = eval $$iterate_ref_hash;
		$tt = "gCan{9}";
		$tmp2 = \%{$tt};
		print DBG "RC : tmp2 $tmp2  tmp1 $tmp1 gcan $gCan{9}\n";
		foreach $stg_key_hash (reverse sort keys %{$iterate_ref_hash}){
			print DBG "RC : HASH Iterator_recursion : \$key = $stg_key_hash\n";
			$temp = $iterate_lines;
			$temp =~ s/$iterate_key/$stg_key_hash/g;
			$temp =~ s/$iterate_value/$$iterate_ref_hash{$stg_key_hash}/g;
			$result .= $temp;
		}
	} elsif($iterate_var_type eq "\@"){
		my $my_cnt;
		$my_cnt = @$iterate_ref_hash;
		#ITERATOR_DEBUG print DBG "--> ARRAY : $iterate_ref_hash  size =  $my_cnt\n";
		for(my $i = 0 ; $i < $my_cnt ; $i++){
			#ITERATOR_DEBUG print DBG "array : \$$iterate_ref_hash \[ $i \] = $$iterate_ref_hash[$i]\n";
			$temp = $iterate_lines;
			$temp =~ s/$iterate_key/$i/g;
			$temp =~ s/$iterate_value/$$iterate_ref_hash[$i]/g;
			$result .= $temp;
		}
	} elsif($iterate_var_type eq "\&"){
		my $my_cnt;
		$my_cnt = @$iterate_ref_hash;
		#ITERATOR_DEBUG print DBG "--> REVERSE ARRAY : $iterate_ref_hash  size =  $my_cnt\n";
		for(my $i = $my_cnt - 1 ; $i >= 0 ; $i--){
			#ITERATOR_DEBUG print DBG "REVERSE array : \$$iterate_ref_hash \[ $i \] = $$iterate_ref_hash[$i]\n";
			$temp = $iterate_lines;
			$temp =~ s/$iterate_key/$i/g;
			$temp =~ s/$iterate_value/$$iterate_ref_hash[$i]/g;
			$result .= $temp;
		}
	} else {
		print "ERROR : unknown iterate var type  : $iterate_var_type\n";
		die $error = 500;
	}
	print DBG "RC : Iterator_recursion : \$result = $result ]]]\n";

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
					($iterate_var_type , $iterate_ref_hash , $iterate_key , $iterate_value) = ($1,$2,$3,$4);
				} else {
					$iterate_lines .= $it_line . "\n";
				}
				$iterate_cnt ++;
			}
			elsif ($it_line =~ /^(.*)\+>>\+/){
#print DBG "SUB_ITERATE : $iterate_cnt : $it_line\n";
				$iterate_cnt--;
				if(0 == $iterate_cnt){
					$iterate_lines = Iterator_recursion($iterate_var_type , $iterate_ref_hash,$iterate_key,$iterate_value,$iterate_lines);
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
		while($replace_in =~ /(\d+)\s*\-\-\-\-/){		# 	----     1을 빼준다.
			my $temp_num;
			$temp_num = $1;
			$temp_num--;
			$replace_in =~ s/\d+\s*\-\-\-\-/$temp_num/;
		}
		$in_cnt ++;
		#print DBG "Set Hash replace2 in_cnt=$in_cnt: $replace_in \n";
	}			# +<+$type{+<+$HASH_KEY_TYPE{uiIP}+>+}+>+  ==> int

	return $replace_in;
}

sub change_special_code {
	my ($s) = @_;
	$s =~ s/\{/#\+#\+#\+\+###/g;
	$s =~ s/\}/#\-#\-#\-\-###/g;
	$s =~ s/\\/#\=#\=#\=\=###/g;
	$s =~ s/\n/#\%#\%#\%\%###/g;
	$s =~ s/\"/#\&#\&#\&\&###/g;
	return $s;
}
sub recover_special_code {
	my ($s) = @_;
	$s =~ s/#\+#\+#\+\+###/\{/g;
	$s =~ s/#\-#\-#\-\-###/\}/g;
	$s =~ s/#\=#\=#\=\=###/\\/g;
	$s =~ s/#\%#\%#\%\%###/\n/g;
	$s =~ s/#\&#\&#\&\&###/\"/g;
	return $s;
}
sub traverse_hash_tree_to_recover_special_code {
	my ($TAXA_TREE,$vn,$lstr,$fh)    = @_;
	#print "sub $TAXA_TREE\n";
	foreach my $key (sort{$a<=>$b} keys %{$TAXA_TREE}) {
		if (ref $TAXA_TREE->{$key} eq 'HASH') {
			#print "K:$key lstr=$lstr\n";
			traverse_hash_tree_to_recover_special_code($TAXA_TREE->{$key},$vn,$lstr . "\{" . recover_special_code($key) . "\}",$fh);
		} else {
			#print "$lstr $key = $TAXA_TREE->{$key}\n";
			print $fh "\$$vn$lstr\{" . recover_special_code($key) ."\}=\"" . recover_special_code($TAXA_TREE->{$key}) . "\"\n";
		}
	}
}
sub traverse_hash_tree {
	my ($TAXA_TREE,$vn,$lstr,$fh)    = @_;
	traverse_hash_tree_to_recover_special_code($TAXA_TREE,$vn,$lstr,$fh);
}


# set the variables from file
print "arguments count : $#ARGV\n";
($filename,$stcfilename) = (@ARGV);
if($stcfilename eq ""){
	$filename = "default.GV";
	$stcfilename = "default.stc";
}

## init file open
open(DBG,">debug.log");
open(TIME_DBG,">time_debug.log");
open(VAR_DBG,">var_debug.log");


print "fname = $filename , stc fname = $stcfilename\n";
open(FH, "<",$filename) or die "Can't open < $filename: $!";
my $lcnt = 0 ;
while(<FH>){
	$s = $s_org = $_;
	chop($s);
	eval $s;
	$s =~ /^\$([^\{]+)/;
	$hashName{$1} = "Done";
	if($1 eq "gCan"){ print "== $s\n"; }
	#recover_hash_value(\%{$vname},$s);
	#LOG1 print $s_org;
	#if($lcnt >50){ last; }
	#$lcnt++;
}
close(FH);



foreach my $key (keys %hashName){
	print VAR_DBG "----[$key]----\n";
	traverse_hash_tree(\%{$key},$key,"",VAR_DBG);
}

CChange($stcfilename,"stc","","DEBUG_ON");

print \%{gCol} . "\n";
print getHashRef("gCol") . "\n";
foreach my $key (sort{$a<=>$b} keys %{getHashRef("gCol")}) { print "$key  ";} print "\n";
print $gCol{9} . "\n";
print \%{"gCol{9}"} . "\n";
print getHashRef("gCol{9}") . "\n";
$tmp = $gCol{9};
foreach my $key (sort{$a<=>$b} keys %$tmp) { print "A$key  ";} print "\n";
foreach my $key (sort{$a<=>$b} keys %{(getHashRef("gCol"))->{9}}) { print "B$key  ";} print "\n";
foreach my $key (sort{$a<=>$b} keys %{getHashRef("gCol{9}")}) { print "C$key  ";} print "\n";
foreach my $key (sort{$a<=>$b} keys %{getHashRef("gCan{3-4}")}) { print "C$key  ";} print "\n";
foreach my $key (sort{$a<=>$b} keys %{getHashRef("gCan{9}")}) { print "C$key  ";} print "\n";
foreach my $key (sort{$a<=>$b} keys %{getHashRef("gCan{1}")}) { print "C$key  ";} print "\n";
foreach my $key (sort{$a<=>$b} keys %{getHashRef("gCan{2}")}) { print "C$key  ";} print "\n";

my $comment =  <<END_COMMENT;
		foreach my $key (keys %hashName){
			print VAR_DBG "----[$key]----\n";
			traverse_hash_tree(\%{$key},$key,"",VAR_DBG);
		}
END_COMMENT

