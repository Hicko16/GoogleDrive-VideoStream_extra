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

use constant USAGE => $0 . "-i IP -p 8096 -a api_key -u username -z password\n";


my %opt;
die (USAGE) unless (getopts ('i:p:a:u:z:',\%opt));

my $IP =  $opt{'i'};
$IP = '127.0.0.1' if $IP eq '';
my $port =  $opt{'p'};
my $apiKey = $opt{'a'};
my $username = $opt{'u'};
my $password = $opt{'z'};




die(USAGE) if ($port eq '' or $apiKey eq '');


my @array;
TOOLS_CRAWLER::ignoreCookies();
my @results = TOOLS_CRAWLER::complexGET('http://'.$IP.':'.$port.'/emby/Users?api_key='.$apiKey,'',[''],[''],(['"ConnectUserName":"','"','"']));
print "ID = ".$results[3];





