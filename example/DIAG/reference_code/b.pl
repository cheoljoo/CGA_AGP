#!/bin/perl

our $tttime;
our $cchange_start_time;
our $outputdir = "OUTPUT";
our %local_var_set;

our @EXPORT = qw(traverse_hash_tree  recover_special_code change_special_code sort_keys max_keys getHashRef print_fp end_time_log mid_time_log start_time_log  __SUB__);

sub __SUB__ { return  __FILE__ . "||" . (caller 2)[3] . "|" . (caller 2)[2] . "-" . (caller 1)[3] . "|" . (caller 1)[2] . "-" . (caller 0)[2] . ": " }

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

sub max_keys
{
	my $iterate_var_name;
	my $allDigit = 1;
	my $max=0;
	($iterate_var_name ) = @_;
	foreach my $tmpKey ( keys %{getHashRef($iterate_var_name)}){
		if(not ($tmpKey =~ /^\s*\d*\s*$/)){
			$allDigit = 0;
			last;
		}
		if($max < $tmpKey){ $max = $tmpKey; }
	}

	if($allDigit == 1){ return  $max; }
	else { return  0; }
}

sub sort_keys
{
	my $iterate_var_name;
	my $iterate_op_type;
	my $allDigit = 1;
	my $tmpReverse = "+";
	my $tmpValue = 0;
	my $debug = "DEBUG_OFF";
	my @ret;
	($iterate_var_name ,$iterate_op_type,$debug) = @_;
	if($iterate_op_type =~ m/-/){ $tmpReverse = "-"; }
	if($iterate_op_type =~ m/V/){ $tmpValue = "V"; }
	if($tmpValue eq "V"){
		foreach my $tmpKey ( keys %{getHashRef($iterate_var_name)}){
			if(not (getHashRef($iterate_var_name)->{$tmpKey} =~ /^\s*\d*\s*$/)){
				$allDigit = 0;
				last;
			}
		}
	} else {
		foreach my $tmpKey ( keys %{getHashRef($iterate_var_name)}){
			if(not ($tmpKey =~ /^\s*\d*\s*$/)){
				$allDigit = 0;
				last;
			}
		}
	}

	if($allDigit == 1){ 
		if($tmpValue eq "V"){
			@ret = sort {getHashRef($iterate_var_name)->{$a} <=> getHashRef($iterate_var_name)->{$b}} keys %{getHashRef($iterate_var_name)};
		} else {
			@ret = sort {$a <=> $b} keys %{getHashRef($iterate_var_name)};
		}
	}
	else { @ret =  sort keys %{getHashRef($iterate_var_name)}; }

	if($tmpReverse eq "-"){
		@ret = reverse @ret;
	}

	if($debug eq "DEBUG_ON"){
		print DBG __SUB__;
		foreach (@ret){
			print DBG "  $_";
		}
		print DBG "\n";
	}

	return @ret
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
	my $allDigit = 1;
	#print "sub $TAXA_TREE\n";
	foreach my $tmpKey ( keys %{$TAXA_TREE}){
		if(not ($tmpKey =~ /^\s*\d*\s*$/)){
			$allDigit = 0;
			last;
		}
	}

	my @ret;
	if($allDigit == 1){
		@ret = sort {$a <=> $b} keys %{$TAXA_TREE};
	} else {
		@ret = sort keys %{$TAXA_TREE};
	}
	foreach my $key (@ret) {
		if (ref $TAXA_TREE->{$key} eq 'HASH') {
			#print "K:$key lstr=$lstr\n";
			if(recover_special_code($key) =~ m/^\s*\d+\s*$/){
				traverse_hash_tree_to_recover_special_code($TAXA_TREE->{$key},$vn,$lstr . "\{" . recover_special_code($key) . "\}",$fh);
			} else {
				traverse_hash_tree_to_recover_special_code($TAXA_TREE->{$key},$vn,$lstr . "\{\"" . recover_special_code($key) . "\"\}",$fh);
			}
		} else {
			if(recover_special_code($key) =~ m/^\s*\d+\s*$/){
			#print "$lstr $key = $TAXA_TREE->{$key}\n";
				print $fh "\$$vn$lstr\{" . recover_special_code($key) ."\}=\"" . recover_special_code($TAXA_TREE->{$key}) . "\"\n";
			} else {
				print $fh "\$$vn$lstr\{\"" . recover_special_code($key) ."\"\}=\"" . recover_special_code($TAXA_TREE->{$key}) . "\"\n";
			}
		}
	}
}
sub traverse_hash_tree {
	my ($TAXA_TREE,$vn,$lstr,$fh)    = @_;
	print __SUB__ . "$TAXA_TREE $vn $lstr\n";
	traverse_hash_tree_to_recover_special_code($TAXA_TREE,$vn,$lstr,$fh);
}


sub BKMG_from_int {
	my ($value) = @_;
	if($value < 1024){
		return "$value B";
	}
	$value = int($value/1024);
	if($value < 1024){ return "$value K"; }
	$value = int($value/1024);
	if($value < 1024){ return "$value M"; }
	$value = int($value/1024);
	return "$value G";
}

sub int_from_BKMG {
	my ($value) = @_;
	if($value =~ m/\s*(\d+)K\s*$/){
		return $1 * 1024;
	} elsif($value =~ m/\s*(\d+)M\s*$/){
		return $1 * 1024 * 1024;
	} elsif($value =~ m/\s*(\d+)G\s*$/){
		return $1 * 1024 * 1024 * 1024;
	} elsif($value =~ m/\s*(\d+)[B]?\s*$/){
		return $1;
	}
	return -1;
}


1;


our %DIAG;

$inputFileName = "default.def";
open(LOGI,"<$inputFileName");
{
	while(<LOGI>){
		my $s = $_;
		chop($s);
		print "$s\n";
		if($s =~ m/^\s*(?P<func>[^:\s]+)\s*:\s*(?P<value>[^:\s]+)\s*:\s*(?P<op>[^:]+)\s*:\s*(?P<sizetype>[^:\s]+)\s*:\s*(?P<argu>[^:\s]+)\s*$/){
			$func = $+{func};
			$value = $+{value};
			$op = $+{op};
			$sizetype = $+{sizetype};
			$argu = $+{argu};
			$op =~ s/\s//g;
			print __SUB__() . "func $func : value $value : op $op : size $sizetype : argu $argu\n";
			#$DIAG{value}{func}{op}{read} = 
			#$DIAG{value}{func}{op}{write} = 
			#$DIAG{value}{func}{size} = 
			#$DIAG{value}{func}{argu} = 
			my @ops = split(/,/,$op);
			foreach my $key (@ops){
				$DIAG{$value}{$func}{op}{$key} = $func;
			}
			$DIAG{$value}{$func}{size} = $sizetype;
			$DIAG{$value}{$func}{argu} = $argu;
			if($checkValue{$value} eq ""){ $checkValue{$value} = $func;}
			else { print "ERROR : $value must unique valule. -> current value : $value , exist func $checkValue{$value}\n"; exit; }
			if($checkFunc{$func} eq ""){ $checkFunc{$func} = $value; }
			else { print "ERROR : $func must unique function. -> current function : $func , exist value $checkFunc{$func}\n"; exit; }
		}
	}
	close(LOGI);
}


#### STEP 2
# Find increase the memory size each process in a day
# Find increasing memory size and cpu % than yesterday
#### OUT
foreach my $key (keys %DIAG){ print $key;} print "\n";
open(OUT,">default.GVm");
traverse_hash_tree(\%{DIAG},DIAG,"",OUT);
close(OUT);

