#!/usr/bin/perl

###
##
## The purpose of this script is two-fold:
## 1) remove extra qualty STRM files when there is multiple in the same movie / tv folder (keep the highest quality)
## 2) rename the SRT files to match the name of the STRM file
##
## This script takes a -d directory, where this is the directory to scan
## This script takes a -t type, where type is either tv or movie.  The script behaviour is different based on if
##  the folder is a movie or tv folder.  Movie folders there will be only 1 title per folder whereas with tv folders
##  you have multiple episodes in each folder, so care needs to be taken to remove extra qualities by episode only,
##  and to map the SRT files to the correct episode.
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 50;

use Getopt::Std;		# and the getopt module


my %opt;
die (USAGE) unless (getopts ('d:t:',\%opt));

# directory to scan
my $directory = $opt{'d'};
my $type = $opt{'t'};

if ($type ne 'tv' or $type ne 'movie'){
	print STDERR "type needs to be either tv or movie.";
	exit(0);
}


readDIR($directory);



sub readDIR($){

my $directory = shift;

opendir (my $dir, $directory) or die $!;

my $currentDirectory_strm;
my $currentDirectory_strm_resolution = 0;
my @srtFiles;
while (my $file = readdir($dir)) {

	next if $file eq '.' or $file eq '..';

	if ( -d $directory. '/'. $file){

		readDIR($directory. '/'. $file);
		next;

	# is strm file
	}elsif ($file =~ m%\.strm%i){
		my ($resolution) = $file =~ m%original (\d+)%;
		if ($resolution > $currentDirectory_strm_resolution){
			if ($currentDirectory_strm_resolution > 0){
				print "DELETING $currentDirectory_strm\n";
				unlink $directory . '/'. $currentDirectory_strm;
			}
			$currentDirectory_strm_resolution = $resolution;
			$currentDirectory_strm = $file;
		}elsif ($resolution <  $currentDirectory_strm_resolution){
			print "DELETING $file\n";
			unlink $directory . '/'. $file;

		}
	# is srt file
	}elsif ($file =~ m%\.srt%i){
		push @srtFiles, $file;
		print "PUSHING $currentDirectory_strm\n";

	}

}
close($dir);

my $current=0;
my $filename = '';
if ($current < $#srtFiles + 1){
	($filename) = $currentDirectory_strm =~ m%^(.*?)\.strm%i;
	print "FILENAME $filename\n";
	if ($filename eq ''){
		return;
	}

}

while ($current < $#srtFiles+1){
	my $renameTo = $srtFiles[$current];
	my ($srtFilename, $srtCode2) = $srtFiles[$current] =~ m%^(.*?)\.(\S\S)\.srt%i;
	my $is2Letter = 0;
	if ($srtFilename eq ''){
		($srtFilename) = $srtFiles[$current] =~ m%^(.*?)\.\S\S\S\.srt%i;

		if ($srtFilename eq ''){
			#($srtFilename) = $srtFiles[$current] =~ m%^(.*?)\.srt%i;
			#if ($srtFilename eq ''){
				$current++;
				next;
			#}
		}
	}else{
		$is2Letter = 1;
		my $srtCode3 = '';
		if ($srtCode2 eq 'en'){
			$srtCode3 = 'eng';
			$renameTo =~ s%\.$srtCode2\.%\.$srtCode3\.%i;
		}

	}
	$renameTo =~ s%$srtFilename%$filename%i;
	print "RENAME $srtFiles[$current] to $renameTo\n";
	rename $directory . '/'. $srtFiles[$current],$directory . '/'. $renameTo ;

	$current++;


}


}