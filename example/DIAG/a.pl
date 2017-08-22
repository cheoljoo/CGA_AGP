#!/bin/perl
use lib '.';
use LIB;

our %DIAG;

$inputFileName = "default.def";

$_DESC_{DIAG}{0}{Name}="Value";
$_DESC_{DIAG}{0}{Description}="Value for Parsing (digit or hex)";
$_DESC_{DIAG}{0}{isDIGIT}=1;
$_DESC_{DIAG}{1}{Name}="Function";
$_DESC_{DIAG}{1}{Description}="Function Name";
$_DESC_{DIAG}{2}{Name}="Cmd";
$_DESC_{DIAG}{2}{Description}="size:arguemnts size / argu:arguments variable / Operations (write,read,add...)";
$_DESC_{checkValue}{0}{Name}="Index";
$_DESC_{checkValue}{0}{Description}="digit and returns function name";
$_DESC_{checkValue}{0}{isDIGIT}=1;
$_DESC_{checkFunc}{0}{Name}="Function";
$_DESC_{checkFunc}{0}{Description}="function name and returns index";

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
			print LIB::__SUB__() . "func $func : value $value : op $op : size $sizetype : argu $argu\n";
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
			if($checkValue{$value} eq ""){ $checkValue{$value} = $func; $checkOrg{$value} = $s; }
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
#DEBUG : foreach my $key (keys %DIAG){ print $key;} print "\n";
LIB::traverse_hash_tree(\%{DIAG},DIAG,"default.GVm",NEW,\%{_DESC_},FUNC,SUBCMD);
LIB::traverse_hash_tree(\%{checkValue},checkValue,"default.GVm",ADD);
LIB::traverse_hash_tree(\%{checkFunc},checkFunc,"default.GVm",ADD);
LIB::traverse_hash_tree(\%{checkOrg},checkOrg,"default.GVm",ADD);
LIB::traverse_hash_tree(\%{_DESC_},_DESC_,"default.GVm",ADD);
# Call function of libary
# when we call with LIB-> ...   , First argument is library name.  This is inserted automatically.
#LIB->traverse_hash_tree(\%{checkOrg},checkOrg,"default.GVm",ADD);

