#!/usr/bin/perl

###
##
## The purpose of this script is to create STRM files by using a supplied TAB file.
###

use Getopt::Std;		# and the getopt module


my %opt;
die (USAGE) unless (getopts ('s:d:t:h:o',\%opt));

# directory to scan
my $directory = $opt{'d'};
my $transcodeLabel = $opt{'t'};
my $inputSpreadsheet = $opt{'s'};
my $hostname = $opt{'h'};
my $generateOriginal = 0;
if ($opt{'o'}){
	$generateOriginal = 1;
}

# some checks
if (!(-e $directory)){
	die ("target does not exist " . $directory);
}
my $movieDirectory = $directory . '/movies/' ;
if (!(-e $movieDirectory)){
	mkdir $movieDirectory;
}

open(INPUT,$inputSpreadsheet) or die ("Cannot open $inputSpreadsheet ".$!);
my %movieHash;
my %movieCount;
while(my $line =<INPUT>){
	my ($folderID,$fileID,$fileName, $movieTitle, $movieYear, $resolution, $hash) = $line =~ m%^([^\t]*)\t[^\t]*\t([^\t]*)\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t[^\t]*%;
	if ($resolution > 0 and $movieTitle ne '' and $movieYear ne '' and $movieHash{$hash} != 1){
		if (!(-e $movieDirectory . $movieTitle.'('.$movieYear.')') ){
			mkdir $movieDirectory . $movieTitle.'('.$movieYear.')';
		}

		my $version = '';
		if ($movieCount{$movieTitle} >= 1){
			$version = ' ' . ($movieCount{$movieTitle}+1);
		}

		print "$movieTitle $resolution $hash\n";
		if ($generateOriginal){
			open(OUTPUT,'>' . $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - original '. $resolution . 'p'.$version.'.strm' ) or die ("Cannot create STRM file ".$!);
			print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName;
			close OUTPUT;
		}
		open(OUTPUT,'>' . $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - '.$transcodeLabel.' 420p'.$version.'.strm' ) or die ("Cannot create STRM file ".$!);
		print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName.'&preferred_quality=2&override=true';
		close OUTPUT;

		if ($resolution > 420){
			open(OUTPUT,'>' . $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - '.$transcodeLabel.' 720p'.$version.'.strm' ) or die ("Cannot create STRM file ".$!);
			print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName.'&preferred_quality=1&override=true';
			close OUTPUT;
		}
		if ($resolution > 720){
			open(OUTPUT,'>' . $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - '.$transcodeLabel.' 1080p'.$version.'.strm' ) or die ("Cannot create STRM file ".$!);
			print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName.'&preferred_quality=0&override=true';
			close OUTPUT;
		}

		$movieHash{$hash} = 1;
		$movieCount{$movieTitle}++;
	}
}

close(INPUT);

