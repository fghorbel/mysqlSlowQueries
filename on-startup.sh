#!/bin/bash 
#
log_file=/mnt/on-startup.log
echo -e "=================== $(date) =====================" > $log_file
exec > $log_file 2>&1


GEM_HOME="/usr/local/bundle"
PATH=$GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH


unset BUNDLE_PATH
unset BUNDLE_BIN

LOGROTATE_LOGFILES="/mnt/logs/*.lg"
LOGROTATE_FILESIZE="${LOGROTATE_FILESIZE:-100M}"
LOGROTATE_FILENUM="${LOGROTATE_FILENUM:-1}"

cat > /etc/logrotate.conf << EOF
${LOGROTATE_LOGFILES}
{
  size ${LOGROTATE_FILESIZE}
  missingok
  notifempty
  copytruncate
  rotate ${LOGROTATE_FILENUM}
}
EOF

CRON_EXPR="*/1 * * * * "

cat <(crontab -l) <(echo "SHELL=/bin/bash") | crontab -
cat <(crontab -l) <(echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin") | crontab -
cat <(crontab -l) <(echo "$CRON_EXPR        /usr/sbin/logrotate -v /etc/logrotate.conf > /var/log/cron.log 2>&1") | crontab -

mv /mnt/fluent-plugin-mysqlslowquerylog/git_back /mnt/fluent-plugin-mysqlslowquerylog/.git
cd /mnt/fluent-plugin-mysqlslowquerylog && rake build ; fluent-gem install pkg/fluent-plugin-mysqlslowquerylog-0.0.1.gem

echo "================= $(date): Successfully completed ================="

