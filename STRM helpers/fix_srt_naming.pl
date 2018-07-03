#!/usr/bin/perl

###
##
## The purpose of this script is two-fold:
## 1) remove extra qualty STRM files when there is multiple in the same movie / tv folder (keep the highest quality)
## 2) rename the SRT files to match the name of the STRM file
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



readDIR($directory);



sub readDIR($){

my $directory = shift;

opendir (my $dir, $directory) or die $!;

my %currentDirectory_strm;
my %currentDirectory_strm_resolution;
my %srtFiles;
while (my $file = readdir($dir)) {

	next if $file eq '.' or $file eq '..';

	my ($base) = $file =~ m%(S\d+E\d+)%;

	if ( -d $directory. '/'. $file){

		readDIR($directory. '/'. $file);
		next;

	# is strm file
	}elsif ($file =~ m%\.strm%i){
		my ($resolution) = $file =~ m%original (\d+)%;
		if ($resolution > $currentDirectory_strm_resolution{$base}){
			if ($currentDirectory_strm_resolution{$base} > 0){
				print "DELETING $currentDirectory_strm{$base}\n";
				unlink $directory . '/'. $currentDirectory_strm{$base};
			}
			$currentDirectory_strm_resolution{$base} = $resolution;
			$currentDirectory_strm{$base} = $file;
		}elsif ($resolution <  $currentDirectory_strm_resolution{$base}){
			print "DELETING $file\n";
			unlink $directory . '/'. $file;

		}
	# is srt file
	}elsif ($file =~ m%\.srt%i){
		push @{$srtFiles{$base}}, $file;
		print "PUSHING $currentDirectory_strm{$base}\n";

	}

}
close($dir);

foreach my $key (keys %currentDirectory_strm){
	my $current=0;
	my $filename = '';
	if ($current < $#{$srtFiles{$key}} + 1){
		($filename) = $currentDirectory_strm{$key} =~ m%^(.*?)\.strm%i;
		print "FILENAME $filename\n";
		if ($filename eq ''){
			return;
		}

	}

	while ($current < $#{$srtFiles{$key}}+1){
		my $renameTo = ${$srtFiles{$key}}[$current];
		my ($srtFilename, $srtCode2) =  ${$srtFiles{$key}}[$current] =~ m%^(.*?)\.(\S\S)\.srt%i;
		my $is2Letter = 0;
		if ($srtFilename eq ''){
			($srtFilename) =  ${$srtFiles{$key}}[$current] =~ m%^(.*?)\.\S\S\S\.srt%i;

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
		print "RENAME  ${$srtFiles{$key}}[$current] to $renameTo\n";
		rename $directory . '/'.  ${$srtFiles{$key}}[$current],$directory . '/'. $renameTo;

		$current++;


	}

}


}