#!/usr/bin/perl

use constant PATH_TO_EMBY_FFMPEG => '/opt/emby-server/bin/';

use constant FILTER_PGS => 1;

my $pidi=0;

$SIG{QUIT} = sub {  kill 'KILL', $pid;die "Caught a quit $pid $!"; };
$SIG{TERM} = sub {  kill 'KILL', $pid;die "Caught a term $pid $!"; };
$SIG{INT} = sub {  kill 'KILL', $pid;die "Caught a int $pid $!"; };
$SIG{HUP} = sub {  kill 'KILL', $pid;die "Caught a hup $pid $!"; };
$SIG{ABRT} = sub {  kill 'KILL', $pid;die "Caught a abrt $pid $!"; };
$SIG{TRAP} = sub {  kill 'KILL', $pid;die "Caught a trap $pid $!"; };
$SIG{STOP} = sub {  kill 'KILL', $pid;die "Caught a stop $pid $!"; };

my $FFPROBE_OEM = PATH_TO_EMBY_FFMPEG.'/ffprobe.oem ';
#my $FFPROBE_OEM = 'ffprobe ';



sub createArglist(){
	my $arglist = '';
	foreach my $current (0 .. $#ARGV) {
		if ($ARGV[$current] =~ m%\s% or $ARGV[$current] =~ m%\(% or $ARGV[$current] =~ m%\)% or $ARGV[$current] =~ m%\&%){
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
foreach my $current (0 .. $#ARGV) {
	# fetch how long to encode
	if ($ARGV[$current] =~ m%\d\d:\d\d:\d\d%){
		my ($hour,$min,$sec) = $ARGV[$current] =~ m%0?(\d+):0?(\d+):0?(\d+)%;
		$duration = $hour*60*60 + $min*60 + $sec;
		$duration_ptr = $current;
	}elsif ($ARGV[$current] =~ m%^htt.*\:9988%){
		$url = $ARGV[$current];
	}elsif (0 and $ARGV[$current] =~ m%\-user_agent%){
		$ARGV[$current++] = '';
		$ARGV[$current] = '';
	}elsif (0 and $ARGV[$current] =~ m%\-fflags%){
		$ARGV[$current++] = '';
		$ARGV[$current] = '';
	}elsif (0 and $ARGV[$current] =~ m%\-f%){
		$ARGV[$current++] = '';
		$ARGV[$current] = '';
	}elsif ($ARGV[$current] =~ m%\.ts%){
		$filename_ptr = $current;
		#$ARGV[$filename_ptr] =~ s%\.\d+\.ts%\.$count\.ts%;
	}elsif ($ARGV[$current] =~ m%\.srt%){
		$isSRT = 1;
	}
}
$arglist = createArglist();

$pid = open ( LS, '-|', $FFPROBE_OEM . ' ' . $arglist . ' 2>&1');
my $output = do{ local $/; <LS> };
close LS;

#my $output = `/u01/ffmpeg-git-20171123-64bit-static/ffmpeg $arglist -v error 2>&1`;
print $FFPROBE_OEM . ' ' . $arglist ;
my $line= '';
my $skip = 0;
while(($line) = $output =~ m%^(.*?)\n%){
	$output =~ s%^.*?\n%%;
	if (FILTER_PGS and $line =~ m%hdmv_pgs_subtitle%){
		$skip = 1;
	}elsif(FILTER_PGS and $line =~ m%Stream \#%){
		$skip = 0;
	}
	if (!($skip)){
		print $line . "\n";
	}

}

#print $output;

