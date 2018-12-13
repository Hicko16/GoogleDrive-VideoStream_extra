#!/usr/bin/perl

###
##
## The purpose of this script is to create a movie collection by creating a collections.xml
## This on works on Emby < 3.6, as in 3.6, collections.xml is no longer used.
##
## The input is a txt file of the form"movie<tab>year
##
####

use Getopt::Std;		# and the getopt module
use File::Copy;



my %opt;
die (USAGE) unless (getopts ('i:q:t:m:c:d:w:b:vx',\%opt));

# directory for backups
my $inputSpreadsheet  = $opt{'i'};
my $quality =  $opt{'q'};
my @nfoCriteria = split(',', $opt{'w'});
my @blacklistnfoCriteria = split(',', $opt{'b'});

if ($quality eq '' and $inputSpreadsheet eq '' and $#nfoCriteria < 0){
	die($0 . "(-i spreadsheet) (-q quality) (-t tv_folder) (-m movie_folder) -c collection_name -d target_dir -n nfo_criteria (-v) (-x)\n -v verbose, -x deep dive into tv" ."either quality, nfo criteria or a spreadsheet for input is required");
}

my @searchCriteria =


my $tvSourceDirectory =  $opt{'t'};
my $movieSourceDirectory =  $opt{'m'};
my $targetDirectory =  $opt{'d'};
my $collectionName =  $opt{'c'};
my $isVerse = 0;
if ($opt{'v'}){
	$isVerse = 1;
}
my $isTVDeep = 0;
if ($opt{'x'}){
	$isTVDeep = 1;
}

my $minQuality = 0;
my $maxQuality = 9999;
my $isByQuality = 1;
if ($quality == 2160){
	$minQuality = 1081;
}elsif ($quality == 1080){
	$maxQuality = 1080;
	$minQuality = 721;
}elsif ($quality == 720){
	$maxQuality = 720;
	$minQuality = 481;
}elsif ($quality == 480){
	$maxQuality = 480;
}else{
	$isByQuality = 0;
}

# some checks
if (!(-e $targetDirectory)){
	die ("target does not exist " . $targetDirectory);
}
if (!(-e $movieSourceDirectory) and !(-e $tvSourceDirectory)){
	die ("neither source does exists: " . $movieSourceDirectory . ' or ' . $tvSourceDirectory);
}
if ($collectionName eq ''){
	die ("no collection name specified (-c name).");
}

use POSIX qw(strftime);

my $datestring = strftime "%D %r", localtime;


my $targetDirectoryBoxSet = "$targetDirectory/$collectionName [boxset]/";

mkdir "$targetDirectoryBoxSet";

open(XML,">" . $targetDirectoryBoxSet . '/collection.xml') or die ("Cannot save to $targetDirectoryBoxSet ".$!);
#  <Added>$datestring</Added>
#  <TmdbId>748</TmdbId>

print XML <<EOF;
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Item>
  <ContentRating>CA-PG</ContentRating>
  <Added>8/16/18 12:33:19 PM</Added>
  <LockData>false</LockData>
  <Overview>$collectionName</Overview>
  <LocalTitle>$collectionName</LocalTitle>
  <PremiereDate>2000-07-13</PremiereDate>
  <DisplayOrder>PremiereDate</DisplayOrder>
  <ProductionYear>2000</ProductionYear>
  <Genres>
    <Genre>Action</Genre>
    <Genre>Adventure</Genre>
    <Genre>Science Fiction</Genre>
    <Genre>Fantasy</Genre>
    <Genre>Thriller</Genre>
  </Genres>
  <Studios>
    <Studio>The Donners' Company</Studio>
  </Studios>
  <CollectionItems>
EOF

my %elminateDuplicates;

if ($inputSpreadsheet ne ''){

	open(INPUT,$inputSpreadsheet) or die ("Cannot open $inputSpreadsheet ".$!);


	while(my $line =<INPUT>){

	#    <CollectionItem>
	#      <Path>/u01/STRM/movies/the mask of zorro(1998)/the mask of zorro(1998) - original 1080p.strm</Path>
	#    </CollectionItem>
		my ($title, $year) = $line =~ m%([^\t]+)\t([^\t]+)\n%;
		my $source = "$movieSourceDirectory/$title($year)";
    	next unless -d "$source";
		opendir my $dh2, "$source" or die("cannot open $source");
		while (my $file = readdir $dh2) {
			next if $file eq '.' or $file eq '..';
    		print "file $file\n" if $isVerse;
    		if ($#nfoCriteria >= 0){
				next unless $file =~ m%\.nfo%;
				open (NFO, "$source/$file") or next;
				my $match=0;

				while (my $line = <NFO>){
				    foreach my $criteria (@nfoCriteria) {
						if ($line =~ m%$criteria%){
							$file  =~ s%\.nfo%\.strm%;

							#remove the strm file from path
							$file  =~ s%\/([\/]+)\.strm$%%;

							if ($elminateDuplicates{$file} == 0){
		    					print "match $file\n";
								$match = 1;
								$elminateDuplicates{$file}++;
							}

#							last;
						}
				    }
				    foreach my $criteria (@blacklistnfoCriteria) {
						if ($line =~ m%$criteria%){
	    					print "blacklist $file\n";
							$match = 0;
							last;
						}
				    }
#				    last if $match;

				}
				close (NFO);
				next unless $match;
    		}else{
				next unless ($file =~ m%\.strm$%);
    		}
			#$file =~ s%\&%\&amp;%g;
			print "matched $file \n";
			my $cleanPath = "$source/$file";
			$cleanPath =~  s%\&%\&amp;%g;
			print XML <<EOF;
    <CollectionItem>
      <Path>$cleanPath</Path>
    </CollectionItem>
EOF
			last;
		}
		closedir $dh2;


	}

	close(INPUT);
}else{
	my @array = ($movieSourceDirectory,$tvSourceDirectory);
	while (@array) {

	my $sourceDirectory = shift(@array);
	if (opendir my $dh, $sourceDirectory){

	while (my $folder = readdir $dh) {
		next if $folder eq '.' or $folder eq '..';

    	print "folder $folder\n" if $isVerse;
    	next unless -d "$sourceDirectory/$folder";
		opendir my $dh2, "$sourceDirectory/$folder" or die("cannot open $sourceDirectory/$folder");
		my @files;
		while (my $file = readdir $dh2) {
			next if $file eq '.' or $file eq '..';
			push @files, "$sourceDirectory/$folder/$file"
		}
		closedir $dh2;


		while (my $file = pop @files) {
			# is a tv season folder?
			if ($isTVDeep and -d $file){
				opendir my $dh2, $file or die("cannot open $file");

				while (my $file2 = readdir $dh2) {
					next if $file2 eq '.' or $file2 eq '..';
					push @files, "$file/$file2"
				}
				closedir $dh2;
				next;
			}
    		print "file $file\n" if $isVerse;
			my ($q) = $file =~ m% (\d+)p%;
			#next if $q == 0;
			next if $q > $maxQuality or $q < $minQuality;
    		if ($#nfoCriteria >= 0){
				next unless $file =~ m%\.nfo$%;
				next unless $file =~ m%original$%;

				open (NFO, $file) or next;
				my $match=0;

				while (my $line = <NFO>){
				    foreach my $criteria (@nfoCriteria) {
						if ($line =~ m%$criteria%i){
							$file  =~ s%\.nfo$%\.strm%;

							#remove the strm file from path
							#$file  =~ s%\/([^\/]+)\.strm$%%;

							if ($elminateDuplicates{$file} == 0){
		    					print "match $file\n";
								$match = 1;
								$elminateDuplicates{$file}++;
							}

#							last;
						}
				    }
				    foreach my $criteria (@blacklistnfoCriteria) {
						if ($line =~ m%$criteria%){
	    					print "blacklist $file\n";
							$match = 0;
							last;
						}
				    }

#				    last if $match;

				}
				close (NFO);
				next unless $match;
				if ($file =~ m%/tvshow\.strm$%){
					$file =~ s%/tvshow\.strm%/%;
				}
    		}else{
				next unless ($file =~ m%\.strm$%);
			}
			#$file =~ s%\&%\&amp;%g;
			print "matched $file \n";
			my $cleanPath = $file;
			$cleanPath =~  s%\&%\&amp;%g;
			$cleanPath =~  s%\/\/%\/%g;
			$cleanPath =~  s%\/$%%;
			print XML <<EOF
    <CollectionItem>
      <Path>$cleanPath</Path>
    </CollectionItem>
EOF
		}

	}
	closedir $dh;
	}
	}

}
print XML <<EOF;
  </CollectionItems>
</Item>
EOF

	close(XML);
