#!/bin/sh

echo "DATABASE BACKUP" > /var/log/allspark-backup.log
mysql -N -e 'show databases' | while read dbname; do if [ $dbname != 'information_schema' ] && [ $dbname != 'performance_schema' ]; then mysqldump --routines --triggers --single-transaction "$dbname" > "/srv/db-backup/$dbname".sql; fi done
cd /srv/db-backup/
zip -v `date +%Y-%m-%d.zip` *.sql >> /var/log/allspark-backup.log
rm /srv/db-backup/*.sql

echo "" >> /var/log/allspark-backup.log

echo "SERVER BACKUP" >> /var/log/allspark-backup.log
ssh-keygen -f "/home/debian/.ssh/known_hosts" -R "[$BACKUP_SERVER]:$BACKUP_SERVER_SSHPORT"
rdiff-backup -v 6 --force --exclude /srv/databases --exclude /srv/files/backup@demoptimus.fr --print-statistics --remote-schema "ssh -p$BACKUP_SERVER_SSHPORT -o 'StrictHostKeyChecking no' -i /home/debian/private.pem %s sudo rdiff-backup --server" /srv autobackup@$BACKUP_SERVER::/srv >> /var/log/allspark-backup.log

ssh -o 'StrictHostKeyChecking no' -i /root/private.pem -p $BACKUP_SERVER_SSHPORT autobackup@$BACKUP_SERVER sudo umount /backup >> /var/log/allspark-backup.log
sleep 1
ssh -o 'StrictHostKeyChecking no' -i /root/private.pem -p $BACKUP_SERVER_SSHPORT autobackup@$BACKUP_SERVER sudo rdiff-backup-fs --full /backup /srv >> /var/log/allspark-backup.log

mail -s "BACKUP REPORT" postmaster@$DOMAIN -aFrom:postmaster@$DOMAIN < /var/log/allspark-backup.log
