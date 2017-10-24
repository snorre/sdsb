FROM ubuntu:latest
MAINTAINER snorre.visnes@gmail.com

RUN mkdir /sdsb
ADD sdsb_lib.sh /sdsb
ADD sdsb_run.sh /sdsb
ADD sdsb_run_and_notify.sh /sdsb
RUN chmod 0755 /sdsb/*run*

ENV REMOTE_SERVER=""
ENV REMOTE_DATA_ROOT=""
ENV REMOTE_SNAPSHOT_ROOT=""
ENV BANDWIDTH_LIMIT_KBS=1000
ENV SENDGRID_API_KEY=""
ENV NOTIFICATION_EMAIL=""
RUN echo 'local_data_root="/data-to-backup"'
RUN echo 'remote_server="$REMOTE_SERVER"'
RUN echo 'remote_data_root="$REMOTE_DATA_ROOT"'
RUN echo 'remote_snapshot_root="$REMOTE_SNAPSHOT_ROOT"'
RUN echo 'bandwidth_limit_KBs=$BANDWIDTH_LIMIT_KBS'
RUN echo 'sendgrid_api_key="$SENDGRID_API_KEY"'
RUN echo 'notification_email="$NOTIFICATION_EMAIL"'

ADD sdsb-crontab /etc/cron.d/sdsb-crontab
RUN chmod 0644 /etc/cron.d/sdsb-crontab
RUN touch /var/log/cron.log

RUN mkdir /data-to-backup
VOLUME /data-to-backup

RUN apt-get update
RUN apt-get -y install cron

CMD cron && tail -f /var/log/cron.log
