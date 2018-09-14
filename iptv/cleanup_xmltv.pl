#!/usr/bin/perl

###
##
## The purpose of this script is to generate the m3u file given a spreadsheet as input
## The script takes a provided spreadsheet file (-s) and outputs a copy of the claned-up m3u file
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 2;

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . ' -m source.m3u -s  source.xmltv -t target.xmltv -c channellist.tab';


use IO::Handle;

my %opt;
die (USAGE) unless (getopts ('m:s:t:c:',\%opt));

# directory to scan
my $sourceXML = $opt{'s'};
my $source = $opt{'m'};
my $targetXML = $opt{'t'};
my $channelList = $opt{'c'};


die(USAGE) if ($source eq '' or $targetXML eq '');



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
open (INPUTXML, $sourceXML) or die ("cannot open $sourceXML: " + $!);
my $XMLTV = <INPUTXML>;
$XMLTV =~ s%\|%%g;
$XMLTV =~ s%</display-name>%</display-name>\n%g;

close(INPUTXML);

open (OUTPUT, '> '.$targetXML) or die ("cannot create $targetXML: " + $!);
OUTPUT->autoflush;
my $line = <INPUT>;
$line =~ s%\r%%;
print OUTPUT $line;
while (my $line = <INPUT>){

	#remove carriage return
	$line =~ s%\r?\n%%;

	if ($line =~ m%^\#EXTINF\:\-1%){

		($country,$channel) = $line =~ m%^\#EXTINF\:\-1\,([\S]+)[^\|]+\| ([^\n]+)$%;
		($rawName) = $line =~ m%^\#EXTINF\:\-1\,([^\n]+)$%;
		$rawName =~ s%\|%%g;

		$channel =~ s%\{[^\}]+\}%%;
		$channel =~ s%\([^\)]+\)%%;
		$channel =~ s%\[[^\)]+\]%%;
		$channel =~ s% \- %%;
		$channel =~ s%ʜᴅ%%;
		$channel =~ s%\s+$%%;
		$country =~ s%\d+$%%;
		#$rawName =~
		$channel =~ s%\&$%\&amp;%;
		$channel =~ s%\n%%;


		#print "$country ${channel}x $rawName\n";
		if (defined($channelMapping{$country . ' - ' . $channel}[0])){
			my $entry = $channelMapping{$country . ' - ' . $channel}[1];
			#print "match $entry = $rawName\n";
			$XMLTV =~ s%<display-name>$rawName</display-name>%<display-name>$entry</display-name>%;
		}


	}


}
print OUTPUT $XMLTV;

close(OUTPUT);
close(INPUT);




1;


