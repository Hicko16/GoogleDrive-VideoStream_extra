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
my @results = TOOLS_CRAWLER::complexJSONPOST('http://'.$IP.':'.$port.'/emby/Users/New?api_key='.$apiKey,'',[''],[''],(['"Id":"','"','"']),'{"Name":"'. $username . '"}');
print "ID = ".$results[3];
my $userID = $results[3];
my @results = TOOLS_CRAWLER::complexJSONPOST('http://'.$IP.':'.$port.'/emby/Users/'.$userID.'/Policy?api_key='.$apiKey,'',[''],[''],(['"Id":"','"','"']),'{"IsAdministrator":false,"IsHidden":true,"IsDisabled":false,"EnableLiveTvManagement":false,"EnableLiveTvAccess":true,"EnableMediaPlayback":true,"EnableAudioPlaybackTranscoding":true,"EnableVideoPlaybackTranscoding":true,"EnablePlaybackRemuxing":true,"EnableContentDeletion":false,"EnableContentDownloading":false,"EnableSyncTranscoding":false,"BlockedTags":["premium"],"EnableMediaConversion":false,"RemoteClientBitrateLimit":0}');
my @results = TOOLS_CRAWLER::complexJSONPOST('http://'.$IP.':'.$port.'/emby/Users/'.$userID.'/Password?api_key='.$apiKey,'',[''],[''],(['"Id":"','"','"']),'{"Id":'.$username.',"CurrentPassword":"","CurrentPw":"","NewPw":"'.$password.'"}');





