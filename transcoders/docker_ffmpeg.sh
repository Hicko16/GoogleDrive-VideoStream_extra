#! /bin/sh

for var in "$@"
do
	case "$string" in
	*ffmpeg*)
		;;
	*)
	  	string="${string} $var"
	  	;;
    esac
done
case "$string" in
	*9988*)
		wget 172.17.0.1:9998/stream --post-data="$string"
		;;
	*)
		/bin/ffmpeg.oem $string
		;;
esac

