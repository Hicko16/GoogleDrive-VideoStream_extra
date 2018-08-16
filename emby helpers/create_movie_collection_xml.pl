#!/usr/bin/perl

###
##
## The purpose of this script is to create a movie collection by symlinking.
##
## The input is a txt file of the form"movie<tab>year
##
####

use Getopt::Std;		# and the getopt module
use File::Copy;



my %opt;
die (USAGE) unless (getopts ('i:q:s:c:t:',\%opt));

# directory for backups
my $inputSpreadsheet  = $opt{'i'};
my $quality =  $opt{'q'};
if ($quality eq '' and $inputSpreadsheet eq ''){
	die("either quality or a spreadsheet for input is required");
}

my $sourceDirectory =  $opt{'s'};
my $targetDirectory =  $opt{'t'};
my $collectionName =  $opt{'c'};

my $minQuality = 0;
my $maxQuality = 9999;
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
	die("invalid quality: $quality");
}

# some checks
if (!(-e $targetDirectory)){
	die ("target does not exist " . $targetDirectory);
}
if (!(-e $sourceDirectory)){
	die ("source does not exist " . $sourceDirectory);
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

print XML <<EOF;
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Item>
  <ContentRating>PG</ContentRating>
  <Added>8/16/18 2:05:44 AM</Added>
  <LockData>false</LockData>
  <Overview>When a power-crazed despot schemes to buy California from Mexico, it takes two Zorros--the legendary Don Diego de la Vega (Anthony Hopkins) and his chosen successor Alejandro Murrieta (Antonio Banderas), a dashing bandit-turned-hero--to defeat the tyrant's unscrupulous plans. The original caped crusader is back! Antonio Banderas and Catherine Zeta-Jones return for more swashbuckling action, adventure and excitement in THE LEGEND OF ZORRO!</Overview>
  <LocalTitle>Zorro Collection</LocalTitle>
  <PremiereDate>1998-07-16</PremiereDate>
  <DisplayOrder>PremiereDate</DisplayOrder>
  <ProductionYear>1998</ProductionYear>
  <TmdbId>1657</TmdbId>
  <Genres>
    <Genre>Action</Genre>
    <Genre>Adventure</Genre>
  </Genres>
  <Studios>
    <Studio>TriStar Pictures</Studio>
    <Studio>Amblin Entertainment</Studio>
    <Studio>Columbia Pictures</Studio>
  </Studios>
  <CollectionItems>
EOF

if ($inputSpreadsheet ne ''){

open(INPUT,$inputSpreadsheet) or die ("Cannot open $inputSpreadsheet ".$!);



while(my $line =<INPUT>){

#    <CollectionItem>
#      <Path>/u01/STRM/movies/the mask of zorro(1998)/the mask of zorro(1998) - original 1080p.strm</Path>
#    </CollectionItem>
	my ($title, $year) = $line =~ m%([^\t]+)\t([^\t]+)\n%;
	my $source = "$sourceDirectory/$title($year)";
	opendir my $dh, $source or next;


	closedir $dh;

	my $target = "$targetDirectory/$title($year)";
	if (-e $source and !(-e $target)){
		symlink ($source, $target);
		print "create symlink for $target\n";
	}

}

print XML <<EOF;
s
  </CollectionItems>
</Item>
EOF

close(INPUT);
close(XML);
}else{
	opendir my $dh, $sourceDirectory or die("cannot open $sourceDirectory");

	while (my $folder = readdir $dh) {
		next if $folder eq '.' or $folder eq '..';


    	print "folder $folder\n";
    	next unless -d "$sourceDirectory/$folder";
		opendir my $dh2, "$sourceDirectory/$folder" or die("cannot open $sourceDirectory/$folder");
		while (my $file = readdir $dh2) {
			next if $file eq '.' or $file eq '..';
    		print "file $file\n";
			my ($q) = $file =~ m% (\d+)p%;
			next if $q == 0;
			next if $q > $maxQuality or $q < $minQuality;
			next unless ($file =~ m%\.strm$%);
			#$file =~ s%\&%\&amp;%g;
			print "matched $file \n";
			my $cleanPath = "$sourceDirectory/$folder/$file";
			$cleanPath =~  s%\&%\&amp;%g;
			print XML <<EOF
    <CollectionItem>
      <Path>$cleanPath</Path>
    </CollectionItem>
EOF
		}
		closedir $dh2;

	}
	closedir $dh;

	print XML <<EOF;
  </CollectionItems>
</Item>
EOF

	close(XML);
}

