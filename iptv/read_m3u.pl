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
my @blacklist = ('XXX','²⁴/⁷','24/7', '24-7', 'WEBCAMS', 'ₓₓₓ', 'IHEART', 'MC RADIO', 'RADIO', 'MC', 'MX', 'TV SHOW', 'DJING');
my %matches = ('EPL' => 'Sports', 'AHL' => 'Sports', 'BR' => 'Brazil', 'ESPN' => 'Sports', 'FSR' => 'Sports', 'NFL' => 'Sports', 'VIP' => 'Sports','PPV' => 'Sports','AU' => 'Australian', 'AS' => '', 'PT' => 'Sports', 'SEV' => 'Sports',  'NHL' => 'Sports', 'NBA' => 'Sports', 'NEWS' => 'United States - Regionals', 'ES' => 'Spain', 'IR' => 'Ireland', 'PT' => 'Portugal', 'IN' => 'Indian', 'USA' => 'United States', 'UK' => 'United Kingdom' , 'LOC' => 'United States - Regionals', 'CA' => 'Canada', 'FUBO' => 'United States');
my %filters = ('ʜᴅ' => '', 'HD' => '');
my $isWebCheck = 1 if defined($opt{'c'});
my $isRemoveVOD = 1 if defined($opt{'v'});
my %tvGrid;

die (USAGE) if ($target eq '');



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
	  		foreach my $match(keys %matches) {
	  			if ($groupTitle =~ m%$match%){
	  				$groupTitle = $matches{$match};
	  			}
	  		}
	  		foreach my $match(keys %filters) {
	  			if ($name =~ m%$match%){
	  				$name =~ s%$match%$filters{$match}%;
	  			}
	  		}
	  		$groupTitle = "\L$groupTitle\E";
  			$name = "\L$name\E";
  			$name =~  s/^\s+|\s+$//g;

			$line = <INPUT>;
			$line =~ s%\r%%;
			$line =~ s%\n%%;
			#print OUTPUT $groupTitle . "\t" . $name . "\t" . $line . "\n";
			$tvGrid{$groupTitle}{$name}[$#{$tvGrid{$groupTitle}{$name}}+1] = $line;
		}

	}
	close(INPUT);

}

open (OUTPUT, '> '.$target) or die ("cannot create $target: " + $!);
OUTPUT->autoflush;

  		foreach my $group (sort keys  %tvGrid) {
	  		foreach my $name (sort keys %{$tvGrid{$group}}) {
	  			my $URL = '';
	  			for (my $i=0; $i <= $#{$tvGrid{$group}{$name}}; $i++){
	  				$URL .= $tvGrid{$group}{$name}[$i] . "\t";
	  			}
				print OUTPUT $group . "\t" . $name . "\t" . $URL . "\n";

	  		}
  		}
close(OUTPUT);


1;


