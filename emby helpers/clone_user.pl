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
my @directoriesToMake = ("$targetDirectory/userdata/$userTarget", "$targetDirectory/users/$userTarget");
foreach my $directoryToMake (@directoriesToMake){
    mkdir $directoryToMake or die("cannot create " . $directoryToMake . " " . $!);
}

my @filesToMake = (["$sourceDirectory/userdata/$userSource/displayprefs.json", "$targetDirectory/userdata/$userTarget/displayprefs.json"],
["$sourceDirectory/userdata/$userSource/userdata.json","$targetDirectory/userdata/$userTarget/userdata.json"],
["$sourceDirectory/users/$userSource/sec.txt", "$targetDirectory/users/$userTarget/sec.txt"],
["$sourceDirectory/users/$userSource/config.xml", "$targetDirectory/users/$userTarget/config.xml"],
["$sourceDirectory/users/$userSource/policy.xml", "$targetDirectory/users/$userTarget/policy.xml"]);

foreach my $fileToCopy (@filesToMake){
	copy($fileToCopy[0], $fileToCopy[1]) or die ("cannot copy file ". $fileToCopy[0] . " " . $!);
}

print "created " . $userTarget . "\n";





