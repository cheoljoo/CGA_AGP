#!/bin/perl

our %gCan;      # %gCan{index}{Description}{Value}{Define}{Continue}
our %gRow;      # horizontal meaing : %gRow{index}{value}{define} = history
our $gRowCnt = 0;
our $gRowMaxIndex = 0;
our %gCol;      # structure
our $gColCnt = 0;
our %gColStruct;
our $gColMaxIndex = 0;

our %gTmp;
our $gIndexOfStart;

sub analyse_contig_tree_recursively {
	my $TAXA_TREE   = shift @_;
	#print $TAXA_TREE;
	foreach (keys %{$TAXA_TREE}) {
		print "$_ \n";
		if (ref $TAXA_TREE->{$_} eq 'HASH') {
			analyse_contig_tree_recursively($TAXA_TREE->{$_});
		}
	}
}

$filename = shift (@ARGV);
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
		$gCan{$lBytes}{$lDescription}{lValue}{$lDefine}{$lContinue} = $lOthers;
	# upper regular expression express the following three regex.   we can combine the syntax with | in regex.
	# elsif($s =~ /:\s*(\([^\)]*\)|\s*)/)        # $` $&  $'
	# elsif($s =~ /^\s*Index\s+([\d-?]+)\s*:\s*\s*Value\s*:\s*(\S+)\s*,\s*Define\s*:\s*(\S+)\s*(\\?)\s*/){        # $` $&  $'
	# elsif($s =~ /^\s*Index\s+([\d-?]+)\s*:\s*\(([^\)]*)\)\s*Value\s*:\s*(\S+)\s*,\s*Define\s*:\s*(\S+)\s*(\\?)\s*/){        # $` $&  $'
	} else {
		print "ERR: $s\n";
	}
}
close(FH);

print "\n======= Origin  ==========\n";
print $total_context_org;
foreach my $key (keys %gCan) {
	#LOG1 #print $keys;
}
#LOG2 analyse_contig_tree_recursively(\%gCan);
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
print $total_context_org;

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

		if($gIndexOfStart < $gIndexOld){
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
				if($key >= $gIndexOfStart){
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

		{
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
				if($key >= $gIndexOfStart){
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

## Print gCol
foreach $key (sort {$a<=>$b} keys %gColStruct){
	print "gColStruct\{$key\}{Name} = $gColStruct{$key}{Name}\n";
}

# Make the Structure from gCol
foreach $key (sort {$a<=>$b} keys %gCol){
	if($gRowMaxIndex < $key){ $gRowMaxIndex = $key; }
	$tmpStructMembers = "";
	print "gColStruct\{$key\}{Name} = $gColStruct{$key}{Name}\n";
	$tmpStructMembers .= "struct  $gColStruct{$key}{Name} {\n";
	foreach $key2 (sort {$a<=>$b} keys %{$gCol{$key}}){
		print "gCol\{$key\}\{$key2\} Len:$gCol{$key}{$key2}{Len} Span:$gCol{$key}{$key2}{Span} V:$gCol{$key}{$key2}{Value} D:$gCol{$key}{$key2}{Define}\n";
		if($gCol{$key}{$key2}{Len} == ""){ next; }
		if($gCol{$key}{$key2}{Len} == 1){
			$tmpStructMembers .= "\tchar $gCol{$key}{$key2}{Define};";
		} elsif($gCol{$key}{$key2}{Len} == 2){
			$tmpStructMembers .= "\tshort $gCol{$key}{$key2}{Define};";
		} elsif($gCol{$key}{$key2}{Len} == 4){
			$tmpStructMembers .= "\tint $gCol{$key}{$key2}{Define};";
		} elsif($gCol{$key}{$key2}{Len} > 4){
			$tmpStructMembers .= "\tchar *$gCol{$key}{$key2}{Define};";
		} else {
			$tmpStructMembers .= "\tERROR : $gCol{$key}{$key2}{Define};";
		}
		$tmpStructMembers .= "\t\t/* Len:$gCol{$key}{$key2}{Len} Span:$gCol{$key}{$key2}{Span} V:$gCol{$key}{$key2}{Value} D:$gCol{$key}{$key2}{Define} Desc:$Col{$key}{$key2}{Description} C:$gCol{$key}{$key2}{Comments} */\n";
		if($gColMaxIndex < $key2){ $gColMaxIndex = $key2; }
	}
	$tmpStructMembers .= "};\n";
	$gColStruct{$key}{Struct} = $tmpStructMembers;
	print "$gColStruct{$key}{Struct}";
}

$a = <<'END_MESSAGE';
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<title>테이블</title>
</head>
<body>
 <h1>데이터 테이블 캡션</h1>
  <table border="1">
END_MESSAGE

$b = <<'END_MESSAGE';
  </table>
  </body>
  </html>
END_MESSAGE

exit;




# belowin code will be removed
# This is reference code.
our %gStr;          # $gStr{string} = index
our %gStrCount;     # $gStrCount{index} = count
our @gNum;          # $gNum{index} = string
our %gLengthCount;  # $gLengthCount{length of string} = count
our %gLengthText;   # $gLengthCount{length of string} = concatenation of strings
our $gMaxCount = 1;
our $total_context_org; # to check whether original file is changed or not between org and chg.
our $total_context_chg;

my $num;
foreach $filename (@ARGV){
	print "$filename\n";
	open(FH, "<",$filename) or die "Can't open < $filename: $!";
	$total_context_org = "";
	$total_context_chg = "";
	while(<FH>){

		$s = $_;
		$s_org = $s;
		$total_context_org .= $s;

		# DLT_STRING(...)   or DLT_CSTRING(...) 
		# These types will use in DLT_LOG functions as arguments.
		if(($s =~ /DLT_STRING/)  or  ($s =~ / DLT_CSTRING/)){   
			while(1){   # several DLT_STING will be located in one sentense. 
				# This is for DLT_STRING
				if($s =~ /DLT_STRING\s*\(\s*\"([^"]*)\"\s*\)/){
					#print "S $1 --> $s";
					$strLen = length($1);
					$temp = "$gMaxCount";
					$keyLen = length($temp) + 2 ;       # 2 is !~
					if($strLen > $keyLen){
						if($gStr{$1} != 0){
							$num = $gStr{$1};
							$gStrCount{$num} ++;
						} else {
							$gStr{$1} = $gMaxCount;
							$gNum[$gMaxCount] = $1;
							$num = $gMaxCount;
							$gStrCount{$num} = 1;
							$gLengthCount{length($1)} ++;
							$gLengthText{length($1)} .= "#\t\t$1\n";
							$gMaxCount ++;
						}
						# to distinguish between processed DLT_STRING and unproessed it.
						$s =~ s/DLT_STRING\s*\(\s*\"([^"]*)\"\s*\)/DLT_SSSTRING\(\"!~$num\"\)/;
					} else {
						$s =~ s/(DLT_STRING)(\s*\(\s*\"[^"]*\"\s*\))/DLT_SSSTRING$2/;
					}
				} elsif($s =~ /DLT_CSTRING\s*\(\s*\"([^"]*)\"\s*\)/){    # copy from DLT_sRING
					#print "C $1 --> $s";
					$strLen = length($1);
					$temp = "$gMaxCount";
					$keyLen = length($temp) + 2 ;       # 2 is !~
					if($strLen > $keyLen){
						if($gStr{$1} != 0){
							$num = $gStr{$1};
							$gStrCount{$num} ++;
						} else {
							$gStr{$1} = $gMaxCount;
							$gNum[$gMaxCount] = $1;
							$num = $gMaxCount;
							$gStrCount{$num} = 1;
							$gLengthCount{length($1)} ++;
							$gLengthText{length($1)} .= "#\t\t$1\n";
							$gMaxCount ++;
						}
						$s =~ s/DLT_CSTRING\s*\(\s*\"([^"]*)\"\s*\)/DLT_SSCSTRING\(\"!~$num\"\)/;
					} else {
						$s =~ s/(DLT_CSTRING)(\s*\(\s*\"[^"]*\"\s*\))/DLT_SSCSTRING$2/;
					}
				} else {
					last;
				}
			}
		} elsif($s =~ /(^.*DLT_LOG_STRING[^\"]+)\"([^\"]*)\"([^\"]+)/){ # DLT_LOG_STRING....() is the same level of DLT_LOG(...)
			# DLT_LOG_STRING
			# DLT_LOG_STRING_INT
			# DLT_LOG_STRING_UINT
			#print "D $2 --> $s";
			$strLen = length($2);
			$temp = "$gMaxCount";
			$keyLen = length($temp) + 2 ;       # 2 is !~
			if($strLen > $keyLen){
				if($gStr{$2} != 0){
					$num = $gStr{$2};
					$gStrCount{$num} ++;
				} else {
					$gStr{$2} = $gMaxCount;
					$gNum[$gMaxCount] = $2;
					$num = $gMaxCount;
					$gStrCount{$num} = 1;
					$gLengthCount{length($2)} ++;
					$gLengthText{length($2)} .= "#\t\t$2\n";
					$gMaxCount ++;
				}
				$s = "$1\"!~$num\"$3";
			} else {
			}
		}
		$s =~ s/DLT_SSCSTRING/DLT_CSTRING/g;
		$s =~ s/DLT_SSSTRING/DLT_STRING/g;
		if($s eq $s_org){
			#print "$s";
			$total_context_chg .= $s;
		} else {
			chop($s);
			#print "$s \t\t\/\/\/\/*$s_org";
			$total_context_chg .= "$s \t\t\/\/\/\/*$s_org";
		}
	}
	close(FH);
	if($total_context_org ne $total_context_chg){
		open(FO,">","./chg/$filename\.chg");
		print FO $total_context_chg;
		close(FO);
	}
}

open(FO,">","./chg/string_list.chg");
my $goodSize = 0;
my $badSize = 0;
my $tAdv = 0;       # Total Advantage Size
my $tSize = 0;       # Total Size
my $tLine = 0;       # Total Line of DLT LOG line
						# except DLT_STRING(temp)
						# except DLT_STRING("11") // short msg
print FO "# Sorted String and Index Table.\n";
foreach my $key (sort {$gStrCount{$b} <=> $gStrCount{$a}} keys %gStrCount){
	$strLen = length($gNum[$key]);
	$temp = "$key";
	$keyLen = length($temp) + 2 ;       # 2 is !~
	$tSize += ( $strLen * $gStrCount{$key} );
	$tLine += $gStrCount{$key};
	#print "$key : len $keyLen\n";
	if($strLen > $keyLen){
		$goodSize += ( ($strLen - $keyLen) * $gStrCount{$key} );
		print FO "A";
	} elsif($strLen < $keyLen){
		$badSize += ( ($keyLen - $strLen) * $gStrCount{$key} );
		print FO "D";
	} else {
		print FO "=";
	}
	print FO "!~ (index) $key : (used count) $gStrCount{$key} -> (len) $strLen  : (origin string) \[$gNum[$key]\]\n";
}
print FO "Advantages in Matched LOG: $goodSize Bytes\n";
print FO "Disadvantages in Matched LOG: $badSize Bytes\n";
my $tAdv = $goodSize - $badSize;
print FO "Total Size in Matched LOG: $tSize Bytes\n";
print FO "Total Advantages in Matched LOG: $tAdv Bytes\n";
my $tAdvPercentage = 100 * ($tAdv / $tSize);
print FO "Total Advantages % in Matched LOG: $tAdvPercentage% Saved\n";
$temp = 100 * (($tAdv) / ($tSize + 8 * $tLine));
print FO "Total Advantages % considerd app,ctx size(8) in Matched LOG: $temp% Saved\n";
print FO "\n\n\n";

print FO "# Index Table\n";
for (my $i = 1 ; $i < $gMaxCount;$i++){
	print FO "!~$i : $gStrCount{$i} -> \[$gNum[$i]\]\n";
}
print FO "\n\n\n";

foreach my $key (sort {$gLengthCount{$b} <=> $gLengthCount{$a}} keys %gLengthCount){
	print FO "Length : $key  => Count : $gLengthCount{$key}\n$gLengthText{$key}";
}
close(FO);

open(FO,">","./chg/dltString.c");
print FO "
#include \"dltString.h\"

";

print FO "char *dltString\[ DLT_STRING_MAX_COUNT \] = {\n";
print FO "\t\"\!\~\"\n";
for (my $i = 1 ; $i < $gMaxCount;$i++){
	$strLen = length($gNum[$i]);
	print FO "\t, \"$gNum[$i]\"   \t// $i\n";
}
print FO "};\n\n";
print FO "
char *getDltStringIndex(int i){
	if( (i >= DLT_STRING_MAX_COUNT) || (i <= 0) ){
		return NULL;
	}
	return dltString[i];
}

char *getDltString(char *s){
	if(strlen(s) > DELIMITER_SIZE){
		if(strncmp(DELIMITER,s,DELIMITER_SIZE) == 0){
			return getDltStringIndex(atoi(s + DELIMITER_SIZE));
		} else {
			return s;
		}
	} else {
		return s;
	}
}

#ifdef TEST
int main(void){
	int i=0;
	for(i=0; i< DLT_STRING_MAX_COUNT ; i++){
		printf(\"\%d : \%s\\n\",i,getDltStringIndex(i));
	}
	printf(\"!~~ : %s\\n\",getDltString(\"!~~\"));
	printf(\"22 : %s\\n\",getDltString(\"22\"));
	printf(\"223 : %s\\n\",getDltString(\"223\"));
	printf(\"STRING : %s\\n\",getDltString(\"STRING\"));
	printf(\"!~ : %s\\n\",getDltString(\"!~\"));
	printf(\"!~1 : %s\\n\",getDltString(\"!~1\"));
	printf(\"!~22 : %s\\n\",getDltString(\"!~22\"));
	printf(\"!~22MM : %s\\n\",getDltString(\"!~22MM\"));
	printf(\"!~M22 : %s\\n\",getDltString(\"!~M22\"));
	printf(\"!~1000 : %s\\n\",getDltString(\"!~1000\"));
	return 0;
}
#endif // TEST
";
close(FO);

open(FO,">","./chg/dltString.h");
print FO "
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define DELIMITER \"!~\"
#define DELIMITER_SIZE			2
#define DLT_STRING_MAX_COUNT	$gMaxCount

extern char *dltString\[ DLT_STRING_MAX_COUNT \];
extern char *getDltStringIndex(int i);
extern char *getDltString(char *s);

";
close(FO);
