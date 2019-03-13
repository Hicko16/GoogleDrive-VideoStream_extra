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
		(
		sleep 10000
		wget -q 172.17.0.1:9998/stop/$$ --post-data="$string"
		) &
		wget -q 172.17.0.1:9998/start/$$ --post-data="$string"
		;;
	*)
		/bin/ffmpeg.oem $stringf
		;;
esac

