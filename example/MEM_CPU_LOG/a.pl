#!/bin/perl

our $tttime;
our $cchange_start_time;
our $outputdir = "OUTPUT";
our %local_var_set;

our @EXPORT = qw(traverse_hash_tree  recover_special_code change_special_code sort_keys max_keys getHashRef print_fp end_time_log mid_time_log start_time_log  __SUB__);

sub __SUB__ { return  (caller 2)[3] . "|" . (caller 2)[2] . "-" . (caller 1)[3] . "|" . (caller 1)[2] . "-" . (caller 0)[2] . ": " }

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
	traverse_hash_tree_to_recover_special_code($TAXA_TREE,$vn,$lstr,$fh);
}



sub calculate_memory_BKMG {
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


our %MEMTASK;
our %MEMTOTAL;
our %RAM;
our %CPUTOTAL;
our %CPUTASK;

our $logFileName = "memory.log";
opendir(DIR, ".");
@files = readdir(DIR);
closedir(DIR);

foreach $dir (@files){
	if(not ((-d $dir) && ($dir =~ m/_(?P<MONTH>\d+)_(?P<DAY>\d+)_(?P<YEAR>\d+)\s*$/)) ){
		next ;
	}
	my $logPath = "$dir/$logFileName";
	my $date = "$+{YEAR}_$+{MONTH}_$+{DAY}";

	if(not (-e $logPath) ){ next; }
	print "$logPath : $date\n";

	my $min = 0;
	my $memcmdlistcnt=0;
	my $cpucmdlistcnt=0;
	open(LOGI,"<$logPath");
	while(<LOGI>){
		$s = $_;
		chop($s);
		if($s =~ m/^\s*DATE\s*:\s*.*up\s+(\d+)\s*min/){
			# DATE :  00:25:32 up 5 min,  load average: 1.04, 0.84, 0.40
			$min = $1;
			print "$min : $s\n";
		} elsif($s =~ m/^\s*(\d+)\s+(\d+[BMKG]?)\s+(\d+[BMKG]?)\s+(\d+[BMKG]?)\s+(\d+[BMKG]?)\s+(.*)\s*$/){
			# PID       Vss      Rss      Pss      Uss  cmdline
			# 848   238332K    5752K    4083K    3940K  /usr/bin/rild
			$pid = $1;
			$vss = calculate_memory_BKMG($2);
			$rss = calculate_memory_BKMG($3);
			$pss = calculate_memory_BKMG($4);
			$uss = calculate_memory_BKMG($5);
			$cmdline = $6;
			$MEMTASK{$date}{$min}{$pid}{vss} = $vss;
			$MEMTASK{$date}{$min}{$pid}{rss} = $rss;
			$MEMTASK{$date}{$min}{$pid}{pss} = $pss;
			$MEMTASK{$date}{$min}{$pid}{uss} = $uss;
			$MEMTASK{$date}{$min}{$pid}{cmd} = $cmdline;
			$MEMCMDLIST{$cmdline} = $memcmdlistcnt++;
			print "$pid : $vss : $rss : $pss : $uss : $cmdline\n";
		} elsif($s =~ m/^\s*(\d+[BMKG]?)\s+(\d+[BMKG]?)\s+TOTAL\s*$/){
			#                  57041K   51036K  TOTAL
			$totalPss = calculate_memory_BKMG($1);
			$totalUss = calculate_memory_BKMG($2);
			$MEMTOTAL{$date}{$min}{pss} = $totalPss;
			$MEMTOTAL{$date}{$min}{uss} = $totalUss;
			print "TOTAL pss $totalPss : uss $totalUss\n";
		} elsif($s =~ m/^\s*RAM:\s*(\d+[BMKG]?)\s+total,\s+(\d+[BMKG]?)\s+free/){
			# RAM: 159948K total, 7512K free, 0K buffers, 69248K cached, 912K shmem, 23056K slab
			$total = calculate_memory_BKMG($1);
			$free = calculate_memory_BKMG($2);
			$RAM{$date}{$min}{total} = $total;
			$RAM{$date}{$min}{free} = $free;
			print "RAM total $total : free $free\n";
		} elsif($s =~ m/^\s*CPU:\s*(?P<usr>[\d\.]+)%\s+usr\s+(?P<sys>[\d\.]+)%\s+sys\s+[\d\.]+%\s+nic\s+(?P<idle>[\d\.]+)%\s+idle/){
			#CPU:  0.0% usr 18.1% sys  0.0% nic 81.8% idle  0.0% io  0.0% irq  0.0% sirq
			$CPUTOTAL{$date}{$min}{usr} = $+{usr};
			$CPUTOTAL{$date}{$min}{sys} = $+{sys};
			$CPUTOTAL{$date}{$min}{idle} = $+{idle};
			print "CPUTOTAL usr $+{usr} : sys $+{sys} : idle $+{idle}\n";
			#print "CPU usr $1 : sys $2 : idle $3\n";
		} elsif($s =~ m/^\s*(?P<PID>\d+)\s+(?P<PPID>\d+)\s+(?P<USER>\S+)\s+(?P<STAT>\S+)\s*\<?\s*(?P<VSZ>\d+)[m\s]+(?P<PVSZ>[\d\.]+)\s+(?P<CPU>[\d\.]+)\s+(?P<PCPU>[\d\.]+)\s+(?P<COMMAND>[\S ]+)\s*$/){
			# 867     1 root     S     200m127.8   0  0.0 /usr/bin/netmgrd
			# 820     1 root     S <   192m122.8   0  0.0 /usr/bin/thermal-engine
			$pid = $+{PID};
			$CPUTASK{$date}{$min}{$pid}{ppid} = $+{PPID};
			$CPUTASK{$date}{$min}{$pid}{user} = $+{USER};
			$CPUTASK{$date}{$min}{$pid}{stat} = $+{STAT};
			$CPUTASK{$date}{$min}{$pid}{vsz} = $+{VSZ};
			$CPUTASK{$date}{$min}{$pid}{pvsz} = $+{PVSZ};
			$CPUTASK{$date}{$min}{$pid}{cpu} = $+{CPU};
			$CPUTASK{$date}{$min}{$pid}{pcpu} = $+{PCPU};
			$CPUTASK{$date}{$min}{$pid}{command} = $+{COMMAND};
			$CPUCMDLIST{$+{COMMAND}} = $cpucmdlistcnt++;
			print __SUB__ . "CPU pid $+{PID} : ppid $+{PPID} : user $+{USER} : stat $+{STAT} : vsz $+{VSZ} : pvsz $+{PVSZ} : cpu $+{CPU} : pcpu $+{PCPU} : cmd $+{COMMAND}\n";
		}
	}
	close(LOGI);
}


#### STEP 2
# Find increase the memory size each process in a day
# Find increasing memory size and cpu % than yesterday
my $minCountMax = 0;
foreach my $date (keys %{MEMTASK}){
	my $minCount = 0;
	foreach my $min (keys %{$MEMTASK{$date}}){
		$minCount++;
		foreach my $pid (keys %{$MEMTASK{$date}{$min}}){
			$memPID{$date}{$pid}{$min}{pss} = $MEMTASK{$date}{$min}{$pid}{pss};
		}
	}
	if($minCountMax < $minCount){ $minCountMax = $minCount; }
}
# Find increase the memory size each process in a day
foreach my $date (keys %{memPID}){
	foreach my $pid (keys %{$memPID{$date}}){
		my $increase = 1;
		my $pssMax = 0;
		my $initmin;
		my $finalmin;
		foreach my $min (sort {$a <=> $b} keys %{$memPID{$date}{$pid}}){ # minutes
			if($pssMax == 0){
				$initmin = $min;
				$pssMax = $MEMTASK{$date}{$min}{$pid}{pss};
			}
			elsif($pssMax <= $MEMTASK{$date}{$min}{$pid}{pss}){
			} else {
				$increase = 0;
			}
			$finalmin = $min;
		}
		if( ($increase == 1) && ($MEMTASK{$date}{$initmin}{$pid}{pss} < $MEMTASK{$date}{$finalmin}{$pid}{pss}) ){
			print "$increase $date $initmin $finalmin $pid $MEMTASK{$date}{$finalmin}{$pid}{cmd} ($MEMTASK{$date}{$initmin}{$pid}{pss} < $MEMTASK{$date}{$finalmin}{$pid}{pss})\n";
			$MEMTASK{$date}{$finalmin}{$pid}{pssleak} = 1;
			$memPID{$date}{$pid}{$finalmin}{cmd} = $MEMTASK{$date}{$finalmin}{$pid}{cmd};
		}
	}
}

my $mul = int(24 / $minCountMax);
foreach $date (sort keys %{MEMTASK}){
	#print "D$date ";
	$tmpDate = $date;
	my $lcnt = 1;
	foreach $min (sort {$a <=> $b} keys %{$MEMTASK{$date}}){
		#print "M$min ";
		my $indexHour = sprintf("%3d",$mul * $lcnt);
		$lcnt++;
		foreach $pid (keys %{$MEMTASK{$date}{$min}}){
			#print "P$pid ";
			# {date}{index_of_min}{process}
			my $cmd = $MEMTASK{$date}{$min}{$pid}{cmd};
			my $pss = $MEMTASK{$date}{$min}{$pid}{pss};
			$tmpDate =~ s/_/,/g;
			$tmpDateTime = $tmpDate . ", " . $indexHour;
			if( $MEMTASK{$date}{$min}{$pid}{pssleak} == 1){
				$MEMCHART{$tmpDateTime}{$cmd}{pssleak} = "MemLeak:$cmd";
			}
			$MEMCHART{$tmpDateTime}{$cmd}{pss} = $pss;
			$MEMCMDCHART{$cmd}{$tmpDateTime}{pss} = $pss;
		}
		print "\n";
	}
	print "\n";
}
print "mul $mul $minCountMax\n";

#### OUT
open(OUT,">default.GVm");
traverse_hash_tree(\%{MEMTASK},MEMTASK,"",OUT);
traverse_hash_tree(\%{MEMTOTAL},MEMTOTAL,"",OUT);
traverse_hash_tree(\%{RAM},RAM,"",OUT);
traverse_hash_tree(\%{CPUTASK},CPUTASK,"",OUT);
traverse_hash_tree(\%{CPUTOTAL},CPUTOTAL,"",OUT);
traverse_hash_tree(\%{MEMCMDLIST},MEMCMDLIST,"",OUT);
traverse_hash_tree(\%{CPUCMDLIST},CPUCMDLIST,"",OUT);
traverse_hash_tree(\%{memPID},memPID,"",OUT);
traverse_hash_tree(\%{MEMCHART},MEMCHART,"",OUT);
traverse_hash_tree(\%{MEMCMDCHART},MEMCMDCHART,"",OUT);
close(OUT);

