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

use constant USAGE => $0 . "-p 8096 -i emby-server -a api_key -b backup_location -l instance_name (-L)\n -L for including logs in backup";

use Time::localtime;
my $tm = localtime;
my $time = sprintf("%04d%02d%02d", $tm->year+1900,($tm->mon)+1, $tm->mday);


my %opt;
die (USAGE) unless (getopts ('p:a:i:b:',\%opt));

my $instance  = $opt{'i'};
my $backupLocation  = $opt{'b'} . '/library.db.'. $time;
my $label  = $opt{'l'};
my $port =  $opt{'p'};
my $apiKey = $opt{'a'};
my $includeLogs = 0;
if (defined($opt{'L'})){
	$includeLogs = 1;
}
my $libraryDB = '/var/lib/'.$instance.'/data/library.db';
my $embyLibrary =  '/var/lib/'.$instance . '/*';
my $backupLocationEmby  = $opt{'b'} . '/emby.' . $label . '.'.$time.'.tgz';


die(USAGE) if ($port eq '' or $instance eq '');


my $url = 'http://127.0.0.1:'.$port.'/emby/System/Shutdown?api_key='.$apiKey;

TOOLS_CRAWLER::ignoreCookies();
my @results = TOOLS_CRAWLER::simplePOST($url);
sleep(10);
copy($libraryDB,$backupLocation);
if ($includeLogs){
	`/bin/tar -zcvf $backupLocationEmby $embyLibrary`;
}else{
	`/bin/tar --exclude='$embyLibrary/logs' -zcvf $backupLocationEmby $embyLibrary`;
}

`/usr/sbin/service $instance start`;
`/bin/gzip $backupLocation`;




