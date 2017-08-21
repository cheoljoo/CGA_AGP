#!/bin/perl
use lib '.';
use LIB;

our %checkValue;

	foreach $k (keys %checkValue){
		print $k . "\n";
	}

mkdir "OUTPUT";
mkdir "OUTPUT/stc";
# set the variables from file
print "arguments count : $#ARGV\n";
($filename,$stcfilename) = (@ARGV);
if($stcfilename eq ""){
	$filename = "default.GVm";
	$stcfilename = "default.stc";
}

## init file open
open(DBG,">debug.log");
open(TIME_DBG,">time_debug.log");

print "fname = $filename , stc fname = $stcfilename\n";
open(FH, "<",$filename) or die "Can't open < $filename: $!";
my $lcnt = 0 ;
while(<FH>){
	$s = $s_org = $_;
	chop($s);
	eval $s;
	if(not($s =~ /^\$([^\{]+)/)){ next; }
	$hashName{$1} = "Done";
	#if($1 eq "gCan"){ print "== $s\n"; }
	#recover_hash_value(\%{$vname},$s);
	#LOG1 print $s_org;
	#if($lcnt >50){ last; }
	#$lcnt++;
}
close(FH);

LIB::loadVarFromFile("default.GVm");


foreach my $key (keys %gVariables){
	$$key = $gVariables{$key};
	print "gVariables : " . $key . "\n";
}



#LIB::traverse_hash_tree(\%{$key},$key,"var_debug.log",NEW); or remove var_debug.log
unlink("./var_debug.log");
foreach my $key (keys %hashName){
	print "----[$key]----\n";
	LIB::traverse_hash_tree(\%{$key},$key,"var_debug.log",ADD);
}

LIB::CChange($stcfilename,"stc","","DEBUG_ON");

	foreach $k (keys %checkValue){
		print $k . "\n";
	}

exit;

print \%{gCol} . "\n";
print LIB::getHashRef("gCol") . "\n";
foreach my $key (sort{$a<=>$b} keys %{LIB::getHashRef("gCol")}) { print "$key  ";} print "\n";
print $gCol{9} . "\n";
print \%{"gCol{9}"} . "\n";
print LIB::getHashRef("gCol{9}") . "\n";
$tmp = $gCol{9};
foreach my $key (sort{$a<=>$b} keys %$tmp) { print "A$key  ";} print "\n";
foreach my $key (sort{$a<=>$b} keys %{(LIB::getHashRef("gCol"))->{9}}) { print "B$key  ";} print "\n";
foreach my $key (sort{$a<=>$b} keys %{LIB::getHashRef("gCol{9}")}) { print "C$key  ";} print "\n";
#foreach my $key (sort{$a<=>$b} keys %{LIB::getHashRef("gCan{3-4}")}) { print "C$key  ";} print "\n";
#foreach my $key (sort{$a<=>$b} keys %{LIB::getHashRef("gCan{9}")}) { print "C$key  ";} print "\n";
#foreach my $key (sort{$a<=>$b} keys %{LIB::getHashRef("gCan{1}")}) { print "C$key  ";} print "\n";
#foreach my $key (sort{$a<=>$b} keys %{LIB::getHashRef("gCan{2}")}) { print "C$key  ";} print "\n";
LIB::getHashRef(gCan)->{100}->{10} = 11111;
foreach my $key (sort{$a<=>$b} keys %{LIB::getHashRef("gCan")}) { print "C$key  ";} print "\n";
foreach my $key (sort{$a<=>$b} keys %{LIB::getHashRef("gCan{100}")}) { print "C$key  ";} print "\n";
foreach my $key (sort keys %{MEMCMDLIST}) { print "C$key  ";} print "\n";

my $comment =  <<END_COMMENT;
		foreach my $key (keys %hashName){
			print VAR_DBG "----[$key]----\n";
			traverse_hash_tree(\%{$key},$key,"",VAR_DBG);
		}
END_COMMENT


