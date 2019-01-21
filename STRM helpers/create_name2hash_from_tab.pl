#!/usr/bin/perl

###
##
## The purpose of this script is to create a file that converts filename to hash
###

use Getopt::Std;		# and the getopt module


my %opt;
die (USAGE) unless (getopts ('m:o:',\%opt));

# list of files
my $mainfile = $opt{'m'};
# output files
my $outputfiles = $opt{'o'};

my %nameHash;

open(INPUT,$mainfile) or die ("Cannot open $mainfile ".$!);

while(my $line =<INPUT>){#
	my ($fileID,$fileName, $movieTitle, $movieYear, $resolution, $hash) = $line =~ m%^[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t[^\t]*%;
	#print ".$fileID";
	if ($fileName ne '' and $hash ne ''){
		$nameHash{$fileName} = $hash;
	}
}#

close(INPUT);


open(OUTPUT,'>' . $outputfiles . '.names') or die ("Cannot open $outputfiles.names ".$!);
foreach my $key (keys %nameHash) {
	print OUTPUT $key . ',' . $nameHash{$key} . "\n";
}
close(OUTPUT);





