from openjdk:8-jre-alpine
RUN apk add --no-cache curl unzip
RUN curl http://www.h2database.com/h2-2017-06-10.zip -o h2.zip
RUN unzip h2.zip -d /opt/
RUN rm h2.zip
RUN mkdir -p /opt/h2-data
ADD run.sh /opt/h2/bin
CMD ["sh", "/opt/h2/bin/run.sh"]
