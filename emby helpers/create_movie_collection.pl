#!/usr/bin/perl

###
##
## The purpose of this script is to create a movie collection by symlinking.
##
## The input is a txt file of the form"movie<tab>year
##
####

use Getopt::Std;		# and the getopt module
use File::Copy;


my %opt;
die (USAGE) unless (getopts ('i:s:d:',\%opt));

# directory for backups
my $inputSpreadsheet  = $opt{'i'};

my $sourceDirectory =  $opt{'s'};
my $targetDirectory =  $opt{'d'};

# some checks
if (!(-e $targetDirectory)){
	die ("target does not exist " . $targetDirectory);
}
if (!(-e $sourceDirectory)){
	die ("source does not exist " . $sourceDirectory);
}

open(INPUT,$inputSpreadsheet) or die ("Cannot open $inputSpreadsheet ".$!);

while(my $line =<INPUT>){
	my ($title, $year) = $line =~ m%([^\t]+)\t([^\t]+)\n%;
	my $source = "$sourceDirectory/$title($year)";
	my $target = "$targetDirectory/$title($year)";
	if (-e $source and !(-e $target)){
		symlink ($sourceDirectory, $target);
		print "create symlink for $target\n";
	}

}

close(INPUT);
