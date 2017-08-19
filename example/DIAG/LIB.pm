#!/bin/perl
package LIB;
require Exporter;

our $tttime;
our $cchange_start_time;
our $outputdir = "OUTPUT";
our %local_var_set;

#our @EXPORT = qw(traverse_hash_tree  recover_special_code change_special_code sort_keys max_keys getHashRef print_fp end_time_log mid_time_log start_time_log  __SUB__);

sub __SUB__ { return  __FILE__ . "||" . (caller 2)[3] . "|" . (caller 2)[2] . "-" . (caller 1)[3] . "|" . (caller 1)[2] . "-Line:" . (caller 0)[2] . ": " }

sub start_time_log {
	my $tmpLogInit = shift @_;
	if($tmpLogInit eq "LIB"){ print "ERROR:" . __SUB__ . "value $tmpLogInit\n"; exit; }
	($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
	$Month++;
	$Year += 1900;
	print_fp( "$tmpLogInit structg : CChange START ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",DBG,TIME_DBG);
	$tttime = $Hour * 3600 + $Minute * 60 + $Second;
	$cchange_start_time = $Hour * 3600 + $Minute * 60 + $Second;
}
sub mid_time_log {
	my $tmpLogInit = shift @_;
	if($tmpLogInit eq "LIB"){ print "ERROR:" . __SUB__ . "value $tmpLogInit\n"; exit; }
	($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
	$Month++;
	$Year += 1900;
	$ddtime = ($Hour * 3600 + $Minute * 60 + $Second) - $tttime;
	$tttime = $Hour * 3600 + $Minute * 60 + $Second;
	print_fp( "$tmpLogInit structg ($ddtime) : CChange ITERATE recursion END 1 ($stc_filename_input) - $Month-$Day-$Year : $Hour : $Minute : $Second\n",DBG,TIME_DBG);
}
sub end_time_log {
	my $tmpLogInit = shift @_;
	if($tmpLogInit eq "LIB"){ print "ERROR:" . __SUB__ . "value $tmpLogInit\n"; exit; }
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
	if($print_contents eq "LIB"){ print "ERROR:" . __SUB__ . "value $print_contents\n"; exit; }
	foreach $to_file (@_) {
		## STD라는 것은 DBG에 대해서 만들어둔 것으로 STD 나 DBG이나 같은 값을 의미한다.  
		print $to_file $print_contents;
	}
}

sub getHashRef {
	my ($name) = @_;        # gCan{9}
	if($name eq "LIB"){ print "ERROR:" . __SUB__ . "value $name\n"; exit; }
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
	if($iterate_var_name eq "LIB"){ print "ERROR:" . __SUB__ . "value $iterate_var_name\n"; exit; }
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
	if($iterate_var_name eq "LIB"){ print "ERROR:" . __SUB__ . "value $iterate_var_name\n"; exit; }
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
	if($s eq "LIB"){ print "ERROR:" . __SUB__ . "value $s\n"; exit; }
	$s =~ s/\{/#\+#\+#\+\+###/g;
	$s =~ s/\}/#\-#\-#\-\-###/g;
	$s =~ s/\\/#\=#\=#\=\=###/g;
	$s =~ s/\n/#\%#\%#\%\%###/g;
	$s =~ s/\"/#\&#\&#\&\&###/g;
	return $s;
}
sub recover_special_code {
	my ($s) = @_;
	if($s eq "LIB"){ print "ERROR:" . __SUB__ . "value $s\n"; exit; }
	$s =~ s/#\+#\+#\+\+###/\{/g;
	$s =~ s/#\-#\-#\-\-###/\}/g;
	$s =~ s/#\=#\=#\=\=###/\\/g;
	$s =~ s/#\%#\%#\%\%###/\n/g;
	$s =~ s/#\&#\&#\&\&###/\"/g;
	return $s;
}
sub traverse_hash_tree_to_recover_special_code {
	my ($TAXA_TREE,$vn,$lstr,$fh,@keyOrder)    = @_;
	if($TAXA_TREE eq "LIB"){ print "ERROR:" . __SUB__ . "value $TAXA_TREE\n"; exit; }
	my $allDigit = 1;
	my $keyOrderCnt = @keyOrder;

	print " sub $TAXA_TREE $vn $lstr $fh\n";
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
				traverse_hash_tree_to_recover_special_code($TAXA_TREE->{$key},$vn,$lstr . "\{" . recover_special_code($key) . "\}",$fh,@keyOrder);
			} else {
				traverse_hash_tree_to_recover_special_code($TAXA_TREE->{$key},$vn,$lstr . "\{\"" . recover_special_code($key) . "\"\}",$fh,@keyOrder);
			}
		} else {
			my $hashVar;
			my $hashValue;
			#print $fh "\$$vn$lstr\{\"" . recover_special_code($key) ."\"\}=\"" .  recover_special_code($TAXA_TREE->{$key}) . "\"\n";
			if(recover_special_code($key) =~ m/^\s*\d+\s*$/){
			#print "$lstr $key = $TAXA_TREE->{$key}\n";
				$hashVar = "\$$vn$lstr\{" . recover_special_code($key) ."\}";
			} else {
				$hashVar = "\$$vn$lstr\{\"" . recover_special_code($key) ."\"\}";
			}
			$hashValue = recover_special_code($TAXA_TREE->{$key});
			print $fh "$hashVar=\"" . $hashValue . "\"\n";
			if($keyOrderCnt > 0){
				my @myHashName = split(/{/,$hashVar);
				my $myHashNameCnt = @myHashName;
				my $tmpFirstElement = $myHashName[1];
				if( ($keyOrderCnt + 2) > $myHashNameCnt){ # 2 means HashName and first element. we can make new variable with elements after second order.
					print "ERROR : HashVar must have more elements\n\tNew @keyOrder [ cnt $keyOrderCnt ] , OldHash @myHashName [ cnt $myHashNameCnt ] - $hashVar\n";
					print __SUB__ . ":: ERROR : # 2 means HashName and first element. we can make new variable with elements after second order.\n";
					exit;
				}
				#Debug: print $fh "@keyOrder [ $keyOrderCnt ] , @myHashName [ $myHashNameCnt ]\n";
				for(my $i=0;$i<$keyOrderCnt;$i++){
					my @newVar = @myHashName;
					$newVar[0] = $myHashName[0] . "_$keyOrder[$i]";
					$newVar[1] = $newVar[$i+2];
					$newVar[$i+2] = $tmpFirstElement;
					my $n = join('{',@newVar);
					print $fh "$n=\"" . $hashValue . "\"\n";
				}
			}
		}
	}
}

sub traverse_hash_tree {
	my ($lib,$TAXA_TREE,$vn,$filename,$mode,@keyOrder)    = @_;
	print __SUB__ . "AA $TAXA_TREE $vn $lstr $filename $mode @keyOrder\n";
	if($mode eq "NEW"){ open(OUT,">default.GVm"); }
	else { open(OUT,">>default.GVm"); }
	traverse_hash_tree_to_recover_special_code($TAXA_TREE,$vn,"",OUT,@keyOrder);
	close(OUT);
}


sub BKMG_from_int {
	my ($value) = @_;
	if($value eq "LIB"){ print "ERROR:" . __SUB__ . "value $value\n"; exit; }
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
	if($value eq "LIB"){ print "ERROR:" . __SUB__ . "value $value\n"; exit; }
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

