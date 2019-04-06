#!/usr/bin/perl

###
##
## The purpose of this script is to remove invalid IPTV channels in a M3U file.
## The script takes a provided M3U file (-s) and outputs a copy of the claned-up M3U file (-t).
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 2;

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . " -s file.m3u8";



my %opt;
die (USAGE) unless (getopts ('s:',\%opt));

# directory to scan
my $source = $opt{'s'};

die (USAGE) if ($source eq '');



	open (INPUT, $source) or die ("cannot open $source: " + $!);
	my $line = <INPUT>;

	while (my $line = <INPUT>){

		#remove carriage return
		$line =~ s%\r%%;

		my ($logo) = $line =~ m%tvg-logo\=\"([^\"]+)\"%;

		if ($logo ne ''){

			print $logo . "\n";
		}

	}
	close(INPUT);




1;


