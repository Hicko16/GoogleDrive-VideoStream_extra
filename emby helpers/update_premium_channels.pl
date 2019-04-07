#!/usr/bin/perl

###
##
## The purpose of this script is to fetch all TVHclient and mark them with a premium tag
##
##
###

use Getopt::Std;		# and the getopt module
use File::Copy;

use File::Basename;
use lib dirname (__FILE__) ;
require '../crawler.pm';

use constant USAGE => $0 . "-i IP -p 8096 -a api_key -f file\n";


my %opt;
die (USAGE) unless (getopts ('i:p:a:f:',\%opt));

my $IP =  $opt{'i'};
$IP = '127.0.0.1' if $IP eq '';
my $port =  $opt{'p'};
my $apiKey = $opt{'a'};
my $file = $opt{'f'};



die(USAGE) if ($port eq '' or $apiKey eq ''or $file eq '');


my $url = 'http://'.$IP.':'.$port.'/emby/LiveTv/Channels?Fields=ProviderIds&api_key='.$apiKey;
my @array;
TOOLS_CRAWLER::ignoreCookies();
#my @results = TOOLS_CRAWLER::complexGET($url,'',[''],[''],['"Id":"', '"', '","Number":"\d+","ChannelNumber":"\d+","ProviderIds":\{"ExternalServiceId":"Emby"\}']);
#my @results = TOOLS_CRAWLER::returnWEB($url,$file,[''],[''],['\{"Name":"', '"\}', '"\}']);
my $results = TOOLS_CRAWLER::returnGET($url);
#print $results;
$results =~ s%"MediaType":"Video"\}%\n%g;
#print $results;
while (<$results>){
	print $_;
	#my ($entry) = <$results>;
	#last if $entry eq '';
	#$results =~ s%$entry%%;
	#print "\n\nENTRY ".$entry . "\n";

}




for (my $i=3; $i <$#results; $i=$i+2){
	#if ($results[$i] > 290018){
#		print "results=". $results[$i] . "\n";
		my $url = 'http://'.$IP.':'.$port.'/emby/Items/'.$results[$i].'?api_key='.$apiKey;
		#my @results = TOOLS_CRAWLER::complexJSONPOST($url,'',[''],[''],(['<ddd','<','<']),'{"Genres":["premium"],"ProviderIds":{"ExternalServiceId":"Emby"},"Tags":["premium"]}');
		#my @results = TOOLS_CRAWLER::complexJSONPOST($url,'',[''],[''],(['<ddd','<','<']),'{"ProviderIds":{"ExternalServiceId":"Emby"},"Tags":["premium"]}');

#	}


}

		my $url = 'http://'.$IP.':'.$port.'/emby/Items/610879?api_key='.$apiKey;

#my @results = TOOLS_CRAWLER::complexJSONPOST($url,'',[''],[''],(['<ddd','<','<']),'{"Name":"Sony Max UK HD","ServerId":"7f422d149e1444a7b2d034b0e0ae65e0","Id":"610879","Number":"79638","ChannelNumber":"79638","ProviderIds":{"ExternalServiceId":"Emby"},"IsFolder":false,"Type":"TvChannel","ImageTags":{},"BackdropImageTags":[],"Tags":["premium"],"MediaType":"Video"}');







