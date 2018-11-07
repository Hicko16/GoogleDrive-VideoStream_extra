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
#require 'crawler.pm';

require '../crawler.pm';
use constant USAGE => $0 . " -i emby-server -p 8096 -l label [-w webhook] [-t]\n\t -t sends test message\n";


my %opt;
die (USAGE) unless (getopts ('w:p:d:l:t',\%opt));

my $port  = $opt{'p'};
my $directory  = $opt{'d'};
my $url = 'http://localhost:'.$port;
my $webhook = $opt{'w'};
my $isTest=0;
$isTest = 1 if ($opt{'t'});
my $processName = 'python default.py';


die(USAGE) if ($port eq '' or $directory eq '');


TOOLS_CRAWLER::ignoreCookies();
my @results = TOOLS_CRAWLER::simpleGET($url);

if ($results[0] != 1){
	sleep 30;
	@results = TOOLS_CRAWLER::simpleGET($url);
	if ($results[0] != 1){
		#`cd "$directory";sh vs-server.sh restart; sh vs-server.sh start`;

		my $pid = `ps -ef | grep '$processName' | grep -v grep | awk '{print \$2}'`;
		while(my ($line) = $pid =~ m%(\d+)\n%){
        	$pid =~ s%\d+\n%%;
        	`kill -9 $pid`;
		}
		`cd "$directory";nohup $processName &`;
      	`curl -X POST --data '{ "embeds": [{"title": "VideoStream Issue", "description": "$label -- Instance restarted - missing process", "type": "link" }] }' -H "Content-Type: application/json" $webhook` if ($webhook ne '');

	}

}



if ($isTest){

      	`curl -X POST --data '{ "embeds": [{"title": "VideoStream Issue", "description": "$label -- TEST MESSAGE", "type": "link" }] }' -H "Content-Type: application/json" $webhook` if ($webhook ne '');

}


