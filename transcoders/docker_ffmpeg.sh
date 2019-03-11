#! /bin/sh

for var in "$@"
do
	if [[ $string != *"ffmpeg"* ]]; then
    	string="${string} \"$var\""
    fi
done
if [[ $string == *"9988"* ]]; then
wget 172.17.0.1:9998/stream --post-data='$string'
else
/bin/ffmpeg.oem $string
fi

