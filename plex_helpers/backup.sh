tar -zcf Cache.$1.tgz Cache
tar -zcf Codecs.$1.tgz Codecs
tar -zcf "Crash Reports.$1.tgz" "Crash Reports"
tar -zcf Diagnostics.$1.tgz Diagnostics
tar -zcf Logs.$1.tgz Logs
tar -zcf Media.$1.tgz Media
tar -zcf Metadata.$1.tgz Metadata
tar -zcf Plug-ins.$1.tgz Plug-ins
service plexmediaserver stop
sleep 5
tar -zcf "Plug-in Support.$1.tgz" "Plug-in Support"
cp Preferences.xml Preferences.$1.xml
service plexmediaserver start