#
# docker_i_backup.sh current_date_YYYYMMDD location_of_scripts port access_token docker_instance_name
#
date=`date --reference=last.backup.done`
sudo touch last.backup.start
if test -e cache.snar
then
cp cache.snar cache.$1.snar
cp metadata.snar metadata.$1.snar
CACHE=cache.$1.snar
METADATA=metadata.$1.snar
else
CACHE=cache.snar
METADATA=metadata.snar
fi

tar -g $CACHE -zcf cache.$1.tgz cache
tar -g $METADATA -zcf metadata.$1.tgz metadata
tar -zcf config.$1.tgz config
tar -zcf localization.$1.tgz localization
tar -zcf plugins.$1.tgz plugins
tar -zcf root.$1.tgz root
perl $2/stop_emby.pl -p $3 -a $4
sleep 5
sudo docker stop $5
sleep 5
tar -zcf "data.$1.tgz" "data"
sudo docker start $5
mv last.backup.start last.backup.done