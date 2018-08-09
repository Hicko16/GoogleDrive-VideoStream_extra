#!/usr/bin/perl

###
##
## The purpose of this script is to load an IPTV file into a spreadsheet for cleanup
## The script takes a provided M3U file (-s) and outputs a copy of the claned-up tab file (-t).
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 2;

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . ' -s source.m3u8 -t spreadsheet.tab';



use LWP::UserAgent;
use LWP;
use IO::Handle;

my %opt;
die (USAGE) unless (getopts ('s:t:',\%opt));

# directory to scan
my $source = $opt{'s'};
my $target = $opt{'t'};



open (INPUT, $source) or die ("cannot open $source: " + $!);
open (OUTPUT, '> '.$target) or die ("cannot create $target: " + $!);
OUTPUT->autoflush;
my $line = <INPUT>;

my $channel = '';
my $country = '';

while (my $line = <INPUT>){

	if ($line =~ m%^\#EXTINF\:\-1%){
		($country,$channel) = $line =~ m%^\#EXTINF\:\-1\,([^\:]+)\: ([^\n]+)%;
		$channel =~ s%\{[^\}]+\}%%;
		$channel =~ s%\([^\)]+\)%%;

		print "$country $channel\n";
	}


}
close(OUTPUT);
close(INPUT);




1;


