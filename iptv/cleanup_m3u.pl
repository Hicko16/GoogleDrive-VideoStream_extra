#!/usr/bin/perl

###
##
## The purpose of this script is to generate the m3u file given a spreadsheet as input
## The script takes a provided spreadsheet file (-s) and outputs a copy of the claned-up m3u file
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 2;

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . ' -s  source.m3u8 -t target.m3u8 -a service_number -c channellist.tab';


use IO::Handle;

my %opt;
die (USAGE) unless (getopts ('s:t:c:a:',\%opt));

# directory to scan
my $source = $opt{'s'};
my $target = $opt{'t'};
my $channelList = $opt{'c'};
my $serviceNumber = $opt{'a'};


die(USAGE) if ($source eq '' or $target eq '');



open (CHANNELS, $channelList) or die ("cannot open $channelList: " + $!);

my %channelMapping;
while (my $line = <CHANNELS>){

	$line =~ s%\r?\n%%;
	if ($line =~ m%^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)%){
		my ($channelNumber,$country,$channelName,$cleanChannelName) = $line =~  m%^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)%;
		$channelMapping{$country . ' - ' . $channelName}[0] = $channelNumber;
		$channelMapping{$country . ' - ' . $channelName}[1] = $cleanChannelName;
		#print $channelMapping{$country . ' - ' . $channelName}[1] ." $country ${channelName}x\n";
	}


}
close(CHANNELS);
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
		$channel =~ s%\{[^\}]+\}%%;
		$channel =~ s%\([^\)]+\)%%;
		$channel =~ s%\[[^\)]+\]%%;
		$channel =~ s% \- %%;
		$channel =~ s%ʜᴅ%%;
		$channel =~ s%\s+$%%;


		if (defined($channelMapping{$country . ' - ' . $channel}[0])){
			print OUTPUT "#EXTINF:-1 tvg-id=\"".$channelMapping{$country . ' - ' . $channel}[0].$serviceNumber."\" tvg-name=\"".$channelMapping{$country . ' - ' . $channel}[1]."\"\n";
			my $line = <INPUT>;
			$line =~ s%\r%%;
			print OUTPUT $line . "\n";
			print "$country ${channel}x\n";
		}else{
			print "$country ${channel}x not defined\n";
		}
	}


}

close(OUTPUT);
close(INPUT);




1;


