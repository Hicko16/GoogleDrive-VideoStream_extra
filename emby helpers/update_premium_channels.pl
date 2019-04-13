#!/usr/bin/perl

###
##
## The purpose of this script is to fetch all TVHclient and mark them with a premium tag
##
##
###

use Getopt::Std;		# and the getopt module
use File::Copy;

use File::Basename;
use lib dirname (__FILE__) ;
require '../crawler.pm';

use constant USAGE => $0 . "-i IP -p 8096 -a api_key -f file\n";


my %opt;
die (USAGE) unless (getopts ('i:p:a:f:',\%opt));

my $IP =  $opt{'i'};
$IP = '127.0.0.1' if $IP eq '';
my $port =  $opt{'p'};
my $apiKey = $opt{'a'};
my $file = $opt{'f'};



die(USAGE) if ($port eq '' or $apiKey eq '');


my $url = 'http://'.$IP.':'.$port.'/emby/LiveTv/Channels?Fields=ProviderIds&api_key='.$apiKey;
my @array;
TOOLS_CRAWLER::ignoreCookies();
my @results = TOOLS_CRAWLER::complexGET($url,'',[''],[''],['"Id":"', '"', '","Number":"\d+","ChannelNumber":"\d+","ProviderIds":\{"ExternalServiceId":"Emby"\}']);
#my @results = TOOLS_CRAWLER::returnWEB($url,$file,[''],[''],['\{"Name":"', '"\}', '"\}']);
my $results = TOOLS_CRAWLER::returnGET($url);
#print $results;
#print $results;
#print $results;
while (<$results>){
	print $_;
	#my ($entry) = <$results>;
	#last if $entry eq '';
	#$results =~ s%$entry%%;
	#print "\n\nENTRY ".$entry . "\n";

}


#{"Name":"Syria TV","ServerId":"32654fdf89a942218c9313154551738c","Id":"595696","Number":"73750","ChannelNumber":"73750","ProviderIds":{"ExternalServiceId":"Emby"},"IsFolder":false,"Type":"TvChannel","ImageTags":{},"BackdropImageTags":[],"MediaType":"Video"}


while ($results =~ m%\{"Name":"[^\"]+","ServerId":"[^\"]+","Id":"([^\"]+)","Number":"[^\"]+","ChannelNumber":"[^\"]+","ProviderIds":\{"ExternalServiceId":"Emby"\},"IsFolder":false,"Type":"TvChannel","ImageTags":\{\},"BackdropImageTags":\[\],"MediaType":"Video"\}%){
	my ($name,$id) = $results =~ m%\{"Name":"([^\"]+)","ServerId":"[^\"]+","Id":"([^\"]+)","Number":"[^\"]+","ChannelNumber":"[^\"]+","ProviderIds":\{"ExternalServiceId":"Emby"\},"IsFolder":false,"Type":"TvChannel","ImageTags":\{\},"BackdropImageTags":\[\],"MediaType":"Video"\}%;
	#my ($record) = $results =~ m%(\{"Name":"[^\"]+","ServerId":"[^\"]+","Id":"[^\"]+","Number":"[^\"]+","ChannelNumber":"[^\"]+","ProviderIds":\{"ExternalServiceId":"Emby"\},"IsFolder":false,"Type":"TvChannel","ImageTags":\{\},"BackdropImageTags":\[\],"MediaType":"Video"\})%;

	my $genre='[]';
	if ($name =~ m%SPORT%){
		$genre = '["Sports"]';
	}
	my $record = '{"AirDays":[],"AirTime":"","AirsAfterSeasonNumber":"","AirsBeforeEpisodeNumber":"","AirsBeforeSeasonNumber":"","Album":"","AlbumArtists":[],"ArtistItems":[],"AspectRatio":"","CommunityRating":"","CriticRating":"","CustomRating":"","DateCreated":"2019-04-08T04:00:00.000Z","DisplayOrder":"","EndDate":null,"ForcedSortName":"","Genres":'.$genre.',"Id":"'.$id.'","IndexNumber":null,"LockData":false,"LockedFields":[],"Name":"'.$name.'","OfficialRating":"","OriginalTitle":"","Overview":"","ParentIndexNumber":null,"PreferredMetadataCountryCode":"","PreferredMetadataLanguage":"","PremiereDate":null,"ProductionYear":"","ProviderIds":{"ExternalServiceId":"Emby"},"Status":"","Studios":[],"Taglines":[],"Tags":["premium"],"Video3DFormat":""}';

	#$record =~ s%"ProviderIds":\{"ExternalServiceId":"Emby"\},%"ProviderIds":\{"ExternalServiceId":"Emby"\},"Tags":\["premium"\],%;
	my $url = 'http://'.$IP.':'.$port.'/emby/Items/'.$id.'?api_key='.$apiKey;

	my @response;
	#if ($name =~ m%UTV%){
			print STDERR "ID = $id\n";

		@response = TOOLS_CRAWLER::complexJSONPOST($url,'',[''],[''],(['<ddd','<','<']),$record);
		print "record = $record\n";
		print @response;
	#}
	$results =~ s%\{"Name":"[^\"]+","ServerId":"[^\"]+","Id":"[^\"]+","Number":"[^\"]+","ChannelNumber":"[^\"]+","ProviderIds":\{"ExternalServiceId":"Emby"\},"IsFolder":false,"Type":"TvChannel","ImageTags":\{\},"BackdropImageTags":\[\],"MediaType":"Video"\}%%;


}


for (my $i=3; $i <$#results; $i=$i+2){
	#if ($results[$i] > 290018){
#		print "results=". $results[$i] . "\n";
		my $url = 'http://'.$IP.':'.$port.'/emby/Items/'.$results[$i].'?api_key='.$apiKey;
		#my @results = TOOLS_CRAWLER::complexJSONPOST($url,'',[''],[''],(['<ddd','<','<']),'{"Genres":["premium"],"ProviderIds":{"ExternalServiceId":"Emby"},"Tags":["premium"]}');
		#my @results = TOOLS_CRAWLER::complexJSONPOST($url,'',[''],[''],(['<ddd','<','<']),'{"ProviderIds":{"ExternalServiceId":"Emby"},"Tags":["premium"]}');
		#print STDOUT "processing ...".$url ."\n";
#	}


}








