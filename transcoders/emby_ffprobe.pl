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

use constant LOGFILE => '/tmp/transcode.log';

my $FFPROBE_OEM = PATH_TO_EMBY_FFMPEG.'/ffprobe.oem ';
my $FFPROBE_OEM = 'ffprobe ';



sub createArglist(){
	my $arglist = '';
	foreach my $current (0 .. $#ARGV) {
		if ($ARGV[$current] =~ m%\s% or $ARGV[$current] =~ m%\(% or $ARGV[$current] =~ m%\)% or $ARGV[$current] =~ m%\&%){
	   		$arglist .= ' "' .$ARGV[$current] . '"';
		}else{$arglist .= ' ' .$ARGV[$current];}
	}
	return $arglist;

}

$arglist = createArglist();

open (LOG, '>>' . LOGFILE) or die $!;
print LOG "passed in $arglist\n";

print LOG "running " . $FFPROBE_OEM . ' ' . $arglist  . "\n";

$pid = open ( LS, '-|', $FFPROBE_OEM . ' ' . $arglist . ' 2>&1');
my $output = do{ local $/; <LS> };
close LS;

my $line= '';
my $skip = 0;

my $index = 0;
my @index;
my $current=0;
my $printOutput=0;
while(($line) = $output =~ m%^(.*?)\n%){
	$output =~ s%^.*?\n%%;
	if (FILTER_PGS and $line =~ m%hdmv_pgs_subtitle% and $line =~ m%Stream \#%){
		$skip = 1;
		$index[$index] = 1
	}elsif(FILTER_PGS and ($line =~ m%Stream \#%)){
		$skip = 0;
	}
	if ($line =~ m%Stream \#%){
		$index++;
	}

	if ($line =~ m%^        \{%){
		if ($index[$current] == 1){
			$skip = 1;
		}
		$current++;
	}elsif ($skip == 1 and $line =~ m%^        \}%){
		$skip = 2;
	}elsif ($line =~ m%^\{%){
		$printOutput = 1;
		$skip = 0;
	}


	if ($skip == 0){
		print STDERR $line . "\n" if $printOutput;
		print LOG $line  . "\n";
	}elsif ($skip == 2){
		$skip =0;
	}else{
		print LOG "SKIP -> " . $line  . "\n";
	}

}

close(LOG);
#print $output;

