FROM ubuntu:latest
MAINTAINER snorre.visnes@gmail.com

RUN mkdir /sdsb
ADD sdsb_lib.sh /sdsb
ADD sdsb_run.sh /sdsb
ADD sdsb_run_and_notify.sh /sdsb
ADD sdsb_prepare_container.sh /sdsb
RUN chmod 0755 /sdsb/*.sh

ENV REMOTE_SERVER=""
ENV REMOTE_DATA_ROOT=""
ENV REMOTE_SNAPSHOT_ROOT=""
ENV BANDWIDTH_LIMIT_KBS=""
ENV SENDGRID_API_KEY=""
ENV NOTIFICATION_EMAIL=""
ENV SSH_USERNAME=""

# Also set in sdsb-crontab
ENV SDSB_PATH="/sdsb"

ADD sdsb-crontab /etc/cron.d/sdsb-crontab
RUN chmod 0644 /etc/cron.d/sdsb-crontab
RUN touch /var/log/cron.log

RUN apt-get -qq update
RUN apt-get -y -qq install cron curl rsync ssh

CMD /sdsb/sdsb_prepare_container.sh && \
   cron && \
   tail -f /var/log/cron.log
