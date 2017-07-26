# https://blog.ostermiller.org/find-comment

$a = "

/****
* Common multi-line comment style.
/*
****/
/****
* Another common multi-line comment style.
*/

    ";

print "Before= " . $a;
$a =~ s/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))//g;
print "After= " . $a;

$a = "

/****
* Common multi-line comment style. */
****/
List ;
/****
* Another common multi-line comment style.
*/

    ";

print "Before= " . $a;
$a =~ s/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))//g;
print "After= " . $a;

$a = "
// The comment around this code has been commented out.
// /*
some_code();
// */
";
print "Before= " . $a;
my @pp = $a =~ s/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))//g;
print "After= " . $a;
print @pp . "\n";
foreach my $key (@pp){
	print "$key\n";
}



$a = "
{ /* test 1 */
	if{  // test 2 
		// test 3
	}
	else {
	  anything
	}
	who;
}
";
print "Before= " . $a;
if($a =~ /(\{([^\{\}]|(?R))*\})/){
	print $1 . " TT\n";
	print @_ . " TT\n";
}

$a = "
  /* test 1 */
	if{  // test 2 
		// test 3
	}
	else {
	  anything
	}
	who;
}
";
print "Before= " . $a;
if(my @matches = $a =~ /(\{([^\{\}]|(?R))*\})/sg){
	print $1 . " KK1\n";
	print $2 . " KK2\n";
	print $3 . " KK3\n";
	print @_ . " KK\n";
	foreach (@matches){
		print $_ . "Y\n";
	}
}



$a = "
  /* test 1 */
  {  // test 2 
		// test 3
	}
          {
	  anything
	}
	who;
}
";
print "Before= " . $a;
if(my @matches = $a =~ /([ \t]*)(\{([^\{\}]|(?R))*\})/sg){
	print "[" . $1 . "] KK1\n";
	print "[" . $2 . "] KK2\n";
	print "[" . $3 . "] KK3\n";
	print "[" . $4 . "] KK4\n";
	print "[" . @_ . "] KK\n";
	my $cnt=0;
	foreach (@matches){
		print $_ . "Y$cnt\n";
		$cnt++;
	}
}



