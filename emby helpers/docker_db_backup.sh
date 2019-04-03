#
# docker_db_backup.sh current_date_YYYYMMDD location_of_scripts port access_token docker_instance_name
#
tar -zcf config.$1.tgz config
cd "$2"; perl stop_emby.pl -p $3 -a $4; cd -
sleep 5
sudo docker stop $5
sleep 5
tar -zcf "data.$1.tgz" "data"
sudo docker start $5
