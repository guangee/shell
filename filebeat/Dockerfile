FROM ubuntu:20.04
ADD https://files.tulan.tech/filebeat /usr/bin/
ADD filebeat.yml /filebeat.yml
CMD ["sh","-c","filebeat -e -c /filebeat.yml"]
