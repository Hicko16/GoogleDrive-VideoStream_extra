#!/usr/bin/perl

###
##
## The purpose of this script is to create a list of all videos requiring analysis
###

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . "  -i sql_dump -o outputfile\n\t -v is verbose\n";


my %opt;
die (USAGE) unless (getopts ('i:o:vl:',\%opt));

# directory to scan
my $output = $opt{'o'};
my $input = $opt{'i'};


my $isVerbose = 0;
if (defined($opt{'v'})){
	$isVerbose = 1;
}

my $logfile = $opt{'l'};

if ($output eq ''){
	die (USAGE);
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
	}elsif ($resolution eq '' and $movieTitle ne '' and $movieYear ne ''){
		next if ($videoHash{$fileName.'_'} ne '' or $videoHash{$fileName} ne '');
		$videoHash{$fileName.'_'} = $movieDirectory . $movieTitle.'('.$movieYear.')/'. $movieTitle.'('.$movieYear.') - original'.$version.' '.$resolution . 'p.strm';
	}elsif ($resolution > 0 and $tvTitle ne '' and $tvSeason ne ''){

		next if ($videoHash{$fileName} ne '');
		$videoHash{$fileName} = $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - original'. $version . ' '.$resolution . 'p.strm';
	}elsif ($resolution eq '' and $tvTitle ne '' and $tvSeason ne ''){
		next if ($videoHash{$fileName.'_'} ne '' or $videoHash{$fileName} ne '');
		$videoHash{$fileName} = $tvDirectory . $tvTitle.'/season '.$tvSeason . '/'.$tvTitle. ' S'. $tvSeason.'E'.$tvEpisode.' - original'. $version . ' '.$resolution . 'p.strm';

	}
}

close(INPUT);

open(INPUT,$input) or die ("Cannot open $input ".$!);
open(OUTPUT,'>' . $output) or die ("Cannot open $output ".$!);
open(LOGFILE, '>'. $logfile) or die ("Cannot create $logfile" . $!) if $logfile ne '';
print OUTPUT "begin transaction;";
#INSERT INTO "media_parts" VALUES(44,44,1,'52a37ff9c24586292d2598497445f8dafd205364','fc349023336c7d19','/var/lib/plexmediaserver/media/tv/''Til Death/Season 01/''Til Death - S01E01 - Pilot WEBDL-1080p.mkv',
while(my $line =<INPUT>){
	if ($line =~ m%INSERT INTO "media_parts"%){
		my ($filenameWithPath) = $line =~ m%INSERT INTO "media_parts" VALUES\([^\,]+,[^\,]+,[^\,]+,[^\,]+,[^\,]+,'([^\,]+)',%;
		next if $filenameWithPath eq '';
		#print "filename = $filenameWithPath\n" if $isVerbose;
		my ($filename) = $filenameWithPath =~ m%.*?/([^\/]+)$%;
		$filename =~ s%''%'%g;
		if ($videoHash{$filename} ne ''){
			print "match = $filename\n" if $isVerbose;
			my $printFilenameWithPath = $filenameWithPath;
			my $printSTRM = $videoHash{$filename};
			$printSTRM =~ s%'%''%g;
			print LOGFILE "match\t$filename\t-\t$videoHash{$filename}\n" if $logfile ne '';
			#print OUTPUT "UPDATE media_parts SET file= replace(file, '$filenameWithPath', '$printSTRM') where file='$printFilenameWithPath';\n";
			print OUTPUT "UPDATE media_parts SET file='$printSTRM' where file='$printFilenameWithPath';\n";
			$count++;
			if ($count == 100){
				$count = 0;
				print OUTPUT "commit; begin transaction;";

			}
		}elsif ($videoHash{$filename.'_'} ne ''){
			print "match (transcode error) = $filename\n" if $isVerbose;
			my $printFilenameWithPath = $filenameWithPath;
			my $printSTRM = $videoHash{$filename.'_'};
			$printSTRM =~ s%'%''%g;
			print LOGFILE "match (transcode error)\t$filename\t-\t".$videoHash{$filename.'_'}."\n" if $logfile ne '';
			#print OUTPUT "UPDATE media_parts SET file= replace(file, '$filenameWithPath', '$printSTRM') where file='$printFilenameWithPath';\n";
			print OUTPUT "UPDATE media_parts SET file='$printSTRM' where file='$printFilenameWithPath';\n";
			$count++;
			if ($count == 100){
				$count = 0;
				print OUTPUT "commit; begin transaction;";

			}
		}else{
			print "NO match = $filename\n" if $isVerbose;
			print LOGFILE "no match\t$filename \n" if $logfile ne '';

		}
	}
}
print OUTPUT "commit;";

close(INPUT);
close(OUTPUT);
close(LOGFILE)  if $logfile ne '';



