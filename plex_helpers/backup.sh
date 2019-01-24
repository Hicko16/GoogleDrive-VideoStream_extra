#
# backup.sh current_date_YYYYMMDD last_backup_date_time_YYYY:MM:DD hh:mm:ss
#
tar -N '$2' -zcf Cache.$1.tgz Cache
tar -N '$2' -zcf Codecs.$1.tgz Codecs
tar -N '$2' -zcf "Crash Reports.$1.tgz" "Crash Reports"
tar -N '$2' -zcf Diagnostics.$1.tgz Diagnostics
tar -N '$2' -zcf Logs.$1.tgz Logs
tar -N '$2' -zcf Media.$1.tgz Media
tar -N '$2' -zcf Metadata.$1.tgz Metadata
tar -N '$2' -zcf Plug-ins.$1.tgz Plug-ins
service plexmediaserver stop
sleep 5
tar -zcf "Plug-in Support.$1.tgz" "Plug-in Support"
cp Preferences.xml Preferences.$1.xml
service plexmediaserver start