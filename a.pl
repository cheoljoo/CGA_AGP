#!/bin/perl


# this is example for constant.
#  But , I want to use the constant as define.
#  I can not use it.  so it is not a good solution for me.
use constant START_BRACE => "{";
use constant END_BRACE => "}";
use constant BACK_SLASH => "\\";
use constant SHARP => "\#";

our %gCan;      # %gCan{index}{Description}{Value}{Define}{Continue}
our %gRow;      # horizontal meaing : %gRow{index}{value}{define} = history
our $gRowCnt = 0;
our $gRowMaxIndex = 0;
our %gCol;      # structure
our $gColCnt = 0;
our %gColStruct;
our $gColMaxIndex = 0;
our %gPrintHashName;

our %gTmp;
our $gIndexOfStart;

sub getHashRef {
	my ($name) = @_;        # gCan{9}
	my $first;
	#print "F " . $name . "\n";
	$name =~ s/([^\{]+)//;
	$first = $1;
	my $hn = \%{$first};
	#print "F " . $hn . "\n";
	while($name =~ s/^\{([^\}]*)\}//){
		my $uu = $1;
		$hn = $hn->{$uu};
		#print "G " . $uu . "   $hn\n";
	}

	#print "I " . $hn . "\n";
	return $hn;
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
	#print "[r:$s]";
	$s =~ s/#\+#\+#\+\+###/\{/g;
	$s =~ s/#\-#\-#\-\-###/\}/g;
	$s =~ s/#\=#\=#\=\=###/\\/g;
	$s =~ s/#\%#\%#\%\%###/\n/g;
	$s =~ s/#\&#\&#\&\&###/\"/g;
	#print "[R:$s]";
	return $s;
}
sub traverse_hash_tree_to_change_special_code {
	my ($TAXA_TREE,$vn,$lstr,$fh)    = @_;
	#print "[sub $TAXA_TREE]\n";
	foreach my $key (sort{$a<=>$b} keys %{$TAXA_TREE}) {
		if (ref $TAXA_TREE->{$key} eq 'HASH') {
			#print "[K:[$key] lstr=$lstr]\n";
			if($key =~ /^\s*\d+\s*$/){
				traverse_hash_tree_to_change_special_code($TAXA_TREE->{$key},$vn,$lstr . "\{" . change_special_code($key) . "\}",$fh);
			} else {
				traverse_hash_tree_to_change_special_code($TAXA_TREE->{$key},$vn,$lstr . "\{\"" . change_special_code($key) . "\"\}",$fh);
			}
		} else {
			#print "[T:$lstr $key = $TAXA_TREE->{$key}]\n";
			if($key =~ /^\s*\d+\s*$/){
				print $fh "\$$vn$lstr\{" . change_special_code($key) ."\}=\"" . change_special_code($TAXA_TREE->{$key}) . "\"\n";
			} else {
				print $fh "\$$vn$lstr\{\"" . change_special_code($key) ."\"\}=\"" . change_special_code($TAXA_TREE->{$key}) . "\"\n";
			}
		}
	}
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

$filename = shift (@ARGV);
if($filename eq ""){
	$filename = "default.def";
}
open(FH, "<",$filename) or die "Can't open < $filename: $!";
$total_context_org = "";
$total_context_chg = "";
while(<FH>){
	$s = $s_org = $_;
	chop($s);
	$total_context_org .= $s_org;
	#LOG1 print $s_org;
	if( ($s =~ /^\s*\#/)  or
		($s =~ /^\s*\{/)  or
		($s =~ /^\s*\}/) ){
	} elsif($s =~ /^\s*Index\s+([\d-?]+)\s*:\s*(\([^\):]*\)|\s*)\s*Value\s*:\s*(\S+)\s*,\s*Define\s*:\s*(\S+)\s*(\\?)\s*/){        # $` $&  $'
		#LOG1 print "\t==>[$1]  [$2] [$3] [$4] [$5] [$']\n";
		my $lBytes = $1;
		my $lDescription = $2;
		my $lValue = $3;
		my $lDefine = $4;
		my $lContinue = $5;
		my $lOthers = $';   # Comments
		$gCan{$lBytes}{$lDescription}{$lValue}{$lDefine}{$lContinue} = $lOthers;
	# upper regular expression express the following three regex.   we can combine the syntax with | in regex.
	# elsif($s =~ /:\s*(\([^\)]*\)|\s*)/)        # $` $&  $'
	# elsif($s =~ /^\s*Index\s+([\d-?]+)\s*:\s*\s*Value\s*:\s*(\S+)\s*,\s*Define\s*:\s*(\S+)\s*(\\?)\s*/){        # $` $&  $'
	# elsif($s =~ /^\s*Index\s+([\d-?]+)\s*:\s*\(([^\)]*)\)\s*Value\s*:\s*(\S+)\s*,\s*Define\s*:\s*(\S+)\s*(\\?)\s*/){        # $` $&  $'
	} else {
		print "ERR: $s\n";
	}
}
close(FH);
$gPrintHashName{"gCan"} = "";

print "\n======= Origin  ==========\n";
print $total_context_org;
foreach my $key (keys %gCan) {
	#LOG1 #print $keys;
}
#LOG2 traverse_hash_tree(\%gCan);
#LOG2 print $total_context_org;

while(1)
{
	$temp = $total_context_org;
	$total_context_org =~ s/(\#[^\{\n]*)\{/$1#+#+#++###/g;
	$total_context_org =~ s/(\#[^\}\n]*)\}/$1#-#-#--###/g;
	$total_context_org =~ s/(\#[^\\\n]*)\\/$1#=#=#==###/g;
	if($temp eq $total_context_org){
		last;
	}
}
#LOG2 print $total_context_org;

#LOG2 my @matches = $total_context_org =~ /\{(?:\{[^\{]*\}|[^\{])*\}/sg;
#LOG2 foreach (@matches) {
#LOG2 print "!!!! $_\n";
#LOG2 }


# expand the original lines (delimiter : \ )
# The end \ of statemant means that this line has the same rule (sub syntax) of next lines.
$i = 0;
while(1){
	if($total_context_org =~ /\s*Index\s+([\d-?]+)\s*:\s*(\([^\):]*\)|\s*)\s*Value\s*:\s*(\S+)\s*,\s*Define\s*:\s*(\S+)\s*(\\)(\s*)/)
	{        # $` $&  $'
		#LOG2 print "++++++++++++++++++\n";
		$lstart = $`;
		$lmid = $&;
		$lend = $';
		$lspace = $6;
		#LOG2 print "--8--$lspace--8--\n";
		$lspace =~ s/\s*\n//;
		#LOG2 print "--8--$lspace--8--\n";
		$lstart =~ s/\{/#+#+#++###/g;
		$lmid =~ s/\\//;
		#LOG2 print "-1-$lstart-2-\n";
		#LOG2 print "-3-$lmid-4-\n";
		#LOG2 print "-5-$lend-6-\n";
		if($lend =~ s/^(\s*\#[^\n]*\n)(\s*)//){
			$lmid .= $1;
			$lspace = $2;
			#LOG2 print "--7--$lmid--7--\n";
		} else {
			$lmid =~ s/\n\s*$/\n/;
		}
		#LOG2 print "--8--$lspace--8--\n";
		#LOG2 print "=1-$lstart-2-\n";
		#LOG2 print "=3-$lmid-4-\n";
		#LOG2 print "=5-$lend-6-\n";
		$total_context_org = $lstart . $lmid . $lend;
	} else {
		last;
	}
	#my @matches = $total_context_org =~ /\{(?:\{.*\}|[^\{])*\}/sg;
	#foreach (@matches) { print "!! $_\n"; }
	$total_context_org =~ /(\{([^\{\}]|(?R))*\})/g;
	$lbracket = $1;
	#LOG2 print("----------\n$lbracket\n------\n");
	$lbracket =~ s/\{/#+#+#++###/g;
	$lbracket .= "\n";
	#LOG2 print "--9--$lbracket--9--\n";
	$total_context_org = $lstart . $lmid . $lspace . $lbracket . $lspace . $lend;
	#LOG2 print "\n======= $i ==========\n";
	#LOG2 print $total_context_org;
	$i++;
}


print "\n======= Final  ==========\n";
$total_context_org =~ s/$1#\+#\+#\+\+###/\{/g;
$total_context_org =~ s/$1#-#-#--###/\}/g;
$total_context_org =~ s/$1#=#=#==###/\\/g;
print "CONTEXT = " . $total_context_org;

@lines = split(/\n/,$total_context_org);
#LOG3 print @lines;


print "\n======= Analysis  ==========\n";
foreach $line (@lines){
	print $line . "\n";
	if( ($line =~ /^\s*\#/)  or
		($line =~ /^\s*\{/)  or
		($line =~ /^\s*\}/) ){
	} elsif($line =~ /^\s*Index\s+([\d-?]+)\s*:\s*(\([^\):]*\)|\s*)\s*Value\s*:\s*(\S+)\s*,\s*Define\s*:\s*(\S+)\s*/){        # $` $&  $'
		my $lIndex = $1;
		my $lDescription = $2;
		my $lValue = $3;
		my $lDefine = $4;
		my $lOthers = $';   # Comments

		$gIndexOld = $gIndexOfStart;
		if($lIndex =~ /(\d+)\s*-\s*(\d+)/){
			$gIndexOfStart = $1;
			$gLen = $2 - $1 + 1;
		} elsif($lIndex =~ /(\d+)\s*-\s*\?/){
			$gIndexOfStart = $1;
			$gLen = 99999;
		} elsif($lIndex =~ /(\d+)/){
			$gIndexOfStart = $1;
			$gLen = 1;
		} else {
			print "ERR : $line \n";
		}


		## IWISH : Draw the explanation with plantUML 
		print "<<<< $gIndexOfStart < $gIndexOld >>>>\n";
		if($gIndexOfStart < $gIndexOld){
			print "{{{{ $gIndexOfStart < $gIndexOld }}}}\n";
			my $tmpStructName = "";
			foreach $key (sort {$a<=>$b} keys %gTmp){
				{       # copy
					$gCol{$gColCnt}{$key}{Len} = $gTmp{$key}{Len} ;
					$gCol{$gColCnt}{$key}{Span} = $gTmp{$key}{Span} ;
					$gCol{$gColCnt}{$key}{Description} = $gTmp{$key}{Description} ;
					$gCol{$gColCnt}{$key}{Value} = $gTmp{$key}{Value} ;
					$gCol{$gColCnt}{$key}{Define} = $gTmp{$key}{Define} ;
					$gCol{$gColCnt}{$key}{Comments} = $gTmp{$key}{Comments} ;
					if($gTmp{$key}{Len} ne ""){ $tmpStructName .= "__" . $gTmp{$key}{Define}; }
				}
				if($key >= $gIndexOfStart){     # index 0 ...   5     index 3 ... (So remove 5,4 only)
					print "#";
					delete $gTmp{$key}{Len} ;
					delete $gTmp{$key}{Span} ;
					delete $gTmp{$key}{Description} ;
					delete $gTmp{$key}{Value} ;
					delete $gTmp{$key}{Define} ;
					delete $gTmp{$key}{Comments} ;
					delete $gTemp{$key};
				} else {
					$gTmp{$key}{Span}++ ;
				}
			}
			$gColStruct{$gColCnt}{Name} = $tmpStructName;
			$gColCnt ++;
		}

		print "$gIndexOfStart $gLen  $lDescription  $lValue  $lDefine $lOthers\n";
		$gTmp{$gIndexOfStart}{Len} = $gLen;
		$gTmp{$gIndexOfStart}{Span} = 1;
		$gTmp{$gIndexOfStart}{Description} = $lDescription;
		$gTmp{$gIndexOfStart}{Value} = $lValue;
		$gTmp{$gIndexOfStart}{Define} = $lDefine;
		$gTmp{$gIndexOfStart}{Comments} = $lOthers;

		foreach $key (sort {$a<=>$b} keys %gTmp){
			print "$key\[$gTmp{$key}{Len}:$gTmp{$key}{Span}\]  ";
		}
		print "\n";
	}
}
# When it reaches the EOF, Last gTmp is not processed. So I process the last gTmp values
{
	print "{{{{ $gIndexOfStart < $gIndexOld }}}}\n";
	my $tmpStructName = "";
	foreach $key (sort {$a<=>$b} keys %gTmp){
		{       # copy
			$gCol{$gColCnt}{$key}{Len} = $gTmp{$key}{Len} ;
			$gCol{$gColCnt}{$key}{Span} = $gTmp{$key}{Span} ;
			$gCol{$gColCnt}{$key}{Description} = $gTmp{$key}{Description} ;
			$gCol{$gColCnt}{$key}{Value} = $gTmp{$key}{Value} ;
			$gCol{$gColCnt}{$key}{Define} = $gTmp{$key}{Define} ;
			$gCol{$gColCnt}{$key}{Comments} = $gTmp{$key}{Comments} ;
			if($gTmp{$key}{Len} ne ""){ $tmpStructName .= "__" . $gTmp{$key}{Define}; }
		}
		$gColStruct{$gColCnt}{Name} = $tmpStructName;
	}
}
$gPrintHashName{"gCol"} = "Column";
$gPrintHashName{"gColStruct"} = "Each Structure of each Column";
$gPrintHashName{"gVariables"} = "Global Variables.  I will make the varible directly.";
$gVariables{gColCnt} = $gColCnt;

## Print gCol
foreach $key (sort {$a<=>$b} keys %gColStruct){
	print "gColStruct\{$key\}{Name} = $gColStruct{$key}{Name}\n";
}


open(GVW,">"."default.GV") or die "GVW:ERROR$!\n";
foreach my $key (sort keys %gPrintHashName){
	traverse_hash_tree_to_change_special_code(\%$key,$key,"",GVW);
}
close(GVW) or die "Error in closing the file ", __FILE__, " $!\n";;

