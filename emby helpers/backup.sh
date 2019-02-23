#
# backup.sh current_date_YYYYMMDD
#
date=`date --reference=last.backup.done`
touch last.backup.start
tar -N "$date" -zcf Cache.$1.tgz Cache
tar -N "$date" -zcf Config.$1.tgz Config
tar -N "$date" -zcf localization.$1.tgz localization
tar -N "$date" -zcf metadata.$1.tgz metadata
tar -N "$date" -zcf plugins.$1.tgz plugins
tar -N "$date" -zcf root.$1.tgz root
service emby-server stop
sleep 5
tar -zcf "Data.$1.tgz" "Data"
service emby-server start
mv last.backup.start last.backup.done