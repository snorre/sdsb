FROM ubuntu:latest
MAINTAINER snorre.visnes@gmail.com

RUN mkdir /sdsb
ADD sdsb_run.sh /sdsb
ADD sdsb_run_and_notify.sh /sdsb
RUN chmod 0755 /sdsb/*.sh

ENV REMOTE_SERVER=""
ENV REMOTE_DATA_ROOT=""
ENV REMOTE_SNAPSHOT_ROOT=""
ENV BANDWIDTH_LIMIT_KBS=""
ENV SENDGRID_API_KEY=""
ENV NOTIFICATION_EMAIL=""
ENV SSH_USERNAME=""

ENV SDSB_PATH="/sdsb"
ENV DIRECTORY_TO_BACKUP="/data-to-backup""

RUN apt-get -qq update
RUN apt-get -y -qq install curl rsync ssh nano

CMD /sdsb/sdsb_run_and_notify.sh
#CMD /sdsb/sdsb_run.sh
