#!/usr/bin/perl

###
##
## The purpose of this script is to restore a backup plex file set.
###

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . " -s directory_source_of_backup -t target_directory -d datestamp_YYYMMDD\n";


my %opt;
die (USAGE) unless (getopts ('s:t:d:',\%opt));

# directory to scan
my $datestamp = $opt{'d'};
my $backupDirectory = $opt{'s'};
my $outputDirectory = $opt{'t'};


if ($outputDirectory eq ''){
	die (USAGE);
}


my @files = glob "'$backupDirectory/*$datestamp*.tgz'";

for (my $i=0; $i <= $#files; $i++){
	print STDERR "extract " . $files[$i] . "\n";
	`cd '$outputDirectory'; tar -zxf '$files[$i]'`;

}


