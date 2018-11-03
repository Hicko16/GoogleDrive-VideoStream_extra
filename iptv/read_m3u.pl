#!/usr/bin/perl

###
##
## The purpose of this script is to remove invalid IPTV channels in a M3U file.
## The script takes a provided M3U file (-s) and outputs a copy of the claned-up M3U file (-t).
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 2;

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . " -s (source.m3u8,source2.m3u8) -t target.m3u8";



my %opt;
die (USAGE) unless (getopts ('s:t:w:vc',\%opt));

# directory to scan
my $target = $opt{'t'};
my @files = split(',', $opt{'s'});
my @blacklist = ('XXX','²⁴/⁷','24/7', '24-7', 'WEBCAMS', 'ₓₓₓ', 'IHEART', 'MC RADIO', 'RADIO');
my $isWebCheck = 1 if defined($opt{'c'});
my $isRemoveVOD = 1 if defined($opt{'v'});

die (USAGE) if ($target eq '');


open (OUTPUT, '> '.$target) or die ("cannot create $target: " + $!);
OUTPUT->autoflush;

foreach my $source(@files) {
	open (INPUT, $source) or die ("cannot open $source: " + $!);
	my $line = <INPUT>;

	while (my $line = <INPUT>){

		#remove carriage return
		$line =~ s%\r%%;


		if ($line =~ m%^\#%){

			my $name;
			my $groupTitle;
			($name) = $line =~ m%tvg-name\=\"([^\"]+)\"%;
			($groupTitle) = $line =~ m%group-title\=\"([^\"]+)\"%;

			if ($name eq ''){
				($groupTitle,$name) = $line =~ m%\,([^\|]+)\|([^\n]+)\n%;
				if ($name eq ''){
					$line = <INPUT>;
					next;
				}

			}

			my $next=0;
	  		foreach my $filter( @blacklist) {
	  			if ($groupTitle =~ m%$filter%){
	  				print "blacklist $filter $line\n";
					$line = <INPUT>;
	  				$next =1;
	  			}
	  		}
			if ($next){
				next;
			}

			$line = <INPUT>;
			$line =~ s%\r%%;
			$line =~ s%\n%%;
			print OUTPUT $groupTitle . "\t" . $name . "\t" . $line . "\n";
		}

	}
	close(INPUT);

}
close(OUTPUT);


1;


