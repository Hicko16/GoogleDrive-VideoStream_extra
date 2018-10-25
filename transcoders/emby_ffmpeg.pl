#!/usr/bin/perl

use File::Copy qw(move);
use File::Path qw/make_path/;


use File::Basename;
use lib dirname (__FILE__) ;
require 'config.cfg';

my $RECORDING_DIR = CONFIG->RECORDING_DIR;
my $RECORDING_DIR_UPLOAD = CONFIG->RECORDING_DIR_UPLOAD;


my $pid=0;
my $KILLSIGNAL=0;

#my $FFMPEG_OEM = CONFIG::PATH_TO_EMBY_FFMPEG.'/ffmpeg.oem -timeout 5000000 ';
my $FFMPEG = CONFIG->PATH_TO_EMBY_FFMPEG.'/ffmpeg.oem ';
#these options are not compatible with Emby 3.5.2 or higher
  #my $FFMPEG_TEST = PATH_TO_EMBY_FFMPEG.'/ffmpeg.oem -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 2000 -timeout 5000000 ';
my $FFMPEG_TEST = CONFIG->PATH_TO_EMBY_FFMPEG.'/ffmpeg.oem ';
my $FFMPEG_DVR = 'ffmpeg ';

my $FFPROBE = CONFIG->PATH_TO_EMBY_FFMPEG .'/ffprobe ';
my $PROXY = CONFIG->PROXY;
my $PROXY_DETERMINATOR = CONFIG->PROXY_DETERMINATOR;

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
my $seek = '';
foreach my $current (0 .. $#ARGV) {
	# fetch how long to encode
	if ($ARGV[$current] =~ m%\d\d:\d\d:\d\d%){
		my ($hour,$min,$sec) = $ARGV[$current] =~ m%0?(\d+):0?(\d+):0?(\d+)%;
		$duration = $hour*60*60 + $min*60 + $sec;
		$duration_ptr = $current;
	}elsif ($ARGV[$current] =~ m%^htt.*\:9988% or $ARGV[$current] =~ m%^htt.*\:9989% or $ARGV[$current] =~ m%^htt.*\:9990%){
		$url = $ARGV[$current];
	}elsif (0 and $ARGV[$current] =~ m%\-user_agent%){
		$ARGV[$current++] = '';
		$ARGV[$current] = '';
	}elsif ($ARGV[$current] =~ m%\-ss%){
		$ARGV[$current++] = '-ss';
		$seek = $ARGV[$current];
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
if ($arglist =~ m%file\:\/%){
	exit(0);
}

my $FFMPEG_OEM;
my $ALT_FFMPEG_DETERMINATOR = CONFIG->ALT_FFMPEG_DETERMINATOR;
if ((CONFIG->ALT_FFMPEG) && $arglist =~ m%$ALT_FFMPEG_DETERMINATOR%){
	$FFMPEG_OEM = CONFIG->FFMPEG_OEM_332;
}else{
	$FFMPEG_OEM = CONFIG->FFMPEG_OEM;
}


open (LOG, '>>' . CONFIG->LOGFILE) or die $!;
print LOG "passed in $arglist\n";


# request is for subtitle remuxing
if ($isSRT){

	# block subtitle remuxing requets?
	if (CONFIG->BLOCK_SRT){
		die("SRT transcoding is disabled.");
	}else{
		print STDERR "running " . 'ffmpeg ' . $arglist . "\n";
        print LOG "running " . 'ffmpeg ' . $arglist . "\n\n";

		`$FFMPEG_OEM $arglist`;
	}

# ### Python-GoogleDrive-VideoStream REQUEST
# we've been told to either video/audio transcode or direct stream
}elsif ($arglist =~ m%\:9988% or $arglist =~ m%\:9989% or $arglist =~ m%\:9990%){


	# when direct streaming, prefer the Google Transcode version over remuxing
	# this will reduce ffmpeg from remuxing and causing high cpu at the start of a new playback request
	# the remuxing will be spreadout over the entire playback session as Google will limit the transfer rate
	if (CONFIG->PREFER_GOOGLE_TRANSCODE){

		# request to transcode?
		if ($arglist =~ m%\-pix_fmt yuv420p% or $arglist =~ m%\-bsf\:v h264_mp4toannexb% or $arglist =~ m%\-codec\:v\:0 libx264%){
			if ($arglist =~ m%\,426\)% or $arglist =~ m%\,640\)% ){
				$arglist =~ s%\"?\Q$url\E\"?%\"$url\&preferred_quality\=2\&override\=true\"%;
			}elsif ($arglist =~ m%\,1280\)% or $arglist =~ m%\,720\)%){
				$arglist =~ s%\"?\Q$url\E\"?%\"$url\&preferred_quality\=1\&override\=true\"%;
			}else{#($arglist =~ m%\,1080\)%
				$arglist =~ s%\"?\Q$url\E\"?%\"$url\&preferred_quality\=0\&override\=true\"%;
			}

			$arglist =~ s%\-codec\:v\:0 .* -f segment%\-codec\:v\:0 copy \-copyts \-vsync \-1 \-codec\:a\:0 copy \-copypriorss\:a\:0 0 \-f segment%;

		# direct stream only?
		}else{
			#you've made it here because transcode was requested but the resolution is likely not provided
			# force Google transcode stream stream?
			if (CONFIG->FORCE_GOOGLE_TRANSCODE_FOR_REMUX){
				$arglist =~ s%\"?\Q$url\E\"?%\"$url\&preferred_quality\=0\&override\=true\"%;
			}
			#$arglist =~ s%\"?\Q$url\E\"?%\"$url\&preferred_quality\=0\&override\=true\"%;
		}

		my $audioSelection = 0;
		($audioSelection) = $arglist =~ m%\-map 0\:0 \-map 0\:(\d+) %;

		print LOG "AUDIO SELECTION $audioSelection\n";
		#if ($arglist =~ m%\-map 0\:2 %){
		if ((CONFIG->FORCE_REMUX_AUDIO and $audioSelection == 1) or $audioSelection > 1){
			$arglist =~ s%\-map 0\:$audioSelection %\-map 1\:$audioSelection %;
			my $audioURL = '-i "'.$url.'"';
			if ($seek ne ''){
				$audioURL = '-ss ' . $seek . ' ' . $audioURL;
			}
			$arglist =~ s%\-i "([^\"]+)" %\-i "$1" $audioURL %;
			$arglist =~ s%\-codec\:a\:0 copy \-copypriorss\:a\:0 0 %\-codec\:a aac \-copypriorss\:a 0  %;

		}


		# fix for AVI file transcoding
		$arglist =~ s%\-f avi %-f mp4 %;

		$arglist =~ s%\-f matroska,webm %\-f mp4 %;

		#for emby 3.6
		$arglist =~ s%\-f matroska %\-f mp4 %;

		print STDERR "URL = $url, $arglist\n";
	    print LOG "URL = $url, $arglist\n\n";

		#`$FFMPEG_OEM $arglist`;
		$pid = open ( LS, '-|', $FFMPEG_OEM . ' ' . $arglist . ' 2>&1');
		my $output = do{ local $/; <LS> };
		close LS;
		#my $output = `/u01/ffmpeg-git-20171123-64bit-static/ffmpeg $arglist -v error 2>&1`;

		# no transcoding available
		if($output =~ m%moov atom not found%){
			$arglist =~ s%\-f mp4 %\-f matroska,webm %;
			print LOG "$FFMPEG_OEM $arglist\n\n";
			`$FFMPEG_OEM $arglist`;
		}

	# let's check to see if we are trying remux 4k content
	}else{
		$pid = open ( LS, '-|', $FFPROBE . ' -i "' . $url . '" 2>&1');
		my $output = do{ local $/; <LS> };
		close LS;

		# content is 4K HEVC which is going to trigger video transcoding (at this point)
		# even when you block video transcoding in Emby admin console, it will try to video encode if remuxing is enabled
		if (CONFIG->BLOCK_TRANSCODE and $output =~ m%hevc%){
			# prefer to drop to Google Transcode over video transcoding
			if (CONFIG->GOOGLE_TRANSCODE){
				$arglist =~ s%\"?\Q$url\E\"?%\"$url\&preferred_quality\=0\&override\=true\"%;
				$arglist =~ s%\-f matroska,webm %\-f mp4 %;

				print STDERR "URL = $url, $arglist\n";
                print LOG "URL = $url, $arglist\n\n";
				`$FFMPEG_OEM $arglist`;
			# reject the playback request
			}else{
				die("video/audio transcoding is disabled.");
			}

		# direct stream
		}else{
			`$FFMPEG_OEM $arglist`;
		}

	}


#### LIVE TV REQUEST
# request with no duration, so not a DVR request, cycle over network errors
# in Emby 3.5.2 +, DVR requests mimic Live TV requests (they no longer use the -d for length of time to record)
}elsif (!($arglist =~ m%recording%) and $duration_ptr == -1){

	# emby 3.5.2 remove -individual_header_trailer0
	#$arglist =~ s%\-individual_header_trailer 0%%;

	#capture m3u8 filename

	my ($m3u8) = $arglist =~ m%segment_file ([^\ ]+\.m3u8)%;
	my ($channel) = $arglist =~ m%\-i [^\ ]+\/([^\/]+)\.[^\ ]+%;
	print LOG "m3u8 output file " . $m3u8 . ", channel ".$channel."\n";

    print LOG "running LIVETV " . $FFMPEG_TEST . ' ' . $arglist . "\n\n";

	my $username;
	my $password;
	if (CONFIG->IPTV_MANAGE_SERVER ne ''){
		require CONFIG->PATH . 'crawler.pm';
		TOOLS_CRAWLER::ignoreCookies();
		my @results = TOOLS_CRAWLER::complexGET(CONFIG->IPTV_MANAGE_SERVER . '/get/',undef,[],[],[('username\=', '\&', '\&'),('password\=', '\&', '\&')]);

		$username = $results[3];
		$password = $results[5];
		print "username = $username, password = $password\n";

		$arglist =~ s%USERNAME%$username%;
		$arglist =~ s%PASSWORD%$password%;
	}



	if ($arglist =~ m%\-pix_fmt yuv420p%){
		$arglist =~ s%\-codec\:v\:0 .* -f segment%\-codec\:v\:0 copy \-copyts \-vsync \-1 \-codec\:a\:0 copy \-copypriorss\:a\:0 0 \-f segment%;
	}

	#$pid = open ( LS, '-|', $FFMPEG . ' ' . $arglist . ' 2>&1');
	#my $output = do{ local $/; <LS> };
	#close LS;
	#my $output = `/u01/ffmpeg-git-20171123-64bit-static/ffmpeg $arglist -v error 2>&1`;


	if ($arglist =~ m%$PROXY_DETERMINATOR%){
		print STDERR "running PROXY LIVETV " . $FFMPEG_TEST . ' ' . $PROXY . ' '. $arglist . "\n";
        print LOG "running PROXY LIVETV " . $FFMPEG_TEST . ' ' . $PROXY . ' '. $arglist . "\n\n";
		`$FFMPEG_TEST -http_proxy $PROXY $arglist -v error`;
	}else{
		print STDERR "running LIVETV " . $FFMPEG_TEST . ' ' . $arglist . "\n";
        print LOG "running LIVETV " . $FFMPEG_TEST . ' ' . $arglist . "\n\n";
        if (CONFIG->IPTV_MANAGE_SERVER ne ''){
        	my $url = CONFIG->IPTV_MANAGE_SERVER.'/free/'. $username;
			`$FFMPEG_TEST $arglist -v error; wget "$url";wget "$url"; echo "FREED" >> /tmp/transcode.log`;
		}else{
			`$FFMPEG_TEST $arglist -v error; echo "TEST" >> /tmp/transcode.log`;
		}
	}



	#if (CONFIG->IPTV_MANAGE_SERVER ne ''){
	#	TOOLS_CRAWLER::simpleGET(CONFIG->IPTV_MANAGE_SERVER.'/free/'. $username);
	#}
	print STDERR "\n\n\nDONE\n\n";

	#}

#### LIVE TV DVR REQUEST
# request with duration indicates timed recording
# provided for backward compatibility with emby < 3.5
# * in Emby 3.5.2 +, DVR requests mimic Live TV requests (they no longer use the -d for length of time to record)
}elsif ($arglist =~ m%recording% or $duration != 0){

	if (CONFIG->RECORDING_SERVER ne ''){
		#$arglist = createArglist();
		my $RECORDING_SERVER = CONFIG->RECORDING_SERVER;
		#`wget http://$RECORDING_SERVER/process --post-data="cmd=$arglist"`;
		use LWP::UserAgent;
		my $ua = LWP::UserAgent->new;
		my $req = HTTP::Request->new(POST => "http://$RECORDING_SERVER/process");
		$req->content_type('application/x-www-form-urlencoded');
		$req->content("cmd=$arglist");
		my $res = $ua->request($req);
		if ($res->is_success) {
		    print LOG $res->content;
		}
		else {
		    print LOG $res->status_line, "\n";
		}


	}elsif ($duration !=0){

		my @moveList;
		my $current=0;
		my $finalFilename = $ARGV[$filename_ptr];
		$finalFilename  =~ s%\.ts%\.mp4%;
		$ARGV[$filename_ptr] =~ s%\.ts%\.$count\.ts%;
		while (-e $ARGV[$filename_ptr]){
			$count++;
			$ARGV[$filename_ptr] =~ s%\.\d+\.ts%\.$count\.ts%;
		}
		$renameFileName = $ARGV[$filename_ptr];
		$renameFileName =~ s%\.ts%\.mp4%;


		my $now = 60;
		my $failures=0;
		while ($now > 59 and $failures < 100){
		  	$arglist = createArglist();

			if ($arglist =~ m%$PROXY_DETERMINATOR%){
				print STDERR 'run ffmpeg $PROXY -v error ' . $arglist . "\n";

				`$FFMPEG_DVR $PROXY $arglist -v error`;
			}else{
				print STDERR 'run ffmpeg  -v error ' . $arglist . "\n";
				`$FFMPEG_DVR $arglist -v error`;

			}

			#$pid = open ( LS, '-|', '/u01/ffmpeg-git-20171123-64bit-static/ffmpeg  -v error ' . $arglist . ' 2>&1');
			#my $output = do{ local $/; <LS> };
			#close LS;
			#print STDERR $output;

			# we will rename the file later
			$moveList[$current][0] = $ARGV[$filename_ptr];
			$moveList[$current][1] = $renameFileName;
			$moveList[$current][2] = $moveList[$current][0];
			$moveList[$current][3] = $moveList[$current][1];
			$moveList[$current][2] =~ s%$RECORDING_DIR%$RECORDING_DIR_UPLOAD%;
			$moveList[$current][3] =~ s%$RECORDING_DIR%$RECORDING_DIR_UPLOAD%;
			$current++;

			# calculate the new duration -- add a failure to the counter and wait for 5 seconds to let the failure condition pass
			$now = ($start + $duration + 5) - time ;
			if ($now > 59){
				sleep 5;
				$failures++;
			}

			# print the duration in correct format
			my $hour = int($now /60/60);
		    my $min = int ($now /60%60);
			my $sec = int ($now %60);
			$ARGV[$duration_ptr] = ($hour<10? '0':'').$hour.":".($min <10? '0':'').$min.':' . ($sec<10?'0':'').$sec;

			# increment filename
			$ARGV[$filename_ptr] =~ s%\.\d+\.ts%\.$count\.ts%;
			while (-e $ARGV[$filename_ptr]){
				$count++;
				$ARGV[$filename_ptr] =~ s%\.\d+\.ts%\.$count\.ts%;
				$renameFileName = $ARGV[$filename_ptr];
				$renameFileName =~ s%\.ts%\.mp4%;
			}
			print STDERR "next iteration " .$now . "\n";

		}

		my $concat = '';
		my $previous = '';
		for (my $i=0; $i <= $#moveList; $i++){
			if ($concat eq ''){
				$concat .= 'concat:'.$moveList[$i][0];
			}else{
				if ($moveList[$i][0] ne $moveList[$i-1][0]){
					$concat .= '|'.$moveList[$i][0];
				}
			}

		}
		print STDERR "$FFMPEG_DVR -i $concat -codec copy $finalFilename";
	    print LOG "$FFMPEG_DVR -i $concat -codec copy $finalFilename\n\n";
		`$FFMPEG_DVR -i "$concat" -codec copy "$finalFilename"`;



		my $finalFilenameUpload = $finalFilename;
		$finalFilenameUpload =~ s%$RECORDING_DIR%$RECORDING_DIR_UPLOAD%;

		my ($finalDIR) = $finalFilenameUpload =~ m%(.*?)/[^\/]+$%;
		make_path($finalDIR);


		for (my $i=0; $i <= $#moveList; $i++){
			if ($i==0 or $moveList[$i][0] ne $moveList[$i-1][0]){

				move $moveList[$i][0], $moveList[$i][2];
				move $moveList[$i][1], $moveList[$i][3];
				print STDERR "move $moveList[$i][0],$moveList[$i][2]\n";

			}
		}
		move $finalFilename, $finalFilenameUpload;

	}else{

		my @moveList;
		my $current=0;
		my $finalFilename = $ARGV[$filename_ptr];
		$finalFilename  =~ s%\.ts%\.mp4%;
		$ARGV[$filename_ptr] =~ s%\.ts%\.$count\.ts%;
		while (-e $ARGV[$filename_ptr]){
			$count++;
			$ARGV[$filename_ptr] =~ s%\.\d+\.ts%\.$count\.ts%;
		}
		$renameFileName = $ARGV[$filename_ptr];
		$renameFileName =~ s%\.ts%\.mp4%;


		my $failures=0;
		while ($KILLSIGNAL == 0 and $failures < 100){
		  	$arglist = createArglist();

			if ($arglist =~ m%$PROXY_DETERMINATOR%){
				print STDERR 'run ffmpeg $PROXY -v error ' . $arglist . "\n";
				`$FFMPEG_TEST $PROXY $arglist -v error`;
			}else{
				print STDERR 'run DVR ffmpeg  -v error ' . $arglist . "\n";
				print LOG 'run DVR ffmpeg  -v error ' . $arglist . "\n";

				#`touch /tmp/$ARGV[$filename_ptr].signal`;
				`$FFMPEG_TEST $arglist -v error`;
				if ($? == 0){
					$KILLSIGNAL = 1;
				}else{
					sleep 5;

				}
				#$pid = open ( LS, '-|', $FFMPEG_TEST  . ' -v error ' . $arglist . ' 2>&1');
				#my $output = do{ local $/; <LS> };
				#close LS;
				#print LOG $output;

			}


			# we will rename the file later
			$moveList[$current][0] = $ARGV[$filename_ptr];
			$moveList[$current][1] = $renameFileName;
			$moveList[$current][2] = $moveList[$current][0];
			$moveList[$current][3] = $moveList[$current][1];
			$moveList[$current][2] =~ s%$RECORDING_DIR%$RECORDING_DIR_UPLOAD%;
			$moveList[$current][3] =~ s%$RECORDING_DIR%$RECORDING_DIR_UPLOAD%;
			$current++;

			$failures++;


			# increment filename
			$ARGV[$filename_ptr] =~ s%\.\d+\.ts%\.$count\.ts%;
			while (-e $ARGV[$filename_ptr]){
				$count++;
				$ARGV[$filename_ptr] =~ s%\.\d+\.ts%\.$count\.ts%;
				$renameFileName = $ARGV[$filename_ptr];
				$renameFileName =~ s%\.ts%\.mp4%;
			}
			print STDERR "next iteration \n";

		}
		if ($failures < 100){

			my $concat = '';
			my $previous = '';
			for (my $i=0; $i <= $#moveList; $i++){
				if ($concat eq ''){
					$concat .= 'concat:'.$moveList[$i][0];
				}else{
					if ($moveList[$i][0] ne $moveList[$i-1][0]){
						$concat .= '|'.$moveList[$i][0];
					}
				}

			}
			print STDERR "$FFMPEG_DVR -i $concat -codec copy $finalFilename";
		    print LOG "$FFMPEG_DVR -i $concat -codec copy $finalFilename\n\n";
			`$FFMPEG_TEST -i "$concat" -codec copy "$finalFilename"`;


			my $finalFilenameUpload = $finalFilename;
			$finalFilenameUpload =~ s%$RECORDING_DIR%$RECORDING_DIR_UPLOAD%;

			my ($finalDIR) = $finalFilenameUpload =~ m%(.*?)/[^\/]+$%;
			make_path($finalDIR);


			for (my $i=0; $i <= $#moveList; $i++){

				if ($i==0 or $moveList[$i][0] ne $moveList[$i-1][0]){

					print LOG "move $moveList[$i][0],$moveList[$i][2]\n";
					move $moveList[$i][0], $moveList[$i][2];
					move $moveList[$i][1], $moveList[$i][3];

				}
			}
			print LOG "move $finalFilename,$finalFilenameUpload\n";
			move $finalFilename, $finalFilenameUpload;


		}
	}


}

close(LOG);
