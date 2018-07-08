#!/usr/bin/perl

use File::Path qw(make_path);
use File::Copy;


use constant LOGFILE => '/tmp/recordings.log';
use constant ROOT_RECORDING => '/u01/recordings/';
use constant ROOT_UPLOADING => '/u01/upload.gd/media/recordings/';



my $ROOT_RECORDING = ROOT_RECORDING;

# get total arg passed to this script
my $total = $#ARGV + 1;
my $counter = 1;


# get script name
my $scriptname = $0;

open (LOG, '>>' . LOGFILE) or die $!;


my $recordingFile = $ARGV[0];

my ($path, $filename) = $recordingFile =~ m%^$ROOT_RECORDING(.*?)/([^/]+).ts$%;

print LOG "path = $path, file = $filename\n";


#make the path
make_path(ROOT_UPLOADING . "/$path/");

my @oldFiles = glob $ROOT_RECORDING . '/'. $filename . '*';
print LOG "searching " .  $ROOT_RECORDING . '/'. $filename . '*' . "\n";
foreach my $oldFile (@oldFiles){
	my ($shortFilename) = $oldFile =~ m%\/([^\/]+)$%;
	my $newFile = ROOT_UPLOADING . "/$path/" . $shortFilename;
	move($oldFile, $newFile)
}



close(LOG);


