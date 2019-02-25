#
# backup.sh current_date_YYYYMMDD
#
date=`date --reference=last.backup.done`
touch last.backup.start
tar -N "$date" -zcf cache.$1.tgz cache
tar -N "$date" -zcf config.$1.tgz config
tar -N "$date" -zcf localization.$1.tgz localization
tar -N "$date" -zcf metadata.$1.tgz metadata
tar -N "$date" -zcf plugins.$1.tgz plugins
tar -N "$date" -zcf root.$1.tgz root
service emby-server stop
sleep 5
tar -zcf "data.$1.tgz" "data"
service emby-server start
mv last.backup.start last.backup.done