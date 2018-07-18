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
die (USAGE) unless (getopts ('s:t:u:y:',\%opt));

# directory for backups
my $sourceDirectory = $opt{'s'};
my $targetDirectory = $opt{'t'};

my $userSource =  $opt{'u'};
my $userTarget =  $opt{'y'};

# some checks
if (!(-e $targetDirectory)){
	die ("target does not exist " . $targetDirectory);
}
if (!(-e $sourceDirectory . '/userdata/' . $userSource . '/')){
	die ("source user does not exist " . $userSource);
}
if (-e $targetDirectory . '/userdata/' . $userTargert . '/'){
	die ("target user already exists " . $userTargert);
}

# make user
mkdir $targetDirectory . '/userdata/' . $userTargert . '/';
mkdir $targetDirectory . '/users/' . $userTargert . '/';

copy($sourceDirectory . '/userdata/' . $userSource . '/displayprefs.json', $targetDirectory . '/userdata/' . $userTargert . '/displayprefs.json');
copy($sourceDirectory . '/userdata/' . $userSource . '/userdata.json', $targetDirectory . '/userdata/' . $userTargert . '/userdata.json');
copy($sourceDirectory . '/users/' . $userSource . '/sec.txt', $targetDirectory . '/users/' . $userTargert . '/sec.txt');
copy($sourceDirectory . '/users/' . $userSource . '/config.xml', $targetDirectory . '/users/' . $userTargert . '/config.xml');
copy($sourceDirectory . '/users/' . $userSource . '/policy.xml', $targetDirectory . '/users/' . $userTargert . '/policy.xml');

print "created " . $userTarget . "\n";





