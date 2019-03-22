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

use constant USAGE => $0 . "-i IP -p 8096 -a api_key\n";


my %opt;
die (USAGE) unless (getopts ('i:p:a:',\%opt));

my $IP =  $opt{'i'};
$IP = '127.0.0.1' if $IP eq '';
my $port =  $opt{'p'};
my $apiKey = $opt{'a'};



die(USAGE) if ($port eq '' or $apiKey eq '');


my $url = 'http://'.$IP.':'.$port.'/emby/LiveTv/Channels?Fields=ProviderIds&api_key='.$apiKey;
my @array;
TOOLS_CRAWLER::ignoreCookies();
my @results = TOOLS_CRAWLER::complexGET($url,'',[''],[''],['"Id":"', '"', '","Number":"\d+","ChannelNumber":"\d+","ProviderIds":{"ExternalServiceId":"TVHclient LiveTvService"}']);

for (my $i=3; $i <$#results; $i=$i+2){
	print "results=". $results[$i];
	my $url = 'http://'.$IP.':'.$port.'/emby/Items/'.$results[$i].'?api_key='.$apiKey;
	TOOLS_CRAWLER::ignoreCookies();
	my @results = TOOLS_CRAWLER::complexJSONPOST($url,'',[''],[''],(['<ddd','<','<']),'{"Genres":["premium"],"ProviderIds":{"ExternalServiceId":"TVHclient LiveTvService"},"Tags":["premium"]}');


}






