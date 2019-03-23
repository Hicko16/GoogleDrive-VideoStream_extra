#!/usr/bin/perl

###
##
## The purpose of this script is to create a list of user update records
###

use Getopt::Std;		# and the getopt module

use constant USAGE => $0 . "  -i sql_dump -o outputfile\n\t -v is verbose\n";


my %opt;
die (USAGE) unless (getopts ('i:o:vl:',\%opt));

# directory to scan
my $output = $opt{'o'};
my $input = $opt{'i'};


my $isVerbose = 0;
if (defined($opt{'v'})){
	$isVerbose = 1;
}

my $logfile = $opt{'l'};

if ($output eq ''){
	die (USAGE);
}



# some checks
if (!(-e $input)){
	die ("input file does not exist " . $input);
}

open(INPUT,$input) or die ("Cannot open $input ".$!);
open(OUTPUT,'>' . $output) or die ("Cannot open $output ".$!);
#open(LOGFILE, '>'. $logfile) or die ("Cannot create $logfile" . $!) if $logfile ne '';
print OUTPUT "begin transaction;";

my @listOfTables = ('metadata_item_views','view_settings','library_section_permissions','plugin_permissions','metadata_item_settings','media_item_settings','media_part_settings','play_queues','metadata_item_accounts','statistics_bandwidth','statistics_media');

$count=0;

while(my $line =<INPUT>){
	foreach (@listOfTables){
		if ($line =~ m%INSERT INTO "$_"%){

			print OUTPUT $line;
			$count++;
			if ($count == 100){
				$count = 0;
				print OUTPUT "commit; begin transaction;";

			}
		}

	}

}
print OUTPUT "commit;";

close(INPUT);
close(OUTPUT);



