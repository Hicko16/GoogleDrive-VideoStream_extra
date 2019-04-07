#
# backup.sh current_date_YYYYMMDD
#
date=`date --reference=last.backup.done`
touch last.backup.start
if test -e cache.snar
then
cp cache.snar cache.$1.snar
cp metadata.snar metadata.$1.snar
MEDIA=media.$1.snar
METADATA=metadata.$1.snar
else
MEDIA=media.snar
METADATA=metadata.snar
fi
#tar -N "$date" -zcf Cache.$1.tgz Cache
tar -zcf Codecs.$1.tgz Codecs
#tar -N "$date" -zcf "Crash Reports.$1.tgz" "Crash Reports"
#tar -N "$date" -zcf Diagnostics.$1.tgz Diagnostics
#tar -N "$date" -zcf Logs.$1.tgz Logs
tar -g $MEDIA -zcf Media.$1.tgz Media
tar -g $METADATA -zcf Metadata.$1.tgz Metadata
tar -zcf Plug-ins.$1.tgz Plug-ins
service plexmediaserver stop
sleep 5
tar -zcf "Plug-in Support.$1.tgz" "Plug-in Support"
cp Preferences.xml Preferences.$1.xml
service plexmediaserver start
mv last.backup.start last.backup.done