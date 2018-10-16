#!/usr/bin/perl

use File::Basename;
use lib dirname (__FILE__) ;
require 'config.cfg';



my $pidi=0;


my $FFPROBE_OEM = CONFIG->PATH_TO_EMBY_FFMPEG.'/ffprobe.oem ';
#my $FFPROBE_OEM = 'ffprobe ';

my $PROXY = CONFIG->PROXY;
my $PROXY_DETERMINATOR = CONFIG->PROXY_DETERMINATOR;
my $IPTV_DETERMINATOR = CONFIG->IPTV_DETERMINATOR;


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

if ($arglist =~ m%file:/%){
	exit(0);
}

open (LOG, '>>' . CONFIG->LOGFILE) or die $!;
print LOG "passed in $arglist\n";



if ($arglist =~ m%$IPTV_DETERMINATOR%){
	print LOG "relaying IPTV " . $arglist . "\n";
	close(LOG);
	print STDOUT <<EOF;
ffprobe version 3.2.12-1~deb9u1 Copyright (c) 2007-2018 the FFmpeg developers
  built with gcc 6.3.0 (Debian 6.3.0-18+deb9u1) 20170516
  configuration: --prefix=/usr --extra-version='1~deb9u1' --toolchain=hardened --libdir=/usr/lib/x86_64-linux-gnu --incdir=/usr/include/x86_64-linux-gnu --enable-gpl --disable-stripping --enable-avresample --enable-avisynth --enable-gnutls --enable-ladspa --enable-libass --enable-libbluray --enable-libbs2b --enable-libcaca --enable-libcdio --enable-libebur128 --enable-libflite --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm --enable-libmp3lame --enable-libopenjpeg --enable-libopenmpt --enable-libopus --enable-libpulse --enable-librubberband --enable-libshine --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libssh --enable-libtheora --enable-libtwolame --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libwebp --enable-libx265 --enable-libxvid --enable-libzmq --enable-libzvbi --enable-omx --enable-openal --enable-opengl --enable-sdl2 --enable-libdc1394 --enable-libiec61883 --enable-chromaprint --enable-frei0r --enable-libopencv --enable-libx264 --enable-shared
  libavutil      55. 34.101 / 55. 34.101
  libavcodec     57. 64.101 / 57. 64.101
  libavformat    57. 56.101 / 57. 56.101
  libavdevice    57.  1.100 / 57.  1.100
  libavfilter     6. 65.100 /  6. 65.100
  libavresample   3.  1.  0 /  3.  1.  0
  libswscale      4.  2.100 /  4.  2.100
  libswresample   2.  3.100 /  2.  3.100
  libpostproc    54.  1.100 / 54.  1.100
[hls,applehttp @ 0x559699d23740] Opening 'http://useast4.vaders.tv:80/latino_nat_geo_sd/tracks-v1/mono.m3u8?' for reading
[hls,applehttp @ 0x559699d23740] Opening 'http://useast4.vaders.tv:80/latino_nat_geo_sd/tracks-v1/2018/09/11/23/13/43-04004.ts' for reading
[hls,applehttp @ 0x559699d23740] Opening 'http://useast4.vaders.tv:80/latino_nat_geo_sd/tracks-v1/2018/09/11/23/13/47-04004.ts' for reading
Input #0, hls,applehttp, from 'http://vapi.vaders.tv/play/56686.m3u8?':
  Duration: N/A, start: 63768.733889, bitrate: N/A
  Program 0
    Metadata:
      variant_bitrate : 2140176
    Stream #0:0: Video: h264 (High) ([27][0][0][0] / 0x001B), yuv420p, 1920x1080, 29.97 fps, 29.97 tbr, 90k tbn, 60 tbc
    Metadata:
      variant_bitrate : 2140176

EOF

	exit(0);

}elsif ($arglist =~ m%$PROXY_DETERMINATOR%){
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
	if (CONFIG->FILTER_PGS and $line =~ m%hdmv_pgs_subtitle% and $line =~ m%Stream \#%){
		$skip = 1;
		$index[$index] = 1
	}elsif(CONFIG->FILTER_PGS and ($line =~ m%Stream \#%)){
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

