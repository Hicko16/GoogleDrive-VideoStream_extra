#!/usr/bin/perl

###
##
## The purpose of this script is to watch the plex transcode directory and fix the naming on the chunks
##
## This script takes a -d directory, where this is the directory to scan
###

use Getopt::Std;		# and the getopt module


my %opt;
die (USAGE) unless (getopts ('d:',\%opt));

# directory to scan
my $directory = $opt{'d'};


while(1){
readDIR($directory);
sleep 1;
}


sub readDIR($$){

my $directory = shift;

opendir (my $dir, $directory) or die $!;

while (my $file = readdir($dir)) {

	next if $file eq '.' or $file eq '..';

	# it's a directory
	if ( -d $directory. '/'. $file){

		readDIR($directory. '/'. $file);
		next;


	# is file that needs to be fixed
	}else{
		next unless $file =~ m%chunk.*\.ts%;
		#next unless $file =~ m%\.ts%;
		my $withoutTS = $file;
		$withoutTS =~ s%\.ts%%;
		symlink($file,$directory. '/'. $withoutTS);

	}

}
close($dir);


}


