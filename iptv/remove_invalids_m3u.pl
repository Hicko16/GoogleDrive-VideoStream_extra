#!/usr/bin/perl

###
##
## The purpose of this script is to remove invalid IPTV channels in a M3U file.
## The script takes a provided M3U file (-s) and outputs a copy of the claned-up M3U file (-t).
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 2;

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . ' -s source.m3u8 -t target.m3u8';



use LWP::UserAgent;
use LWP;
use IO::Handle;

my %opt;
die (USAGE) unless (getopts ('s:t:',\%opt));

# directory to scan
my $source = $opt{'s'};
my $target = $opt{'t'};



 my $ua = new LWP::UserAgent;	# call the constructor method for this object

$ua->agent('Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)');		# set the identity
$ua->timeout(30);		# set the timeout


open (INPUT, $source) or die ("cannot open $source: " + $!);
open (OUTPUT, '> '.$target) or die ("cannot create $target: " + $!);
OUTPUT->autoflush;
my $line = <INPUT>;
print OUTPUT $line;
my $buffer = '';
my $isSuccess = 0;
while (my $line = <INPUT>){

	$buffer .= $line;

	if ($line =~ m%^\#%){
		next;
	}

	my ($URL) = $line =~ m%([^\n]+)\n%;
	# Create a user agent object

	my $req = new HTTP::Request GET => $URL;
	$req->protocol('HTTP/1.1');

	for (my $i=0; $i <= RETRY; $i++){
		my $res = $ua->request($req);


		if($res->is_success){
		  		print STDOUT "success --> $URL\n";
				print OUTPUT $buffer;
				last;
				$isSuccess = 1;
		}elsif ($i == RETRY){
			print STDOUT "failed --> $URL\n";
		}
	}
	$buffer = '';

}
close(OUTPUT);
close(INPUT);




1;

