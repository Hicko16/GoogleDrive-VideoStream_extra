#! /bin/sh

for var in "$@"
do
	case "$string" in
	*ffmpeg*)
		;;
	*)
	  	string="${string} \"$var\""
	  	stringf="${stringf} $var"
	  	;;
    esac
done

case "$string" in
	*998*)
		#wget -q 172.17.0.1:9999/ffprobe/$$ --post-data="$string" -O /tmp/$$
		/bin/ffprobe.oem $stringf
		;;
	*)
echo ffprobe version 3.2.12-1~deb9u1 Copyright (c) 2007-2018 the FFmpeg developers
echo  built with gcc 6.3.0 (Debian 6.3.0-18+deb9u1) 20170516
echo  configuration: --prefix=/usr --extra-version='1~deb9u1' --toolchain=hardened --libdir=/usr/lib/x86_64-linux-gnu --incdir=/usr/include/x86_64-linux-gnu --enable-gpl --disable-stripping --enable-avresample --enable-avisynth --enable-gnutls --enable-ladspa --enable-libass --enable-libbluray --enable-libbs2b --enable-libcaca --enable-libcdio --enable-libebur128 --enable-libflite --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm --enable-libmp3lame --enable-libopenjpeg --enable-libopenmpt --enable-libopus --enable-libpulse --enable-librubberband --enable-libshine --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libssh --enable-libtheora --enable-libtwolame --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libwebp --enable-libx265 --enable-libxvid --enable-libzmq --enable-libzvbi --enable-omx --enable-openal --enable-opengl --enable-sdl2 --enable-libdc1394 --enable-libiec61883 --enable-chromaprint --enable-frei0r --enable-libopencv --enable-libx264 --enable-shared
echo  libavutil      55. 34.101 / 55. 34.101
echo  libavcodec     57. 64.101 / 57. 64.101
echo  libavformat    57. 56.101 / 57. 56.101
echo  libavdevice    57.  1.100 / 57.  1.100
echo  libavfilter     6. 65.100 /  6. 65.100
echo  libavresample   3.  1.  0 /  3.  1.  0
echo  libswscale      4.  2.100 /  4.  2.100
echo  libswresample   2.  3.100 /  2.  3.100
echo  libpostproc    54.  1.100 / 54.  1.100
echo[hls,applehttp @ 0x559699d23740] Opening 'http://useast4.vaders.tv:80/latino_nat_geo_sd/tracks-v1/mono.m3u8?' for reading
echo[hls,applehttp @ 0x559699d23740] Opening 'http://useast4.vaders.tv:80/latino_nat_geo_sd/tracks-v1/2018/09/11/23/13/43-04004.ts' for reading
echo[hls,applehttp @ 0x559699d23740] Opening 'http://useast4.vaders.tv:80/latino_nat_geo_sd/tracks-v1/2018/09/11/23/13/47-04004.ts' for reading
echoInput #0, hls,applehttp, from 'http://vapi.vaders.tv/play/56686.m3u8?':
echo  Duration: N/A, start: 63768.733889, bitrate: N/A
echo  Program 0
echo    Metadata:
echo      variant_bitrate : 2140176
echo    Stream #0:0: Video: h264 (High) ([27][0][0][0] / 0x001B), yuv420p, 1920x1080, 29.97 fps, 29.97 tbr, 90k tbn, 60 tbc
echo    Metadata:
echo      variant_bitrate : 2140176
echo
		;;
esac



