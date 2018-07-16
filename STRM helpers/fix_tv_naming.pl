#!/usr/bin/perl

###
##
## The purpose of this script is to fix the naming of tv shows by adding the show title to them
##
## This script takes a -d directory, where this is the directory to scan
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 50;

use Getopt::Std;		# and the getopt module


my %opt;
die (USAGE) unless (getopts ('d:',\%opt));

# directory to scan
my $directory = $opt{'d'};



readDIR($directory,'');



sub readDIR($$){

my $directory = shift;
my $showtitle = shift;

opendir (my $dir, $directory) or die $!;

my %currentDirectory_strm;
my %currentDirectory_strm_resolution;
my %srtFiles;
while (my $file = readdir($dir)) {

	next if $file eq '.' or $file eq '..';

	my ($base) = $file =~ m%(S\d+E\d+)%;

	if ( -d $directory. '/'. $file){

		if (!($file =~ m%season%i)){
			$showtitle = $file;
		}
		readDIR($directory. '/'. $file, $showtitle);
		next;

	# is file that needs to be fixed
	}elsif ($file =~ m%^S\d+\E\d+%i){
		print "fixing  $showtitle $directory/$file\n";
		rename $directory . '/'.  $file,$directory . '/'. $showtitle . ' ' . $file;
	}

}
close($dir);


}


