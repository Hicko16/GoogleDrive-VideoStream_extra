#!/usr/bin/perl

###
##
## The purpose of this script is to shutdown emby cleanly, and back up the library file.
##
##
###

use Getopt::Std;		# and the getopt module
use File::Copy;

use File::Basename;
use lib dirname (__FILE__) ;
require '../crawler.pm';

use constant USAGE => $0 . "-p 8096 -a api_key -i id";



my %opt;
die (USAGE) unless (getopts ('p:a:i:',\%opt));

my $id  = $opt{'i'};
my $port =  $opt{'p'};
my $apiKey = $opt{'a'};

die(USAGE) if ($port eq '' or $id eq '');


my $url = 'http://127.0.0.1:'.$port.'/emby/ScheduledTasks/Running/'.$id.'?api_key='.$apiKey;

TOOLS_CRAWLER::ignoreCookies();
my @results = TOOLS_CRAWLER::simplePOST($url);




