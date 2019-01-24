#
# backup.sh current_date_YYYYMMDD
#
date=`date --reference=last.backup.done`
touch last.backup.start
tar -N $date -zcf Cache.$1.tgz Cache
tar -N $date -zcf Codecs.$1.tgz Codecs
tar -N $date -zcf "Crash Reports.$1.tgz" "Crash Reports"
tar -N $date -zcf Diagnostics.$1.tgz Diagnostics
tar -N $date -zcf Logs.$1.tgz Logs
tar -N $date -zcf Media.$1.tgz Media
tar -N $date -zcf Metadata.$1.tgz Metadata
tar -N $date -zcf Plug-ins.$1.tgz Plug-ins
service plexmediaserver stop
sleep 5
tar -zcf "Plug-in Support.$1.tgz" "Plug-in Support"
cp Preferences.xml Preferences.$1.xml
service plexmediaserver start
mv last.backup.start last.backup.done