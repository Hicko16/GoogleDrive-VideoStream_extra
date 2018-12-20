#!/usr/bin/perl

###
##
## The purpose of this script is to create STRM files by using a supplied TAB file.
###

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . " -d directory_to_save -t transcode_label -s spreadsheet.tab -h hostname [-o] [-a] [-u]\n\t -u unique only no duplicates, -o original only -z transcode only, -a include tv (default movies only)\n";


my %opt;
die (USAGE) unless (getopts ('s:d:t:h:oavz',\%opt));

# directory to scan
my $directory = $opt{'d'};
my $transcodeLabel = $opt{'t'};
my $inputSpreadsheet = $opt{'s'};
my $hostname = $opt{'h'};
my $generateOriginal = 0;
if (defined($opt{'o'})){
	$generateOriginal = 1;
}

my $isOnlyUnique = 0;
if (defined($opt{'u'})){
	$isOnlyUnique = 1;
}
my $generateTranscode = 0;
if (defined($opt{'z'})){
	$generateTranscode = 1;
}
my $isVerbose = 0;
if (defined($opt{'v'})){
	$isVerbose = 1;
}
my $includeTV = 0;
if (defined($opt{'a'})){
	$includeTV = 1;
}

if ($directory eq ''){
	die (USAGE);
}


# some checks
if (!(-e $directory)){
	die ("target does not exist " . $directory);
}
my $movieDirectory = $directory . '/movies/' ;
if (!(-e $movieDirectory)){
	mkdir $movieDirectory;
}

my $tvDirectory = $directory . '/tv/' ;

if ($includeTV and !(-e $tvDirectory)){
	mkdir $tvDirectory;
}


open(INPUT,$inputSpreadsheet) or die ("Cannot open $inputSpreadsheet ".$!);
my %movieHash;
my %movieCount;
my %tvHash;
my %tvCount;
while(my $line =<INPUT>){
	my ($folderID,$fileID,$fileName, $tvTitle, $tvSeason, $tvEpisode, $movieTitle, $movieYear, $resolution, $hash) = $line =~ m%^([^\t]*)\t[^\t]*\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t[^\t]*%;
	if ($resolution > 0 and $movieTitle ne '' and $movieYear ne '' and $movieHash{$hash} != 1){
		if (!(-e $movieDirectory . $movieTitle.'('.$movieYear.')') ){
			mkdir $movieDirectory . $movieTitle.'('.$movieYear.')';
		}

		my $version = '';
		if ($movieCount{$movieTitle} >= 1){
			next if ($isOnlyUnique);
			$version =  '_'.($movieCount{$movieTitle}+1);
		}

		print "$movieTitle $resolution $hash\n" if $isVerbose;
		if ($generateOriginal){
			if (! (-e $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - original'.$version.' '.$resolution . 'p.strm')){
				open(OUTPUT,'>' . $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - original'.$version.' '.$resolution . 'p.strm' ) or die ("Cannot create STRM file ".$!);
				print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName;
				close OUTPUT;
			}
		}
		if ($generateTranscode){
			if (! (-e $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - '.$transcodeLabel.$version.' 420p.strm' )){
				open(OUTPUT,'>' . $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - '.$transcodeLabel.$version.' 420p.strm' ) or die ("Cannot create STRM file ".$!);
				print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName.'&preferred_quality=2&override=true';
				close OUTPUT;
			}
			if ($resolution > 420){
				if (! (-e $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - '.$transcodeLabel.$version.' 720p.strm' )){
					open(OUTPUT,'>' . $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - '.$transcodeLabel.$version.' 720p.strm' ) or die ("Cannot create STRM file ".$!);
					print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName.'&preferred_quality=1&override=true';
					close OUTPUT;
				}
			}
			if ($resolution > 720){
				if (! (-e $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - '.$transcodeLabel.$version.' 1080p.strm' )){
					open(OUTPUT,'>' . $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - '.$transcodeLabel.$version.' 1080p.strm' ) or die ("Cannot create STRM file ".$!);
					print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName.'&preferred_quality=0&override=true';
					close OUTPUT;
				}
			}
		}
		$movieHash{$hash} = 1;
		$movieCount{$movieTitle}++;
	}elsif ($includeTV and $resolution > 0 and $tvTitle ne '' and $tvSeason ne '' and $tvHash{$hash} != 1){
		if (!(-e $tvDirectory . $tvTitle) ){
			mkdir $tvDirectory . $tvTitle;
		}
		if (!(-e $tvDirectory . $tvTitle.'/season '.$tvSeason) ){
			mkdir $tvDirectory . $tvTitle.'/season '.$tvSeason;
		}

		my $version = '';
		if ($tvCount{$tvTitle.$tvSeason.$tvEpisode} >= 1){
			next if ($isOnlyUnique);
			$version = '_' . ($tvCount{$tvTitle.$tvSeason.$tvEpisode}+1);
		}

		print "$tvTitle $resolution $hash\n" if $isVerbose;
		if ($generateOriginal){
			if (! (-e $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - original'. $version . ' '.$resolution . 'p.strm')){
				open(OUTPUT,'>' . $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - original'. $version . ' '.$resolution . 'p.strm' ) or die ("Cannot create STRM file ".$!);
				print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName;
				close OUTPUT;
			}
		}
		if ($generateTranscode){
			if (! (-e $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - '.$transcodeLabel.$version.' 480p.strm' )){
				open(OUTPUT,'>' . $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - '.$transcodeLabel.$version.' 480p.strm' ) or die ("Cannot create STRM file ".$!);
				print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName.'&preferred_quality=2&override=true';
				close OUTPUT;
			}

			if ($resolution > 420){
				if (! (-e $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - '.$transcodeLabel.$version.' 720p.strm' )){
					open(OUTPUT,'>' . $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - '.$transcodeLabel.$version.' 720.strm' ) or die ("Cannot create STRM file ".$!);
					print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName.'&preferred_quality=1&override=true';
					close OUTPUT;
				}
			}
			if ($resolution > 720){
				if (! (-e $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - '.$transcodeLabel.$version.' 1080p.strm' )){
					open(OUTPUT,'>' . $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - '.$transcodeLabel.$version.' 1080p.strm' ) or die ("Cannot create STRM file ".$!);
					print OUTPUT $hostname . '/default.py?mode=video&instance=gdrive1&folder='.$folderID.'&filename='.$fileID.'&title='.$fileName.'&preferred_quality=0&override=true';
					close OUTPUT;
				}
			}
		}
		$tvHash{$hash} = 1;
		$tvCount{$tvTitle.$tvSeason.$tvEpisode}++;
	}
}

close(INPUT);

