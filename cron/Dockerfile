FROM ubuntu:22.04
RUN apt update && apt install curl vim cron mysql-client rclone nginx wget unzip  jq gettext net-tools tree -y

# install entrypoint
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# defaults env vars
ENV CRON_SCHEDULE="0 0 * * *"
ENV COMMAND="rclone version"

RUN wget https://github.com/mikefarah/yq/releases/download/v4.16.2/yq_linux_amd64 && chmod +x yq_linux_amd64 && mv yq_linux_amd64 /usr/bin/yq
COPY .bashrc /root/.bashrc
ADD sources.list /etc/apt/sources.list

ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["cron", "-f"]
CMD cron start && tail -f /task.log
