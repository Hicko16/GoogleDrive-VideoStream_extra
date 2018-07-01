#!/usr/bin/perl

# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 50;

use Getopt::Std;		# and the getopt module


my %opt;
die (USAGE) unless (getopts ('d:',\%opt));

my $directory = $opt{'d'};



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