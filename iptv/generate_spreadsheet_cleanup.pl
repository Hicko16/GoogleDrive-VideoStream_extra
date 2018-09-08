#!/usr/bin/perl

###
##
## The purpose of this script is to remove invalid IPTV channels in a M3U file.
## The script takes a provided M3U file (-s) and outputs a copy of the claned-up M3U file (-t).
## The script takes a provided comma delimited list (-l).
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 2;
use constant WEB_TEST => 0;

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . ' -s source.m3u8 -t target.m3u8 (-l list1,list2)';



use LWP::UserAgent;
use LWP;
use IO::Handle;

my %opt;
die (USAGE) unless (getopts ('s:t:l:',\%opt));

# directory to scan
my $source = $opt{'s'};
my $target = $opt{'t'};

die(USAGE) if ($source eq '' or $target eq '');

my $list = $opt{'l'};
my @filter;

while (my ($item) = $list =~ m%^([^\,]+)%){
	$list =~ s%^[^\,]+\,?%%;
	print "item = $item\n";
	push(@filter,$item);

}


 my $ua = new LWP::UserAgent;	# call the constructor method for this object

$ua->agent('Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)');		# set the identity
$ua->timeout(30);		# set the timeout


open (INPUT, $source) or die ("cannot open $source: " + $!);
open (OUTPUT, '> '.$target) or die ("cannot create $target: " + $!);
OUTPUT->autoflush;
my $line = <INPUT>;

my $buffer = '';
my $isSuccess = 0;

my $channel = '';
my $country = '';
my $type = '';
my $skip=0;
while (my $line = <INPUT>){

	$line =~ s%\r%%;
	if ($skip){
		$skip = 0;
		next;
	}
	if ($line =~ m%^\#EXTINF\:\-1%){
		($country,$channel) = $line =~ m%^\#EXTINF\:\-1\,([^\:]+)\: ([^\n]+)%;
		$channel =~ s%\{[^\}]+\}%%;
		$channel =~ s%\([^\)]+\)%%;

		if ($channel =~ m%news%i or $channel =~ m%%i){
			$type = 'news';
		}elsif($channel =~ m%sport%i or $channel =~ m%espn%i or $channel =~ m%nfl% or $channel =~ m%nba%i or $channel =~ m%nhl%){
			$type = 'sports';
		}elsif($channel =~ m%stars%i or $channel =~ m%showtime%i){
			$type = 'movies';
		}else{
			$type = '';
		}

		print "$country $channel $type\n";
	}

	if ($line =~ m%^\#%){
		next;
	}

	my ($URL) = $line =~ m%([^\n]+)\n%;
	# Create a user agent object

	my $req = new HTTP::Request GET => $URL;
	$req->protocol('HTTP/1.1');

	for (my $i=0; $i <= RETRY; $i++){
		if (WEB_TEST){
			my $res = $ua->request($req);

			if($res->is_success){
			  		print STDOUT "success --> $URL\n";
					print OUTPUT "\t1\t$country\t$channel\t$type\t$line\n";
					last;
					$isSuccess = 1;
			}elsif ($i == RETRY){
				print STDOUT "failed --> $URL\n";
				print OUTPUT "\t0\t$country\t$channel\t$type\n";
			}
		}else{
					print OUTPUT "\t1\t$country\t$channel\t$type\t$line\n";
					last;
					$isSuccess = 1;

		}
	}

}
close(OUTPUT);
close(INPUT);




1;


