# https://blog.ostermiller.org/find-comment

$a = "

/****
* Common multi-line comment style.
****/
/****
* Another common multi-line comment style.
*/

    ";

print "Before= " . $a;
$a =~ s/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))//;
print "After= " . $a;

$a = "
// The comment around this code has been commented out.
// /*
some_code();
// */
";
print "Before= " . $a;
$a =~ s/((?:\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/)|(?:\/\/.*))//;
print "After= " . $a;
