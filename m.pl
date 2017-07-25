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

sub __SUB__ { (caller 1)[3] }

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

open(VAR_DBG,">var_debug.log");

$inputfilename = shift (@ARGV);
if($inputfilename eq ""){
	$inputfilename = "default.GV";
}

open(FH, "<",$inputfilename) or die "Can't open < $inputfilename: $!";
my $lcnt = 0 ;
while(<FH>){
	$s = $s_org = $_;
	chop($s);
	eval $s;
	$s =~ /^\$([^\{]+)/;
	$gPrintHashName{$1} = "Done";
	if($1 eq "gCan"){ print "== $s\n"; }
	#recover_hash_value(\%{$vname},$s);
	#LOG1 print $s_org;
	#if($lcnt >50){ last; }
	#$lcnt++;
}
close(FH);


foreach my $key (sort keys %gPrintHashName){
	print VAR_DBG "----[$key]----\n";
	traverse_hash_tree(\%{$key},$key,"",VAR_DBG);
}

# Make the Structure from gCol
$gRowMaxIndex = 0;
$gColMaxIndex = 0;
foreach $key (sort {$a<=>$b} keys %gCol){
	if($gRowMaxIndex < $key){ $gRowMaxIndex = $key; }
	$tmpStructMembers = "";
	print "gColStruct\{$key\}{Name} = $gColStruct{$key}{Name}\n";
	$tmpStructMembers .= "struct  $gColStruct{$key}{Name} {\n";
	foreach $key2 (sort {$a<=>$b} keys %{$gCol{$key}}){
		$max = $key2;
		print "gCol\{$key\}\{$key2\} Len:$gCol{$key}{$key2}{Len} Span:$gCol{$key}{$key2}{Span} V:$gCol{$key}{$key2}{Value} D:$gCol{$key}{$key2}{Define}\n";
		if($gCol{$key}{$key2}{Len} == ""){ next; }
		if($gCol{$key}{$key2}{Len} == 1){
			$tmpStructMembers .= "\tchar $gCol{$key}{$key2}{Define};";
		} elsif($gCol{$key}{$key2}{Len} == 2){
			$tmpStructMembers .= "\tshort $gCol{$key}{$key2}{Define};";
			$max += 1;
		} elsif($gCol{$key}{$key2}{Len} == 4){
			$tmpStructMembers .= "\tint $gCol{$key}{$key2}{Define};";
			$max += 3;
		} elsif($gCol{$key}{$key2}{Len} > 4){
			$tmpStructMembers .= "\tchar *$gCol{$key}{$key2}{Define};";
			if($gCol{$key}{$key2}{Len} != 99999){
				$max += ($gCol{$key}{$key2}{Len} - 1);
			}
		} else {
			$tmpStructMembers .= "\tERROR : $gCol{$key}{$key2}{Define};";
		}
		$tmpStructMembers .= "\t\t/* Len:$gCol{$key}{$key2}{Len} Span:$gCol{$key}{$key2}{Span} V:$gCol{$key}{$key2}{Value} D:$gCol{$key}{$key2}{Define} Desc:$Col{$key}{$key2}{Description} C:$gCol{$key}{$key2}{Comments} */\n";
		if($gColMaxIndex < $max){ $gColMaxIndex = $max; }
	}
	$tmpStructMembers .= "};\n";
	$gColStruct{$key}{Struct} = $tmpStructMembers;
	print "$gColStruct{$key}{Struct}";
}

print "\$gRowMaxIndex = $gRowMaxIndex (vertical max count)\n";
print "\$gColMaxIndex = $gColMaxIndex (horizontal max count)\n";

$gVariables{gColMaxIndex} = $gColMaxIndex;
$gVariables{gRowMaxIndex} = $gRowMaxIndex;

# URL for table -> http://blog.naver.com/seri313/221013562648
# Color -> http://blog.naver.com/cjsong/220415983494
# table attribute -> http://blog.naver.com/scyan2011/220980441610
# hieght attribute -> http://blog.naver.com/eeccy0601/220428488387
#
$a = <<'END_MESSAGE';
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<title>테이블</title>
</head> 
<STYLE TYPE="text/css">
table {font-size: 75%;}
</STYLE>
<body>
 <h1>데이터 테이블 캡션</h1>
  <table border="1">
END_MESSAGE

# $gCol{1}{2}
#       0 1 2                |
#    0: - - -     --> x      V y
#    1: - - -
#    2: - X -
for($j=0;$j<=$gColMaxIndex;$j++){
	for($i=0;$i<=$gRowMaxIndex;$i++){
		if($gCol{$i}{$j}{Len}){
			if($gCol{$i}{$j}{Len} == 99999){ $gCol{$i}{$j}{Len} = $gColMaxIndex - $j + 1;
			}
			if($gCol{$i}{$j}{Span} > 1){
				$gCol{$i - $gCol{$i}{$j}{Span} + 1}{$j}{Span} = $gCol{$i}{$j}{Span};
				for($k=$i-$gCol{$i}{$j}{Span} + 2;$k <= $i; $k++){
					$gCol{$k}{$j}{Span} = 0;
				}
			}
		}
	}
}
# fill a blank between values
#  fill all parts with blank
for($i=0;$i<=$gRowMaxIndex;$i++){
	$cur = 0;
	for($j=0;$j<=$gColMaxIndex;$j++){
		if($gCol{$i}{$j}{Len}){
			print "$i $j $gCol{$i}{$j}{Len}\n";
			$j += $gCol{$i}{$j}{Len} -1;
		} else {
			$gCol{$i}{$j}{Len} = $gColMaxIndex - $j + 1;
			$gCol{$i}{$j}{Span} = -1;
			last;
		}
	}
}
for($j=0;$j<=$gColMaxIndex;$j++){
	printf("%3d ",$j);
	for($i=0;$i<=$gRowMaxIndex;$i++){
		if($gCol{$i}{$j}{Len}){
			printf("\[%3d:%3d\] ",$gCol{$i}{$j}{Len} , $gCol{$i}{$j}{Span});
			$gRow{$j}{$i}{Len} = $gCol{$i}{$j}{Len};
			$gRow{$j}{$i}{Span} = $gCol{$i}{$j}{Span};
			$gRow{$j}{$i}{Description} = $gCol{$i}{$j}{Description};
			$gRow{$j}{$i}{Value} = $gCol{$i}{$j}{Value};
			$gRow{$j}{$i}{Define} = $gCol{$i}{$j}{Define};
			$gRow{$j}{$i}{Comments} = $gCol{$i}{$j}{Comments};
		} else {
			$gRow{$j}{$i}{Len} = 0;
			print "\[       \] ";
		}
	}
	print "\n";
}
$gPrintHashName{gRow} = "";

$b = "";
for($j=0;$j<=$gColMaxIndex;$j++){
	$b .= "<tr height=35px><td>$j<\/td>\n";
	for($i=0;$i<=$gRowMaxIndex;$i++){
		if(($gCol{$i}{$j}{Len} >= 1) && ($gCol{$i}{$j}{Span} >= 1) ){
			$b .= "<td align=center border=1 bgcolor=beige ";
			if($gCol{$i}{$j}{Len} >= 1){ $b .= " rowspan=\"$gCol{$i}{$j}{Len}\" "; }
			if($gCol{$i}{$j}{Span} >= 1){ $b .= " colspan=\"$gCol{$i}{$j}{Span}\" "; }
			$b .= " >\n";
			$b .= $gCol{$i}{$j}{Value} . "<br>" . $gCol{$i}{$j}{Description} . "\n";
			$b .= " <\/td>\n";
		} elsif(($gCol{$i}{$j}{Len} >= 1) && ($gCol{$i}{$j}{Span} == -1) ){
			$b .= "<td border=0 \n";
			if($gCol{$i}{$j}{Len} >= 1){ $b .= " rowspan=\"$gCol{$i}{$j}{Len}\" \n"; }
			$b .= ">   <\/td>\n";       # no value
		}
	}
	$b .= "<\/tr>\n";
}

$c = <<'END_MESSAGE';
  </table>
  </body>
  </html>
END_MESSAGE

open(FH,">","a.html");
print FH $a;
print FH $b;
print FH $c;
close(FH);


open(GVW,">"."default.GVm") or die "GVW:ERROR$!\n";
foreach my $key (sort keys %gPrintHashName){
	traverse_hash_tree_to_change_special_code(\%$key,$key,"",GVW);
}
close(GVW) or die "Error in closing the file ", __FILE__, " $!\n";;

