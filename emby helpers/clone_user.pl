#!/usr/bin/perl

###
##
## The purpose of this script is to clone user(s) based on a provided user.
##
## This script takes a -d directory, where this is the directory to scan
###

use Getopt::Std;		# and the getopt module
use File::Copy;


my %opt;
die (USAGE) unless (getopts ('d:s:t:u:y:',\%opt));

# directory for backups
my $directory  = $opt{'d'};
my $sourceDirectory = $directory . '/'. $opt{'s'};
my $targetDirectory = $directory . '/'. $opt{'t'};

my $userSource =  $opt{'u'};
my $userTarget =  $opt{'y'};

# some checks
if (!(-e $targetDirectory)){
	die ("target does not exist " . $targetDirectory);
}
if (!(-e $sourceDirectory . '/userdata/' . $userSource . '/')){
	die ("source user does not exist " . $userSource);
}
if (-e $targetDirectory . '/userdata/' . $userTarget . '/'){
	die ("target user already exists " . $userTarget);
}

# make user
mkdir $targetDirectory . '/userdata/' . $userTargert . '/';
mkdir $targetDirectory . '/users/' . $userTargert . '/';

copy('"'. $sourceDirectory . '/userdata/' . $userSource . '/displayprefs.json'. '"', '"'. $targetDirectory . '/userdata/' . $userTarget . '/displayprefs.json'. '"') or die ("cannot copy displayprefs.json" . $sourceDirectory . '/userdata/' . $userSource . '/displayprefs.json ' . $targetDirectory . '/userdata/' . $userTarget . '/displayprefs.json');
copy($sourceDirectory . '/userdata/' . $userSource . '/userdata.json', $targetDirectory . '/userdata/' . $userTarget . '/userdata.json') or die ("cannot copy userdata.json");
copy($sourceDirectory . '/users/' . $userSource . '/sec.txt', $targetDirectory . '/users/' . $userTarget . '/sec.txt')  or die ("cannot copy sec.txt");
copy($sourceDirectory . '/users/' . $userSource . '/config.xml', $targetDirectory . '/users/' . $userTarget . '/config.xml') or die ("cannot copy config.xml");
copy($sourceDirectory . '/users/' . $userSource . '/policy.xml', $targetDirectory . '/users/' . $userTarget . '/policy.xml') or die ("cannot copy policy.xml");

print "created " . $userTarget . "\n";





