#!/usr/bin/perl

###
##
## The purpose of this script is to generate the m3u file given a spreadsheet as input
## The script takes a provided spreadsheet file (-s) and outputs a copy of the claned-up m3u file
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 2;

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . ' -s  source.tab -t target.m3u8';


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
my $type = '';
while (my $line = <INPUT>){

	 $line =~ s%\r%%;
	if ($line =~ m%^\#EXTINF\:\-1%){
		($country,$channel) = $line =~ m%^\#EXTINF\:\-1\,([^\:]+)\: ([^\n]+)%;
		$channel =~ s%\{[^\}]+\}%%;
		$channel =~ s%\([^\)]+\)%%;

		if ($channel =~ m%news%i or $channel =~ m%%i){
			$type = 'news';
		}elsif($channel =~ m%sport%i or $channel =~ m%espn%i or $channel =~ m%nfl%i){
			$type = 'sports';
		}elsif($channel =~ m%stars%i or $channel =~ m%showtime%i){
			$type = 'movies';
		}else{
			$type = '';
		}

		print "$country $channel $type\n";
	}


}
close(OUTPUT);
close(INPUT);




1;


