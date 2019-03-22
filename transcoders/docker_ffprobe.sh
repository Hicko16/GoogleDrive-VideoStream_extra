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

wget -q 172.17.0.1:9999/ffprobe/$$ --post-data="$string" -O /tmp/$$ &

