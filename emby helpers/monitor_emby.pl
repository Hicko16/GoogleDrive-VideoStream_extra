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
die (USAGE) unless (getopts ('i:w:',\%opt));

my $instance  = $opt{'i'};
my $webhook = $opt{'w'};
my $logFile = '/var/lib/'.$instance.'/logs/embyserver.txt';

$output = `tail -1000 $logFile 2>&1`;


if ($output =~ m%WebSocketException%){
        print "restarting emby";
        `/usr/sbin/service $instance restart`;
        `curl -X POST --data '{ "embeds": [{"title": "Emby Issue", "description": "Instance restarted", "type": "link" }] }' -H "Content-Type: application/json" $webhook`;
}




