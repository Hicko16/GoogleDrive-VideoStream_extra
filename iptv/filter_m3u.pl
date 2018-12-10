#!/usr/bin/perl

###
##
## The purpose of this script is to remove invalid IPTV channels in a M3U file.
## The script takes a provided M3U file (-s) and outputs a copy of the claned-up M3U file (-t).
###
# number of times to retry when ffmpeg encounters network errors
use constant RETRY => 2;

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . " -s source.m3u8 -t target.m3u8 (-w whitelist1,,whitelist2) (-c) (-v)\n where -v enabled removing VOD and -c enabled web check to validate URL\n double comma (,,) is used to split entries in the whitelist";



use LWP::UserAgent;
use LWP;
use IO::Handle;


my %opt;
die (USAGE) unless (getopts ('s:t:w:vc',\%opt));

# directory to scan
my $source = $opt{'s'};
my $target = $opt{'t'};
my @filters = split(',,', $opt{'w'});
my @blacklist;
my $isWebCheck = 1 if defined($opt{'c'});
my $isRemoveVOD = 1 if defined($opt{'v'});

if ($isRemoveVOD){
	@blacklist = ('MatchCenter','24/7','²⁴/⁷');
}

die (USAGE) if ($source eq '' or $target eq '');


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

	#remove carriage return
	$line =~ s%\r%%;
	$buffer .= $line;


	if ($line =~ m%^\#%){

		next if $#filters == -1 and $#blacklist == -1;

		if ($#blacklist != -1){
			my $include = 1;
	  		foreach my $filter(@blacklist) {
	  			if ($line =~ m%$filter%){
	  				print "blacklist $filter $line\n";
	  				$include = 0; next;
	  			}
	  		}
	  		if ($include == 0){
		  		$line = <INPUT>;
		  		$buffer = '';
		  		next;
	  		}

		}

  		next if $#filters == -1;
		my $include = 0;
  		foreach my $filter(@filters) {

  			if ($line =~ m%$filter%){
  				print "filter $filter $line\n";
  				$include = 1; next;
  			}
  		}
  		#not in our whitelist list filter, don't include
  		if ($include == 0){
	  		$line = <INPUT>;
	  		$buffer = '';
	  		#print "blank $line\n";
  		}
		next;

	}
	my ($URL) = $line =~ m%([^\n]+)\n%;
	# Create a user agent object

	my $req = new HTTP::Request GET => $URL;
	$req->protocol('HTTP/1.1');

	for (my $i=0; $i <= RETRY; $i++){
		if ($isWebCheck){
			my $res = $ua->request($req);#, , ('Range' => 'bytes=0-80'));

			if($res->is_success){
					#if ($res->content() ne ''){
			  		print STDOUT "success --> $URL\n";
					print OUTPUT $buffer;
					last;
					$isSuccess = 1;
					#}
			}elsif ($i == RETRY){
				print STDOUT "failed --> $URL\n";
			}
		}else{
					print OUTPUT $buffer;
					last;

		}
	}
	$buffer = '';

}
close(OUTPUT);
close(INPUT);




1;


