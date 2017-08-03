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
our %gVariables;

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
	my $allDigit = 1;
	foreach my $tmpKey ( keys %{$TAXA_TREE}){
		if(not ($tmpKey =~ /^\s*\d*\s*$/)){
			$allDigit = 0;
			last;
		}
	}

	# always sort as sequence of digit or string
	my @tmpRt;
	if($allDigit == 1){ @tmpRt =  sort {$a <=> $b} keys %{$TAXA_TREE}; }
	else { @tmpRt =   sort keys %{$TAXA_TREE}; }

	foreach my $key (@tmpRt) {
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
	if($1 eq "gVariables"){ print "== $s\n"; }
	#recover_hash_value(\%{$vname},$s);
	#LOG1 print $s_org;
	#if($lcnt >50){ last; }
	#$lcnt++;
}
close(FH);

foreach my $key (keys %gVariables){
	print "[ $key ] \n";
	$$key = $gVariables{$key};
}


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
print "[Len:Span]\n";
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


# change gCol and gRow
# sibling means the index with span value >=1  (representitives of each group)
### sibling will be caclulated from gRow
my $siblingKeyX=0;
foreach $keyY (sort {$a<=>$b} keys %gRow){  # keyY : byte index on html table
	foreach $keyX (sort {$a<=>$b} keys %{$gRow{$keyY}}){
		if( ($gCol{$keyX}{$keyY}{Value} eq "") || ($gCol{$keyX}{$keyY}{Value} eq "?") || ($gCol{$keyX}{$keyY}{Len} <= 0) ){
			$gCol{$keyX}{$keyY}{ParserSiblingX} = $gCol{$keyX}{$keyY-1}{ParserSiblingX};
			$gCol{$keyX}{$keyY}{ParserSiblingY} = $gCol{$keyX}{$keyY-1}{ParserSiblingY};
			$gRow{$keyY}{$keyX}{ParserSiblingX} = $gCol{$keyX}{$keyY-1}{ParserSiblingX};
			$gRow{$keyY}{$keyX}{ParserSiblingY} = $gCol{$keyX}{$keyY-1}{ParserSiblingY};
		} elsif($gRow{$keyY}{$keyX}{Span} <= 0){
			$gRow{$keyY}{$keyX}{ParserSiblingX} = $siblingKeyX;
			$gCol{$keyX}{$keyY}{ParserSiblingX} = $siblingKeyX;
		} else {
			$gRow{$keyY}{$keyX}{ParserSiblingX} = $keyX;
			$gCol{$keyX}{$keyY}{ParserSiblingX} = $keyX;
			$siblingKeyX = $keyX;
		}
	}
}
my $siblingKeyY;
foreach $keyX (sort {$a<=>$b} keys %gCol){
	foreach $keyY (sort {$a<=>$b} keys %{$gCol{$keyX}}){
		if( ($gCol{$keyX}{$keyY}{Value} eq "") || ($gCol{$keyX}{$keyY}{Value} eq "?") || ($gCol{$keyX}{$keyY}{Len} <= 0) ){
			$gCol{$keyX}{$keyY}{ParserSiblingY} = $siblingKeyY;
			$gRow{$keyY}{$keyX}{ParserSiblingY} = $siblingKeyY;
		} else {
			$gCol{$keyX}{$keyY}{ParserSiblingY} = $keyY;
			$gRow{$keyY}{$keyX}{ParserSiblingY} = $keyY;
			$siblingKeyY = $keyY;
		}
	}
}
print "bytes [Len:Span:ParserSiblingX:ParserSiblingY]\n";
print "if span == -1 , Ignore the below column\n";
print "Byte";
for($i=0;$i<=$gRowMaxIndex;$i++){
	printf("\[_____%2d____\] ",$i);
}
print "\n";
for($j=0;$j<=$gColMaxIndex;$j++){
	printf(" %2d ",$j);
	for($i=0;$i<=$gRowMaxIndex;$i++){
		if(1){ # for debug
			printf("\[%2d:%2d:%2d:%2d\] ",$gCol{$i}{$j}{Len} , $gCol{$i}{$j}{Span}, $gCol{$i}{$j}{ParserSiblingX} , $gCol{$i}{$j}{ParserSiblingY});
		} else {
			if($gCol{$i}{$j}{Len}){
				printf("\[%2d:%2d:%2d:%2d\] ",$gCol{$i}{$j}{Len} , $gCol{$i}{$j}{Span}, $gCol{$i}{$j}{ParserSiblingX} , $gCol{$i}{$j}{ParserSiblingY});
			} else {
				print "\[__:__:__:__\] ";
			}
		}
	}
	print "\n";
}



### LongDefine name  : we will use these in parameter of parser function as separating origins.
### each long name is unique.
### parent
my $tmpCnt =0;
foreach $keyX (sort {$a<=>$b} keys %gCol){
	my $tmpLongDefine = "";
	my $tmpHistory = "";
	foreach $keyY (sort {$a<=>$b} keys %{$gCol{$keyX}}){
		if($gCol{$keyX}{$keyY}{Define} ne ""){ $tmpLongDefine = $tmpLongDefine . "__" . $gCol{$keyX}{$keyY}{Define}; }
		my $tmpH = $tmpHistory . "_ " . "$keyX:$keyY(S:$gCol{$keyX}{$keyY}{ParserSiblingX})";
		$gCol{$keyX}{$keyY}{LongDefine} = $tmpLongDefine;
		$gRow{$keyY}{$keyX}{LongDefine} = $tmpLongDefine;
		if($gLongDefine{Name}{$tmpLongDefine} eq ""){
			$gLongDefine{Name}{$tmpLongDefine} = $tmpCnt;
			$gLongDefine{History}{$tmpLongDefine} = $tmpH;
			$gLongDefine{Index}{$tmpCnt} = $tmpLongDefine;
			$gLongDefineDebug{$tmpLongDefine}{Name} = $tmpCnt;
			$gLongDefineDebug{$tmpLongDefine}{History} = $tmpH;
			$tmpCnt++;
		}
		if( ($gCol{$keyX}{$keyY}{Value} eq "") || ($gCol{$keyX}{$keyY}{Value} eq "?") || ($gCol{$keyX}{$keyY}{Len} <= 0) ){
			$gCol{$keyX}{$keyY}{ParserParentX} = $gCol{$keyX}{$keyY-1}{ParserParentX};
			$gCol{$keyX}{$keyY}{ParserParentY} = $gCol{$keyX}{$keyY-1}{ParserParentY};
			$gRow{$keyY}{$keyX}{ParserParentX} = $gCol{$keyX}{$keyY-1}{ParserParentX};
			$gRow{$keyY}{$keyX}{ParserParentY} = $gCol{$keyX}{$keyY-1}{ParserParentY};
			#$gCol{$keyX}{$keyY}{ParserSiblingX} = $gCol{$keyX}{$keyY-1}{ParserSiblingX};
			#$gCol{$keyX}{$keyY}{ParserSiblingY} = $gCol{$keyX}{$keyY-1}{ParserSiblingY};
			#$gRow{$keyY}{$keyX}{ParserSiblingX} = $gCol{$keyX}{$keyY-1}{ParserSiblingX};
			#$gRow{$keyY}{$keyX}{ParserSiblingY} = $gCol{$keyX}{$keyY-1}{ParserSiblingY};
		} elsif($keyY > 0){
			$gCol{$keyX}{$keyY}{ParserParentX} = $gCol{$keyX}{$keyY-1}{ParserSiblingX};
			$gCol{$keyX}{$keyY}{ParserParentY} = $gCol{$keyX}{$keyY-1}{ParserSiblingY};
			$gRow{$keyY}{$keyX}{ParserParentX} = $gCol{$keyX}{$keyY-1}{ParserSiblingX};
			$gRow{$keyY}{$keyX}{ParserParentY} = $gCol{$keyX}{$keyY-1}{ParserSiblingY};
		}
	}
}
print "bytes [Len:Span:ParserParentX:ParserParentY]\n";
print "Byte";
for($i=0;$i<=$gRowMaxIndex;$i++){
	printf("\[_____%2d____\] ",$i);
}
print "\n";
for($j=0;$j<=$gColMaxIndex;$j++){
	printf(" %2d ",$j);
	for($i=0;$i<=$gRowMaxIndex;$i++){
		if(1){ # for debug
			printf("\[%2d:%2d:%2d:%2d\] ",$gCol{$i}{$j}{Len} , $gCol{$i}{$j}{Span}, $gCol{$i}{$j}{ParserParentX} , $gCol{$i}{$j}{ParserParentY});
		} else {
			if($gCol{$i}{$j}{Len}){
				printf("\[%2d:%2d:%2d:%2d\] ",$gCol{$i}{$j}{Len} , $gCol{$i}{$j}{Span}, $gCol{$i}{$j}{ParserParentX} , $gCol{$i}{$j}{ParserParentY});
			} else {
				print "\[__:__:__:__\] ";
			}
		}
	}
	print "\n";
}
$gPrintHashName{gLongDefine} = "Long Definition";
$gPrintHashName{gLongDefineDebug} = "Long Definition for debugging ";


# gParserCol gathers when value is not ? or NULL.
foreach $keyX (sort {$a<=>$b} keys %gCol){
	foreach $keyY (sort {$a<=>$b} keys %{$gCol{$keyX}}){
			# $gCol{0}{5}{"Span"}="1"
			# $gCol{0}{5}{"ParserSiblingX"}="0"
			# $gCol{0}{5}{"LongDefine"}="__START_BYTES__MSG_ODI__SEQ_NUMBER__ODI_MSG_DYN_DATA__FuClass_ID"
			# $gCol{0}{5}{"Len"}="2"
			# $gCol{0}{5}{"Parent"}="9"
			# $gCol{0}{5}{"Comments"}=""
			# $gCol{0}{5}{"Define"}="FuClass_ID"
			# $gCol{0}{5}{"Description"}="(FuClass_ID)"
			# $gCol{0}{5}{"Value"}="0x03"
		if( ($gCol{$keyX}{$keyY}{Value} ne "") && ($gCol{$keyX}{$keyY}{Value} ne "?") && ($gCol{$keyX}{$keyY}{Span} > 0) ){
			print "Col $keyX:$keyY Span:$gCol{$keyX}{$keyY}{Span} Len:$gCol{$keyX}{$keyY}{Len} Parent:$gCol{$keyX}{$keyY}{Parent} Val:$gCol{$keyX}{$keyY}{Value} LD:$gCol{$keyX}{$keyY}{LongDefine}\n";
			$gParserCol{$keyX}{$keyY}{Span}        = $gCol{$keyX}{$keyY}{Span};
			$gParserCol{$keyX}{$keyY}{ParserSiblingX}     = $gCol{$keyX}{$keyY}{ParserSiblingX};
			$gParserCol{$keyX}{$keyY}{ParserSiblingY}     = $gCol{$keyX}{$keyY}{ParserSiblingY};
			$gParserCol{$keyX}{$keyY}{LongDefine}  = $gCol{$keyX}{$keyY}{LongDefine};
			$gParserCol{$keyX}{$keyY}{Len}         = $gCol{$keyX}{$keyY}{Len};
			$gParserCol{$keyX}{$keyY}{ParserParentX}      = $gCol{$keyX}{$keyY}{ParserParentX};
			$gParserCol{$keyX}{$keyY}{ParserParentY}      = $gCol{$keyX}{$keyY}{ParserParentY};
			$gParserCol{$keyX}{$keyY}{Comments}    = $gCol{$keyX}{$keyY}{Comments};
			$gParserCol{$keyX}{$keyY}{Define}      = $gCol{$keyX}{$keyY}{Define};
			$gParserCol{$keyX}{$keyY}{Description} = $gCol{$keyX}{$keyY}{Description};
			$gParserCol{$keyX}{$keyY}{Value}       = $gCol{$keyX}{$keyY}{Value};
			$gParserRow{$keyY}{$keyX}{Span}        = $gCol{$keyX}{$keyY}{Span};
			$gParserRow{$keyY}{$keyX}{ParserSiblingX}     = $gCol{$keyX}{$keyY}{ParserSiblingX};
			$gParserRow{$keyY}{$keyX}{ParserSiblingY}     = $gCol{$keyX}{$keyY}{ParserSiblingY};
			$gParserRow{$keyY}{$keyX}{LongDefine}  = $gCol{$keyX}{$keyY}{LongDefine};
			$gParserRow{$keyY}{$keyX}{Len}         = $gCol{$keyX}{$keyY}{Len};
			$gParserRow{$keyY}{$keyX}{ParserParentX}      = $gCol{$keyX}{$keyY}{ParserParentX};
			$gParserRow{$keyY}{$keyX}{ParserParentY}      = $gCol{$keyX}{$keyY}{ParserParentY};
			$gParserRow{$keyY}{$keyX}{Comments}    = $gCol{$keyX}{$keyY}{Comments};
			$gParserRow{$keyY}{$keyX}{Define}      = $gCol{$keyX}{$keyY}{Define};
			$gParserRow{$keyY}{$keyX}{Description} = $gCol{$keyX}{$keyY}{Description};
			$gParserRow{$keyY}{$keyX}{Value}       = $gCol{$keyX}{$keyY}{Value};
		}
	}
}
foreach $keyY (sort {$a<=>$b} keys %gRow){
	foreach $keyX (sort {$a<=>$b} keys %{$gRow{$keyY}}){
		if( ($gCol{$keyX}{$keyY}{Value} ne "") && ($gCol{$keyX}{$keyY}{Value} ne "?") && ($gCol{$keyX}{$keyY}{Span} > 0) ){
			print "Row $keyY:$keyX Span:$gCol{$keyX}{$keyY}{Span} Len:$gCol{$keyX}{$keyY}{Len} ParserParentX:$gCol{$keyX}{$keyY}{ParserParentX} Val:$gCol{$keyX}{$keyY}{Value} LD:$gCol{$keyX}{$keyY}{LongDefine}\n";
		}
	}
}
$gPrintHashName{gParserCol} = "Parser-relation between child and parent : only we will express the parent in child node";
$gPrintHashName{gParserRow} = "Parser-relation between child and parent : only we will express the parent in child node";

print "bytes [Len:Span:ParserParentX:ParserParentY]\n";
print "Byte";
for($i=0;$i<=$gRowMaxIndex;$i++){
	printf("\[_____%2d____\] ",$i);
}
print "\n";
for($j=0;$j<=$gColMaxIndex;$j++){
	printf(" %2d ",$j);
	for($i=0;$i<=$gRowMaxIndex;$i++){
		if(0){ # for debug
			printf("\[%2d:%2d:%2d:%2d\] ",$gCol{$i}{$j}{Len} , $gCol{$i}{$j}{Span}, $gCol{$i}{$j}{ParserParentX} , $gCol{$i}{$j}{ParserParentY});
		} else {
			if( ($gCol{$i}{$j}{Span} > 0) && ($gCol{$i}{$j}{Value} ne "") && ($gCol{$i}{$j}{Value} ne "?") ){
				printf("\[%2d:%2d:%2d:%2d\] ",$gCol{$i}{$j}{Len} , $gCol{$i}{$j}{Span}, $gCol{$i}{$j}{ParserParentX} , $gCol{$i}{$j}{ParserParentY});
			} else {
				print "\[__:__:__:__\] ";
			}
		}
	}
	print "\n";
	printf(" %2d ",$j);
	for($i=0;$i<=$gRowMaxIndex;$i++){
		if(0){ # for debug
			printf("\[%2d:%2d:%2d:%2d\] ",$gCol{$i}{$j}{Len} , $gCol{$i}{$j}{Span}, $gCol{$i}{$j}{ParserParentX} , $gCol{$i}{$j}{ParserParentY});
		} else {
			if( ($gCol{$i}{$j}{Span} > 0) && ($gCol{$i}{$j}{Value} ne "") && ($gCol{$i}{$j}{Value} ne "?") ){
				printf("%10s    ",$gCol{$i}{$j}{Value});
			} else {
				print "              ";
			}
		}
	}
	print "\n";
}

open(GVW,">"."default.GVm") or die "GVW:ERROR$!\n";
foreach my $key (sort keys %gPrintHashName){
	traverse_hash_tree_to_change_special_code(\%$key,$key,"",GVW);
}
close(GVW) or die "Error in closing the file ", __FILE__, " $!\n";;

