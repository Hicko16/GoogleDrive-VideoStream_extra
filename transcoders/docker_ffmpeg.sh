#! /bin/sh

for var in "$@"
do
    string="${string} \"$var\""
done
wget 172.17.0.1:9998/stream --post-data='$string'
