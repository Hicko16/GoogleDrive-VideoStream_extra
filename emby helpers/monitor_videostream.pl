#!/usr/bin/perl

###
##
## The purpose of this script is to monitor emby, looking for the following:
##
## - WebSocketException (force restart)
## - high memory usage (force restart)
## - login check (force restarts)
##
###

use Getopt::Std;		# and the getopt module
use File::Copy;

use File::Basename;
use lib dirname (__FILE__) ;
require 'crawler.pm';

#require '../crawler.pm';


my %opt;
die (USAGE) unless (getopts ('i:w:p:d:',\%opt));

my $port  = $opt{'p'};
my $directory  = $opt{'d'};
my $url = 'http://localhost:'.$port;
my $webhook = $opt{'w'};

TOOLS_CRAWLER::ignoreCookies();
my @results = TOOLS_CRAWLER::simpleGET($url);

if ($results[0] != 1){
	sleep 30;
	@results = TOOLS_CRAWLER::simpleGET($url);
	if ($results[0] != 1){
		`cd "$directory";sh vs-noscheduler.sh restart`;
		if ($webhook ne ''){
        	`curl -X POST --data '{ "embeds": [{"title": "VideoStream Issue", "description": "Instance restarted - missing process", "type": "link" }] }' -H "Content-Type: application/json" $webhook`;
		}

	}

}





