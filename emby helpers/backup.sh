#
# backup.sh current_date_YYYYMMDD location_of_scripts port access_token
#
date=`date --reference=last.backup.done`
touch last.backup.start
tar -N "$date" -zcf cache.$1.tgz cache
tar -zcf config.$1.tgz config
tar -zcf localization.$1.tgz localization
tar -N "$date" -zcf metadata.$1.tgz metadata
tar -zcf plugins.$1.tgz plugins
tar -zcf root.$1.tgz root
perl $2/stop_emby.pl -p $3 -a $4
sleep 5
service emby-server stop
sleep 5
tar -zcf "data.$1.tgz" "data"
service emby-server start
mv last.backup.start last.backup.done