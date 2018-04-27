FROM openjdk:8-jre-alpine
RUN apk add --no-cache curl unzip
RUN curl http://www.h2database.com/h2-2017-06-10.zip -o h2.zip
RUN unzip h2.zip -d /opt/
RUN rm h2.zip
RUN mkdir -p /opt/h2-data
RUN apk del --no-cache unzip curl libcurl libssh2
ENTRYPOINT ["java", "-jar", "/opt/h2/bin/h2-1.4.196.jar", "-baseDir", "/opt/h2-data"]
