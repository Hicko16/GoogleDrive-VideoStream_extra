#!/usr/bin/perl



use constant LOGFILE => '/tmp/recordings.log';

# get total arg passed to this script
my $total = $#ARGV + 1;
my $counter = 1;


# get script name
my $scriptname = $0;

open (LOG, '>>' . LOGFILE) or die $!;

print LOG "Total args passed to $scriptname : $total\n";

# Use loop to print all args stored in an array called @ARGV
foreach my $a(@ARGV) {
	print "Arg # $counter : $a\n";
	print LOG "Arg # $counter : $a\n";
	$counter++;
}