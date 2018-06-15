#!/usr/bin/perl

use File::Copy qw(move);

# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 50;

# block subtitle remuxing?
use constant BLOCK_SRT => 1;

# block 4K video encoding requets
use constant BLOCK_TRANSCODE => 1;

# prefer to drop 4K to Google Transcode for 4k video encoding requests
use constant GOOGLE_TRANSCODE => 1;

# prefer to direct stream requests with Google Transcode feeds (will reduce CPU load)
use constant PREFER_GOOGLE_TRANSCODE => 1;

use constant PATH_TO_TRANSCODER => '"/usr/lib/plexmediaserver/Plex Transcoder.oem"';

use constant LOGFILE => '/tmp/transcode.log';

my $pidi=0;

$SIG{QUIT} = sub {  kill 'KILL', $pid;die "Caught a quit $pid $!"; };
$SIG{TERM} = sub {  kill 'KILL', $pid;die "Caught a term $pid $!"; };
$SIG{INT} = sub {  kill 'KILL', $pid;die "Caught a int $pid $!"; };
$SIG{HUP} = sub {  kill 'KILL', $pid;die "Caught a hup $pid $!"; };
$SIG{ABRT} = sub {  kill 'KILL', $pid;die "Caught a abrt $pid $!"; };
$SIG{TRAP} = sub {  kill 'KILL', $pid;die "Caught a trap $pid $!"; };
$SIG{STOP} = sub {  kill 'KILL', $pid;die "Caught a stop $pid $!"; };

my $PATH_TO_TRANSCODER = PATH_TO_TRANSCODER;


sub createArglist(){
	my $arglist = '';
	foreach my $current (0 .. $#ARGV) {
		#if ($ARGV[$current] =~ m%^\-% and !( $ARGV[$current] =~ m%exp%)){
	   	#	$arglist .= ' ' .$ARGV[$current];
		#}else{
	   	#	$arglist .= ' "' .$ARGV[$current] . '"';
		#}
		if ($ARGV[$current] =~ m%\s% or $ARGV[$current] =~ m%\(% or $ARGV[$current] =~ m%\)% or $ARGV[$current] =~ m%\&% or $ARGV[$current] =~ m%\[% or $ARGV[$current] =~ m/%/ or $ARGV[$current] =~ m/=/){
	   		$arglist .= ' "' .$ARGV[$current] . '"';
		}else{$arglist .= ' ' .$ARGV[$current];}

	}
	return $arglist;

}

my $start = time;
my $duration = 0;
my $duration_ptr = -1;
my $arglist = '';
my $filename_ptr = 0;
my $count = 1;
my $renameFileName = '';
my $isSRT = 0;
my $url = '';
my $replace=1;
my $seek = '';
my $originalvideo  = '';
my $srtfile = '';
my $video = 'http://premium1.monkeydevices.com:9988/default.py?kv=1jlVj9dwEJIxmjWMA4v---AHT0OnG2UTMISmpWdyZjhHewxGUtLClxyG92GEg4sZ8AX2ZCaPJwEOmXa3Da57ejW99Z2MWzePSdAyBgRQ0ZGOg+e7vIrqX7V5kYCEeWMeVzE8DqZrtipfCLHSeJsJf+v9vEhg6nu7WefDoF2GRDokW9vLzY9CB5YtyiXaWGepeB97hILy---IxXJ---G38VSfUXRDL---4o7iJOrAa0pXRlhO3RcXW+t8A6NhiOJ875P2suTGrQXAU6TBgTphX4suflRKeNaYZSMy2o7v5m1QAh41aLRXMaF4YeIbsNNI5y8QNM6oJVIPmDgCtdpIhCxUdBPeVFcEMxGjsCViYCczVSGDNGNhp2DNXzqr5ql6I2mS5v28WMLm5Br3SBD8X8+gVeERgA==';
foreach my $current (0 .. $#ARGV) {
	# fetch how long to encode
	if ($ARGV[$current] =~ m%\d\d:\d\d:\d\d%){
		my ($hour,$min,$sec) = $ARGV[$current] =~ m%0?(\d+):0?(\d+):0?(\d+)%;
		$duration = $hour*60*60 + $min*60 + $sec;
		$duration_ptr = $current;
	}elsif ($replace and  $ARGV[$current] =~ m%\-ss%){
		$ARGV[$current++] = '-ss';
		$seek = $ARGV[$current];
	}elsif ($replace==1 and  $ARGV[$current] =~ m%\-i%){
		$ARGV[$current++] = '-i';
		$originalvideo = $ARGV[$current];
		#$ARGV[$current] = $video;
		$replace = 2;
	}elsif ($replace ==2 and  $ARGV[$current] =~ m%\-i%){
		$ARGV[$current++] = '-i';
		if  ($ARGV[$current] ne '0'){
			$srtfile = '-i "' . $ARGV[$current] . '" ';
		}
		$replace = 3;
		#$ARGV[$current] = $video;
	}
}
$arglist = createArglist();

open (LOG, '>>' . LOGFILE) or die $!;
print LOG "passed in $arglist\n";

#$arglist =~ s%\-codec\:0 \S+%\-codec\:0 h264%;
#$arglist =~ s%\-codec\:1 \S+%\-codec\:1 aac%;

if ($srtfile ne '' and $seek ne ''){
	$srtfile = '-ss ' . $seek . ' ' . $srtfile;

}

my $audio = '';
if ($arglist =~ m%\-codec\:0 aac%){
	$arglist =~ s%\-codec\:0 aac%\-codec\:1 aac%;
	$audio = '-i "/u01/recordings/test3.aac"';

}elsif ($arglist =~ m%\-codec\:\#0x100 aac%){
	#$arglist =~ s%\-codec\:0 aac%\-codec\:1 aac%;
	$arglist =~ s%\-codec\:\#0x100 aac%\-codec\:\#0x101 aac%;
	$audio = '-i "/u01/recordings/test3.aac"';
}elsif ($arglist =~ m%map 0\:\#0x100%){
	$arglist =~ s%map 0\:\#0x100%map 0\:\#0x101%;
	$audio = '-i "/u01/recordings/test3.aac"';
}elsif ($arglist =~ m%map 0\:0 \-metadata%){
	$arglist =~ s%map 0\:1 \-metadata%map 0\:0 \-metadata%;
	$audio = '-i "/u01/recordings/test3.aac"';

}

if ($audio ne '' and $seek ne ''){
	$audio = '-ss ' . $seek . ' ' . $audio;

}

if (PREFER_GOOGLE_TRANSCODE){

	if ($arglist =~ m%scale\=w\=1280\:h\=720%){
		$video .= '&preferred_quality=1&override=true';
	}elsif ($arglist =~ m%scale\=w\=720\:h\=406%){
		$video .= '&preferred_quality=2&override=true';
	}elsif ($arglist =~ m%scale\=w\=1920\:h\=1080%){
		$video .= '&preferred_quality=0&override=true';
	}elsif ($arglist =~ m%scale\=w\=3840\:h\=2160% or $arglist =~ m%scale\=w\=3840\:h\=2026%){
		$video .= '&preferred_quality=2&override=true';
	}else{
#		$video .= '&preferred_quality=3&override=true';

		$video .= '&preferred_quality=0&override=true';
	}
}
if ($arglist =~ m% dash %){
	if ($audio ne ''){
		$arglist =~ s%\-i .* -f dash%\-i "$video" $audio $srtfile \-codec\:v\:0 copy \-copyts \-vsync \-1 \-codec\:a aac \-map 0\:v \-map 1\:a \-f dash%;
		$arglist =~ s%map 1:s:0 %map 2:s:0 %;
	}else{
		$arglist =~ s%\-i .* -f dash%\-i "$video" $srtfile \-codec\:v\:0 copy \-copyts \-vsync \-1 \-codec\:a\:0 copy \-copypriorss\:a\:0 0 \-f dash%;
	}

}elsif ($arglist =~ m%\-segment_format mpegts %){
	if ($audio ne ''){
		if ($srtfile ne ''){
		$arglist =~ s%\-i .* \-segment_format mpegts \-f ssegment %\-i "$video" $srtfile $audio \-codec\:v\:0 copy \-copyts \-vsync \-1 \-codec\:a aac \-map 0\:v \-map 2\:a \-segment_format mpegts \-f ssegment %;
		}else{
			$arglist =~ s%\-i .* \-segment_format mpegts \-f ssegment %\-i "$video" $audio \-codec\:v\:0 copy \-copyts \-vsync \-1 \-codec\:a aac \-map 0\:v \-map 1\:a \-segment_format mpegts \-f ssegment %;

		}
	}else{
		$arglist =~ s%\-i .* \-segment_format mpegts \-f ssegment %\-i "$video" $srtfile \-codec\:v\:0 copy \-copyts \-vsync \-1 \-codec\:a\:0 copy \-copypriorss\:a\:0 0 \-segment_format mpegts \-f ssegment %;
	}
#	$arglist =~ s%\-i .* \-segment_format mpegts \-f ssegment %\-i "$video" \-codec\:v\:0 copy \-copyts \-vsync \-1 \-codec\:a\:0 copy \-copypriorss\:a\:0 0 \-segment_format mpegts \-f ssegment %;
}elsif ($arglist =~ m%\-segment_format matroska %){
	$arglist =~ s%\-i .* \-f segment \-segment_format matroska .* -segment_list %\-i "$video" \-codec\:v\:0 copy \-copyts \-vsync \-1 \-codec\:a\:0 copy \-copypriorss\:a\:0 0 -segment_format matroska -f ssegment -individual_header_trailer 0 -segment_time 1 -segment_start_number 128 -segment_copyts 1 -segment_time_delta 0.0625 -segment_list %;
#	$arglist =~ s%\-f segment \-segment_format matroska %\-codec\:v\:0 copy \-copyts \-vsync \-1 \-codec\:a\:0 copy \-copypriorss\:a\:0 0 \-f segment \-segment_format matroska %;
	#$arglist =~ s/chunk\-\%05d/media\-\%05d\.ts/;

}

if (0 and $arglist =~ m%\-codec\:\#0x02 aac%){
	$arglist =~ s%\-codec\:\#0x02 aac%\-codec\:\#0x01 aac%;
	$arglist =~ s%\-codec:a:0 copy%-i "/u01/recordings/test.m4a" \-codec:a:0 copy%;

}


$arglist =~ s%\-loglevel quiet \-loglevel_plex error%%;
#$arglist =~ s%\-segment_format_options live=1 %%;


print LOG "$PATH_TO_TRANSCODER $arglist\n\n";
close(LOG);
print "$PATH_TO_TRANSCODER $arglist \n\n";

`$PATH_TO_TRANSCODER $arglist 2>/tmp/testrun`;




