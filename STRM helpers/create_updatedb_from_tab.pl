#!/usr/bin/perl

###
##
## The purpose of this script is to create an update DB file for Plex DB to replace regular files with STRM files
###

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . " -d strm_directory -i inputfile -o outputfile -s spreadsheet.tab\n\t -v is verbose\n";


my %opt;
die (USAGE) unless (getopts ('d:s:i:o:v',\%opt));

# directory to scan
my $directory = $opt{'d'};
my $output = $opt{'o'};
my $inputSpreadsheet = $opt{'s'};
my $input = $opt{'i'};


my $isVerbose = 0;
if (defined($opt{'v'})){
	$isVerbose = 1;
}

if ($output eq ''){
	die (USAGE);
}

my $movieDirectory = $directory . '/movies/' ;
my $tvDirectory = $directory . '/tv/' ;


# some checks
if (!(-e $inputSpreadsheet)){
	die ("spreadsheet does not exist " . $inputSpreadsheet);
}
# some checks
if (!(-e $input)){
	die ("input file does not exist " . $input);
}


open(INPUT,$inputSpreadsheet) or die ("Cannot open $inputSpreadsheet ".$!);
my %videoHash;
while(my $line =<INPUT>){
	my ($folderID,$fileID,$fileName, $tvTitle, $tvSeason, $tvEpisode, $movieTitle, $movieYear, $resolution, $hash) = $line =~ m%^([^\t]*)\t[^\t]*\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t[^\t]*%;
	if ($resolution > 0 and $movieTitle ne '' and $movieYear ne ''){

		next if ($videoHash{$fileName} ne '');
		$videoHash{$fileName} = $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - original'.$version.' '.$resolution . 'p.strm';

	}elsif ($resolution > 0 and $tvTitle ne '' and $tvSeason ne ''){

		next if ($videoHash{$fileName} ne '');
		$videoHash{$fileName} = $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - original'. $version . ' '.$resolution . 'p.strm';
	}
}

close(INPUT);

open(INPUT,$input) or die ("Cannot open $input ".$!);
open(OUTPUT,'>' . $output) or die ("Cannot open $output ".$!);

#INSERT INTO "media_parts" VALUES(44,44,1,'52a37ff9c24586292d2598497445f8dafd205364','fc349023336c7d19','/var/lib/plexmediaserver/media/tv/''Til Death/Season 01/''Til Death - S01E01 - Pilot WEBDL-1080p.mkv',
while(my $line =<INPUT>){
	if ($line =~ m%INSERT INTO "media_parts"%){
		my ($filenameWithPath) = $line =~ m%INSERT INTO "media_parts" VALUES\([^\,]+,[^\,]+,[^\,]+,[^\,]+,[^\,]+,'([^\,]+)',%;
		next if $filenameWithPath eq '';
		print "filename = $filenameWithPath\n" if $isVerbose;
		my ($filename) = $filenameWithPath =~ m%.*?/([^\/]+)$%;
		if ($videoHash{$filename} ne ''){
			print "match = $filename\n";
			my $printFilenameWithPath = $filenameWithPath;
			my $printSTRM = $videoHash{$filename};
			$printFilenameWithPath =~ s%'%''%g;
			$printSTRM =~ s%'%''%g;
			#print OUTPUT "UPDATE media_parts SET file= replace(file, '$filenameWithPath', '$printSTRM') where file='$printFilenameWithPath';\n";
			print OUTPUT "UPDATE media_parts SET file='$printSTRM' where file='$printFilenameWithPath';\n";
		}else{
			print "NO match = $filename\n";
		}
	}
}

close(INPUT);
close(OUTPUT);



