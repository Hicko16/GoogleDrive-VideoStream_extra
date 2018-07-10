#!/usr/bin/perl

use File::Path qw(make_path);
use File::Copy;


use constant LOGFILE => '/tmp/recordings.log';
use constant ROOT_RECORDING => '/u01/recordings/';
use constant ROOT_UPLOADING => '/u01/upload.gd/media/recordings/';
use constant FFMPEG => 'ffmpeg';


my $ROOT_RECORDING = ROOT_RECORDING;
my $FFMPEG = FFMPEG;

# get total arg passed to this script
my $total = $#ARGV + 1;
my $counter = 1;


# get script name
my $scriptname = $0;

open (LOG, '>>' . LOGFILE) or die $!;


my $recordingFile = $ARGV[0];

my ($path, $filename) = $recordingFile =~ m%^$ROOT_RECORDING(.*?)/([^/]+).ts$%;
`$FFMPEG -i "$ROOT_RECORDING/$path/$filename.ts" -c copy "$ROOT_RECORDING/$path/$filename.mp4"`;
print LOG "path = $path, file = $filename\n";


#make the path
make_path(ROOT_UPLOADING . "/$path/");

opendir (my $dh, ROOT_RECORDING . '/'. $path . '/') or die $!;
print LOG "searching " .  ROOT_RECORDING . '/'. $path .  "\n";

while (my $file = readdir($dh)){
    next if $file =~ /^\./;
	move(ROOT_RECORDING . '/'. $path . '/' . $file, ROOT_UPLOADING . '/'. $path . '/' .$file);
}
closedir($dh);


close(LOG);


