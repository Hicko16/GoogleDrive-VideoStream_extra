#!/usr/bin/perl

###
##
## The purpose of this script is to generate the m3u file given a spreadsheet as input
## The script takes a provided spreadsheet file (-s) and outputs a copy of the claned-up m3u file
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 2;

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . ' -s  source.m3u8 -t target.m3u8 -a service_number (-c channellist.tab | -n number) -l\n -l limits to 1 channel occurrence';


use IO::Handle;

my %opt;
die (USAGE) unless (getopts ('s:t:c:a:n:l',\%opt));

# directory to scan
my $source = $opt{'s'};
my $target = $opt{'t'};
my $channelList = $opt{'c'};
my $serviceNumber = $opt{'a'};
my $number = $opt{'n'};
my $limit = 1 if defined ($opt{'l'});



my @channelcache;

die(USAGE) if ($source eq '' or $target eq '');

my %channelMapping;

if ($channelList ne ''){
	open (CHANNELS, $channelList) or die ("cannot open $channelList: " + $!);

	while (my $line = <CHANNELS>){

		$line =~ s%\r?\n%%;
		if ($line =~ m%^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)%){
			my ($channelNumber,$country,$channelName,$cleanChannelName) = $line =~  m%^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)%;
			$channelMapping{$country . ' - ' . $channelName}[0] = $channelNumber;
			$channelMapping{$country . ' - ' . $channelName}[1] = $cleanChannelName;
			print "|$channelNumber|" . $channelMapping{$country . ' - ' . $channelName}[1] ."|$country|${channelName}|\n";
		}



	}
	close(CHANNELS);
}
open (INPUT, $source) or die ("cannot open $source: " + $!);
open (OUTPUT, '> '.$target) or die ("cannot create $target: " + $!);
OUTPUT->autoflush;
my $line = <INPUT>;
$line =~ s%\r%%;
print OUTPUT $line;
while (my $line = <INPUT>){

	#remove carriage return
	$line =~ s%\r?\n%%;

	if ($line =~ m%^\#EXTINF\:\-1%){

		($country,$channel) = $line =~ m%^\#EXTINF\:\-1\,([\S]+)[^\|]+\| ([^\n]+)$%;
		if ($country eq ''){
			($country,$channel) = $line =~ m%^\#EXTINF\:\-1\,([^\:]+)\: ([^\n]+)$%;

			if ($country eq 'US'){
				$country = 'USA';
			}
		}
		$channel =~ s%\{[^\}]+\}%%;
		$channel =~ s%\([^\)]+\)%%;
		$channel =~ s%\[[^\)]+\]%%;
		$channel =~ s% \- %%;
		$channel =~ s% \| \S\S\S?\*?%%;
		$channel =~ s%ʜᴅ%%;
		$channel =~ s%\s+$%%;
		$country =~ s%\d+$%%;



		if (defined($channelMapping{$country . ' - ' . $channel}[0])){
			my $channelNumber = int($channelMapping{$country . ' - ' . $channel}[0].$serviceNumber);
			print $channelNumber . " x\n";
			if ($channelcache[$channelNumber] != 0 and $limit){
				print "|$country|${channel}|".$channelMapping{$country . ' - ' . $channel}[0]."| duplicate\n";
			}else{
				while ($channelcache[$channelNumber] != 0){
					$channelNumber++;
				}
				$channelcache[$channelNumber]++;
				print OUTPUT "#EXTINF:-1 tvg-id=\"".$channelNumber."\" tvg-name=\"".$channelMapping{$country . ' - ' . $channel}[1]."\"\n";
				my $line = <INPUT>;
				$line =~ s%\r%%;
				print OUTPUT $line . "\n";
				print "$channelNumber $country ${channel}x\n";
			}

		}elsif ($number ne ''){
			($channel) = $line =~ m%^\#EXTINF\:\-1\,([^\n]+)$%;
			print OUTPUT "#EXTINF:-1 tvg-id=\"".$number.$serviceNumber."\" tvg-name=\"".$channel."\"\n";
			my $line = <INPUT>;
			$line =~ s%\r%%;
			print OUTPUT $line . "\n";
			print "$number $country ${channel}x\n";
			$number++;
		}else{
			print "|$country|${channel}|".$channelMapping{$country . ' - ' . $channel}[0]."| not defined\n";
		}
	}


}

close(OUTPUT);
close(INPUT);




1;


