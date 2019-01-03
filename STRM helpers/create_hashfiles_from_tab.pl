#!/usr/bin/perl

###
##
## The purpose of this script is to create hash files from STRM tabs
###

use Getopt::Std;		# and the getopt module


my %opt;
die (USAGE) unless (getopts ('m:f:o:',\%opt));

# list of files
my $fileList = $opt{'f'};
my $mainfile = $opt{'m'};
# output files
my $outputfiles = $opt{'o'};
my @files = split(',', $fileList);

my %mainAssignment;
my %hashMatches;
my $count = 0;



foreach my $file (@files) {
	open(INPUT,$file) or die ("Cannot open $file ".$!);
	my %tmpAssignment;
	while(my $line =<INPUT>){
		my ($fileID,$fileName, $movieTitle, $movieYear, $resolution, $hash) = $line =~ m%^[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t[^\t]*%;
		#print ".$fileID";
		if ($fileID ne '' and $hash ne '' and $tmpAssignment{$fileID} eq ''){
			$tmpAssignment{$fileID} = $hash;
			push @{$hashMatches{$hash}}, $fileID;
		}
	}
	if ($count == 0){
		%mainAssignment = %tmpAssignment;
		$count++;
	}

	close(INPUT);
}

foreach my $key (keys %hashMatches) {
	print "for key $key ";
	for (my $i=0; $i < $#{$hashMatches{$key}}; $i++){
		print $hashMatches{$key}[$i] . ' ';
	}
	print "\n";
}


open(OUTPUT,'>' . $outputfiles . '.main') or die ("Cannot open $outputfiles.main ".$!);
foreach my $key (keys %mainAssignment) {
	print OUTPUT $key . ',' . $mainAssignment{$key} . "\n";
}
close(OUTPUT);

open(OUTPUT,'>' . $outputfiles . '.hashes') or die ("Cannot open $outputfiles.hashes ".$!);
foreach my $key (keys %hashMatches) {
	print OUTPUT $key . ',';
	print OUTPUT $hashMatches{$key}[0];
	for (my $i=1; $i < $#{$hashMatches{$key}}; $i++){
		print OUTPUT '|'.$hashMatches{$key}[$i];
	}
	print OUTPUT "\n";

}
close(OUTPUT);




