#!/usr/bin/perl

###
##
## The purpose of this script is to create STRM files by using a supplied TAB file.
###

use Getopt::Std;		# and the getopt module


my %opt;
die (USAGE) unless (getopts ('s:d:t:',\%opt));

# directory to scan
my $directory = $opt{'d'};
my $transcodeLabel = $opt{'t'};
my $inputSpreadsheet = $opt{'s'};

# some checks
if (!(-e $directory)){
	die ("target does not exist " . $directory);
}
my $movieDirectory = $directory . '/movies/' ;
if (!(-e $movieDirectory)){
	mkdir $movieDirectory;
}

open(INPUT,$inputSpreadsheet) or die ("Cannot open $inputSpreadsheet ".$!);
my %movieHash;
my %movieCount;
while(my $line =<INPUT>){
	my ($fileID,$fileName, $movieTitle, $movieYear, $resolution, $hash) = $line =~ m%^[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t[^\t]*%;
	if ($resolution > 0 and $movieTitle ne '' and $movieYear ne '' and $movieHash{$hash} != 1){
		if (!(-e $movieDirectory . $movieTitle.'('.$movieYear.')') ){
			mkdir $movieDirectory . $movieTitle.'('.$movieYear.')';
		}
		if ($movieCount{$movieTitle} >= 1){
			print "$movieTitle $resolution version #" . ($movieCount{$movieTitle}+1). "\n";

		}else{
			print "$movieTitle $resolution $hash\n";
		}

		$movieHash{$hash} = 1;
		$movieCount{$movieTitle}++;
	}
}

close(INPUT);

