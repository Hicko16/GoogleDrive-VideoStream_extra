#!/usr/bin/perl

###
##
## The purpose of this script is to generate channel numbers
###
# number of times to retry when ffmpeg encounters network errors
use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . ' -s  target.m3u8 -t target.m3u8';


use IO::Handle;

my %opt;
die (USAGE) unless (getopts ('s:t:',\%opt));

# directory to scan
my $source = $opt{'s'};
my $target = $opt{'t'};

die(USAGE) if ($source eq '' or $target eq '');



open (INPUT, $source) or die ("cannot open $source: " + $!);
open (OUTPUT, '> '.$target) or die ("cannot create $target: " + $!);
OUTPUT->autoflush;

while (my $line = <INPUT>){

	 $line =~ s%\r%%;
	if ($line =~ m%^#EXTINF%){
		my $nextLine = <INPUT>;
		my ($channel) = $line =~ m%\/(\d+)\.m3u8%;
		$line =~ s%\-1%\-1 tvg-id="$channel",%;
		print OUTPUT $line;
		print OUTPUT $nextLine;
		print "$line\n";
	}else{
		print OUTPUT $line;
	}


}
close(OUTPUT);
close(INPUT);




1;





