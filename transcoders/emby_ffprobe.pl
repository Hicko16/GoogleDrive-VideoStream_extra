#!/usr/bin/perl

use constant PATH_TO_EMBY_FFMPEG => '/opt/emby-server/bin/';

use constant FILTER_PGS => 1;

use constant PROXY_DETERMINATOR => 'sofasttv';
use constant PROXY => 'http:// :8888';


my $pidi=0;


use constant LOGFILE => '/tmp/transcode.log';

my $FFPROBE_OEM = PATH_TO_EMBY_FFMPEG.'/ffprobe.oem ';
#my $FFPROBE_OEM = 'ffprobe ';

my $PROXY = PROXY;
my $PROXY_DETERMINATOR = PROXY_DETERMINATOR;


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

if ($arglist =~ m%$PROXY_DETERMINATOR%){
	print LOG "running PROXY " . $FFPROBE_OEM . ' ' . $arglist  . "\n";
	$FFPROBE_OEM .= " -http_proxy $PROXY "
}else{
	print LOG "running " . $FFPROBE_OEM . ' ' . $arglist  . "\n";
}

$pid = open ( LS, '-|', $FFPROBE_OEM . ' ' . $arglist . ' 2>&1');
my $output = do{ local $/; <LS> };
close LS;

my $line= '';
my $skip = 0;

my $index = 0;
my @index;
my $current=0;
my $stdout=0;
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
		$stdout = 1;
		$skip = 0;
	}


	if ($skip == 0){
		if ($stdout){
			print STDOUT $line . "\n"
		}else{
			print STDERR $line . "\n"
		}
		print LOG $line  . "\n";
	}elsif ($skip == 2){
		$skip =0;
	}else{
		print LOG "SKIP -> " . $line  . "\n";
	}

}

close(LOG);
#print $output;

