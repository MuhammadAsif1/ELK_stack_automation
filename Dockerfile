FROM logstash:6.8.6

RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD logstash.conf /usr/share/logstash/pipeline/

RUN rm -f /usr/share/logstash/config/logstash.yml
ADD logstash.yml /usr/share/logstash/config/

#EXPOSE 5044

MAINTAINER Muhammad_Asif
